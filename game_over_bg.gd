extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Smoke.material.set("shader_parameter/fade", 0.0)
	$AnimationPlayer.play("fade_in")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#
#func fade_in():
#	$AnimationPlayer.play("fade_in")
