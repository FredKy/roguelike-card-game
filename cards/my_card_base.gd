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
const ORGANIZETIME = 0.5
const ZOOMTIME = 0.2
var tween
var tween2

var setup = true
var start_scale = Vector2()
var default_pos = Vector2()
var zoom_scale = 2

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
	print(card_info)
	$CardBack.scale *= size/$CardBack.size
	
	$HiddenPanel/Image.region_rect = card_info[4]
	print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Info.text = card_info[3]
	
	position = startpos
	
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
			else:
				position = targetpos
				rotation = targetrot
				scale = orig_scale*zoom_scale
		DRAWN_TO_HAND: #animate card from deck to player hand.
			
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + targetrot*t
#				if !tween:
#					tween = create_tween()
#					tween.set_ease(Tween.EASE_IN_OUT)
#					tween.set_trans(Tween.TRANS_CUBIC)
#					#tween.interpolate_value(startpos, targetpos-startpos,DRAWTIME,1,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
#					tween.tween_property(self, "position", targetpos, DRAWTIME)
#					tween.parallel().tween_property(self, "rotation", 2*PI+targetrot, DRAWTIME)

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

func reset_pos_rot_scale_and_time():
	startpos = position
	startrot = rotation
	start_scale = scale
	t = 0
	setup = false


func _on_focus_mouse_entered():
	match state:
		IN_HAND, REORGANIZE_HAND:
			state = FOCUS_IN_HAND


func _on_focus_mouse_exited():
	match state:
		FOCUS_IN_HAND:
			state = REORGANIZE_HAND
