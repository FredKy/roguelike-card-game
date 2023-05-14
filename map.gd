extends Node2D

@onready var game_state = get_node("/root/GameState")
#const MAP_NODES = {0 : [1,2], 1: [3,4], 2: [4,5], 3: [6], 4: [6,7], 5: [7,8], 6: [9],
#7: [9, 10], 8: [10, 11], 9: [12, 13], 10: [13, 14], 11: [14], 12: [15], 13: [15], 14: [15]}
var map_nodes = {}

var current_map_node = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	map_nodes = game_state.MAP_NODES
	current_map_node = game_state.global_current_map_node
	activate_nodes_on_player_path()
	

func activate_nodes_on_player_path():
	var node_indeces = map_nodes[current_map_node]
	for node in $MapNodes.get_children():
		node.disabled = true
		if node_indeces.find(node.index) > -1:
			node.disabled = false
			node.play_scale_animation()

