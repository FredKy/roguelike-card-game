extends Control

@onready var game_state = get_node("/root/GameState")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$VBoxContainer/StartButton.grab_focus()
	$TitleText/TitleTextAP.play("show_title_text")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_button_pressed():
	game_state.reset_game_state()
	#get_tree().change_scene_to_file("res://playspace.tscn")
	var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
	add_child(transition)
	await transition.fade_in()
	get_tree().change_scene_to_file("res://map.tscn")


func _on_quit_pressed():
	get_tree().quit()
