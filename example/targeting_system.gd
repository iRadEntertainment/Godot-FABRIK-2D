# targeting_system.gd
extends Node2D

export var active : bool = true
export var show_debug := true
export (NodePath) var attach_to_node
export (float, 0.5, 5.0) var gallop_speed = 1.5
export var max_amplitude = 60
export var animate := true
export (NodePath) var horse_controller_path
var horse_controller


var normals = [Vector2(), Vector2(), Vector2(), Vector2()]
var rays_init_pos = []
var time = 0


var horse_speed = 0
var horse_max_speed = 300


func _ready():
	horse_controller = get_node_or_null(horse_controller_path)
	
	
	for ray in $rays.get_children():
		rays_init_pos.append(ray.position)
	
	var legs = [$"../horse/front_l", $"../horse/front_r",\
			$"../horse/rear_l", $"../horse/rear_r"]
	var targets = []
	var rays = []
	for child in $targets.get_children():
		targets.append(child)
	for child in $rays.get_children():
		rays.append(child)
	
	# assign all legs this node targets
	if active:
		for i in range(4):
			legs[i].target = legs[i].get_path_to(targets[i])
			rays[i].global_position = legs[i].global_position + Vector2.DOWN * 160



func _process(delta):
	if horse_controller:
		horse_speed = -horse_controller.vel.x
	
	time += delta * PI * gallop_speed
	if attach_to_node:
		$rays.global_position = get_node(attach_to_node).global_position + Vector2.DOWN*40
	else:
		$rays.global_position = get_global_mouse_position()
	
	for i in range($rays.get_children().size()):
		var ray : RayCast2D = $rays.get_child(i)
		var target : Position2D = $targets.get_child(i)
		
		# sinusoidal offset for each ray position
		var time_async = time + i*PI/4
		var amplitude = range_lerp(horse_speed, 0,horse_max_speed, 0, max_amplitude)
		amplitude = amplitude if horse_controller else max_amplitude
		var sin_offset = Vector2(cos(time_async)*2*amplitude, sin(-time_async)*abs(amplitude) )
		
		ray.position = rays_init_pos[i] + sin_offset * int(animate) + Vector2.DOWN*80 * int(not animate)
		ray.force_raycast_update()
		
		
		if ray.is_colliding():
			var coll_point = ray.get_collision_point()
			normals[i] = ray.get_collision_normal()
			target.global_position = coll_point
		else:
			normals[i] = Vector2.ZERO
			target.global_position = ray.global_position + ray.cast_to
	
	update()


func _draw():
	if not show_debug:
		return
	var alpha = Color(0,0,0,0.6)
	for i in range($targets.get_children().size()):
		# draw target position
		var target : Position2D = $targets.get_child(i)
		var ray : RayCast2D = $rays.get_child(i)
		
		var tar_pos = target.global_position - global_position
		draw_circle(tar_pos, 8, Color.orange - alpha)
		
		# draw collision normals
		draw_line(tar_pos, tar_pos + normals[i]*120, Color.crimson - alpha, 2.5)
		
		#draw rays
		var ray_pos = ray.global_position - global_position
		var ray_cast_to = ray_pos + ray.cast_to
		draw_line(ray_pos, ray_cast_to, Color.antiquewhite - alpha, 2.5)
		

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_X:
			show_debug = not show_debug




