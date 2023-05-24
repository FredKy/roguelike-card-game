extends Node2D

var t = 0
var target_pos = Vector2(600, 200)
var start_pos = Vector2(100, 200)

func init(start, end):
	start_pos = start
	position = start
	target_pos = end
	$AnimatedSprite2D.animation = "ice_cannon_projectile"
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if t <= 1:
		position = start_pos.lerp(target_pos, t)
		t += delta/float(0.35)
	elif t > 1 and t <= 1.1:
		t += delta/float(0.35)
	elif t > 1.1:
		self.visible = false
	
