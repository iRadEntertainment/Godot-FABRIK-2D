extends Control


export (NodePath) var target
export var active := false

func _ready():
	if target:
		var target_node = get_node(target)
		for node in $operator.get_children():
			if node is IKLimb2D:
				var relative_path = node.get_path_to(target_node)
				node.target = relative_path
	else:
		var target_node = $target_default
		for node in $operator.get_children():
			if node is IKLimb2D:
				var relative_path = node.get_path_to(target_node)
				node.target = relative_path

func _process(delta):
	$target_default.global_position = get_global_mouse_position()
	var d = $operator.global_position.x / get_viewport_rect().size.x
	d = clamp(d, 0, 1)
#	print($bgt.texture.get("gradient").get("offsets"))
	$bgt.texture.get("gradient").set("offsets", [0, d, 1])

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_F:
			OS.window_fullscreen = !OS.window_fullscreen
