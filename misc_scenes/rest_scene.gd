extends Node2D

@onready var util = get_node("/root/UtilityFunctions")
@onready var game_state = get_node("/root/GameState")


# Called when the node enters the scene tree for the first time.
func _ready():
	util.set_background_texture(game_state.global_next_background, self)
	update_global_deck_counter()
	$TopBar.set_health_text(str(game_state.global_player_current_health)\
	+"/"+ str(game_state.global_player_max_health))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_global_deck_counter():
	$TopBar/Deck/GlobalDeckCounter.set_label_text(game_state.global_player_deck.size())

#	max_health = game_state.global_player_max_health
#	current_health = game_state.global_player_current_health
