extends MarginContainer

#@onready var util = get_node("/root/UtilityFunctions")
@onready var game_state = get_node("/root/GameState")
var current_health = 4.0
var max_health = 4.0
var current_shield = 0.0
var max_shield = 100.0
var alive = true

#Array to store all upcoming animations, animation is popped from front when time to play it comes
var animation_queue = []

#Targeted enemies references
var target_queue = []

#Dictionary for storing damage queues for every distinct attack card
var dictionary_of_queues = {}

#Shield number queue
var shield_number_queue = []

@onready var sprite: AnimatedSprite2D = $VBoxContainer/ImageContainer/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	max_health = game_state.global_player_max_health
	current_health = game_state.global_player_current_health
	#$VBoxContainer/ImageContainer/Image.scale.x *= -1
	#$VBoxContainer/ImageContainer/Image.scale *= $VBoxContainer/ImageContainer.get_minimum_size()/$VBoxContainer/ImageContainer/Image.texture.size
	#$VBoxContainer/ImageContainer/AnimatedSprite2D.scale *= 4
	$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
	$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
	$VBoxContainer/ShieldBar/TextureProgress.value = 0
	$VBoxContainer/ShieldBar/TextureProgress.value = 100*current_shield/max_shield
	$VBoxContainer/EnergyShield/ColorRect.scale = Vector2(0,0)
	$VBoxContainer/EnergyShield/ColorRect.visible = true
	
	sprite.animation = "idle"


func change_health_and_check_if_dead(damage_number):
	play_hurt()
	if damage_number > current_shield:
		damage_number -= current_shield
		current_shield = 0
		$AnimationPlayer.stop()
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
		current_health = 0
		$VBoxContainer/Bar/TextureProgress.value = 100*current_health/max_health
		$VBoxContainer/Bar/Count/Background/Number.text = str(current_health)
		play_death_animation_and_die()
		return true
	return false

func add_shield(shield_number):
	current_shield += shield_number
	$VBoxContainer/ShieldBar/TextureProgress.value = min(100*current_shield/max_shield, 100)
	$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)

func play_death_animation_and_die():
	sprite.animation = "dead"
	$AnimateBars.play("fade_out")
	alive = false

func play_hurt():
	sprite.animation = "hurt"

func trigger_attack(card_data: Dictionary):
	var card_name = card_data["name"]
	match card_name:
		"Ice Cannon":
			ice_cannon(card_data["damage"])
		"Zap":
			zap(card_data["damage"])
		"Meteor Shower":
			meteor_shower(card_data["damage"])
		"Freezing Arrow":
			freezing_arrow(card_data["damage"])
	if sprite.animation == "idle":
		sprite.animation = animation_queue.pop_front()

func ice_cannon(attack_number):
	append_value_to_queue("ice_cannon_damage", attack_number, dictionary_of_queues)
	animation_queue.append("ice_cannon")
	
func zap(attack_number):
	append_value_to_queue("zap_damage", attack_number, dictionary_of_queues)
	animation_queue.append("zap")

func meteor_shower(attack_number):
	append_value_to_queue("meteor_shower_damage", attack_number, dictionary_of_queues)
	animation_queue.append("meteor_shower")

func freezing_arrow(attack_number):
	append_value_to_queue("freezing_arrow_damage", attack_number, dictionary_of_queues)
	animation_queue.append("freezing_arrow")

func trigger_shield(card_data: Dictionary):
	match card_data["name"]:
		"Energy Shield":
			energy_shield(card_data["shield"])
		"Energize":
			energize(card_data["shield"])
		"Ice Barrier":
			ice_barrier(card_data["shield"])
	if sprite.animation == "idle":
		sprite.animation = animation_queue.pop_front()

func energy_shield(shield_number):
	shield_number_queue.append(shield_number)
	animation_queue.append("shield")

func ice_barrier(shield_number):
	shield_number_queue.append(shield_number)
	animation_queue.append("shield")

func energize(shield_number):
	animation_queue.append("energize")
	shield_number_queue.append(shield_number)

func reset_shield():
	current_shield = 0
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.stop()
	$VBoxContainer/ShieldBar/TextureProgress.value = min(100*current_shield/max_shield, 100)
	$VBoxContainer/ShieldBar/Count/Background/Number.text = str(current_shield)

func play_highlight():
	$AnimationPlayer2.play("highlight_wanderer")

func stop_highlight():
	$AnimationPlayer2.stop(false)

func _on_animated_sprite_2d_animation_finished():
	if not alive:
		return
	if shield_number_queue.size() > 0:
		if sprite.animation  == "shield" or sprite.animation == "ice_barrier":
			if current_shield == 0:
				$AnimationPlayer.play("create_shield")
			add_shield(shield_number_queue.pop_front())
		elif sprite.animation  == "energize":
			if current_shield == 0:
				$AnimationPlayer.play("create_shield")
			add_shield(shield_number_queue.pop_front())
			$'../'.draw_x_cards(1,0.2)
	if target_queue.size() > 0:
		if sprite.animation == "ice_cannon":
			var enemy = target_queue.pop_front()
			enemy.change_health_and_check_if_dead(dictionary_of_queues["ice_cannon_damage"].pop_front())
		elif sprite.animation == "zap":
			var enemy = target_queue.pop_front()
			enemy.change_health_and_check_if_dead(dictionary_of_queues["zap_damage"].pop_front())
		elif sprite.animation == "meteor_shower":
			var enemy = target_queue.pop_front()
			enemy.change_health_and_check_if_dead(dictionary_of_queues["meteor_shower_damage"].pop_front())
		elif sprite.animation == "freezing_arrow":
			var enemy = target_queue.pop_front()
			enemy.change_health_and_check_if_dead(dictionary_of_queues["freezing_arrow_damage"].pop_front())
			$'../'.draw_x_cards(1,0.2)
	
	if animation_queue.size() > 0:
		sprite.animation = animation_queue.pop_front()
	else:
		sprite.animation = "idle"
	
	sprite.play()

func append_value_to_queue(name_of_queue: String, value, dict):
	if not name_of_queue in dict:
		dict[name_of_queue] = [value]
		print("Queue with name " + name_of_queue + " created: " + str(dict))
	else:
		print("Before append: " + str(dict))
		dict[name_of_queue].append(value)
		print("After append: " + str(dict))
