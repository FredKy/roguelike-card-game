extends Node2D

@onready var game_state = get_node("/root/GameState")
#const MAP_NODES = {0 : [1,2], 1: [3,4], 2: [4,5], 3: [6], 4: [6,7], 5: [7,8], 6: [9],
#7: [9, 10], 8: [10, 11], 9: [12, 13], 10: [13, 14], 11: [14], 12: [15], 13: [15], 14: [15]}
var map_nodes = {}

var current_map_node = 0
var visited_nodes = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if game_state.global_current_act == 1:
		map_nodes = game_state.MAP_ONE_NODES
	elif game_state.global_current_act == 2:
		map_nodes = game_state.MAP_TWO_NODES
	else:
		print("Something weird happened")
		map_nodes = game_state.MAP_ONE_NODES
	current_map_node = game_state.global_current_map_node
	setup_visited_nodes()
	activate_nodes_on_player_path()
	var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
	transition.get_node("ColorRect").modulate = Color(1,1,1,1)
	add_child(transition)
	await transition.fade_out()
	transition.queue_free()
	

func activate_nodes_on_player_path():
	var node_indeces = map_nodes[current_map_node]
	for node in $MapNodes.get_children():
		node.player_is_on_node(false)
		if node.index == current_map_node:
			node.player_is_on_node(true)
		node.disabled = true
		if node_indeces.find(node.index) > -1:
			node.disabled = false
			node.play_scale_animation()

func setup_visited_nodes():
	visited_nodes = game_state.global_visited_nodes
	for node in $MapNodes.get_children():
		if visited_nodes.find(node.index) > -1:
			node.visited = true
			node.transparent()
