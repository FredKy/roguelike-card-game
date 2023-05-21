extends Node

var attack_damage_one = 25

func attack_one(enemy):
	print("Special attack started!")
	enemy.append_value_to_queue("special_attack_damage", attack_damage_one, enemy.damage_queues)
	enemy.animation_queue.append("special_attack")
	if enemy.sprite.animation == "idle":
		enemy.sprite.animation = enemy.animation_queue.pop_front()

	var attack_animation_length = enemy.get_animation_length("special_attack")
	print(attack_animation_length)
	#Wait for attack to occur, playscape scene is awaiting this
	await get_tree().create_timer(attack_animation_length+enemy.POST_ATTACK_DELAY).timeout
