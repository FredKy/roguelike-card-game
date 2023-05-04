extends Node2D

const CARD_SIZE = Vector2(174,240)
const CARD_BASE := preload("res://cards/my_card_base.tscn")
var player_deck := preload("res://cards/player_deck.gd").new()
var card_selected = []
#@onready var deck_size = player_deck.card_list.size()
#@onready var centre_card_oval = Vector2(get_viewport().size) * Vector2(0.5, 1.32)
@onready var centre_card_oval = Vector2(431, 830)
@onready var hor_rad = 800
@onready var ver_rad = 648*0.4
var angle = 0
#var card_spread = 0.25*CARD_SIZE.x/125
var card_spread = 0.1
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
	IN_DISCARD_PILE,
	MOVE_TO_DECK,
}

var card_slot_empty = []

var player_turn = true

func _ready():
	randomize()
	$Enemies/Enemy.visible = true
	$Enemies/Enemy.position = Vector2(760, 80)
	$Enemies/Enemy.scale *= 0.5
	$Enemies/Enemy/VBoxContainer/ImageContainer/AnimatedSprite2D.play()
	$Wanderer.visible = true
	$Wanderer.position = Vector2(100, 80)
	$Wanderer.scale *= 0.5
	$Wanderer/VBoxContainer/ImageContainer/AnimatedSprite2D.play()
	draw_x_cards(6, 0.2)

func draw_card():
	angle = PI/2 + card_spread*(float(number_cards_hand)/2-number_cards_hand)
	var new_card = CARD_BASE.instantiate()
	var base = new_card.get_node("MyCardBase")
	var deck_size = player_deck.card_list.size()
	card_selected = randi() % deck_size
	base.card_name = player_deck.card_list[card_selected]
	base.position = deck_position
	base.discard_pile = discard_position
	base.scale *= CARD_SIZE/base.size
	base.state = DRAWN_TO_HAND
	card_numb = 0
	$Cards.add_child(new_card)
	player_deck.card_list.erase(player_deck.card_list[card_selected])
	angle += 0.05
	deck_size -= 1
	number_cards_hand += 1
	organize_hand()
	if deck_size == 0:
		$Deck/DeckDraw.disabled = true
	#return deck_size
	update_energy_and_cards_playability(0)

func draw_x_cards(x, delay):
	await get_tree().create_timer(0.5).timeout
	for i in range(x):
		draw_card()
		print(player_deck.card_list)
		await get_tree().create_timer(delay).timeout
	

func reshuffle_card():
	var discarded_cards = $DiscardedCards.get_children()
	if discarded_cards.size() > 0:
		
		var top_card = discarded_cards[discarded_cards.size()-1]
		reparent_discarded_card_to_reshuffled(top_card)
		var base = top_card.get_node("MyCardBase")
		#print($DiscardedCards.get_children())
		print($DiscardedCards.get_child_count())
		#base.setup = true
		base.state = MOVE_TO_DECK

func reshuffle_x_cards(x, delay):
	print("x: " + str(x))
	for i in range(x):
		reshuffle_card()
		print(player_deck.card_list)
		await get_tree().create_timer(delay).timeout

func reparent_discarded_card_to_reshuffled(card):
	$DiscardedCards.remove_child(card)
	$CardsReshuffled.add_child(card)

func remove_card_from_reshuffled():
	var card = $CardsReshuffled.get_child(0)
	$CardsReshuffled.remove_child(card)

#func remove_card_from_discard_pile():
#	var card = $DiscardedCards.get_child($DiscardedCards.get_child_count()-1)
#	$DiscardedCards.remove_child(card)

#func reparent_card(card_no):
#	number_cards_hand -= 1
#	card_numb = 0
#	var card = $Cards.get_child(card_no)
#	$Cards.remove_child(card)
#	$CardsInPlay.add_child(card)
#	organize_hand()

func reparent_to_discarded_cards(card_no):
	number_cards_hand -= 1
	card_numb = 0
	var card = $Cards.get_child(card_no)
	$Cards.remove_child(card)
	$DiscardedCards.add_child(card)
	organize_hand()


func organize_hand():
	for card in $Cards.get_children(): # reorganize hand
		angle = PI/2 + card_spread*(float(number_cards_hand)/2-card_numb)
		oval_angle_vector = Vector2(hor_rad*cos(angle), -ver_rad*sin(angle))
		var base = card.get_node("MyCardBase")
		print(centre_card_oval)
		base.targetpos = centre_card_oval + oval_angle_vector - Vector2(0, CARD_SIZE.y)
		base.default_pos = base.targetpos
		base.startrot = base.rotation
		#new_card.targetrot = 2*PI + (angle-deg_to_rad(90))/4
		base.targetrot = (PI/2-angle)/4
		base.card_numb = card_numb
		card_numb += 1
		if base.state == IN_HAND:
			base.setup = true
#			base.target_scale = base.orig_scale
			base.state = REORGANIZE_HAND
#			base.startpos = position
		elif base.state == DRAWN_TO_HAND:
			base.t -= 0.1
			base.startpos = base.targetpos - ((base.targetpos - base.position)/(1-base.t))

func update_energy_and_cards_playability(n):
	$Energy.reduce_energy(n)
	
	for card in $Cards.get_children():
		var base = card.get_node("MyCardBase")
#		print(base)
#		print("Cost: " + str(base.get_card_cost()))
#		print("Energy: " + str($Energy.energy))
		if base.get_card_cost() > $Energy.energy:
			#print(base.card_name)
			#base.set_focus(false)
			base.set_enabled(false)
		else:
			base.set_enabled(true)

func move_one_card_from_hand_to_discard():
	var cards = $Cards.get_children()
	if cards.size() > 0:
		var first_card = cards[cards.size()-1]
		var base = first_card.get_node("MyCardBase")
		print($DiscardedCards.get_child_count())
		base.setup = true
		base.moving_to_discard = true
		base.state = MOVE_TO_DISCARD_PILE

#func reshuffle_x_cards(x, delay):
#	print("x: " + str(x))
#	for i in range(x):
#		reshuffle_card()
#		print(player_deck.card_list)
#		await get_tree().create_timer(delay).timeout

func move_cards_from_hand_to_discard(time):
	var cards_count = $Cards.get_child_count() 
	var delay = time / float(cards_count)
	print("Delay: " + str(delay))
	for i in range(cards_count):
		move_one_card_from_hand_to_discard()
		await get_tree().create_timer(delay).timeout

func end_turn():
	$EndTurnButtonNode.visible = false
	move_cards_from_hand_to_discard(0.5)
	

#func _input(event):
#	if Input.is_action_just_released("leftclick"):
#		var new_card = CARD_BASE.instantiate()
#		var deck_size = player_deck.card_list.size()
#		if (deck_size < 1):
#			return
#		card_selected = randi() % player_deck.card_list.size()
#		new_card.card_name = player_deck.card_list[card_selected]
#		new_card.position = get_global_mouse_position()
#		new_card.scale *= 0.6
#		$Cards.add_child(new_card)
#		player_deck.card_list.erase(player_deck.card_list[card_selected])
