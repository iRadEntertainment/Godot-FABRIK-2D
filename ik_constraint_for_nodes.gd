#===============#
#     ik.gd     #
#===============#

extends Node
class_name IKNodes

var nodes  = []
var angles = []
var p = []
var p_forw = []
var p_back = []
var tot_p = 0
var n = 0
var segments  = []
var nodes_initial_angle = []
var lengths = []
var constraint_angles = []


var init_angle : float
var start : Vector2
var right_vector = Vector2.RIGHT

# -- contact
var contact_threshold = 2
var contact           = false


#================================= INIT ========================================
func set_nodes(_nodes, _angles = null):
	nodes = _nodes
	angles = _angles
	#calculate points and lenghts
	start = nodes[0].global_position
	for node in nodes:
		p.append(node.global_position - start)
		tot_p += 1
	n = tot_p - 1
	p_forw = p.duplicate()
	p_back = p.duplicate()
	
	for i in range (n):
		segments.append(p[i+1] - p[i])
#		nodes_initial_angle.append( nodes[i].global_rotation )
	
	for i in range (segments.size()):
		lengths.append(segments[i].length())
		constraint_angles.append([0,0,0,0])



#================================ PROCESS ======================================
func reach_target(goal, _init_angle = 0, vel = null): # PROCESSED
	# if the p0 is moving between frames follow starting point in process
	start = nodes[0].global_position
	goal -= start
	init_angle = _init_angle
	
	# check if on goal already
	contact = ( p[n] - goal ).length() < contact_threshold
	if contact and ( p[n] - goal ).length() < contact_threshold/4:
		return p
	
	# if velocity != null then move the p[end] to a set distance towards the goal each iteration
	if vel:
		vel = vel if (goal - p[n]).length() > vel else (goal - p[n]).length()
		p[n] = p[n] + (goal - p[n]).normalized()*vel
	else:
		p[n] = goal
	
	p_forw[n] = p[n]
	
	# forward (p[n-1] -> p[n]) to (p[0] -> p[1])
	for i in range (n, 1, -1):
		# looping backwards (from i = n to i = 2) without moving p[0] (it is always a Vector.ZERO)
		var segment = p[i-1] - p[i]
		var forw_offset = segment.normalized() * lengths[i-1]
		p[i-1] = p[i] + forw_offset
		p_forw[i-1] = p[i-1]
	
	# backward (p[1] -> p[0]) to (p[n] -> p[n-1]) 
	for i in range (1,tot_p):
		# the range starts from p[1] to p[n]
		var segment = p[i] - p[i-1]
		var back_offset = segment.normalized() * lengths[i-1]
		p[i] = p[i-1] + back_offset
		p_back[i] = p[i]
		if angles:
			if angles[i-1] != null:
				apply_constraints(i)
	
	# angle constraints
#	if angles:
#		for i in range (n, 0, -1):
#			if angles[i-1] != null:
#				apply_constraints(i)

	translate_and_rotate_nodes()
	return p


#============================== CONSTRAINTS ====================================
func apply_constraints(i):
	var segment = p[i] - p[i-1]
	var a = segment.angle()
	var prev_segment = p[i-1] - p[i-2]
	var prev_segment_angle = prev_segment.angle() if i >= 2 else init_angle
	
	var a0 = angles[i-1][0] + prev_segment_angle
	var a_width = angles[i-1][1]
	var a1 = a0 + a_width
	var a1_wrapped = a1
	while abs(a1_wrapped) > PI:
		a1_wrapped += 2*PI * (1 if a1_wrapped < 0 else -1)
	
	constraint_angles[i-1] = [a0, a1, a, prev_segment_angle] #REMOVE
	
	if not angle_is_between(a, a0, a1, a_width):
		var closer_angle = find_closer_angle(a, a0, a1_wrapped, a_width)
		var valid_position = p[i-1] + (Vector2.RIGHT).rotated(closer_angle) * lengths[i-1]
		p[i] = valid_position
		var rot_offset = a - closer_angle
		if i > n:
			for j in range(i+1, tot_p):
				p[j] = (p[j] - p[i-1]).rotated(-rot_offset)
				


func angle_is_between(a, a0, a1, a_width):
	# darios
#	var _a  = a +PI#fmod(a+ PI, 2*PI)
#	var _a0 = a0+PI#fmod(a0+PI, 2*PI)
#	var _a1 = a1+PI#fmod(a1+PI, 4*PI)
#
#	var cond1 = 4 if _a<_a0 else 0
#	var cond2 = 2 if _a<_a1 else 0
#	var cond3 = 1 if _a<_a1-2*PI else 0
#	var cond4 = 7 if _a>_a1+2*PI else 0
#	var sum = cond1+cond2+cond3+cond4
#
#	return sum in [2,4,7]
	
	#antos
	#wrap angles
	while abs(a1) > PI:
		a1 += 2*PI * (1 if a1 < 0 else -1)
	while abs(a0) > PI:
		a0 += 2*PI * (1 if a0 < 0 else -1)
	
	if a0 < a1:
		if a_width < 0:
			return ((a >= -PI and a <= a0) or (a <= PI and a >= a1))
		return (a >= a0 and a <= a1)
	else:
		if a_width < 0:
			return (a>= a1 and a<= a0)
		return ((a <= a1 and a >= -PI) or (a <= PI and a >= a0))


func find_closer_angle(a, a0, a1, a_width):
	var _a  = a + PI
	var _a0 = a0 + PI
	var _a1 = a1 + PI

	if _a1 < _a0:
		if not( ((_a0 <= _a) and (_a <= 2*PI)) or ((0 <= _a) and (_a <= _a1)) ):
			var x = min( abs(-a0 - -a), abs(2*PI - -a0 + -a) )
			var y = min( abs(-a1 - -a), abs(2*PI - -a1 + -a) )
			var closer = a0 if x < y else a1
			return closer
		if ( ((_a0 <= _a) and (_a <= 2*PI)) or ((0 <= _a) and (_a <= _a1)) ):
			if (_a0 <= _a) and (_a <= 2*PI):
				var x = min( abs(_a - _a0), abs(2*PI - _a + _a0) )
				var y = min( abs(_a - _a1 ), abs(2*PI - _a + _a1) )
				var closer = a0 if x < y else a1
				return closer
			if (0 <= _a) and (_a <= _a1):
				var x = min( abs(_a0 - _a), abs(2*PI - _a0 + _a) )
				var y = min( abs(_a1 - _a), abs(2*PI - _a1 + _a) )
				var closer = a0 if x < y else a1
				return closer
				

	if ( (_a0 <= _a) and (_a <= _a1) ):
		var x = min( abs(_a - _a0), abs(2*PI - _a + _a0) )
		var y = min( abs(_a - _a1), abs(2*PI - _a + _a1) )
		var closer = a0 if x < y else a1
		return closer
	if not( (_a0 <= _a) and (_a <= _a1) ):
		if _a < _a0: 
			var x = min( abs(_a0 - _a), abs(2*PI - _a0 + _a) )
			var y = min( abs(_a1 - _a), abs(2*PI - _a1 + _a) )
			var closer = a0 if x < y else a1
			return closer
		if _a >= _a1: 
			var x = min( abs(_a - _a0), abs(2*PI - _a + _a0) )
			var y = min( abs(_a - _a1), abs(2*PI - _a + _a1) )
			var closer = a0 if x < y else a1
			return closer


func translate_and_rotate_nodes():
	for i in range (tot_p):
		# apply translation to nodes
		nodes[i].global_position = p[i] + start
		
		# apply rotation to nodes
		if i < n:
			var dir = p[i+1] - p[i]
			var rot = dir.angle()
			nodes[i].global_rotation = rot
		else:
			nodes[i].global_rotation = nodes[i-1].global_rotation
