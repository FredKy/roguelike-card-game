extends MarginContainer

var current_health = 10.0
var max_health = 10.0
var attack_damage = 4.0
var has_killed_player = false
var alive = true
var shield_value = 8.0

#May be simplified later
var buffered_damage = 0

#@export var enemy_resource: Resource = load("res://resources/skeleton_spearman.tres")
@export var enemy_resource: Resource
#@export var loaded_sprite_frames: SpriteFrames = load("res://resources/skeleton_spearman_sprite_frames.tres")
@export var loaded_sprite_frames: SpriteFrames
@onready var sprite: AnimatedSprite2D = $VBoxContainer/ImageContainer/AnimatedSprite2D

#Intents
enum {
	ATTACK,
	DEFEND,
}

var intent = ATTACK
var intent_queue = [ATTACK, DEFEND]

func init(pos = Vector2(760, 80), e_r = load("res://resources/skeleton_spearman.tres"), l_s_f = load("res://resources/skeleton_spearman_sprite_frames.tres")):
	position = pos
	enemy_resource = e_r
	loaded_sprite_frames = l_s_f
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.sprite_frames = loaded_sprite_frames
	print(enemy_resource.intent_position)
	
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	sprite.animation = "idle"
	$AttackIntent/Damage.text = "2x" + str(attack_damage)
	$AttackIntent.position = enemy_resource.intent_position
	
	scale *= 0.4
	$VBoxContainer/ImageContainer/AnimatedSprite2D.play()


func change_health_and_check_if_dead(number):
	play_hurt()
	buffered_damage -= number
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

func play_hurt():
	sprite.animation = "hurt"

#Used with buffered damage var to check if enemy is going to die from upcoming qeued damage.
#This function is used to prevent the player from wasting an attack card on an already dead enemy.
func is_already_dead():
	if current_health <= buffered_damage:
		return true
	else:
		return false

func start_attacking():
	print("Attack!")
	$AttackIntent.visible = false
	await get_tree().create_timer(0.5).timeout
	sprite.animation = "attack_2"
	has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(attack_damage)
	if has_killed_player:
		for enemy in $'../../Enemies'.get_children():
			enemy.z_index = 3
			enemy.fade_out_bars()
			enemy.hide_intents()
		$'../../'.animate_stuff_when_player_dies()

func complete_attack():
	await get_tree().create_timer(1.0).timeout
	$AttackIntent.visible = false
	await get_tree().create_timer(0.5).timeout
	start_attacking()
	await get_tree().create_timer(2.5).timeout

func start_defending():
	sprite.animation = "defend"

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
	elif sprite.animation == "dead":
		pass
	else:
		sprite.animation = "idle"
		sprite.play()

func play_death_animation_and_die():
	sprite.animation = "dead"
	$AttackIntent.visible = false
	alive = false
	#Check if any buddies are alive, if not fade out UI stuff and trigger win function
	var buddies_alive = $'../../'.some_enemy_is_alive()
	if not buddies_alive:
		$'../../'.do_stuff_when_all_enemies_are_dead()

func set_new_intent(new_intent):
	$AttackIntent.visible = false
	$DefendIntent.visible = false
	match new_intent:
		ATTACK:
			$AttackIntent.visible = true
			intent = ATTACK
		DEFEND:
			$DefendIntent.visible = true
			intent = DEFEND

func shift_to_next_intent():
	var temp = intent_queue[0]
	var new_intent = intent_queue.pop_front()
	intent_queue.append(temp)
	set_new_intent(new_intent)

func fade_out_bars():
	$AnimateBars.play("fade_out")

func hide_intents():
	$AttackIntent.visible = false


