extends MarginContainer

var current_health = 10
var max_health = 10
var attack_damage = 4
var has_killed_player = false
var alive = true
var shield_value = 8

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
	$AttackIntent/Damage.text = "2x" + str(attack_damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_health_and_check_if_dead(number):
	current_health -= number
	$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	if current_health <= 0:
		current_health = 0
		$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
		$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
		play_death_animation_and_die()
		return true
	return false

func start_attacking():
	print("Attack!")
	$AttackIntent.visible = false
	await get_tree().create_timer(0.5).timeout
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "attack_2"
	has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(attack_damage)
	if has_killed_player:
		animate_stuff_when_player_dies()

func complete_attack():
	await get_tree().create_timer(1.0).timeout
	$AttackIntent.visible = false
	await get_tree().create_timer(0.5).timeout
	start_attacking()
	await get_tree().create_timer(2.5).timeout

func start_defending():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "defend"

func _on_animated_sprite_2d_animation_finished():
	if has_killed_player:
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
		$VBoxContainer/ImageContainer/AnimatedSprite2D.play()
		return
		
	if $VBoxContainer/ImageContainer/AnimatedSprite2D.animation == "attack_2":
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "attack_3"
		$VBoxContainer/ImageContainer/AnimatedSprite2D.play()
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(attack_damage)
		if has_killed_player:
			animate_stuff_when_player_dies()
	elif $VBoxContainer/ImageContainer/AnimatedSprite2D.animation == "dead":
		pass
	else:
		$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "idle"
		$VBoxContainer/ImageContainer/AnimatedSprite2D.play()

func play_death_animation_and_die():
	$VBoxContainer/ImageContainer/AnimatedSprite2D.animation = "dead"
	$AttackIntent.visible = false
	alive = false

func set_new_intent():
	$AttackIntent.visible = true
	intent = ATTACK

func animate_stuff_when_player_dies():
	$'../../Wanderer'.z_index = 3
	z_index = 3
	$'../../'.show_game_over_bg()
	$'../../AnimationPlayer'.play("fade_out_stuff")
	for card in $'../../DiscardedCards'.get_children():
		var base = card.get_node("MyCardBase")
		base.fade_out()
	
	$AnimateBars.play("fade_out")
	


