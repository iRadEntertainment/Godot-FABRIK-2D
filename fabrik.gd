# FABRIK explanation
extends Control

var anim_speed = 0.5

var p = []
var n
var l = []
#var lines_construction = []
#var lines_segments
var active_point
var forward_mode = true

var active_point_color = Color.darkslateblue
var point_color = Color.whitesmoke

#================================ INIT =========================================
func _ready():
	for point in $points.get_children():
		p.append(point)
	n = p.size()-1
	active_point = n
	
	var offset = $root.global_position - p[0].global_position
	for point in p:
		point.global_position += offset
#	p[0].global_position = $root.global_position
	
	for i in range(n+1):
		if i == n:
			l.append(0)
		else:
			var length = (p[i+1].global_position - p[i].global_position).length()
			l.append(length)
	
	for i in range(n):
		# directions
		var new_dir = $lines/line_dash.duplicate()
		new_dir.points = [p[i].global_position, p[i+1].global_position]
		$directions.add_child(new_dir)
		new_dir.global_position = Vector2.ZERO
		
		# lenghts
		var new_length = $lines/line.duplicate()
		new_length.points = [p[i].global_position, p[i+1].global_position]
		$lengths.add_child(new_length)
		new_length.global_position = Vector2.ZERO




#================================ STEPS ========================================
func next_step():
	#color points
	for point in p:
		point.modulate = point_color
	p[active_point].modulate = active_point_color
	
	
	
	if forward_mode:
		if active_point == n:
			move_point(p[active_point], $goal, 0)
		else:
			move_point(p[active_point], p[active_point+1], l[active_point], $directions.get_child(active_point))
		
		active_point -= 1
		if active_point < 0:
			active_point = 0
			forward_mode = false
	else: #backward mode
		if active_point == 0:
			move_point(p[active_point], $root, 0)
		else:
			move_point(p[active_point], p[active_point-1], l[active_point-1])
		
		active_point += 1
		if active_point == n+1:
			active_point = n
			forward_mode = true

#============================== ANIMATONS ======================================
func move_goal(pos):
	$tw.interpolate_property($goal, "global_position", $goal.global_position, pos, anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tw.start()
	

func move_point(_p : Sprite, _to_p : Sprite, _l : float, _direction = null):
	var dir = (_to_p.global_position - _p.global_position).normalized() * _l
	var next_pos = _to_p.global_position - dir
	$tw.interpolate_property(_p, "global_position", _p.global_position, next_pos, anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
#	if _direction:
#		var direction_points : PoolVector2Array = [_p.global_position, next_pos]
#		var dir_line = $directions
#		$tw.interpolate_property(_direction, "points", _direction.points, direction_points, anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tw.start()

#=============================== INPUTS ========================================
func _input(event):
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.button_mask == BUTTON_RIGHT:
			move_goal(get_global_mouse_position())
		elif  event.button_mask == BUTTON_LEFT:
			next_step()

#================================ UTILS ========================================
func show_points(val):
	for point in p:
		point.visible = val
