extends Sprite


var ik = IKNodes.new()

var move_speed = 60
var rot_speed = PI
var transl = Vector2()

func _ready():
	var angles = [[-PI/4, PI/2], [PI/4, PI/2], [PI/8,PI/2]]
	var nodes = [$p1, $p2, $p3, $end]
	ik.set_nodes(nodes, angles)

func _process(delta):
	# move
	transl.y = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	transl.x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	global_position += transl
	# rotate
	if Input.is_key_pressed(KEY_Q): global_rotation -= delta*rot_speed
	elif Input.is_key_pressed(KEY_E): global_rotation += delta*rot_speed
	
	var vel = 300 * delta
	ik.reach_target(get_global_mouse_position(), global_rotation, vel)
	update()
