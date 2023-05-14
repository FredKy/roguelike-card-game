extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_gui_input(event):
	if Input.is_action_just_released("leftclick") and disabled == false:
		get_tree().change_scene_to_file("res://map.tscn")
