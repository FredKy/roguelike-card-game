extends Node

const STARTER_DECK = ["ice_cannon", "ice_cannon", "ice_cannon", "energy_shield", "energy_shield", "energy_shield"]
const STARTER_PLAYER_MAX_HEALTH = 20.0 
var global_player_deck = []
var global_player_max_health
var global_player_current_health

#Map state
const MAP_NODES = {0 : [1,2], 1: [3,4], 2: [4,5], 3: [6], 4: [6,7], 5: [7,8], 6: [9],
7: [9, 10], 8: [10, 11], 9: [12, 13], 10: [13, 14], 11: [14], 12: [15], 13: [15], 14: [15], 15 : []}
var global_current_map_node
var global_visited_nodes

#Battle type
#var battle_type: int
var global_next_battle_type

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_game_state()


func reset_game_state():
	global_player_deck = STARTER_DECK.duplicate()
	global_player_max_health = STARTER_PLAYER_MAX_HEALTH
	global_player_current_health = global_player_max_health
	global_current_map_node = 0
	global_visited_nodes = [0]
