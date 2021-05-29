# controller.gd
extends Node

export (int) var move_speed = 60
export (float) var rot_speed = 1

onready var op = get_parent() #operator
var transl = Vector2()

export (bool) var show_contacts = true
export (Color) var contact_colour = Color.chartreuse
var arms = []


func _ready():
	for child in op.get_children():
		if child is IKLimb2D:
			arms.append(child)


func _process(delta):
	# move
	transl.y = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	transl.x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	op.global_position += transl * move_speed * delta
	# rotate
	if Input.is_key_pressed(KEY_Q): op.global_rotation -= delta*rot_speed*2*PI
	elif Input.is_key_pressed(KEY_E): op.global_rotation += delta*rot_speed*2*PI
	
	#color on contact
	if show_contacts:
		for arm in arms:
			arm.modulate = contact_colour if arm.contact else Color.white
