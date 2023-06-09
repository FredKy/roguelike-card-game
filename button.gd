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
			#distortion.set_warp_time_shader(i+1)
			enemy.add_scene_on_top_of_sprite(distortion)
		top_layer_on = true
	else:
		for i in range($'../../Enemies'.get_child_count()):
			$'../../Enemies'.get_child(i).remove_scenes_from_top_of_sprite()
		top_layer_on = false
	for child in $'../../Wanderer/SpellSprites'.get_children():
		child.queue_free()
	var projectile = load("res://misc_scenes/charge_sprite.tscn").instantiate().init(Vector2(325,145),Vector2(400,200))
	$'../../Wanderer/SpellSprites'.add_child(projectile)
