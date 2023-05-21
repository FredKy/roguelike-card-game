extends Node
# Spellinfo = [Type, Cost, Name, Effect, Image, Damage, Shield, ]
enum {ICE_CANNON, WARP_TIME, COLD_TOUCH, ENERGY_SHIELD, ZAP, ENERGIZE}

const DATA = {
	COLD_TOUCH:
		["spell", 1, "Cold Touch", "Apply 2 chill\nto an enemy", Rect2(9728,64,256,192), 2 ,0],
	ICE_CANNON:
		["attack", 2, "Ice Cannon", "Deal 11 damage\nto an enemy", Rect2(4864,0,256,192), 11, 0],
	WARP_TIME:
		["spell", 3, "Warp Time", "Target enemy passes\n a turn", Rect2(7424,64,256,192), 0, 0],
	ENERGY_SHIELD:
		["shield", 1, "Energy Shield", "Add 6 to shield", Rect2(1280,64,256,192), 0, 6],
	ZAP:
		["attack", 1, "Zap", "Deal 5 damage", Rect2(6400,0,256,192), 5, 0],
	ENERGIZE:
		["shield", 1, "Energize", "Add 5 to shield and\ndraw one card", Rect2(7680,64,256,192), 0, 5],
	}

func card_data_array_to_dictionary(arr):
	var dict = {}
	dict["type"] = arr[0]
	dict["cost"] = arr[1]
	dict["name"] = arr[2]
	dict["effect_text"] = arr[3]
	dict["region_rect"] = arr[4]
	dict["damage"] = arr[5]
	dict["shield"] = arr[6]
	return dict

#var cards = DATA.duplicate()
#
#func change_card_data_arrays_to_dictionaries():
#	for key in cards.keys():
#		print(key)
#		cards[key] = card_data_array_to_dictionary(cards[key])

#func _ready():
#	change_card_data_arrays_to_dictionaries()
#	for key in cards.keys():
#		print(key)
#		cards[key] = card_data_array_to_dictionary(cards[key])
#const CARDS = {
#	COLD_TOUCH:
#		{"type": "spell", "cost": 1, "name": "Cold Touch", "effect": "Apply 2 chill\nto an enemy", "image_pos": Rect2(9728,64,256,192), "damage": 2, "shield": 0},
#	ICE_CANNON:
#		{"type": "attack", "cost": 2, "name": "Ice Cannon", },
#	}
