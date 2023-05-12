extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Smoke.material.set("shader_parameter/fade", 0.0)
	$AnimationPlayer.play("fade_in")
	$Visibility.modulate = Color(1,1,1,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#
#func fade_in():
#	$AnimationPlayer.play("fade_in")


func _on_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
