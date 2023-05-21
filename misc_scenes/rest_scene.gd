extends Node2D

@onready var util = get_node("/root/UtilityFunctions")
@onready var game_state = get_node("/root/GameState")

const HEAL_PERCENT = 40


# Called when the node enters the scene tree for the first time.
func _ready():
	util.set_background_texture(game_state.global_next_background, self)
	update_global_deck_counter()
	$TopBar.set_health_text(str(game_state.global_player_current_health)\
	+"/"+ str(game_state.global_player_max_health))
	$StartRestingButton/Label.visible = false
	$StartRestingButton/Label.text = "Heal "+ str(HEAL_PERCENT) +"% of total HP"

func add_to_health(heal_int):
	var heal_percent = float(heal_int)/100.0
	game_state.global_player_current_health += int(game_state.global_player_max_health*heal_percent)
	if game_state.global_player_current_health > game_state.global_player_max_health:
		game_state.global_player_current_health = game_state.global_player_max_health
	$TopBar.set_health_text(str(game_state.global_player_current_health)\
	+"/"+ str(game_state.global_player_max_health))

func update_global_deck_counter():
	$TopBar/Deck/GlobalDeckCounter.set_label_text(game_state.global_player_deck.size())

#	max_health = game_state.global_player_max_health
#	current_health = game_state.global_player_current_health

func _on_start_resting_pressed():
	add_to_health(HEAL_PERCENT)
	$StartRestingButton/StartResting.disabled = true
	await get_tree().create_timer(1.0).timeout
	var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
	$'../'.add_child(transition)
	await transition.fade_in()
	print(get_tree())
	transition.queue_free()
	var act = game_state.global_current_act
	match act:
		1:
			get_tree().change_scene_to_file("res://map.tscn")
		2:
			get_tree().change_scene_to_file("res://misc_scenes/map_two.tscn")

func _on_start_resting_mouse_entered():
	$StartRestingButton/Label.visible = true


func _on_start_resting_mouse_exited():
	$StartRestingButton/Label.visible = false
