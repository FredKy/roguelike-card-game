extends MarginContainer


@onready var card_database = get_node("/root/MyCardsDatabase")
var card_name = 'cold_touch'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]
@onready var card_data = card_database.card_data_array_to_dictionary(card_info)

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
var old_pos = Vector2()
var old_scale = Vector2()
var reparent = true # Wether or not card can be reparented

var enabled = true

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
var state = DRAWN_TO_HAND

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = 0.5*scale
	print(card_data)
	#print(card_info)
	$CardBack.scale *= size/$CardBack.size
	
	$HiddenPanel/Image.region_rect = card_info[4]
	#print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	#$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Name.text = card_data["name"]
	if card_data["name"].length() > 12:
		$VBoxContainer/Name.set("theme_override_font_sizes/font_size", 23)
	if card_data["name"].length() > 14:
		$VBoxContainer/Name.set("theme_override_font_sizes/font_size", 20)
	$VBoxContainer/Info.text = card_info[3]
	$CardBack.visible = true
	$Focus.set_modulate(Color(1,0.8,0.2,1))
	#Set position for FadeOutCardBack to Discard pile pos
	$'../FadeOutCardBack'.position = $'../../../Discard'.position
	#This scaling will result in size Vector2(174,240), i.e. CARD_SIZE
	$'../FadeOutCardBack'.scale *= 0.6


func _input(event):
#	if $'../../../'.is_dealing_cards:
#		return
	if event is InputEventScreenTouch:
		#print(event)
		if event.is_pressed(): # Pick up card
			#print(event)
			#print(state)
			#print(mouse_in_area_2d)
			if state == FOCUS_IN_HAND:
				if card_select && enabled:
					old_state = state
					state = IN_MOUSE
					$'../'.z_index += 2
					$'../../../'.a_card_is_in_mouse = true
					setup = true
					card_select = false
	if event is InputEventScreenTouch:
		#print(event)
		if not event.is_pressed():
#		if event.is_action_released("leftclick"):
			if not card_select:
				$'../'.z_index -= 2
				$'../../../'.a_card_is_in_mouse = false
				$GlowingBorder.visible = false
				$Focus.visible = false
				$'../../../Wanderer'.stop_highlight()
				
				
				if card_info[0] == "attack":
					var enemies = $'../../../Enemies'
					for i in range(enemies.get_child_count()):
						var enemy = enemies.get_child(i)
						if mouse_pointer_on_enemy(enemy):
							#Only allow attack if it's not wasted damage, otherwise return to hand.
							if not enemies.get_child(i).is_already_dead():
								# Move card to discard pile
								setup = true
								moving_to_discard = true
								state = MOVE_TO_DISCARD_PILE
								card_select = true
								
								# Remove energy
								$'../../../'.update_energy_and_cards_playability(card_data["cost"])
								
#								enemies.get_child(i).buffered_damage += card_data["damage"]
#								#Queue up enemy for damage calculation in Wanderers animation finished function
#								$'../../../Wanderer'.target_queue.append(enemies.get_child(i))
								
								print("Wanderer attacking")
								# Play attack animation and handle damage
								$'../../../Wanderer'.trigger_attack(card_data, enemies.get_child(i))
	#							if card_data["name"] == "Ice Cannon":
	#								$'../../../Wanderer'.ice_cannon(attack_number)
								print("Stopped attacking")
								return
							else:
								setup = true
								targetpos = default_pos
								state = REORGANIZE_HAND
								card_select = true
								return
						else:
							continue
					setup = true
					targetpos = default_pos
					state = REORGANIZE_HAND
					card_select = true
				elif card_info[0] == "spell":
					var enemies = $'../../../Enemies'
					for i in range(enemies.get_child_count()):
						var enemy = enemies.get_child(i)
						if mouse_pointer_on_enemy(enemy):
							#Only allow attack if it's not wasted damage, otherwise return to hand.
							if not enemies.get_child(i).is_already_dead():
								# Move card to discard pile
								setup = true
								moving_to_discard = true
								state = MOVE_TO_DISCARD_PILE
								card_select = true
								
								# Remove energy
								$'../../../'.update_energy_and_cards_playability(card_data["cost"])
								
								#Queue up enemy for damage calculation in Wanderers animation finished function
								$'../../../Wanderer'.target_queue.append(enemies.get_child(i))
								
								print("Wanderer casting spell")
								# Play animation and handle spell effect
								$'../../../Wanderer'.trigger_spell(card_data)
								print("Stopped casting spell")
								return
							else:
								setup = true
								targetpos = default_pos
								state = REORGANIZE_HAND
								card_select = true
								return
						else:
							continue
					setup = true
					targetpos = default_pos
					state = REORGANIZE_HAND
					card_select = true
				elif card_info[0] == "shield":
					mouse_pos = get_global_mouse_position()
					if mouse_pos.y < 400:
						# Remove energy
						$'../../../'.update_energy_and_cards_playability(card_info[1])
						
						# Move card to discard pile
						setup = true
						moving_to_discard = true
						state = MOVE_TO_DISCARD_PILE
						card_select = true
						
						# Play shield animation and handle damage
						$'../../../Wanderer'.trigger_shield(card_data)
					else:
						setup = true
						targetpos = default_pos
						state = REORGANIZE_HAND
						card_select = true
				
				else:
					setup = true
					targetpos = default_pos
					state = REORGANIZE_HAND
					card_select = true


func _physics_process(delta):
	match state:
		NOTHING:
			pass
		IN_HAND:
			$GlowingBorder.visible = false
			#$CardBack.visible = false #Inferior hack to fix bug. Try to fix it for real.
			$'../'.z_index = 2
			if $'../../../'.a_card_is_in_mouse or $'../../../'.is_dealing_cards:
				$Focus.visible = false
				$Focus.disabled = true
			else:
				$Focus.visible = true
				$Focus.disabled = false
		IN_MOUSE:
			$GlowingBorder.visible = true
			if card_info[0] == "attack":
				var enemies = $'../../../Enemies'
				var change_color = false
				for i in range(enemies.get_child_count()):
					var enemy = enemies.get_child(i)
					if mouse_pointer_on_enemy(enemy):
						change_color = true
				if change_color:
					#$Focus.set_modulate(Color(0.79,0.18,0.21,1))
					$Focus.set_modulate(Color(0.88,0.23,0.26,1))
					$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(1,0,0,0))
					#print($GlowingBorder/CardBorderGlow.material.get_shader_parameter("ending_color"))
				else:
					$Focus.set_modulate(Color(1,0.8,0.2,1))
					$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))
			elif card_info[0] == "shield":
				mouse_pos = get_global_mouse_position()
				if mouse_pos.y < 400:
					$'../../../Wanderer'.play_highlight()
					$Focus.set_modulate(Color(0.3,0.3,1,1))
					$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.3,0.3,1,1))
				else:
					$'../../../Wanderer'.stop_highlight()
					$Focus.set_modulate(Color(1,0.8,0.2,1))
					$GlowingBorder/CardBorderGlow.material.set_shader_parameter("ending_color", Vector4(0.7,0.3,0,0))
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				
				position = startpos.lerp(get_global_mouse_position() - $'../../../'.CARD_SIZE + Vector2(30, 45), t)
				rotation = startrot*(1-t) + 0*t
				scale = start_scale*(1-t) + orig_scale*t
				
				if not reorganize_neighbors:
					reorganize_neighbors = true
					
					reset_x_cards(20)
					
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
						if card_numb -4 >= 0:
							move_neighbor_card(card_numb -4, true, 0.25)
						if card_numb -5 >= 0:
							move_neighbor_card(card_numb -4, true, 0.075)
						if card_numb + 1 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +1, false, 1+1)
						if card_numb + 2 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +2, false, 0.25+1+0.75)
						if card_numb + 3 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +3, false, 0.25+0.25+1)
						if card_numb + 4 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +4, false, 0.25+0.65)
						if card_numb + 5 <= number_cards_hand_minus_one:
							move_neighbor_card(card_numb +5, false, 0.15)
				else:
					position = targetpos
					rotation = 0
					scale = orig_scale*zoom_scale
					zooming_in = false
		DRAWN_TO_HAND: #animate card from deck to player hand.
			$Focus.visible = false
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(targetpos, p_b(t))
				if t < 0.5:
					position += Vector2(0,-200)*p_b(t)
				else:
					position += Vector2(0, -200)*(1-p_b(t))
				rotation = startrot*(1-p_b(t)) + (2*PI+targetrot)*p_b(t)
#				position = startpos.lerp(targetpos, t)
#				rotation = startrot*(1-t) + (2*PI+targetrot)*t
				scale = 0.5*orig_scale*(1-p_b(t))+orig_scale*p_b(t)
				var flip_time_factor = 1.2 # 20% faster
				if t < float(1/flip_time_factor):
					scale.x = (0.5*orig_scale*(1-p_b(t))+orig_scale*p_b(t)).x*abs(2*(flip_time_factor*t)-1)
				else:
					scale.x = orig_scale.x
				if $CardBack.visible:
					if t >= float(0.5/flip_time_factor):
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
				#t += delta/float(4.0)
			else:
				position = targetpos
				rotation = targetrot
				#Lines to prevent spinning card bug.
				while startrot > 1:
					startrot -= 2*PI
				while startrot < -1:
					startrot += 2*PI
#				print("Before in hand stats:")
#				print("startrot: " + str(startrot))
#				print("targetrot: " + str(targetrot))
				state = IN_HAND
		REORGANIZE_HAND:
			while startrot > 1:
				startrot -= 2*PI
			while startrot < -1:
				startrot += 2*PI
#			print("Reorganize stats:")
#			print("startrot: " + str(startrot))
#			print("targetrot: " + str(targetrot))
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

					reset_x_cards(20)
					
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
					position = startpos.lerp(targetpos, p_b(t))
					rotation = startrot*(1-p_b(t)) + (2*PI)*p_b(t)
					#scale = start_scale*(1-t) + orig_scale*t
					scale = start_scale*(1-t) + 0.5*orig_scale*t
					var flip_time_factor = 1.2 # 20% faster
					if t < float(1/flip_time_factor):
						scale.x = (start_scale*(1-t) + 0.5*orig_scale*t).x*abs(2*(flip_time_factor*t)-1)
					else:
						scale.x = 0.5*orig_scale.x
					if not $CardBack.visible:
						if t >= float(0.5/flip_time_factor):
							$CardBack.visible = true
					t += delta/float(DRAWTIME)
					#t += delta/float(4.0)
				else:
					position = targetpos
					scale = 0.5*orig_scale
					moving_to_discard = false
					setup = true
					state = IN_DISCARD_PILE
		IN_DISCARD_PILE:
			pass
		MOVE_TO_DECK:
			if setup:
				reset_pos_rot_scale_and_time()
				targetpos = $'../../../Deck'.position + Vector2(9,9)
				scale = 0.5*orig_scale
			if t <= 1:
				position = startpos.lerp(targetpos, p_b(t))
				if t < 0.5:
					position += Vector2(0,-200)*p_b(t)
				else:
					position += Vector2(0, -200)*(1-p_b(t))
				rotation = startrot*(1-p_b(t)) + (-2*PI)*p_b(t)
				
				t += delta/float(RESHUFFLE_TIME)
				#t += delta/float(4)
			else:
				position = targetpos
				rotation = targetrot
				scale = 0.5*orig_scale
				#$'../../../'.player_deck.card_list.append(self.card_name)
				$'../../../'.player_deck.append(self.card_name)
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
		#Potential bug fix
		var number_of_cards = $'../../'.get_child_count()
		if card_number > number_of_cards:
			return
		
		neighbor_card = $'../../'.get_child(card_number).get_node("MyCardBase")
		if neighbor_card.state != FOCUS_IN_HAND && neighbor_card.state != DRAWN_TO_HAND:
			neighbor_card.setup = true
			neighbor_card.state = REORGANIZE_HAND
			#neighbor_card.target_scale = orig_scale
			neighbor_card.targetpos = neighbor_card.default_pos
			#neighbor_card.setup = true

func reset_x_cards(x : int):
	if x >= 1:
		for i in range(1,x):
			if card_numb -i >= 0:
				reset_card(card_numb -i)
			if card_numb + i <= number_cards_hand_minus_one:
				reset_card(card_numb +i)

func reset_pos_rot_scale_and_time():
	startpos = position
	startrot = rotation
	start_scale = scale
	t = 0
	$Focus.set_modulate(Color(1,0.8,0.2,1))
	setup = false

func set_focus_disabled():
	$Focus.disabled = true

func _on_focus_mouse_entered():
	if $'../../../'.is_dealing_cards:
		#$Focus.disabled = true
		return
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
	if $'../../../'.is_dealing_cards:
		#$Focus.disabled = true
		return
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

#Custom ease in and ease out-like curve
#https://stackoverflow.com/questions/13462001/ease-in-and-ease-out-animation-formula
#Parametric blend function
func p_b(x):
	var sq = x * x
	return sq / (2.0 * (sq - x) + 1.0)

func fade_out():
	#print("here")
	$FadeOutAnimationPlayer.play("fade_out")

func mouse_pointer_on_enemy(enemy):
	var enemy_pos = enemy.position
	var enemy_size = enemy.size
	mouse_pos = get_global_mouse_position()
	if mouse_pos.x < enemy_pos.x + enemy_size.x/2 and mouse_pos.x > enemy_pos.x \
	and mouse_pos.y < enemy_pos.y + enemy_size.y/2 and mouse_pos.y > enemy_pos.y/2:
		return true
	else:
		return false

