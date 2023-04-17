extends Node2D

const CARD_BASE := preload("res://cards/card_base.tscn")
var player_hand := preload("res://cards/tut_player_hand.gd").new()
var card_selected = []

@onready var centre_card_oval = Vector2(get_viewport().size) * Vector2(0.5, 1.25)
@onready var hor_rad = get_viewport().size.x*0.45
@onready var ver_rad = get_viewport().size.y*0.4
var angle = deg_to_rad(90)-0.5
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
	var new_card = CARD_BASE.instantiate()
	var deck_size = player_hand.card_list.size()
	if (deck_size < 1):
		return
	card_selected = randi() % player_hand.card_list.size()
	new_card.card_name = player_hand.card_list[card_selected]
	new_card.scale *= 0.6
	
	oval_angle_vector = Vector2(-hor_rad*cos(angle), -ver_rad*sin(angle))
	new_card.startpos = $Deck.position -new_card.size/2
	
	print($Deck.position)
	print(new_card.size)
	print(new_card.size/2)
	print($Deck/Draw.size)
	#new_card.position = centre_card_oval + oval_angle_vector - new_card.size/2
	new_card.targetpos = centre_card_oval + oval_angle_vector - new_card.size/2
	#new_card.targetpos = new_card.startpos #tmp
	print(new_card.targetpos)
	
	new_card.startrot = 0
	new_card.targetrot = 2*PI + (angle-deg_to_rad(90))/4
	
	new_card.state = DRAWN_TO_HAND
	
	$Cards.add_child(new_card)
	player_hand.card_list.erase(player_hand.card_list[card_selected])
	angle += 0.25
	
	
	return deck_size -1

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
