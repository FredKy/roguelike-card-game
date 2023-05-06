extends MarginContainer

var current_health = 10
var max_health = 10
var current_shield = 0
var max_shield = 100
var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#$VBoxContainer/ImageContainer/Image.scale.x *= -1
	#$VBoxContainer/ImageContainer/Image.scale *= $VBoxContainer/ImageContainer.get_minimum_size()/$VBoxContainer/ImageContainer/Image.texture.size
	#$VBoxContainer/ImageContainer/AnimatedSprite2D.scale *= 4
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	$VBoxContainer/ShieldBar/TextureProgress.value = 0
	$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)
	
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_health_and_check_if_dead(damage_number):
	if damage_number > current_shield:
		damage_number -= current_shield
		current_shield = 0
		$VBoxContainer/ShieldBar/TextureProgress.value = 100*current_shield/max_shield
		$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)
		
		current_health -= damage_number
		$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
		$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	else:
		current_shield -= damage_number
		$VBoxContainer/ShieldBar/TextureProgress.value = 100*current_shield/max_shield
		$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)
			
	if current_health <= 0:
		play_death_animation()
		return true
	return false

func add_shield(shield_number):
	current_shield += shield_number
	$VBoxContainer/ShieldBar/TextureProgress.value = min(100*current_shield/max_shield, 100)
	$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)

func play_death_animation():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "dead"
	alive = false

func ice_cannon():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "ice_cannon"

func shield():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "shield"
	
func _on_animated_sprite_2d_animation_finished():
	if not alive:
		return
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
	$VBoxContainer/ImageContainer/AnimatedSprite2D.play()

