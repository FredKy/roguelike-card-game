extends MarginContainer

var current_health = 30
var max_health = 30
var attack_damage = 4
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

func attack():
	print("Attack!")
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "attack_2"
	if $VBoxContainer/ImageContainer/AnimatedSprite2D.animation_finished:
		print("Animation över")
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
