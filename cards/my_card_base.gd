extends MarginContainer


# Declare member variables here.
@onready var card_database = preload("res://assets/cards/my_cards_database.gd").new()
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
const IN_MOUSE_TIME = 0.1
var tween
var tween_d
var tween_r

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


var mouse_pos = Vector2()
var left_hand_side = false
var card_in_play = false
var zoom_scale_in_play = 1.2
var old_pos = Vector2()
var old_scale = Vector2()
var reparent = true # Wether or not card can be reparented

var enabled = true

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
	NOTHING,
}
var state = IN_HAND

# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_info)
	$CardBack.scale *= size/$CardBack.size
	
	$HiddenPanel/Image.region_rect = card_info[4]
	print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Info.text = card_info[3]
	$CardBack.visible = true

func _input(event):
	match state:
		FOCUS_IN_HAND, IN_MOUSE, IN_PLAY:
			if event.is_action_pressed("leftclick"): # Pick up card
				if card_select && enabled:
					old_state = state
					state = IN_MOUSE
					$'../'.z_index += 2
					setup = true
					card_select = false
			if event.is_action_released("leftclick"):
				if not card_select:
					$'../'.z_index -= 2
					$GlowingBorder.visible = false
					$Focus.visible = false
					
					if card_info[0] == "attack":
						var enemies = $'../../../Enemies'
						for i in range(enemies.get_child_count()):
							var enemy_pos = enemies.get_child(i).position
							var enemy_size = enemies.get_child(i).size
							mouse_pos = get_global_mouse_position()
							if mouse_pos.x < enemy_pos.x + enemy_size.x/2 and mouse_pos.x > enemy_pos.x \
								and mouse_pos.y < enemy_pos.y + enemy_size.y/2 and mouse_pos.y > enemy_pos.y/2:
									
									# Remove energy
									$'../../../'.update_energy_and_cards_playability(card_info[1])
									
									# Move card to discard pile
									setup = true
									moving_to_discard = true
									state = MOVE_TO_DISCARD_PILE
									card_select = true
									
									# Play attack animation
									if card_info[2] == "Ice Cannon":
										$'../../../Wanderer'.ice_cannon()
										await get_tree().create_timer(2.0).timeout
									
									# Deal with damage
									var attack_number = card_info[5]
									enemies.get_child(i).change_health(attack_number)
									
									break
							else:
								if state != IN_DISCARD_PILE:
									setup = true
									targetpos = default_pos
									state = REORGANIZE_HAND
									card_select = true
								break
					else:
						if state != IN_DISCARD_PILE:
							setup = true
							targetpos = default_pos
							state = REORGANIZE_HAND
							card_select = true
					if not card_select:
						setup = true
						moving_into_play = true
						state = IN_DISCARD_PILE
						card_select = true


func _physics_process(delta):
	match state:
		NOTHING:
			pass
		IN_HAND:
			$Focus.visible = true
			$GlowingBorder.visible = false
			$'../'.z_index = 0
		IN_PLAY:
			if moving_into_play:
				if setup:
					reset_pos_rot_scale_and_time()
					if reparent:
						$'../../../'.reparent_card(card_numb)
						reparent = false
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
			$GlowingBorder.visible = true
			if card_info[0] == "attack":
				var enemies = $'../../../Enemies'
				for i in range(enemies.get_child_count()):
					var enemy_pos = enemies.get_child(i).position
					var enemy_size = enemies.get_child(i).size
					mouse_pos = get_global_mouse_position()
					if mouse_pos.x < enemy_pos.x + enemy_size.x/2 and mouse_pos.x > enemy_pos.x \
						and mouse_pos.y < enemy_pos.y + enemy_size.y/2 and mouse_pos.y > enemy_pos.y/2:
							$Focus.set_modulate(Color(1,0.5,0.5,1))
							$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(1,0,0,0))
							#print($GlowingBorder/CardBorderGlow.material.get_shader_parameter("ending_color"))
					else:
						$Focus.set_modulate(Color(1,1,1,1))
						$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))

			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				
				position = startpos.lerp(get_global_mouse_position() - $'../../../'.CARD_SIZE + Vector2(30, 45), t)
				rotation = startrot*(1-t) + 0*t
				scale = start_scale*(1-t) + orig_scale*t
				
				if not reorganize_neighbors:
					reorganize_neighbors = true
					if card_numb -1 >= 0:
						reset_card(card_numb -1)
					if card_numb -2 >= 0:
						reset_card(card_numb -2)
					if card_numb -3 >= 0:
						reset_card(card_numb -3)
					if card_numb + 1 <= number_cards_hand_minus_one:
						reset_card(card_numb +1)
					if card_numb + 2 <= number_cards_hand_minus_one:
						reset_card(card_numb +2)
					if card_numb + 3 <= number_cards_hand_minus_one:
						reset_card(card_numb +3)
				t += delta/float(IN_MOUSE_TIME)
			else:
				position = get_global_mouse_position() - $'../../../'.CARD_SIZE + Vector2(30, 45)
				rotation = 0
		FOCUS_IN_HAND:
			$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))
			if zooming_in:
				if setup:
					#print("I was here!")
					reset_pos_rot_scale_and_time()
				if t <= 1:
					position = startpos.lerp(targetpos, t)
					rotation = startrot*(1-t) + 0*t
					scale = start_scale*(1-t) + orig_scale*zoom_scale*t
					t += delta/float(ZOOMTIME)
#					if not IN_DISCARD_PILE:
#						print("I was here!")
					if reorganize_neighbors:
						reorganize_neighbors = false
						number_cards_hand_minus_one = $'../../../'.number_cards_hand
						if card_numb -1 >= 0:
							move_neighbor_card(card_numb -1, true, 1+1) # true is left
						if card_numb -2 >= 0:
							move_neighbor_card(card_numb -2, true, 0.25+1)
						if card_numb -3 >= 0:
							move_neighbor_card(card_numb -3, true, 0.25+0.25)
						if card_numb + 1 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +1, false, 1+1)
						if card_numb + 2 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +2, false, 0.25+1)
						if card_numb + 3 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +3, false, 0.25+0.25)
				else:
					position = targetpos
					rotation = 0
					scale = orig_scale*zoom_scale
					zooming_in = false
		DRAWN_TO_HAND: #animate card from deck to player hand.
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				if !tween:
					tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					#tween.interpolate_value(startpos, targetpos-startpos,DRAWTIME,1,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
					tween.tween_property(self, "position", targetpos, DRAWTIME)
					tween.parallel().tween_property(self, "rotation", 2*PI+targetrot, DRAWTIME)
				var flip_time_factor = 1.2 # 20% faster
				if t < float(1/flip_time_factor):
					scale.x = orig_scale.x*abs(2*(flip_time_factor*t)-1)
				else:
					scale.x = orig_scale.x
				if $CardBack.visible:
					if t >= float(0.5/flip_time_factor):
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				position = targetpos
				rotation = targetrot
				state = IN_HAND
		REORGANIZE_HAND:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				if move_neighbor_card_check:
					move_neighbor_card_check = false
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + targetrot*t
				scale = start_scale*(1-t) + orig_scale*t
				if not reorganize_neighbors:
					reorganize_neighbors = true
					if card_numb -1 >= 0:
						reset_card(card_numb -1)
					if card_numb -2 >= 0:
						reset_card(card_numb -2)
					if card_numb -3 >= 0:
						reset_card(card_numb -3)
					if card_numb + 1 <= number_cards_hand_minus_one:
						reset_card(card_numb +1)
					if card_numb + 2 <= number_cards_hand_minus_one:
						reset_card(card_numb +2)
					if card_numb + 3 <= number_cards_hand_minus_one:
						reset_card(card_numb +3)
				t += delta/float(ORGANIZETIME)
			else:
				position = targetpos
				rotation = targetrot
				scale = orig_scale
				state = IN_HAND
		MOVE_TO_DISCARD_PILE:
			$GlowingBorder.visible = false
			$Focus.visible = false
			if moving_to_discard:
				if setup:
					reset_pos_rot_scale_and_time()
					targetpos = discard_pile
					$'../../../'.reparent_to_discarded_cards(card_numb)
				if t <= 1:
					if !tween_d:
						tween_d = create_tween()
						tween_d.set_ease(Tween.EASE_IN_OUT)
						tween_d.set_trans(Tween.TRANS_CUBIC)
						tween_d.tween_property(self, "position", targetpos, DRAWTIME)
						tween_d.parallel().tween_property(self, "rotation", 2*PI, DRAWTIME)
					scale = start_scale*(1-t) + orig_scale*t
					var flip_time_factor = 1.2 # 20% faster
					if t < float(1/flip_time_factor):
						scale.x = orig_scale.x*abs(2*(flip_time_factor*t)-1)
					else:
						scale.x = orig_scale.x
					if not $CardBack.visible:
						if t >= float(0.5/flip_time_factor):
							$CardBack.visible = true
					t += delta/float(DRAWTIME)
				else:
					position = targetpos
					scale = orig_scale
					moving_to_discard = false
					setup = true
					state = IN_DISCARD_PILE
		IN_DISCARD_PILE:
			pass
		MOVE_TO_DECK:
			if setup:
				reset_pos_rot_scale_and_time()
				targetpos = $'../../../Deck'.position + Vector2(9,9)
			if t <= 1:
				if !tween_r:
					tween_r = create_tween()
					tween_r.set_ease(Tween.EASE_IN_OUT)
					tween_r.set_trans(Tween.TRANS_CUBIC)
					tween_r.tween_property(self, "position", targetpos, RESHUFFLE_TIME)
					tween_r.parallel().tween_property(self, "rotation", -2*PI, RESHUFFLE_TIME)
				t += delta/float(RESHUFFLE_TIME)
			else:
				position = targetpos
				rotation = targetrot
				$'../../../'.player_deck.card_list.append(self.card_name)
				$'../../../Deck/DeckDraw'.disabled = false
				state = NOTHING
				print(self.card_name)
				#$'../../../'.remove_card_from_discard_pile()
				$'../../../'.remove_card_from_reshuffled()

func move_neighbor_card(card_number, left, spread_factor):
	neighbor_card = $'../../'.get_child(card_number).get_node("MyCardBase")
	if left:
		neighbor_card.targetpos = neighbor_card.default_pos - spread_factor*Vector2($'../../../'.CARD_SIZE.x/2,0)
	else:
		neighbor_card.targetpos = neighbor_card.default_pos + spread_factor*Vector2($'../../../'.CARD_SIZE.x/2,0)
	neighbor_card.setup = true
	neighbor_card.state = REORGANIZE_HAND
	#neighbor_card.target_scale = orig_scale
	neighbor_card.move_neighbor_card_check = true

func reset_card(card_number):
	if not neighbor_card.move_neighbor_card_check:
		neighbor_card = $'../../'.get_child(card_number).get_node("MyCardBase")
		if neighbor_card.state != FOCUS_IN_HAND:
			neighbor_card.state = REORGANIZE_HAND
			#neighbor_card.target_scale = orig_scale
			neighbor_card.targetpos = neighbor_card.default_pos
			neighbor_card.setup = true

func reset_pos_rot_scale_and_time():
	startpos = position
	startrot = rotation
	start_scale = scale
	t = 0
	$Focus.set_modulate(Color(1,1,1,1))
	setup = false

func _on_focus_mouse_entered():
	$GlowingBorder.visible = true;
	match state:
		IN_HAND, REORGANIZE_HAND:
			old_state = state
			setup = true
			targetpos.x = default_pos.x 
#			print(get_viewport().size)
#			print(float(get_viewport().size.y)/648)
#			print($'../../../'.CARD_SIZE)
			
			#targetpos.y = get_viewport().size.y - $'../../../'.CARD_SIZE.y*(float(get_viewport().size.x)/1152)*zoom_scale
			targetpos.y = 690 - $'../../../'.CARD_SIZE.y*zoom_scale
#			print(targetpos.y)
			zooming_in = true
			state = FOCUS_IN_HAND

func _on_focus_mouse_exited():
	$GlowingBorder.visible = false;
	match state:
		FOCUS_IN_HAND:
			setup = true
			state = REORGANIZE_HAND
			targetpos = default_pos

func get_card_cost():
	return card_info[1]

func set_focus(b):
	$Focus.visible = b

func set_enabled(b):
	enabled = b
	var style_box_flat = StyleBoxFlat.new()
	style_box_flat.corner_radius_top_left = 9
	style_box_flat.corner_radius_bottom_right = 9
	if !enabled:
		style_box_flat.bg_color = Color(0.53, 0, 0.24, 1)
		$CostRect/CostRect2.add_theme_stylebox_override("panel", style_box_flat)
	else:
		style_box_flat.bg_color = Color(0.76, 0.45, 0, 1)
		$CostRect/CostRect2.add_theme_stylebox_override("panel", style_box_flat)

