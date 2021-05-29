#=====================================#
#                                     #
#  targeting system with ground snap  #
#                                     #
#=====================================#

extends Node2D



export var debug := true
export var active := true
export var arching_speed = 3.8
export var arc_amplitude_x = 160
export var arc_amplitude_y = 80


var rays = []
var targets = []

var is_the_leg_stretched = [true,true,true,true]
var is_the_leg_arching = [false,false,false,false]
var leg_arc_timing = [0, 0, 0, 0]
var leg_arc_detatch_point = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var legs_lengths = [200, 180, 180, 180]
onready var legs = [$"../horse/front_l", $"../horse/front_r",\
			$"../horse/rear_l", $"../horse/rear_r"]


func _ready():
	set_process(active)
	play_everything_without_any_error_please_thank_you()


func play_everything_without_any_error_please_thank_you():
	for child in $targets.get_children():
		targets.append(child)
	for child in $rays.get_children():
		rays.append(child)
	
	# assign this script targets to the horse legs
	
	if active:
		for i in range(4):
			legs[i].target = legs[i].get_path_to(targets[i])
			rays[i].global_position = legs[i].global_position + Vector2.DOWN * 160


func _process(d):
	move_targets_where_they_are_supposed_to_be_for_a_start()
	move_the_rays_according_to_the_stretch_of_the_legs(d)
	update()


func move_the_rays_according_to_the_stretch_of_the_legs(d):
	for i in range (4):
		# check if the leg is stretched
		if not is_the_leg_arching[i]:
			is_the_leg_stretched[i] = \
			(legs[i].global_position - targets[i].global_position).length() > 220#legs_lengths[i]
			
			# store the detach point
			leg_arc_detatch_point[i] = rays[i].global_position - Vector2(arc_amplitude_x, 0)
		
		if is_the_leg_stretched[i]:
			# move the ray in an arc motion
			is_the_leg_arching[i] = true
			leg_arc_timing[i] += (d * arching_speed) 
			
			var sin_offset = Vector2(cos( leg_arc_timing[i])*arc_amplitude_x, \
									 sin(-leg_arc_timing[i])*arc_amplitude_y  )
			
			rays[i].global_position = leg_arc_detatch_point[i] + sin_offset
			
			rays[i].enabled = false if (leg_arc_timing[i] < PI/2) else true
			if rays[i].enabled:
				if rays[i].is_colliding():
					is_the_leg_arching[i] = false
					is_the_leg_stretched[i] = false
					leg_arc_timing[i] = 0



func move_targets_where_they_are_supposed_to_be_for_a_start():
	for i in range(4):
		var tar : Position2D = targets[i]
		var ray : RayCast2D = rays[i]
		
		ray.force_raycast_update()
		if ray.is_colliding():
			tar.global_position = ray.get_collision_point()
		else:
			tar.global_position = ray.global_position + ray.cast_to


func _draw():
	if debug:
		for i in range(4):
			var tar : Position2D = targets[i]
			var ray : RayCast2D = rays[i]
			
			draw_circle(tar.position, 4, Color.bisque)
			var col = Color.blue if is_the_leg_arching[i] else Color.chartreuse
			draw_line(ray.position, ray.position+ray.cast_to, col, 2.5)



