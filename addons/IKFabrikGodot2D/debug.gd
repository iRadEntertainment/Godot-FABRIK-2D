extends Node2D


onready var root = $"../root"
var default_font = Control.new().get_font("font")

func _process(delta):
	update()

func _draw():
	var start_pos = root.get_node("p1").global_position
	for i in range(root.ik.p.size()):
		var p = root.ik.p[i] + start_pos
		var p_forw = root.ik.p_forw[i] + start_pos
		var p_back = root.ik.p_back[i] + start_pos
		
		draw_circle(p, 2, Color.crimson)
		draw_circle(p_forw, 2, Color.firebrick)
		draw_circle(p_back, 2, Color.aquamarine)
		
#		draw_string(default_font, p + Vector2.DOWN*30, "p[%s]"%[i])
		if i < root.ik.n:
			# constraint angles [a0, a1, segment_angle, prev_segment_angle]
			var a0 = root.ik.constraint_angles[i][0]
			var a1 = root.ik.constraint_angles[i][1]
			var a = root.ik.constraint_angles[i][2]
			var prev = root.ik.constraint_angles[i][3]
#			var c_angles = root.ik.constraint_angles[i]
			draw_string(default_font, p + Vector2.DOWN*10, "%.2f, %.2f, %.2f"%[a0, a, a1])
			var vec_sample = Vector2(50, 0)
			draw_line(p, p + vec_sample.rotated(a), Color.green)
			draw_arc(p, 30, a0, a1, 20, Color.coral)
	
	var cont_color = Color.green if root.ik.contact else Color.firebrick
	draw_circle(Vector2(10,10), 6, cont_color)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		visible = not visible
