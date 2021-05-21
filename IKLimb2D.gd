tool
extends Node2D
class_name IKLimb2D, "res://IKLimb2D.png"


export var reach := true
export var use_constraints := false
export var reach_velocity : int = 0

export var view_angles := true setget _view_angles_changed
export var view_bones := true setget _view_bones_changed

export (NodePath) var target
var target_node

var contact := false
export (int) var contact_threshold = 5
var IK : IKNodes


func _view_angles_changed(val):
	view_angles = val
	for child in get_children():
		if child is IKBoneConstraint2D:
			child.view_angles = view_angles
func _view_bones_changed(val):
	view_bones = val
	update()

func _draw():
	if Engine.editor_hint:
		if get_child_count() > 0:
			get_child(0).show_behind_parent = view_bones
			for i in range(1, get_child_count()):
				if view_bones:
					draw_line(get_child(i).position, get_child(i-1).position, Color.red - Color(0,0,0,0.7), 2)
				get_child(i).show_behind_parent = view_bones


func _ready():
	set_process(false)
	if not Engine.editor_hint:
		if get_child_count() == 0:
			return
		# set IK
		IK = IKNodes.new()
		var nodes : Array = []
		for child in get_children():
			nodes.append(child)
		
		IK.contact_threshold = contact_threshold
		
		var angles = []
		if use_constraints:
			for i in range(get_child_count()-1):
				var bone = get_child(i)
				if bone is IKBoneConstraint2D:
					# calculate a0 and a1
					var a0 = 0
					a0 = deg2rad(bone.angle_start) - global_rotation
					var a_width = deg2rad(bone.angle_width)
					
					angles.append([a0, a_width])
				else:
					angles.append(null)
		
		if use_constraints:
			IK.set_nodes(nodes, angles)
		else:
			IK.set_nodes(nodes)
		if target:
			target_node = get_node(target)
		else:
			set_process(false)
			return
		set_process(true)
	else:
		set_process(false)


func _process(delta):
	if not Engine.editor_hint:
		if reach:
			var pos = target_node.global_position
			if reach_velocity > 0:
				IK.reach_target(pos, global_rotation, reach_velocity)
			else:
				IK.reach_target(pos, global_rotation)
			contact = IK.contact

# ============================== WARNINGS ======================================
func _get_configuration_warning() -> String:
	if get_child_count() == 0:
		return ""
	
	var warning : PoolStringArray
	
	if use_constraints:
		var node_found := 0
		for node in get_children():
			if node is IKBoneConstraint2D:
				node_found += 1
		if node_found == 0:
			warning.append("IKLimbs2D requires at least one IKBoneConstraint2D when using constraints")
	
	if not get_children().empty():
		if not get_children()[get_child_count()-1] is Position2D:
			warning.append("IKLimbs requires a Position2D as last child")
	return warning.join("\n")
