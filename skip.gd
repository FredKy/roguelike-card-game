extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_gui_input(_event):
	if Input.is_action_just_released("leftclick") and disabled == false:
		var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
		$'../'.add_child(transition)
		await transition.fade_in()
		print(get_tree())
		transition.queue_free()
		get_tree().change_scene_to_file("res://map.tscn")
