extends Node

const starter_deck = ["ice_cannon", "ice_cannon", "ice_cannon", "energy_shield", "energy_shield", "energy_shield"]
var global_player_deck = []
# Called when the node enters the scene tree for the first time.
func _ready():
	reset_game_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func reset_game_state():
	global_player_deck = starter_deck.duplicate()
