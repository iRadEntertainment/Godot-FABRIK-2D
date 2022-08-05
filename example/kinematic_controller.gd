#kinematic controller.gd

extends Node


onready var kine : KinematicBody2D = get_parent()
var jump_force = -1500

var gravity : int = 3000
var move_speed : int = 250
var dir : int
var vel : Vector2



func _ready():
	pass


func _physics_process(d):
	get_move_inputs()
	if not kine.is_on_floor():
		vel.y += gravity*d
	vel = kine.move_and_slide(vel)


func get_move_inputs():
	dir = int(Input.get_action_strength("right")) - int(Input.get_action_strength("left"))
	vel.x = dir * move_speed
	if Input.is_action_just_pressed("up"):
		vel.y += jump_force
