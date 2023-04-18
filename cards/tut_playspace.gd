extends Node2D

const CARD_SIZE = Vector2(125,175)
const CARD_BASE := preload("res://cards/card_base.tscn")
var player_hand := preload("res://cards/tut_player_hand.gd").new()
var card_selected = []

@onready var centre_card_oval = Vector2(get_viewport().size) * Vector2(0.5, 1.25)
@onready var hor_rad = get_viewport().size.x*0.45
@onready var ver_rad = get_viewport().size.y*0.4
var angle = 0
var card_spread = 0.25
var number_cards_hand = 0
var card_numb = 0
var oval_angle_vector = Vector2()

enum {
	IN_HAND,
	IN_PLAY,
	IN_MOUSE,
	FOCUS_IN_HAND,
	DRAWN_TO_HAND,
	REORGANIZE_HAND,
}

func draw_card():
	angle = PI/2 + card_spread*(float(number_cards_hand)/2-number_cards_hand)
	var new_card = CARD_BASE.instantiate()
	var deck_size = player_hand.card_list.size()
	if (deck_size < 1):
		return
	card_selected = randi() % deck_size
	new_card.card_name = player_hand.card_list[card_selected]
	
	
	oval_angle_vector = Vector2(hor_rad*cos(angle), -ver_rad*sin(angle))
	new_card.startpos = $Deck.position -CARD_SIZE/2
	new_card.targetpos = centre_card_oval + oval_angle_vector - CARD_SIZE
	new_card.default_pos = new_card.targetpos
	new_card.startrot = 0
	#new_card.targetrot = 2*PI + -(angle-deg_to_rad(90))/4
	new_card.targetrot = (PI/2-angle)/4
	new_card.scale *= CARD_SIZE/new_card.size
	new_card.state = DRAWN_TO_HAND
	new_card.card_numb = number_cards_hand
	card_numb = 0
	for card in $Cards.get_children(): # reorganize hand
		angle = PI/2 + card_spread*(float(number_cards_hand)/2-card_numb)
		oval_angle_vector = Vector2(hor_rad*cos(angle), -ver_rad*sin(angle))
		
		card.targetpos = centre_card_oval + oval_angle_vector - CARD_SIZE
		card.default_pos = card.targetpos
		card.startrot = card.rotation
		#new_card.targetrot = 2*PI + (angle-deg_to_rad(90))/4
		card.targetrot = (PI/2-angle)/4
		card.card_numb = card_numb
		card_numb += 1
		if card.state == IN_HAND:
			card.startpos = card.position
			card.state = REORGANIZE_HAND
		elif card.state == DRAWN_TO_HAND:
			card.startpos = card.targetpos - ((card.targetpos - card.position)/(1-card.t))
		
	$Cards.add_child(new_card)
	player_hand.card_list.erase(player_hand.card_list[card_selected])
	angle += 0.25
	deck_size -= 1
	number_cards_hand += 1
	#card_numb += 1
	
	return deck_size

#func _input(event):
#	if Input.is_action_just_released("leftclick"):
#		var new_card = CARD_BASE.instantiate()
#		var deck_size = player_hand.card_list.size()
#		if (deck_size < 1):
#			return
#		card_selected = randi() % player_hand.card_list.size()
#		new_card.card_name = player_hand.card_list[card_selected]
#		new_card.position = get_global_mouse_position()
#		new_card.scale *= 0.6
#		$Cards.add_child(new_card)
#		player_hand.card_list.erase(player_hand.card_list[card_selected])
