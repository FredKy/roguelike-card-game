extends Node2D

const LENGTH = 0.7
# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.modulate = Color(1,1,1,0)

func fade_in(leng = LENGTH):
	$AP.get_animation("fade_in").length = leng
	$AP.play("fade_in")
	await get_tree().create_timer(leng).timeout

func fade_out(leng = LENGTH):
	$AP.get_animation("fade_out").length = leng
	$AP.play("fade_out")
	await get_tree().create_timer(leng).timeout

