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
var card_select = true
var old_state = INF
var moving_into_play = false
var target_scale = Vector2()

enum {
	IN_HAND,
	IN_PLAY,
	IN_MOUSE,
	FOCUS_IN_HAND,
	DRAWN_TO_HAND,
	REORGANIZE_HAND,
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
	match state:
		FOCUS_IN_HAND, IN_MOUSE, IN_PLAY:
			if event.is_action_pressed("leftclick"): # Pick up card
				if card_select:
					old_state = state
					state = IN_MOUSE
					setup = true
					card_select = false
			if event.is_action_released("leftclick"):
				if not card_select:
					if old_state == FOCUS_IN_HAND: # Putting a card into a slot.
						var card_slots = $'../../CardSlots'
						var card_slot_empty = $'../../'.card_slot_empty
						for i in range(card_slots.get_child_count()):
							if card_slot_empty[i]:
								var card_slot_pos = card_slots.get_child(i).position
								var card_slot_size = card_slots.get_child(i).size
								var mouse_pos = get_global_mouse_position()
								if mouse_pos.x < card_slot_pos.x + card_slot_size.x and mouse_pos.x > card_slot_pos.x \
								and mouse_pos.y < card_slot_pos.y + card_slot_size.y and mouse_pos.y > card_slot_pos.y:
									setup = true
									moving_into_play = true
									targetpos = card_slot_pos-$'../../'.CARD_SIZE/2
									target_scale = card_slot_size/size
									state = IN_PLAY
									card_select = true
									break
						if state != IN_PLAY:
							setup = true
							targetpos = default_pos
							state = REORGANIZE_HAND
							card_select = true
					else: # Handle everything once the card is in play.
						var enemies = $'../../Enemies'
						for i in range(enemies.get_child_count()):
							var enemy_pos = enemies.get_child(i).position
							var enemy_size = enemies.get_child(i).size
							var mouse_pos = get_global_mouse_position()
							if mouse_pos.x < enemy_pos.x + enemy_size.x and mouse_pos.x > enemy_pos.x \
								and mouse_pos.y < enemy_pos.y + enemy_size.y and mouse_pos.y > enemy_pos.y:
									# Deal with damage
									setup = true
									moving_into_play = true
									state = IN_PLAY
									card_select = true
									break
						if not card_select:
							setup = true
							moving_into_play = true
							state = IN_PLAY
							card_select = true
						
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		IN_HAND:
			pass
		IN_PLAY:
			if moving_into_play:
				if setup:
					reset_pos_rot_scale_and_time()
				if t <= 1:
					position = startpos.lerp(targetpos, t)
					rotation = startrot*(1-t) + 0*t
					scale = start_scale*(1-t) + target_scale*t
					t += delta/float(IN_MOUSE_TIME)
				else:
					position = targetpos
					rotation = 0
					scale = target_scale
					moving_into_play = false
		IN_MOUSE:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(get_global_mouse_position() - $'../../'.CARD_SIZE, t)
				rotation = startrot*(1-t) + 0*t
				scale = start_scale*(1-t) + orig_scale*t
				t += delta/float(IN_MOUSE_TIME)
			else:
				position = get_global_mouse_position() - $'../../'.CARD_SIZE
				rotation = 0
		FOCUS_IN_HAND:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + 0*t
				scale = start_scale*(1-t) + orig_scale*zoom_scale*t
				t += delta/float(ZOOMTIME)
				if reorganize_neighbors:
					reorganize_neighbors = false
					number_cards_hand_minus_one = $'../../'.number_cards_hand - 1
					if card_numb -1 >= 0:
						move_neighbor_card(card_numb -1, true, 1) # true is left
					if card_numb -2 >= 0:
						move_neighbor_card(card_numb -2, true, 0.25)
					if card_numb + 1 <= number_cards_hand_minus_one:
						move_neighbor_card(card_numb +1, false, 1)
					if card_numb + 2 <= number_cards_hand_minus_one:
						move_neighbor_card(card_numb +2, false, 0.25)
			else:
				position = targetpos
				rotation = 0
				scale = orig_scale*zoom_scale
		DRAWN_TO_HAND: #animate card from deck to player hand.
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				#position = startpos.lerp(targetpos, t)
				if !tween:
					tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					#tween.interpolate_value(startpos, targetpos-startpos,DRAWTIME,1,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
					tween.tween_property(self, "position", targetpos, DRAWTIME)
					tween.parallel().tween_property(self, "rotation", 2*PI+targetrot, DRAWTIME)
					
					
				#rotation = startrot*(1-t) + targetrot*t
				

				#scale.x = orig_scale*abs(2*t-1)
				if t < 0.5:
					scale.x = orig_scale.x*abs(2*(2*t)-1)
				else:
					scale.x = orig_scale.x
				if $CardBack.visible:
					if t >= 0.25:
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				position = targetpos
				rotation = targetrot
				state = IN_HAND
				t = 0
		REORGANIZE_HAND:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				if move_neighbor_card_check:
					move_neighbor_card_check = false
					
				position = startpos.lerp(targetpos, t)
#				if tween2:
#					tween2 = create_tween()
#					tween2.tween_property(self, "position", targetpos, ORGANIZETIME)
#				if !tween:
#					tween = create_tween()
#					tween.interpolate_value(startpos, targetpos-startpos, t, ORGANIZETIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					#tween2.tween_property(self, "position", targetpos, ORGANIZETIME)
				
				rotation = startrot*(1-t) + targetrot*t
				scale = start_scale*(1-t) + orig_scale*t
				t += delta/float(ORGANIZETIME)
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
			else:
				position = targetpos
				rotation = targetrot
				scale = orig_scale
				state = IN_HAND
				#t = 0
				
func move_neighbor_card(card_number, left, spread_factor):
	neighbor_card = $'../'.get_child(card_number) # Parent node in (playscene) scene is Cards
	if left:
		neighbor_card.targetpos = neighbor_card.default_pos - spread_factor*Vector2(65,0)
	else:
		neighbor_card.targetpos = neighbor_card.default_pos + spread_factor*Vector2(65,0)
	neighbor_card.setup = true
	neighbor_card.state = REORGANIZE_HAND
	neighbor_card.move_neighbor_card_check = true

func reset_card(card_number):
	neighbor_card = $'../'.get_child(card_number)
#	if neighbor_card.move_neighbor_card_check:
#		neighbor_card.move_neighbor_card_check = false
#	else:
	if not neighbor_card.move_neighbor_card_check:
		neighbor_card = $'../'.get_child(card_number)
		if neighbor_card.state != FOCUS_IN_HAND:
			neighbor_card.state = REORGANIZE_HAND
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
		IN_HAND, REORGANIZE_HAND:
			setup = true
			targetpos = default_pos
			targetpos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y*zoom_scale
			state = FOCUS_IN_HAND


func _on_focus_mouse_exited():
	match state:
		FOCUS_IN_HAND:
			setup = true
			targetpos = default_pos
			state = REORGANIZE_HAND
