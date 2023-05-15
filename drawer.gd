extends Node2D

const S = 15
const GAP = 20
const LINE_WIDTH = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	queue_redraw()

func _draw():
	draw_set_transform_matrix(transform.inverse())
	#draw_dashed(Vector2(300, 500), Vector2(519, 600), Color(0, 0, 0, 1), 5, 10, false)
	for node in $'../MapNodes'.get_children():
		var path_end_node_indeces = $'../'.map_nodes[node.index]
		for index in path_end_node_indeces:
			for end_node in $'../MapNodes'.get_children():
				if end_node.index == index:
					var diff = end_node.position - node.position
					var direction = diff.normalized()
					var start_diff = GAP*direction
					var end_diff = -GAP*direction
					var start_pos = node.position + start_diff + Vector2(S,S)
					var end_pos = end_node.position + end_diff + Vector2(S,S)
					if end_node.big:
						end_pos += Vector2(15, 15)
					var color = Color(0.9,0.3,0.3,1) if node.visited and end_node.visited else Color(0, 0, 0, 1)
						
					draw_dashed_line(start_pos, end_pos, color, LINE_WIDTH, 10, false)


func draw_dashed(from, to, color, width, dash_length = 5, cap_end = false, antialiased = false):
	var length = (to - from).length()
	var normal = (to - from).normalized()
	var dash_step = normal * dash_length
	
	if length < dash_length: #not long enough to dash
		draw_line(from, to, color, width, antialiased)
		return

	else:
		var draw_flag = true
		var segment_start = from
		var steps = length/dash_length
		for start_length in range(0, steps + 1):
			var segment_end = segment_start + dash_step
			if draw_flag:
				draw_line(segment_start, segment_end, color, width, antialiased)

			segment_start = segment_end
			draw_flag = !draw_flag
		
		if cap_end:
			draw_line(segment_start, to, color, width, antialiased)

