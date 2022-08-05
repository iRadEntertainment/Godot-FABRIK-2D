# FABRIK explanation
extends Control

var anim_speed = 0.3

var p = []
var p_nodes = []
var n
var l = []

var active_point
var forward_mode = true

var iterations_tot = 0 setget _iteration_tot_changed
var iterations_chain = 0 setget _iteration_chain_changed
var iterations_per_click = 1 setget _iteration_per_click_changed

var active_point_color = Color.magenta
var point_color = Color.whitesmoke

onready var point_texture = preload("res://addons/textures/point.png")
var custom_font_point = null

#================================ INIT =========================================
func _ready():
	connect_all_signals()
	
	setup_points()

func connect_all_signals():
	$buttons/delete_points.connect("pressed",self,"delete_all_points")
	custom_font_point = $"points/00/lb".get("custom_fonts/font")
	

func setup_points():
	# init arrays
	p = []
	p_nodes = []
	l = []
	
	# delete all existing directions and lengths lines
	for line in $directions.get_children():
		line.queue_free()
	for line in $lengths.get_children():
		line.queue_free()
	
	# gather the points
	for point in $points.get_children():
		p_nodes.append(point)
		p.append(point.global_position)
	n = p.size()-1
	active_point = n
	
	if p.size() < 1:
		return
	
	var offset = $root.global_position - p[0]
	for i in range(p.size()):
		p[i] += offset
		p_nodes[i].global_position += offset
		
	
	for i in range(n+1):
		if i == n:
			l.append(0)
		else:
			var length = (p[i+1] - p[i]).length()
			l.append(length)
	
	
	#generate new lines
	for i in range(n):
		# directions
		var new_dir = $lines/line_dash.duplicate()
		new_dir.points = [p[i], p[i+1]]
		$directions.add_child(new_dir)
		new_dir.global_position = Vector2.ZERO
		
		# lenghts
		var new_length = $lines/line.duplicate()
		new_length.points = [p[i], p[i+1]]
		$lengths.add_child(new_length)
		new_length.global_position = Vector2.ZERO




#================================ STEPS ========================================
func next_step():
	# if tween is still running on the previous step, cancel the next step
	if $tw.is_active():
		return
	
	
	var points_to_move = []
	var points_toward = []
	var lengths = []
	
	for i in range (iterations_per_click):
		self.iterations_tot += 1
		#color points
		for point in p_nodes:
			point.modulate = point_color
		p_nodes[active_point].modulate = active_point_color
		
		if forward_mode:
			move_point_forward()
			active_point -= 1
			if active_point < 0:
				active_point = 0
				forward_mode = false
		else:
			move_point_backward()
			active_point += 1
			if active_point == n+1:
				active_point = n
				forward_mode = true
				self.iterations_chain += 1
			
	
	animate_points()
	
	

#============================== ANIMATONS ======================================
func move_root(pos):
	active_point = n
	self.iterations_tot = 0
	self.iterations_chain = 0
	forward_mode = true
	
	$root.global_position = pos
#	$tw.interpolate_property($root, "global_position", $root.global_position, pos, anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
#	$tw.start()
#	yield($tw,"tween_all_completed")
	setup_points()


func move_goal(pos):
	active_point = n
	self.iterations_tot = 0
	self.iterations_chain = 0
	forward_mode = true
	
	$tw.interpolate_property($goal, "global_position", $goal.global_position, pos, anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tw.start()


func move_point_forward():
	var i = active_point
	if i == n:
		p[i] = $goal.global_position
	else:
		var dir = (p[i + 1] - p[i]).normalized() * l[i]
		p[i] = p[i + 1] - dir

func move_point_backward():
	var i = active_point
	if i == 0:
		p[i] = $root.global_position
	else:
		var dir = (p[i - 1] - p[i]).normalized() * l[i-1]
		p[i] = p[i - 1] - dir



func animate_points():
	for i in range(p_nodes.size()):
		var point = p_nodes[i]
		$tw.interpolate_property(point, "global_position", point.global_position, p[i], anim_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	$tw.start()


func _process(d):
	# animate the construction lines
	
	for i in range(n):
		# directions
		var dir = $directions.get_child(i)
		dir.points = [p_nodes[i].global_position, p_nodes[i+1].global_position]
		
		# lenghts
		var length = $lengths.get_child(i)
		var direction = (p_nodes[i+1].global_position - p_nodes[i].global_position).normalized()
		if forward_mode:
			length.points = [p_nodes[i+1].global_position,
						p_nodes[i+1].global_position - (direction * l[i])]
		else:
			length.points = [p_nodes[i].global_position,
						p_nodes[i].global_position + (direction * l[i])]


#=============================== INPUTS ========================================
var shift_pressed = false
var ctrl_pressed = false

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			shift_pressed = event.is_pressed()
			$buttons/add_points.pressed = shift_pressed
		if event.scancode == KEY_CONTROL:
			ctrl_pressed = event.is_pressed()


func _on_fabrik_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		#create and delete points
		if shift_pressed:
			if event.button_index == BUTTON_LEFT:
				create_point(get_global_mouse_position())
			elif event.button_index == BUTTON_RIGHT:
				delete_point(get_global_mouse_position())
		
		# next steps and goal move
		else:
			if event.button_index == BUTTON_RIGHT:
				if ctrl_pressed:
					move_root(get_global_mouse_position())
				else:
					move_goal(get_global_mouse_position())
			elif  event.button_index == BUTTON_LEFT:
				next_step()
		
		# iterations per click
		if event.button_index == BUTTON_WHEEL_UP:
			iterations_per_click += 1 if not shift_pressed else (n+1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			iterations_per_click -= 1 if not shift_pressed else (n+1)
		elif event.button_index == BUTTON_MIDDLE:
			iterations_per_click = (n+1) if not shift_pressed else (n+1)*2
		
		self.iterations_per_click = max(1, iterations_per_click)
		

#================================ UTILS ========================================
func show_points(val):
	for point in p:
		point.visible = val

func _iteration_per_click_changed(val):
	iterations_per_click = val
	$iterations/per_click/value.text = str(iterations_per_click)
func _iteration_tot_changed(val):
	iterations_tot = val
	$iterations/tot/value.text = str(iterations_tot)
func _iteration_chain_changed(val):
	iterations_chain = val
	$iterations/chain/value.text = str(iterations_chain)
	

func create_point(pos):
	# create new point
	var new_point = Sprite.new()
	new_point.texture = load("res://addons/textures/point.png")
	new_point.name = "%02d"%($points.get_child_count())
	# set label
	var new_label = Label.new()
	new_label.name = "lb"
	new_label.text = "p%s"%new_point.name
	new_label.rect_min_size = Vector2(40,26)
	new_label.align = Label.ALIGN_CENTER
	new_label.valign = Label.VALIGN_CENTER
	new_label.set("custom_fonts/font", custom_font_point)
	new_point.add_child(new_label)
	new_label.rect_position = Vector2(-20, 8)
	
	$points.add_child(new_point)
	new_point.position = pos
	
	rename_all_points()
	setup_points()


func delete_point(pos):
	if p_nodes.size() <= 1:
		return
	
	var closer_point = 0
	var min_dist = 10000
	for i in range (p_nodes.size()):
		var dist = p[i].distance_to(pos)
		min_dist = min(min_dist, dist)
		if dist == min_dist:
			closer_point = i
	
	p_nodes[closer_point].free()
	
	rename_all_points()
	setup_points()


func rename_all_points():
	if $points.get_children().size() < 1:
		return
	
	var p_count = $points.get_children().size()
	for i in range (p_count):
		var point = $points.get_child(i)
		point.name = "p%02d"%i if i < (p_count-1) else "end"
		point.get_child(0).text = point.name


func delete_all_points():
	for point in $points.get_children():
		point.free()
	
	setup_points()

