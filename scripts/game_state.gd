extends Node

const STARTER_DECK = ["ice_cannon", "ice_cannon", "energize", "energize", "energy_shield", "energy_shield", "zap", "zap"]
const STARTER_PLAYER_MAX_HEALTH = 50.0 
var global_player_deck = []
var global_player_max_health
var global_player_current_health

#Map state
const MAP_ONE_NODES = {0 : [1,2], 1: [3,4], 2: [4,5], 3: [6], 4: [6,7], 5: [7,8], 6: [9],
7: [9, 10], 8: [10, 11], 9: [12, 13], 10: [13, 14], 11: [14], 12: [15], 13: [15], 14: [15], 15 : []}
const DRAFT_POOL = ["ice_cannon", "energize", "zap", "energy_shield"]
const MAP_TWO_NODES = {0 : [1,2,3], 1: [4], 2: [4,5], 3: [6], 4: [7], 5: [7,8,9], 6: [9,10],
7: [11], 8: [12, 13], 9: [13], 10: [13, 14], 11: [15], 12: [15], 13: [16, 17], 14: [17], 15: [18], 16: [18], 17: [18], 18: []}
var global_current_map_node
var global_visited_nodes
var global_current_act

#Location type etc.
var global_next_location_type
var global_next_battle_type
var global_next_background

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_game_state()


func reset_game_state():
	global_player_deck = STARTER_DECK.duplicate()
	global_player_max_health = STARTER_PLAYER_MAX_HEALTH
	global_player_current_health = global_player_max_health
	reset_map_state(1)

func reset_map_state(act):
	global_current_act = act
	global_current_map_node = 0
	global_visited_nodes = [0]
