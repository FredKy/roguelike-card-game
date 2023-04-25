extends MarginContainer

# Declare member variables here.
@onready var card_database = preload("res://assets/cards/cards_database.gd").new()
var card_name = 'mentor'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]
@onready var card_img = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var t = 0
@onready var orig_scale = scale
const DRAWTIME = 0.5
const ORGANIZETIME = 0.25
const ZOOMTIME = 0.2
const IN_MOUSE_TIME = 0.1
var tween
var tween2

var setup = true
var start_scale = Vector2()
var default_pos = Vector2()
var zoom_scale = 2
var reorganize_neighbors = true
var number_cards_hand_minus_one = 0
var card_numb = 0
var neighbor_card
var move_neighbor_card_check = false
var zooming_in = true
var old_state = INF
var card_select = true
var moving_into_play = false
var target_scale = Vector2()
var discard_pile = Vector2()
var moving_to_discard = false

@onready var card_slots = $'../../../CardSlots'
@onready var card_slot_empty = $'../../../'.card_slot_empty
var card_slot_pos = Vector2()
var card_slot_size = Vector2()
var mouse_pos = Vector2()
var left_hand_side = false
var card_in_play = false
var zoom_scale_in_play = 1.2
var old_pos = Vector2()
var old_scale = Vector2()
var reparent = true # Wether or not card can be reparented



enum {
	IN_HAND,
	IN_PLAY,
	IN_MOUSE,
	FOCUS_IN_HAND,
	DRAWN_TO_HAND,
	REORGANIZE_HAND,
	MOVE_TO_DISCARD_PILE,
}
var state = IN_HAND
# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_img)
	$Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(card_img)
	$Card.scale *= size/$Card.texture.get_size()
	$CardBack.scale *= size/$CardBack.texture.get_size()
	$Focus.scale *= size/$Focus.size
	
	var attack = str(card_info[1])
	var retalition = str(card_info[2])
	var health = str(card_info[3])
	var cost = str(card_info[4])
	var special_text = str(card_info[6])
	$Bars/TopBar/Name/CenterContainer/Name.text = card_name.capitalize()
	$Bars/TopBar/Cost/CenterContainer/Cost.text = cost
	$Bars/SpecialText/Name/CenterContainer/Type.text = special_text
	$Bars/BottomBar/Health/CenterContainer/Health.text = health
	$Bars/BottomBar/Attack/CenterContainer/AR.text = str(attack,'/',retalition)
	

func _input(event):
	if event.is_action_pressed("leftclick"): # Pick up card
		if state == FOCUS_IN_HAND:
			if card_select:
				#old_state = state
				state = IN_MOUSE
				#$'../'.z_index += 2
				setup = true
				card_select = false
	if event.is_action_released("leftclick"):
		if not card_select:
			#$'../'.z_index -= 2
			if old_state == IN_HAND or old_state == REORGANIZE_HAND: # Putting a card into a slot.
				for i in range(card_slots.get_child_count()):
					
					if card_slot_empty[i]:
						card_slot_pos = card_slots.get_child(i).position
						card_slot_size = card_slots.get_child(i).size*card_slots.get_child(i).scale
						mouse_pos = get_global_mouse_position()
						if mouse_pos.x < card_slot_pos.x + card_slot_size.x and mouse_pos.x > card_slot_pos.x \
						and mouse_pos.y < card_slot_pos.y + card_slot_size.y and mouse_pos.y > card_slot_pos.y:
							card_slot_empty[i] = false
							setup = true
							moving_into_play = true
							if i < $'../../../'.card_slots_per_side:
								left_hand_side = true
								targetrot = PI/2
								targetpos = card_slot_pos + Vector2(card_slot_size.x,0)
							else:
								targetrot = -PI/2
								targetpos = card_slot_pos + Vector2(0, card_slot_size.y)
#									targetpos = card_slot_pos-$'../../../'.CARD_SIZE/2
							target_scale = Vector2(card_slot_size.y, card_slot_size.x)/size
							state = IN_PLAY
							card_select = true
							card_in_play = true
							break
				if state != IN_PLAY:
					setup = true
					targetpos = default_pos
					target_scale = orig_scale
					state = REORGANIZE_HAND
					card_select = true
			else: # Handle everything once the card is in play.
				var enemies = $'../../../Enemies'
				for i in range(enemies.get_child_count()):
					var enemy_pos = enemies.get_child(i).position
					var enemy_size = enemies.get_child(i).size*enemies.get_child(i).scale
					var mouse_pos = get_global_mouse_position()
					if mouse_pos.x < enemy_pos.x + enemy_size.x and mouse_pos.x > enemy_pos.x \
						and mouse_pos.y < enemy_pos.y + enemy_size.y and mouse_pos.y > enemy_pos.y:
							# Deal with damage
							var attack_number = int($Bars/BottomBar/Attack/CenterContainer/AR.text.split('/')[0])
							enemies.get_child(i).change_health(attack_number)
							setup = true
							moving_to_discard = true
							targetpos = discard_pile
							state = MOVE_TO_DISCARD_PILE
#									moving_into_play = true
#									state = IN_PLAY
							card_select = true
							break
				if not card_select:
					setup = true
					moving_into_play = true
					state = IN_PLAY
					card_select = true
					if card_in_play:
						targetpos = old_pos
						target_scale = old_scale

func move_card(delta, state, time_scale, targetpos, target_scale, targetrot):
	var finished = false
	if setup:
		reset_pos_rot_scale_and_time()
		if state == IN_PLAY:
			if reparent:
				$'../../../'.reparent_card(card_numb)
				reparent = false
		elif state == FOCUS_IN_HAND:
			if not card_in_play:
				if reorganize_neighbors:
					reorganize_neighbors = false
					number_cards_hand_minus_one = $'../../../'.number_cards_hand
					if card_numb -1 >= 0:
						move_neighbor_card(card_numb -1, true, 1) # true is left
					if card_numb -2 >= 0:
						move_neighbor_card(card_numb -2, true, 0.25)
					if card_numb + 1 <= number_cards_hand_minus_one:
						move_neighbor_card(card_numb +1, false, 1)
					if card_numb + 2 <= number_cards_hand_minus_one:
						move_neighbor_card(card_numb +2, false, 0.25)
		elif state == REORGANIZE_HAND:
			if move_neighbor_card_check:
				move_neighbor_card_check = false
	if t <= 1:
		if state == REORGANIZE_HAND and !card_in_play:
			if not reorganize_neighbors:
				reorganize_neighbors = true
				if card_numb -1 >= 0:
					reset_card(card_numb -1)
				if card_numb -2 >= 0:
					reset_card(card_numb -2)
				if card_numb + 1 <= number_cards_hand_minus_one:
					reset_card(card_numb +1)
				if card_numb + 2 <= number_cards_hand_minus_one:
					reset_card(card_numb +2)
		if state == DRAWN_TO_HAND:
			if !tween:
				tween = create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.set_trans(Tween.TRANS_CUBIC)
				#tween.interpolate_value(startpos, targetpos-startpos,DRAWTIME,1,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
				tween.tween_property(self, "position", targetpos, DRAWTIME)
				tween.parallel().tween_property(self, "rotation", 2*PI+targetrot, DRAWTIME)
			if t < 0.5:
				scale.x = orig_scale.x*abs(2*(2*t)-1)
			else:
				scale.x = orig_scale.x
			if $CardBack.visible:
				if t >= 0.25:
					$CardBack.visible = false
		else:
			position = startpos.lerp(targetpos, t)
			rotation = startrot*(1-t) + targetrot*t
			scale = start_scale*(1-t) + target_scale*t
		t += delta/float(time_scale)
	else:
		position = targetpos
		rotation = targetrot
		scale = target_scale
		finished = true
		return finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		IN_HAND:
			pass
		IN_PLAY:
			if moving_into_play:
				if move_card(delta, IN_PLAY, IN_MOUSE_TIME, targetpos, target_scale, targetrot):
					moving_into_play = false
		IN_MOUSE:
			move_card(delta, IN_MOUSE, IN_MOUSE_TIME, get_global_mouse_position() - $'../../../'.CARD_SIZE/2, orig_scale, 0)
		FOCUS_IN_HAND:
			if zooming_in:
				if move_card(delta, FOCUS_IN_HAND, ZOOMTIME, targetpos, target_scale, targetrot):
					zooming_in = false
		DRAWN_TO_HAND: #animate card from deck to player hand.
			if move_card(delta, DRAWN_TO_HAND, DRAWTIME, targetpos, orig_scale, targetrot):
				state = IN_HAND
		REORGANIZE_HAND:
			if move_card(delta, REORGANIZE_HAND, ORGANIZETIME, targetpos, target_scale, targetrot):
				if card_in_play:
					state = IN_PLAY
				else:
					state = IN_HAND
		MOVE_TO_DISCARD_PILE:
			if moving_to_discard:
				if move_card(delta, MOVE_TO_DISCARD_PILE, DRAWTIME, targetpos, orig_scale, 0):
					moving_to_discard = false


func move_neighbor_card(card_number, left, spread_factor):
	neighbor_card = $'../../'.get_child(card_number).get_node('CardBase')
	if left:
		neighbor_card.targetpos = neighbor_card.default_pos - spread_factor*Vector2($'../../../'.CARD_SIZE.x/2, 0)
	else:
		neighbor_card.targetpos = neighbor_card.default_pos + spread_factor*Vector2($'../../../'.CARD_SIZE.x/2, 0)
	neighbor_card.setup = true
	neighbor_card.state = REORGANIZE_HAND
	neighbor_card.target_scale = orig_scale
	neighbor_card.move_neighbor_card_check = true

func reset_card(card_number):
#	if neighbor_card.move_neighbor_card_check:
#		neighbor_card.move_neighbor_card_check = false
#	else:
	if not neighbor_card.move_neighbor_card_check:
		neighbor_card = $'../../'.get_child(card_number).get_node('CardBase')
		if neighbor_card.state != FOCUS_IN_HAND:
			neighbor_card.state = REORGANIZE_HAND
			neighbor_card.target_scale = orig_scale
			neighbor_card.targetpos = neighbor_card.default_pos
			neighbor_card.setup = true
	
	
func reset_pos_rot_scale_and_time():
	startpos = position
	startrot = rotation
	start_scale = scale
	t = 0
	setup = false

func _on_focus_mouse_entered():
	match state:
		IN_HAND, REORGANIZE_HAND, IN_PLAY:
			if card_in_play:
				old_state = IN_PLAY
				old_pos = targetpos
				old_scale = target_scale
				if left_hand_side:
					targetpos = old_pos + card_slot_size*0.5*(zoom_scale_in_play - 1)*Vector2(1,-1)
				else:
					targetpos = old_pos + card_slot_size*0.5*(zoom_scale_in_play - 1)*Vector2(-1,1)
				setup = true
				zooming_in = true
				state = FOCUS_IN_HAND
				target_scale = zoom_scale_in_play*Vector2(card_slot_size.y, card_slot_size.x)/size
			else:
				old_state = state
				setup = true
				targetpos.x = default_pos.x - $'../../../'.CARD_SIZE.x/2
				targetpos.y = get_viewport().size.y - $'../../../'.CARD_SIZE.y*zoom_scale
				zooming_in = true
				state = FOCUS_IN_HAND
				targetrot = 0
				target_scale = orig_scale*zoom_scale


func _on_focus_mouse_exited():
	match state:
		FOCUS_IN_HAND:
			setup = true
			state = REORGANIZE_HAND
			if card_in_play:
				targetpos = old_pos
				target_scale = old_scale
			else:
				targetpos = default_pos
				target_scale = orig_scale
				
