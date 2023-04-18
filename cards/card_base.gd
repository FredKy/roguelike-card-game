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
var tween
var tween2

var setup = true
var start_scale = Vector2()
var default_pos = Vector2()
var zoom_scale = 2
var reorganize_neighbors = true
var number_cards_hand_minus_one
var card_numb = 0
var neighbor_card

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
	position = startpos
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		IN_HAND:
			pass
		IN_PLAY:
			pass
		IN_MOUSE:
			pass
		FOCUS_IN_HAND:
			if setup:
				reset_pos_rot_scale_and_time()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + targetrot*t
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
				rotation = targetrot
				scale = orig_scale*zoom_scale
		DRAWN_TO_HAND: #animate card from deck to player hand.
			
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
			else:
				position = targetpos
				rotation = targetrot
				scale = orig_scale
				state = IN_HAND
				t = 0
				
func move_neighbor_card(card_numb, left, spread_factor):
	neighbor_card = $'../'.get_child(card_numb) # Parent node in scene is Cards
	if left:
		neighbor_card.targetpos = neighbor_card.default_pos - spread_factor*Vector2(100,0)
	else:
		neighbor_card.targetpos = neighbor_card.default_pos + spread_factor*Vector2(100,0)
	neighbor_card.setup = true
	neighbor_card.state = REORGANIZE_HAND

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
			targetrot = 0
			targetpos = default_pos
			targetpos.y = get_viewport().size.y - $'../../'.CARD_SIZE.y*zoom_scale
			state = FOCUS_IN_HAND


func _on_focus_mouse_exited():
	match state:
		FOCUS_IN_HAND:
			setup = true
			targetpos = default_pos
			state = REORGANIZE_HAND
