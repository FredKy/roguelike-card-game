extends Node2D

var map_nodes = {0 : [1,2], 1: [3,4], 2: [4,5]}

var current_map_node = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Level1/Level1A.play_scale_animation()
	$Level1/Level1B.play_scale_animation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_1a_pressed():
	print(map_nodes)
	#get_tree().change_scene_to_file("res://playspace.tscn")


func _on_level_1b_pressed():
	pass # Replace with function body.
