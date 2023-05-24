extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_warp_time_shader(warp_time_shader_index : int):
	pass
	$ColorRect.set("shader", "res://effects/warp_time_"+str(warp_time_shader_index)+".gdshader")
