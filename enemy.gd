extends MarginContainer

var current_health = 30
var max_health = 30
var attack_damage = 4
var has_killed_player = false

#Intents
enum {
	ATTACK,
	DEFEND,
}

var intent = ATTACK

# Called when the node enters the scene tree for the first time.
func _ready():
	#$VBoxContainer/ImageContainer/Image.scale.x *= -1
	#$VBoxContainer/ImageContainer/Image.scale *= $VBoxContainer/ImageContainer.get_minimum_size()/$VBoxContainer/ImageContainer/Image.texture.size
	$VBoxContainer/ImageContainer/Image.scale *= 4
	#$VBoxContainer/ImageContainer/AnimatedSprite2D.scale *= 4
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_health(number):
	current_health -= number
	$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)

func start_attacking():
	print("Attack!")
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "attack_2"
	has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(2)

func _on_animated_sprite_2d_animation_finished():
	if $VBoxContainer/ImageContainer/AnimatedSprite2D.animation == "attack_2":
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "attack_3"
		$VBoxContainer/ImageContainer/AnimatedSprite2D.play()
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(2)
	else:
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
		$VBoxContainer/ImageContainer/AnimatedSprite2D.play()
