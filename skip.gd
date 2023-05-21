extends Button

@onready var game_state = get_node("/root/GameState")

func _on_pressed():
	if disabled == false:
		var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
		$'../'.add_child(transition)
		await transition.fade_in()
		print(get_tree())
		transition.queue_free()
		if game_state.global_current_map_node == 15:
			get_tree().change_scene_to_file("res://misc_scenes/victory.tscn")
		else:
			get_tree().change_scene_to_file("res://map.tscn")
