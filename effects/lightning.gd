extends Node2D


var target_pos = Vector2(600, 200)
var start_pos = Vector2(100, 200)

func init(start, end):
	start_pos = start
	position = start
	target_pos = end
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.3).timeout
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
