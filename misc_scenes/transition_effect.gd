extends Node2D

const LENGTH = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.modulate = Color(1,1,1,0)

func fade_in(len = LENGTH):
	$AP.get_animation("fade_in").length = len
	$AP.play("fade_in")
	await get_tree().create_timer(len).timeout

func fade_out(len = LENGTH):
	$AP.get_animation("fade_out").length = len
	$AP.play("fade_out")
	await get_tree().create_timer(len).timeout

