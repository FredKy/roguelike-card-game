extends Node2D

@onready var game_state = get_node("/root/GameState")
const CARD_SIZE = Vector2(174,240)
const CARD_BASE := preload("res://cards/my_card_base.tscn")
const DRAFT_CARD_BASE := preload("res://cards/draft_card_base.tscn")
const GAME_OVER_BG := preload("res://game_over_bg.tscn")
const ENEMY := preload("res://enemy.tscn")
#var player_deck := preload("res://scripts/player_deck.gd").new()
var player_deck = []
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
	IN_MOUSE,
	FOCUS_IN_HAND,
	DRAWN_TO_HAND,
	REORGANIZE_HAND,
	MOVE_TO_DISCARD_PILE,
	IN_DISCARD_PILE,
	MOVE_TO_DECK,
	NOTHING,
}

#Enemy intent
enum {
	ATTACK,
	DEFEND,
}

#Attack types
enum {
	NORMAL_ATTACK,
	DOUBLE_ATTACK,
}

#Battle type
enum {
	SKELETON_WARRIOR,
	SKELETON_SPEARMAN,
	WARRIOR_AND_SPEARMAN,
}

#Backgrounds
enum {
	SUMMER_FOREST,
	WINTER_FOREST,
}

#var battle_type = WARRIOR_AND_SPEARMAN
var battle_type = WARRIOR_AND_SPEARMAN

var player_turn = true
var a_card_is_in_mouse = false
var is_dealing_cards = false
var player_alive = true

func _process(_delta):
	$DeckCounter.set_label_text(player_deck.size())
	$DiscardCounter.set_label_text($DiscardedCards.get_child_count())

func update_global_deck_counter():
	$TopBar/Deck/GlobalDeckCounter.set_label_text(game_state.global_player_deck.size())

func _ready():
	set_background_texture(game_state.global_next_background)
	battle_type = game_state.global_next_battle_type
	player_deck = game_state.global_player_deck.duplicate()
	update_global_deck_counter()
	$DeckCounter.set_label_text(player_deck.size())
	randomize()
	$EndTurnButtonNode.visible = false
	
	#create_random_draftable_cards()
	
	match battle_type:
		SKELETON_WARRIOR:
			$Enemies.add_child(ENEMY.instantiate().init(Vector2(760, 80), load("res://resources/skeleton_warrior.tres"), [ATTACK, DEFEND]))
		SKELETON_SPEARMAN:
			$Enemies.add_child(ENEMY.instantiate().init(Vector2(760, 80), load("res://resources/skeleton_spearman.tres"), [ATTACK, ATTACK, DEFEND], [NORMAL_ATTACK, DOUBLE_ATTACK]))
		WARRIOR_AND_SPEARMAN:
			$Enemies.add_child(ENEMY.instantiate().init(Vector2(550, 80), load("res://resources/skeleton_warrior.tres")))
			$Enemies.add_child(ENEMY.instantiate().init(Vector2(800, 80), load("res://resources/skeleton_spearman.tres"), [ATTACK, ATTACK, DEFEND], [NORMAL_ATTACK, DOUBLE_ATTACK]))
			
	
	#$Enemies/Enemy/VBoxContainer/ImageContainer/AnimatedSprite2D.play()
	$Wanderer.visible = true
	#$Wanderer.position = Vector2(100, 80)
	#$Wanderer.scale *= 0.4
	$Wanderer/VBoxContainer/ImageContainer/AnimatedSprite2D.play()
	$TurnMessage.modulate = Color(1,1,1,0)
	show_turn_message("BATTLE!")
	await get_tree().create_timer(1.5).timeout
	show_turn_message("Player turn")
	start_player_turn()
	#$EndTurnButtonNode.visible = true

func draw_card():
	angle = PI/2 + card_spread*(float(number_cards_hand)/2-number_cards_hand)
	#var deck_size = player_deck.card_list.size()
	var deck_size = player_deck.size()
	if deck_size == 0:
		reshuffle_x_cards(
			$DiscardedCards.get_child_count(),
			0.5/float($DiscardedCards.get_child_count())
		)
		await get_tree().create_timer(0.51).timeout
	
	#deck_size = player_deck.card_list.size()
	deck_size = player_deck.size()
	var new_card = CARD_BASE.instantiate()
	var base = new_card.get_node("MyCardBase")
	card_selected = randi() % deck_size
	#base.card_name = player_deck.card_list[card_selected]
	base.card_name = player_deck[card_selected]
	base.position = deck_position
	base.discard_pile = discard_position
	base.scale *= CARD_SIZE/base.size
	base.state = DRAWN_TO_HAND
	card_numb = 0
	base.set_focus_disabled()
	$Cards.add_child(new_card)
	#player_deck.card_list.erase(player_deck.card_list[card_selected])
	player_deck.erase(player_deck[card_selected])
	angle += 0.05
	deck_size -= 1
	number_cards_hand += 1
	organize_hand()
	if deck_size == 0:
		$Deck/DeckDraw.disabled = true
	#return deck_size
	update_energy_and_cards_playability(0)

func draw_x_cards(x, delay):
	is_dealing_cards = true
	await get_tree().create_timer(0.5).timeout
	for i in range(x):
		draw_card()
		#print(player_deck.card_list)
		await get_tree().create_timer(delay).timeout
	await get_tree().create_timer(0.5).timeout
	is_dealing_cards = false
	

func reshuffle_card():
	var discarded_cards = $DiscardedCards.get_children()
	if discarded_cards.size() > 0:
		
		var top_card = discarded_cards[discarded_cards.size()-1]
		reparent_discarded_card_to_reshuffled(top_card)
		var base = top_card.get_node("MyCardBase")
		#print($DiscardedCards.get_children())
		#print($DiscardedCards.get_child_count())
		#base.setup = true
		base.state = MOVE_TO_DECK

func reshuffle_x_cards(x, delay):
	#print("x: " + str(x))
	for i in range(x):
		reshuffle_card()
		#print(player_deck.card_list)
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
		#print(centre_card_oval)
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

func reset_energy_and_cards_playability():
	$Energy.reset_energy()
	for card in $Cards.get_children():
		var base = card.get_node("MyCardBase")
		if base.get_card_cost() > $Energy.energy:
			base.set_enabled(false)
		else:
			base.set_enabled(true)

func move_one_card_from_hand_to_discard():
	var cards = $Cards.get_children()
	if cards.size() > 0:
		var first_card = cards[cards.size()-1]
		var base = first_card.get_node("MyCardBase")
		#print($DiscardedCards.get_child_count())
		base.setup = true
		base.moving_to_discard = true
		base.state = MOVE_TO_DISCARD_PILE

func move_cards_from_hand_to_discard(time):
	var cards_count = $Cards.get_child_count() 
	var delay = time / float(cards_count)
	#print("Delay: " + str(delay))
	for i in range(cards_count):
		move_one_card_from_hand_to_discard()
		await get_tree().create_timer(delay).timeout

func end_player_turn():
	#var test_var = $EndTurnButtonNode
	#$EndTurnButtonNode.visible = false
	$EndTurnButtonNode/EndTurnButton.disabled = true
	#$EndTurnButtonNode/EndTurnButton.text = "Enemy turn"
	move_cards_from_hand_to_discard(0.5)
	#await get_tree().create_timer(1.5).timeout
	show_turn_message("Enemy turn")
	await get_tree().create_timer(1).timeout
	start_enemy_turn()

func start_enemy_turn():
	if not some_enemy_is_alive():
		print("You win!")
		return
	for enemy in $Enemies.get_children():
		enemy.reset_shield()
		enemy.reset_animation()
	player_alive = await run_through_enemies_actions()
	end_enemy_turn()

func end_enemy_turn():
	if player_alive:
		show_turn_message("Player turn")
		await get_tree().create_timer(1).timeout
		start_player_turn()
	else:
		print("Game over man")

func some_enemy_is_alive():
	for enemy in $Enemies.get_children():
		print(enemy.alive)
		if enemy.alive:
			return true
	return false

#Performs enemy actions but stops and returns false if the player is killed, true if player survives enemy onslaught.
func run_through_enemies_actions():
	for enemy in $Enemies.get_children():
		#Check so the enemy doesn't return from the dead!
		if not enemy.alive:
			continue
		await get_tree().create_timer(1.0).timeout
		if enemy.intent == ATTACK:
			await enemy.start_attacking()
			#await get_tree().create_timer(duration_of_attack).timeout
			print("Attack done")
			if enemy.has_killed_player:
				return false
		elif enemy.intent == DEFEND:
			enemy.start_defending()
			print("Defending")
			await get_tree().create_timer(1.5).timeout
		enemy.shift_to_next_intent()
	return true

func start_player_turn():
	$EndTurnButtonNode/EndTurnButton.text = "End turn"
	$EndTurnButtonNode.visible = true
	$EndTurnButtonNode/EndTurnButton.disabled = true
	$Wanderer.reset_shield()
	reset_energy_and_cards_playability()
	draw_x_cards(4,0.2)
	await get_tree().create_timer(4*0.2+0.5+0.51+0.5).timeout
	
	$EndTurnButtonNode/EndTurnButton.disabled = false

func show_turn_message(txt):
	$TurnMessage.text = txt
	$TurnMessage/TurnMessageAP.play("show_message")

func show_game_over_bg():
	var instance = GAME_OVER_BG.instantiate()
	add_child(instance)

func animate_stuff_when_player_dies():
	$Wanderer.z_index = 3
	show_game_over_bg()
	$AnimationPlayer.play("fade_out_stuff")
	for card in $DiscardedCards.get_children():
		var base = card.get_node("MyCardBase")
		base.fade_out()

func do_stuff_when_all_enemies_are_dead():
	await move_cards_from_hand_to_discard(0.5)
	#$'../../EndTurnButtonNode'.visible = false
	$EndTurnButtonNode/EndTurnButton.disabled = true
	$AnimationPlayer.play("fade_out_stuff")
	for card in $DiscardedCards.get_children():
		var base = card.get_node("MyCardBase")
		base.fade_out()
	do_stuff_when_player_has_won()

func do_stuff_when_player_has_won():
	game_state.global_player_current_health = $Wanderer.current_health
	await get_tree().create_timer(1.7).timeout
	create_random_draftable_cards()
	$DraftScene.visible = true
	$Skip/SkipAP.play("fade_in")

func create_draftable_card(c_name, pos):
	var draft_card = DRAFT_CARD_BASE.instantiate()
	var base = draft_card.get_node("MyDraftBase")
	#base.card_name = player_deck.card_list[card_selected]
	base.card_name = c_name
	base.position = pos
	base.scale *= CARD_SIZE/base.size #Equivalent of 0.6
	#base.set_focus(true)
	$Draftables.add_child(draft_card)
	#add_child(draft_card_base)

func create_random_draftable_cards():
	create_draftable_card("ice_cannon", Vector2(220, 120))
	create_draftable_card("energy_shield", Vector2(431, 120))
	create_draftable_card("ice_cannon", Vector2(642, 120))

func set_background_texture(background):
	match background:
		SUMMER_FOREST:
			$Background.texture = load("res://assets/images/bg/Paralax/battleback1-2.png")
		WINTER_FOREST:
			$Background.texture = load("res://assets/images/bg/battleback2.png")
		_:
			$Background.texture = load("res://assets/images/bg/battleback5.png")
