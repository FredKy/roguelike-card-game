extends MarginContainer

var current_health = 10.0
var max_health = 10.0
var attack_damage = 4.0
var has_killed_player = false
var alive = true
var shield_value = 8.0
var current_shield = 0

#Used to determine if enemy is going to die from queued up damage
var buffered_damage = 0

@export var enemy_resource: Resource

@onready var sprite: AnimatedSprite2D = $VBoxContainer/ImageContainer/AnimatedSprite2D

#Intents
enum {
	ATTACK,
	DEFEND,
}

var intent
var intent_queue

func init(pos = Vector2(760, 80), e_r = load("res://resources/skeleton_spearman.tres"), i_q = [DEFEND, ATTACK]):
	position = pos
	enemy_resource = e_r
	intent_queue = i_q
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.sprite_frames = enemy_resource.sprite_frames_resource
	print(enemy_resource.intent_position)
	
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	sprite.animation = "idle"
	$Intents/AttackIntent/Damage.text = "2x" + str(attack_damage)
	$Intents/AttackIntent.position = enemy_resource.intent_position
#	$Intents/DefendIntent/ShieldAmount.text = str(shield_value)
#	set_shield_amount(0)
#	$Indicators/Shield.visible = false
	reset_shield()
	$Intents/DefendIntent.position = enemy_resource.intent_position
	
	shift_to_next_intent()
	
	
	scale *= 0.4
	$VBoxContainer/ImageContainer/AnimatedSprite2D.play()


func change_health_and_check_if_dead(number):
	play_hurt()
	buffered_damage -= number
	if number > current_shield:
		number -= current_shield
		current_shield = 0
		set_shield_amount(current_shield)
		
		current_health -= number
		$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
		$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	else:
		current_shield -= number
		set_shield_amount(current_shield)
	
	
	if current_health <= 0:
		current_health = 0
		$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
		$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
		play_death_animation_and_die()
		return true
	return false

func play_hurt():
	sprite.animation = "hurt"

#Used with buffered damage var to check if enemy is going to die from upcoming qeued damage.
#This function is used to prevent the player from wasting an attack card on an already dead enemy.
func is_already_dead():
	if current_health + current_shield <= buffered_damage:
		return true
	else:
		return false

func start_attacking():
	print("Attack!")
	$Intents/AttackIntent/AP.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$Intents/AttackIntent.visible = false
	sprite.animation = "attack_2"
	has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(attack_damage)
	if has_killed_player:
		for enemy in $'../../Enemies'.get_children():
			enemy.z_index = 3
			enemy.fade_out_bars()
			enemy.hide_all_intent_sprites()
		$'../../'.animate_stuff_when_player_dies()

func start_defending():
	$Intents/DefendIntent/AP.play("fade_out")
	await get_tree().create_timer(1.0).timeout
	$Intents/DefendIntent.visible = false
	$Indicators/Shield.visible = true
	set_shield_amount(shield_value)
	sprite.animation = "defend"

func reset_shield():
	current_shield = 0
	set_shield_amount(0)
	$Indicators/Shield.visible = false

func _on_animated_sprite_2d_animation_finished():
	if has_killed_player:
		sprite.animation = "idle"
		sprite.play()
		return
		
	if sprite.animation == "attack_2":
		sprite.animation = "attack_3"
		sprite.play()
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(attack_damage)
		if has_killed_player:
			$'../../'.animate_stuff_when_player_dies()
	elif sprite.animation == "defend":
		pass
	elif sprite.animation == "dead":
		pass
	else:
		sprite.animation = "idle"
		sprite.play()

func play_death_animation_and_die():
	sprite.animation = "dead"
	hide_all_intent_sprites()
	$Indicators/Shield.visible = false
	alive = false
	#Check if any buddies are alive, if not fade out UI stuff and trigger win function
	var buddies_alive = $'../../'.some_enemy_is_alive()
	if not buddies_alive:
		$'../../'.do_stuff_when_all_enemies_are_dead()

func set_new_intent(new_intent):
	print(new_intent)
	print(intent_queue)
	#hide_all_intent_sprites()
	match new_intent:
		ATTACK:
			$Intents/AttackIntent/AP.play("RESET")
			await get_tree().create_timer(0.05).timeout
			$Intents/AttackIntent.visible = true
			$Intents/AttackIntent/AP.play("fade_in")
			intent = ATTACK
		DEFEND:
			$Intents/DefendIntent/AP.play("RESET")
			await get_tree().create_timer(0.05).timeout
			$Intents/DefendIntent.visible = true
			$Intents/DefendIntent/AP.play("fade_in")
			intent = DEFEND

func shift_to_next_intent():
	var temp = intent_queue[0]
	var new_intent = intent_queue.pop_front()
	intent_queue.append(temp)
	set_new_intent(new_intent)

func hide_all_intent_sprites():
	for intent in $Intents.get_children():
		intent.visible = false
#		if intent.visible:
#			intent.get_node("AP").play("fade_out")
#			await get_tree().create_timer(1.0).timeout
#			intent.visible = false

func fade_out_bars():
	$AnimateBars.play("fade_out")

func set_shield_amount(value):
	$Indicators/Shield/Amount.text = str(value)
	current_shield = value


