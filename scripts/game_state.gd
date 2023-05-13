extends Node

const STARTER_DECK = ["ice_cannon", "ice_cannon", "ice_cannon", "energy_shield", "energy_shield", "energy_shield"]
const STARTER_PLAYER_MAX_HEALTH = 20 
var global_player_deck = []
var global_player_max_health
var global_player_current_health



# Called when the node enters the scene tree for the first time.
func _ready():
	reset_game_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func reset_game_state():
	global_player_deck = STARTER_DECK.duplicate()
	global_player_max_health = STARTER_PLAYER_MAX_HEALTH
	global_player_current_health = global_player_max_health
