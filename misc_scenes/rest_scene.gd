extends Node2D

@onready var util = get_node("/root/UtilityFunctions")
@onready var game_state = get_node("/root/GameState")
#Backgrounds
enum {
	SUMMER_FOREST,
	WINTER_FOREST,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	util.set_background_texture(game_state.global_next_background, self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

