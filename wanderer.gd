extends MarginContainer

var current_health = 10
var max_health = 10
var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#$VBoxContainer/ImageContainer/Image.scale.x *= -1
	#$VBoxContainer/ImageContainer/Image.scale *= $VBoxContainer/ImageContainer.get_minimum_size()/$VBoxContainer/ImageContainer/Image.texture.size
	#$VBoxContainer/ImageContainer/AnimatedSprite2D.scale *= 4
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_health_and_check_if_dead(number):
	current_health -= number
	$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	if current_health <= 0:
		play_death_animation()
		return true
	return false

func play_death_animation():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "dead"
	alive = false

func ice_cannon():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "ice_cannon"
	
func _on_animated_sprite_2d_animation_finished():
	if not alive:
		return
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
	$VBoxContainer/ImageContainer/AnimatedSprite2D.play()

