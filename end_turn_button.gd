extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_gui_input(_event):
	var player_animation = $'../../Wanderer/VBoxContainer/ImageContainer/AnimatedSprite2D'.animation
	if Input.is_action_just_released("leftclick") and disabled == false\
	and player_animation == "idle" and $'../../'.some_enemy_is_alive()\
	and $'../../Wanderer'.number_of_buffered_attacks == 0:
		#$'../../'.move_cards_from_hand_to_discard(0.5) #Parameter is how long discard animation takes.
		$'../../'.end_player_turn()
