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

