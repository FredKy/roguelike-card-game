extends MarginContainer

const POST_ATTACK_DELAY = 0.75

var current_health
var max_health
var attack_damage
var double_attack_damage
var has_killed_player = false
var alive = true
var shield_value
var current_shield

#Used to determine if enemy is going to die from queued up damage
var buffered_damage = 0

#Array to store all upcoming animations, animation is popped from front when time to play it comes
var animation_queue = []

#Dictionary with damage queues
var damage_queues = {}

@export var enemy_resource: Resource

@onready var sprite: AnimatedSprite2D = $VBoxContainer/ImageContainer/AnimatedSprite2D
@onready var extra = $ExtraScripts

#Intents
enum {
	ATTACK,
	DEFEND,
	PASS_TURN,
}

#Attack types
enum {
	NORMAL_ATTACK,
	DOUBLE_ATTACK,
	SPECIAL_ATTACK_ONE,
}

var intent
var intent_queue
var attack_type_queue

func init(pos = Vector2(800, 80), e_r = load("res://resources/skeleton_spearman.tres"), i_q = [ATTACK], a_t_q = [DOUBLE_ATTACK, NORMAL_ATTACK]):
	position = pos
	enemy_resource = e_r
	intent_queue = i_q
	attack_type_queue = a_t_q
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.sprite_frames = enemy_resource.sprite_frames_resource
	attack_damage = enemy_resource.attack_damage
	double_attack_damage = enemy_resource.double_attack_damage
	shield_value = enemy_resource.shield_value
	current_health = enemy_resource.health
	max_health = enemy_resource.health
	
	if enemy_resource.extra_script != null:
		extra.set_script(enemy_resource.extra_script)
	$VBoxContainer/ImageContainer/AnimatedSprite2D.position = enemy_resource.sprite_position
	
	$VBoxContainer/Bar/TextureProgress.value = 100
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	sprite.animation = "idle"
	$Intents/AttackIntent.position = enemy_resource.intent_position

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
	animation_queue.append(sprite.animation)
	sprite.animation = "hurt"
	$VBoxContainer/ImageContainer/AnimatedSprite2D/AP.play("hurt_modulation")

#Used with buffered damage var to check if enemy is going to die from upcoming qeued damage.
#This function is used to prevent the player from wasting an attack card on an already dead enemy.
func is_already_dead():
	if current_health + current_shield <= buffered_damage:
		return true
	else:
		return false

#Returns duration to wait to playscape scene
func start_attacking():
	$Intents/AttackIntent/AP.play("fade_out")
	#Wait while attack intent fades out
	await get_tree().create_timer(1.0).timeout
	$Intents/AttackIntent.visible = false
	
	var next_attack_type = get_next_attack_type_and_cycle()
	match next_attack_type:
		DOUBLE_ATTACK:
			await double_attack()
		NORMAL_ATTACK:
			print("Normal attack type")
			await normal_attack()
		SPECIAL_ATTACK_ONE:
			await extra.attack_one(self)
		_:
			await get_tree().create_timer(1).timeout

func normal_attack():
	print("Normal attack started!")
	append_value_to_queue("normal_attack_damage", attack_damage, damage_queues)
	animation_queue.append("normal_attack")
	if sprite.animation == "idle":
		sprite.animation = animation_queue.pop_front()

	var attack_animation_length = get_animation_length("normal_attack")
	print(attack_animation_length)
	#Wait for attack to occur, playscape scene is awaiting this
	await get_tree().create_timer(attack_animation_length+POST_ATTACK_DELAY).timeout

func double_attack():
	print("Double attack started!")
	append_value_to_queue("double_attack_damage", double_attack_damage, damage_queues)
	append_value_to_queue("double_attack_damage", double_attack_damage, damage_queues)
	animation_queue.append("double_attack_1")
	animation_queue.append("double_attack_2")
	if sprite.animation == "idle":
		sprite.animation = animation_queue.pop_front()

	var attack_animation_length = get_animation_length("double_attack_1") + get_animation_length("double_attack_2")
	print(attack_animation_length)
	#Wait for attack to occur, playscape scene is awaiting this
	#await get_tree().create_timer(2.5).timeout
	await get_tree().create_timer(attack_animation_length+POST_ATTACK_DELAY).timeout

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

func reset_animation():
	if sprite.animation == "dead":
		return
	sprite.animation = "idle"
	sprite.play()

func _on_animated_sprite_2d_animation_finished():
	if not alive:
		return
	if has_killed_player:
		sprite.animation = "idle"
		sprite.play()
		for enemy in $'../../Enemies'.get_children():
			enemy.z_index = 3
			enemy.fade_out_bars()
			enemy.hide_all_intent_sprites()
		$'../../'.animate_stuff_when_player_dies()
		return
	
	if sprite.animation == "normal_attack":
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(
			damage_queues["normal_attack_damage"].pop_front()
			)
		if has_killed_player:
			_on_animated_sprite_2d_animation_finished()
			return
		sprite.animation = "idle"
		sprite.play()
	
	elif sprite.animation == "double_attack_1":
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(
			damage_queues["double_attack_damage"].pop_front()
			)
		if has_killed_player:
			_on_animated_sprite_2d_animation_finished()
			return
		sprite.animation = animation_queue.pop_front()
		sprite.play()
		
	elif sprite.animation == "double_attack_2":
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(
			damage_queues["double_attack_damage"].pop_front()
			)
		if has_killed_player:
			_on_animated_sprite_2d_animation_finished()
			return
		sprite.animation = "idle"
		sprite.play()
	
	elif sprite.animation == "special_attack":
		has_killed_player = $'../../Wanderer'.change_health_and_check_if_dead(
			damage_queues["special_attack_damage"].pop_front()
			)
		if has_killed_player:
			_on_animated_sprite_2d_animation_finished()
			return
		sprite.animation = "idle"
		sprite.play()
		
	elif sprite.animation == "defend":
		pass
	elif sprite.animation == "dead":
		pass
	elif sprite.animation == "hurt":
		print("Animation queue after 'hurt' played: " +str(animation_queue))
		sprite.animation = animation_queue.pop_front()
		print("After pop: " +str(animation_queue))
		sprite.play()
	else:
		if animation_queue.size() > 0:
			sprite.animation = animation_queue.pop_front()
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
			set_attack_intent_text()
			$Intents/AttackIntent/AP.play("RESET")
			await get_tree().create_timer(0.05).timeout
			$Intents/AttackIntent.visible = true
			$Intents/AttackIntent/AP.play("fade_in")
			intent = ATTACK
		DEFEND:
			set_defend_intent_text()
			$Intents/DefendIntent/AP.play("RESET")
			await get_tree().create_timer(0.05).timeout
			$Intents/DefendIntent.visible = true
			$Intents/DefendIntent/AP.play("fade_in")
			intent = DEFEND
		PASS_TURN:
			pass

func shift_to_next_intent():
	var temp = intent_queue[0]
	var new_intent = intent_queue.pop_front()
	intent_queue.append(temp)
	set_new_intent(new_intent)

func get_next_attack_type_and_cycle():
	var temp = attack_type_queue[0]
	var next_attack_type = attack_type_queue.pop_front()
	attack_type_queue.append(temp)
	return next_attack_type

func set_attack_intent_text():
	var next_attack_type = attack_type_queue[0]
	match next_attack_type:
		DOUBLE_ATTACK:
			$Intents/AttackIntent/Damage.text = "2x" + str(double_attack_damage)
		NORMAL_ATTACK:
			$Intents/AttackIntent/Damage.text = str(attack_damage)
		SPECIAL_ATTACK_ONE:
			$Intents/AttackIntent/Damage.text = str(extra.attack_damage_one)

func set_defend_intent_text():
	$Intents/DefendIntent/ShieldAmount.text = str(shield_value)

func hide_all_intent_sprites():
	for i in $Intents.get_children():
		i.visible = false
#		if intent.visible:
#			intent.get_node("AP").play("fade_out")
#			await get_tree().create_timer(1.0).timeout
#			intent.visible = false

func fade_out_bars():
	$AnimateBars.play("fade_out")

func set_shield_amount(value):
	$Indicators/Shield/Amount.text = str(value)
	current_shield = value

func append_value_to_queue(name_of_queue: String, value, dict: Dictionary):
	if not name_of_queue in dict:
		dict[name_of_queue] = [value]
		print("Queue with name " + name_of_queue + " created: " + str(dict))
	else:
		print("Before append: " + str(dict))
		dict[name_of_queue].append(value)
		print("After append: " + str(dict))

func get_animation_length(name_anim: String):
	return sprite.sprite_frames.get_frame_count(name_anim)/sprite.sprite_frames.get_animation_speed(name_anim)
