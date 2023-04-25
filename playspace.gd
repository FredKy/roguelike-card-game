extends Node2D

const CARD_SIZE = Vector2(174,240)
const CARD_BASE := preload("res://cards/my_card_base.tscn")
var player_hand := preload("res://cards/player_hand.gd").new()
const card_slot := preload("res://card_slot.tscn")
var card_selected = []
@onready var deck_size = player_hand.card_list.size()
@onready var centre_card_oval = Vector2(get_viewport().size) * Vector2(0.5, 1.32)
@onready var hor_rad = get_viewport().size.x*0.45
@onready var ver_rad = get_viewport().size.y*0.4
var angle = 0
#var card_spread = 0.25*CARD_SIZE.x/125
var card_spread = 0.002*CARD_SIZE.x
var number_cards_hand = -1
var card_numb = 0
var oval_angle_vector = Vector2()
@onready var deck_position = $Deck.position
@onready var discard_position = $Discard.position

enum {
	IN_HAND,
	IN_PLAY,
	IN_MOUSE,
	FOCUS_IN_HAND,
	DRAWN_TO_HAND,
	REORGANIZE_HAND,
	MOVE_TO_DISCARD_PILE,
}

var card_slot_empty = []

func _ready():
	randomize()
	#$Enemies/Enemy.visible = true
	$Enemies/Enemy.position = get_viewport().size*0.4 + Vector2(200,-300)
	$Enemies/Enemy.scale *= 0.5
	var new_slot = card_slot.instantiate()
	new_slot.position = get_viewport().size*0.4
	new_slot.size = CARD_SIZE
	$CardSlots.add_child(new_slot)
	card_slot_empty.append(true)

func draw_card():
	angle = PI/2 + card_spread*(float(number_cards_hand)/2-number_cards_hand)
	var new_card = CARD_BASE.instantiate()
	var base = new_card.get_node("MyCardBase")
	card_selected = randi() % deck_size
	base.card_name = player_hand.card_list[card_selected]
	base.position = deck_position
	base.discard_pile = discard_position
	base.scale *= CARD_SIZE/base.size
	base.state = DRAWN_TO_HAND
	card_numb = 0
	$Cards.add_child(new_card)
	player_hand.card_list.erase(player_hand.card_list[card_selected])
	angle += 0.25
	deck_size -= 1
	number_cards_hand += 1
	organize_hand()
	return deck_size

func reparent_card(card_no):
	number_cards_hand -= 1
	card_numb = 0
	var card = $Cards.get_child(card_no)
	$Cards.remove_child(card)
	$CardsInPlay.add_child(card)
	organize_hand()

func organize_hand():
	for card in $Cards.get_children(): # reorganize hand
		angle = PI/2 + card_spread*(float(number_cards_hand)/2-card_numb)
		oval_angle_vector = Vector2(hor_rad*cos(angle), -ver_rad*sin(angle))
		var base = card.get_node("MyCardBase")
		base.targetpos = centre_card_oval + oval_angle_vector - Vector2(0, CARD_SIZE.y)
		base.default_pos = base.targetpos
		base.startrot = base.rotation
		#new_card.targetrot = 2*PI + (angle-deg_to_rad(90))/4
		base.targetrot = (PI/2-angle)/4
		base.card_numb = card_numb
		card_numb += 1
		if base.state == IN_HAND:
			base.setup = true
			base.state = REORGANIZE_HAND
		elif base.state == DRAWN_TO_HAND:
			base.t -= 0.1
			base.startpos = base.targetpos - ((base.targetpos - base.position)/(1-base.t))

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
