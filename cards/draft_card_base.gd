extends MarginContainer

@onready var util = get_node("/root/UtilityFunctions")
@onready var game_state = get_node("/root/GameState")
# Declare member variables here.
@onready var card_database = preload("res://scripts/my_cards_database.gd").new()
#var card_name = 'ice_cannon'
#var card_name = 'warp_time'
var card_name = 'cold_touch'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]

var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var t = 0
@onready var orig_scale = scale
const DRAWTIME = 0.5
const RESHUFFLE_TIME = 0.25
const ORGANIZETIME = 0.25
const ZOOMTIME = 0.2
const SHRINK_TIME = 0.7
const MOVE_TO_TOP_BAR_TIME = 1.5

var setup = true
var start_scale = Vector2()
var default_pos = Vector2()
var zoom_scale = 1.1
var reorganize_neighbors = true
var number_cards_hand_minus_one = 0
var card_numb = 0
var neighbor_card
var move_neighbor_card_check = false
var zooming_in = true
var old_state = INF
var target_scale = Vector2()

var enabled = true
var shrink_neighbors = false
var drafted_card_index = -1
var draft_card_index_array = [0,1,2]

enum {
	ON_TABLE,
	FOCUS_ON_TABLE,
	REORGANIZE_HAND,
	NOTHING,
	MOVE_TO_UI_DECK,
	SELECTED,
	SHRINK,
}
var state = ON_TABLE

# Called when the node enters the scene tree for the first time.
func _ready():
	default_pos = position
	#print(card_info)
	$CardBack.scale *= size/$CardBack.size
	
	$HiddenPanel/Image.region_rect = card_info[4]
	#print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Info.text = card_info[3]
	$CardBack.visible = false
	#$Focus.set_modulate(Color(1,0.8,0.2,1))
	#$Focus.visible = false
	#$GlowingBorder.visible = true
	#Set position for FadeOutCardBack to Discard pile pos
	$'../FadeOutCardBack'.position = $'../../../Discard'.position
	#This scaling will result in size Vector2(174,240), i.e. CARD_SIZE
	$'../FadeOutCardBack'.scale *= 0.6
	
#	$Focus.set_modulate(Color(1,0.8,0.2,1))
#	$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		print(event.position)
		if event.is_pressed():
			if enabled:
				#if (mouse_in_area_2d):
				enabled = false
				set_focus(false)
				$GlowingBorder.visible = false
				setup = true
				targetpos = default_pos
				shrink_neighbors = true
				print(card_numb)
				drafted_card_index = card_numb
				state = SELECTED
#		for card in $'../../../Draftables'.get_children():
#			var base = card.get_node("MyDraftBase")
#			base.enabled = false
#			if !base.drafted:
#				shrink()
#
#func _input(event):
#	for card in $'../../../Draftables'.get_children():
#		var base = card.get_node("MyDraftBase")
#		base.enabled = false
#	pass
#	if event is InputEventScreenTouch:
#		if event.is_pressed():
#			if enabled:
#				#if (mouse_in_area_2d):
#				enabled = false
#				set_focus(false)
#				$GlowingBorder.visible = false
#				setup = true
#				targetpos = default_pos
#				state = SELECTED
#				for card in $'../../../Draftables'.get_children():
#					var base = card.get_node("MyDraftBase")
#					if base.card_numb == index:
#						enabled = false
#						set_focus(false)
#						$GlowingBorder.visible = false
#
#						setup = true
#						targetpos = default_pos
#						state = SELECTED
#					print(card.get_node("MyDraftBase"))
#					print(state)
#					if state == FOCUS_ON_TABLE or (ON_TABLE and mouse_in_area_2d):

#					elif state == ON_TABLE or state == REORGANIZE_HAND or not mouse_in_area_2d:
#						enabled = false
#						set_focus(false)
#						$GlowingBorder.visible = false
##						state = NOTHING
##						await get_tree().create_timer(0.3).timeout
##						state = SHRINK
				#await $'../../../'.shrink_rest_of_draftable_cards()
#	if event is InputEventScreenTouch:
#		pass
#		#print(event)
#		if not event.is_pressed():
#			mouse_in_area_2d = false

func shrink():
	state = SHRINK

func is_selected():
	if state == SELECTED or state == MOVE_TO_UI_DECK or state == NOTHING:
		return true
	else:
		return false

func _physics_process(delta):
	match state:
		NOTHING:
			pass
		ON_TABLE:
			$GlowingBorder.visible = false
		FOCUS_ON_TABLE:
			$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))
			if zooming_in:
				if setup:
					reset_pos_rot_scale_and_time()
				if t <= 1:
					position = startpos.lerp(targetpos, t)
					rotation = startrot*(1-t) + 0*t
					scale = start_scale*(1-t) + orig_scale*zoom_scale*t
					t += delta/float(ZOOMTIME)
				else:
					position = targetpos
					rotation = 0
					scale = orig_scale*zoom_scale
					zooming_in = false
		SELECTED:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + 0*t
				#orig_scale*zoom_scale = 0.6*1.1 = 0.66
				scale = start_scale*(1-t) + orig_scale*zoom_scale*t
				t += delta/float(ZOOMTIME)
				
				if shrink_neighbors:
					shrink_neighbors = false
					draft_card_index_array.remove_at(drafted_card_index)
					for element in draft_card_index_array:
						shrink_neighbor_card(element)
			else:
				position = targetpos
				rotation = 0
				scale = orig_scale*zoom_scale
				zooming_in = false
				setup = true
				state = MOVE_TO_UI_DECK
		REORGANIZE_HAND:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + targetrot*t
				scale = start_scale*(1-t) + orig_scale*t
				t += delta/float(ORGANIZETIME)
			else:
				position = targetpos
				rotation = targetrot
				scale = orig_scale
				state = ON_TABLE
		MOVE_TO_UI_DECK:
			if setup:
				print(game_state.global_player_deck)
				game_state.global_player_deck.append(card_info[2].to_snake_case())
				print("Added to global deck")
				print(game_state.global_player_deck)
				$'../../../DraftScene/AP'.play("fade_out")
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(Vector2(-100,-180), parametric_blend(t))
				if t < 0.75:
					rotation = startrot*(1-t/float(0.75)) + 4*PI*t/float(0.75)
				else:
					rotation = 4*PI
				if t < 0.5:
					scale = start_scale*(1-2*t) + Vector2(0.075,0.075)*2*t
				else:
					scale = Vector2(0.075,0.075)
				var flip_time_factor = 1.9 # 20% faster
				if t < float(1/flip_time_factor):
					scale.x = scale.x*abs(2*(flip_time_factor*t)-1)
				else:
					scale.x = scale.x
				if not $CardBack.visible:
					if t >= float(0.5/flip_time_factor):
						$CardBack.visible = true
				t += delta/float(MOVE_TO_TOP_BAR_TIME)
				#t += delta/float(15)
			else:
				$'../../../'.update_global_deck_counter()
				position = Vector2(-100,-180)
				rotation = 4*PI
				scale = Vector2(0.075,0.075)
				state = NOTHING
		SHRINK:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
#				position = startpos.lerp(targetpos, t)
#				rotation = startrot*(1-t) + targetrot*t
				scale = start_scale*(1-parametric_blend(t)) + Vector2(0,0)*parametric_blend(t)
				t += delta/float(SHRINK_TIME)
			else:
#				position = targetpos
#				rotation = targetrot
				scale = Vector2(0,0)
				state = NOTHING


func shrink_neighbor_card(card_number):
	neighbor_card = $'../../'.get_child(card_number).get_node("MyDraftBase")
	neighbor_card.enabled = false
	neighbor_card.set_focus(false)
	neighbor_card.set_glowing_border_visible(false)
	neighbor_card.state = SHRINK

func reset_pos_rot_scale_and_time():
	startpos = position
	startrot = rotation
	start_scale = scale
	t = 0
	$Focus.set_modulate(Color(1,0.8,0.2,1))
	setup = false

func _on_focus_mouse_entered():
#	print("Mouse entered card!")
#	print(state)
	if not enabled:
		return
	$GlowingBorder.visible = true
	match state:
		ON_TABLE, REORGANIZE_HAND:
			#print(state)
			old_state = state
			setup = true
			targetpos.x = default_pos.x 
			targetpos.y = 385 - $'../../../'.CARD_SIZE.y*zoom_scale
			zooming_in = true
			state = FOCUS_ON_TABLE
			#print(state)

func _on_focus_mouse_exited():
	if not enabled:
		return
	$GlowingBorder.visible = false
	match state:
		FOCUS_ON_TABLE:
			setup = true
			state = REORGANIZE_HAND
			targetpos = default_pos

func set_focus(b):
	$Focus.visible = b

func set_glowing_border_visible(b):
	$GlowingBorder.visible = b

#Custom ease in and ease out-like curve
#https://stackoverflow.com/questions/13462001/ease-in-and-ease-out-animation-formula
func parametric_blend(x):
	var sq = x * x
	return sq / (2.0 * (sq - x) + 1.0)

func fade_out():
	#print("here")
	$AnimationPlayer.play("fade_out")



