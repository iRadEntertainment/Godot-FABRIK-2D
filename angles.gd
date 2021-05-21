extends Control

var a0 = -PI/2
var a_width = 3*PI/4
var a1 = a0 + a_width
var a  = 0
var circle_radius = 150
var origin_offset = Vector2(0, -10)

onready var origin = $clock.position

#====================== FUNCTIONS TO BE CHECKED ================================
func angle_in_range():
	var _a  = fmod(a+ PI, 2*PI)
	var _a0 = fmod(a0+PI, 2*PI)
	var _a1 = fmod(a1+PI, 4*PI)
	
	var cond1 = 4 if _a<_a0 else 0
	var cond2 = 2 if _a<_a1 else 0
	var cond3 = 1 if _a<_a1-2*PI else 0
	var cond4 = 7 if _a>_a1+2*PI else 0
	var sum = cond1+cond2+cond3+cond4
#	$controls/vbox/in_range/lb.text = "%s"%sum
	return sum in [2,4,7]


func closer_angle():
	var _a  = a + PI
	var _a0 = a0 + PI
	var _a1 = a1 + PI
	var x = min( abs(_a0 - _a), abs(2*PI - _a0 + _a) )
	var y = min( abs(_a1 - _a), abs(2*PI - _a1 + _a) )
	
	var closer = a0 if x < y else a1
	return closer

#=============================== OTHER STUFF ===================================
func _ready():
	$controls/vbox/a0/sld.min_value = -PI
	$controls/vbox/a_width/sld.min_value = -2*PI
	$controls/vbox/a/sld.min_value = -PI
	$controls/vbox/a0/sld.max_value = PI
	$controls/vbox/a_width/sld.max_value = 2*PI
	$controls/vbox/a/sld.max_value = PI
	$controls/vbox/a0/sld.connect("value_changed", self, "a0_changed")
	$controls/vbox/a_width/sld.connect("value_changed", self, "a_width_changed")
	$controls/vbox/a/sld.connect("value_changed", self, "a_changed")
	update_graphics()


func update_graphics():
	origin = rect_size/2 + origin_offset
	$clock.position = origin
	$clock/a0.rotation = a0
	$clock/a0.points = [Vector2.ZERO, Vector2.RIGHT*circle_radius]
	$clock/a1.rotation = a1
	$clock/a1.points = [Vector2.ZERO, Vector2.RIGHT*circle_radius]
	$clock/a.rotation = a
	$clock/a.points = [Vector2.ZERO, Vector2.RIGHT*circle_radius]
	
	$controls/vbox/a0/sld.value = a0
	$controls/vbox/a0/val.text = "%.2f"%(a0)
	$controls/vbox/a_width/sld.value = a_width
	$controls/vbox/a_width/val.text = "%.2f"%(a_width)
	$controls/vbox/a/sld.value = a
	$controls/vbox/a/val.text = "%.2f"%(a)
	
	$float_lbs/a0.rect_position = origin + Vector2(cos(a0), sin(a0))*circle_radius + Vector2(cos(a0), sin(a0))*40
	$float_lbs/a0.text = "a0: %.2f"%a0
	$float_lbs/a1.rect_position = origin + Vector2(cos(a1), sin(a1))*circle_radius + Vector2(cos(a1), sin(a1))*40
	$float_lbs/a1.text = "a1: %.2f"%a1
	$float_lbs/a.rect_position  = origin + Vector2(cos(a), sin(a))*circle_radius + Vector2(cos(a), sin(a))*40
	$float_lbs/a.text = "a: %.2f"%a
	
	# checks
	$controls/vbox/in_range/bg.color = Color.limegreen if angle_in_range() else Color.brown
	if closer_angle() == a0:
		$controls/vbox/closer/a0/bg.color = Color.limegreen
		$controls/vbox/closer/a1/bg.color = Color.brown
	if closer_angle() == a1:
		$controls/vbox/closer/a1/bg.color = Color.limegreen
		$controls/vbox/closer/a0/bg.color = Color.brown
	
	update()
func _draw():
	# draw origin cross and circle
	draw_line(Vector2(origin.x, 0), Vector2(origin.x, rect_size.y), Color.aliceblue)
	draw_line(Vector2(0, origin.y), Vector2(rect_size.x, origin.y), Color.aliceblue)
	draw_arc(origin, circle_radius, 0, 2*PI, 360, Color.aliceblue)
	
	# draw range
	var points = calculate_range_points()
	var col = Color.bisque - Color(0,0,0,0.6)
	if a0 > a1:
		col = Color.crimson - Color(0,0,0,0.6)
	draw_polygon(points, [col])
#	print(points)

func calculate_range_points():
	var iter = 50
	var _sign = 1 if a0 < a1 else -1
	var increment = _sign * abs(a0 - (a0+a_width))/iter
	var points = []
	points.append(origin)
	for i in range(iter+1):
		var angle_increment = a0 + increment*i
		var p = Vector2(cos(angle_increment), sin(angle_increment))
		points.append(p*circle_radius + origin)
	points.append(origin)

	return points

func a0_changed(val):
	a0 = val
	a1 = a0 + a_width
	update_graphics()
func a_width_changed(val):
	a_width = val
	a1 = a0 + a_width
	update_graphics()
func a_changed(val):
	a = val
	update_graphics()

var mouse_left_down = false
var mouse_right_down = false
var shift_pressed = false
var ctrl_pressed = false
func _input(event):
	if event is InputEventKey:
#		print(event.scancode)
		if event.scancode == KEY_CONTROL:
			ctrl_pressed = event.is_pressed()
		if event.scancode == KEY_SHIFT:
			shift_pressed = event.is_pressed()

func _on_angles_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mouse_left_down = event.is_pressed()
			if event.is_pressed():
				if shift_pressed:
					a0 = get_global_mouse_position().angle_to_point(origin)
				elif ctrl_pressed:
					a_width = get_global_mouse_position().angle_to_point(origin) - a0
				else:
					a = get_global_mouse_position().angle_to_point(origin)
				update_graphics()
			
		if event.button_index == BUTTON_RIGHT:
			mouse_right_down = event.is_pressed()
			if event.is_pressed():
				var new_origin_offset = get_global_mouse_position() - rect_size/2
				$tw.interpolate_property(self, "origin_offset", origin_offset, new_origin_offset, 0.15, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
				$tw.start()
		elif event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
			circle_radius = max(50, circle_radius-10)
		elif event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
			circle_radius = min(300, circle_radius+10)
		update_graphics()
	
	if event is InputEventMouseMotion:
		if mouse_left_down:
			if shift_pressed:
				a0 = get_global_mouse_position().angle_to_point(origin)
			elif ctrl_pressed:
				a_width = get_global_mouse_position().angle_to_point(origin) - a0
			else:
				a = get_global_mouse_position().angle_to_point(origin)
			update_graphics()
		if mouse_right_down:
			origin_offset = get_global_mouse_position() - rect_size/2
		update_graphics()

func _process(delta):
	if $tw.is_active():
		update_graphics()
#	shift_pressed = Input.is_key_pressed(KEY_SHIFT)
#	ctrl_pressed = Input.is_key_pressed(KEY_CONTROL)

