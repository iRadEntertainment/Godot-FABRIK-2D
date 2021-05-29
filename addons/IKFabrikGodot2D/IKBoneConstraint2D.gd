tool
extends Node2D
class_name IKBoneConstraint2D, "res://addons/IKFabrikGodot2D/IKBoneConstraint2D.png"

export (float, -360, 360) var angle_start = -45
export (float, 0, 360) var angle_width = 90

var view_angles := true

var points : PoolVector2Array
var visibility_radius := 30
var a0
var a1
var a_width



func _process(delta):
	draw_angle()

func draw_angle():
	a0 = deg2rad(angle_start) - global_rotation
	a_width = deg2rad(angle_width)
	
	if get_index() > 0:
		var prev_node = get_parent().get_child(get_index()-1)
		var segment : Vector2 = global_position - prev_node.global_position
		var a_prev = segment.angle()
		
		a0 += a_prev
	
	a1 = a0 + a_width
	
	points = []
	var center = Vector2.ZERO
	var iter = 30
	
	var _sign = 1 if a0 < a1 else -1
	var increment = _sign * abs(a0 - (a0+a_width))/iter
	
	points.append(center)
	for i in range (iter+1):
		var angle_increment = a0 + increment*i
		var p = Vector2(cos(angle_increment), sin(angle_increment))
		points.append(p*visibility_radius)
	points.append(center)
	
	update()


func _draw():
	if Engine.editor_hint:
		if view_angles:
			draw_polygon(points, [Color.yellowgreen - Color(0,0,0,0.7)])


# ============================== WARNINGS ======================================
func _get_configuration_warning() -> String:
	var warning : PoolStringArray
	
	if get_parent() is Viewport:
		warning.append("""This node cannot be used as root. Use it as a child of IKLimb2D instead""")
	if get_child_count() == 0:
		warning.append("""This is just an helper node. Use it as parent for other nodes (eg. Sprites2D)""")
	
	return warning.join("\n")
