extends Button

var top_layer_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_pressed():
#	for enemy in $'../../Enemies'.get_children():
#		var distortion = load("res://effects/distortion.tscn").instantiate()
#		enemy.add_scene_on_top_of_sprite(distortion)
	if not top_layer_on:
		for i in range($'../../Enemies'.get_child_count()):
			var enemy = $'../../Enemies'.get_child(i)
			var distortion = load("res://effects/distortion.tscn").instantiate()
			distortion.set_shader(i+1)
			enemy.add_scene_on_top_of_sprite(distortion)
		top_layer_on = true
	else:
		for i in range($'../../Enemies'.get_child_count()):
			$'../../Enemies'.get_child(i).remove_scenes_from_top_of_sprite()
		top_layer_on = false
