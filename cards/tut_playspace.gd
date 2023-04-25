extends Node2D

const CARD_SIZE = Vector2(125,175)*0.6
const CARD_BASE := preload("res://cards/card_base.tscn")
var player_hand := preload("res://cards/tut_player_hand.gd").new()
const card_slot := preload("res://card_slot.tscn")
var card_selected = []
@onready var deck_size = player_hand.card_list.size()
@onready var centre_card_oval = Vector2(get_viewport().size) * Vector2(0.5, 1.32)
@onready var hor_rad = get_viewport().size.x*0.45
@onready var ver_rad = get_viewport().size.y*0.4
var angle = 0
#var card_spread = 0.25/125*CARD_SIZE.x
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

var number_columns = 2 # Per side (4 in total)
var number_rows = 5
var card_slots_per_side = number_columns*number_rows
@onready var view_port_size = get_viewport().size
@onready var outer_x_margin = view_port_size.x/25
@onready var outer_y_margin = view_port_size.y/25
@onready var middle_x_margin = view_port_size.x/10
@onready var card_zone_height = view_port_size.y - (centre_card_oval.y - CARD_SIZE.y - ver_rad)
@onready var card_slot_y_gaps = view_port_size.y/40
@onready var card_slot_x_gaps = view_port_size.x/40
@onready var card_slot_base_width = view_port_size.x/10
@onready var card_slot_total_height = view_port_size.y - outer_y_margin - card_zone_height
@onready var card_slot_total_width = view_port_size.x/2 - outer_x_margin - middle_x_margin/2 - card_slot_base_width
@onready var height_for_card = (card_slot_total_height - (number_rows-1)*card_slot_y_gaps)/number_rows
@onready var width_for_card = (card_slot_total_width - (number_columns-1)*card_slot_x_gaps)/number_columns


func _ready():
	randomize()
	for i in range(2): # Both sets of player
		for j in range(number_columns):
			for k in range(number_rows):
				var new_slot = card_slot.instantiate()
				new_slot.size = Vector2(CARD_SIZE.y, CARD_SIZE.x)
				new_slot.position = Vector2(outer_x_margin + card_slot_base_width, outer_y_margin) + k*Vector2(0, height_for_card + card_slot_y_gaps) \
				+ j*Vector2(card_slot_total_width/number_columns, 0) + i*Vector2(card_slot_total_width + middle_x_margin, 0)
				new_slot.scale *= height_for_card/new_slot.size.y
				$CardSlots.add_child(new_slot)
				card_slot_empty.append(true)
	$Enemies/EnemyLeft.visible = true
	$Enemies/EnemyLeft/VBoxContainer/ImageContainer/Image.flip_h = false
	$Enemies/EnemyLeft.scale *= 0.5
	$Enemies/EnemyLeft.position = Vector2(outer_x_margin + card_slot_base_width/2, card_slot_total_height/2) \
	- $Enemies/EnemyLeft.size*$Enemies/EnemyLeft.scale/2
	$Enemies/EnemyRight.visible = true
	$Enemies/EnemyRight.scale *= 0.5
	$Enemies/EnemyRight.position = Vector2(view_port_size.x - outer_x_margin - card_slot_base_width/2, card_slot_total_height/2) \
	- $Enemies/EnemyRight.size*$Enemies/EnemyRight.scale/2
	
#	var new_slot = card_slot.instantiate()
#	new_slot.position = get_viewport().size*0.4
#	new_slot.size = CARD_SIZE
#	$CardSlots.add_child(new_slot)
#	card_slot_empty.append(true)

func draw_card():
	angle = PI/2 + card_spread*(float(number_cards_hand)/2-number_cards_hand)
	var new_card = CARD_BASE.instantiate()
	card_selected = randi() % deck_size
	new_card.card_name = player_hand.card_list[card_selected]
	new_card.position = deck_position
	new_card.discard_pile = discard_position
	new_card.scale *= CARD_SIZE/new_card.size
	new_card.state = DRAWN_TO_HAND
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
		
		card.targetpos = centre_card_oval + oval_angle_vector - Vector2(0, CARD_SIZE.y)
		card.default_pos = card.targetpos
		card.startrot = card.rotation
		#new_card.targetrot = 2*PI + (angle-deg_to_rad(90))/4
		card.targetrot = (PI/2-angle)/4
		card.card_numb = card_numb
		card_numb += 1
		if card.state == IN_HAND:
			card.setup = true
			card.target_scale = card.orig_scale
			card.state = REORGANIZE_HAND
			card.startpos = card.position
		elif card.state == DRAWN_TO_HAND:
			card.t -= 0.1
			card.startpos = card.targetpos - ((card.targetpos - card.position)/(1-card.t))

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
