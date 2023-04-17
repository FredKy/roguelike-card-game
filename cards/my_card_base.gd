extends MarginContainer


# Declare member variables here.
@onready var card_database = preload("res://assets/cards/my_cards_database.gd").new()
#var card_name = 'ice_cannon'
#var card_name = 'warp_time'
var card_name = 'cold_touch'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]

var startpos = 0
var targetpos = 0
var startrot = 0
var targetrot = 0
var orig_scale = 0
var t = 0
const DRAWTIME = 1

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
	orig_scale = scale.x
	
	$HiddenPanel/Image.region_rect = card_info[4]
	print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Info.text = card_info[3]
	
func _physics_process(delta):
	match state:
		IN_HAND:
			pass
		IN_PLAY:
			pass
		IN_MOUSE:
			pass
		FOCUS_IN_HAND:
			pass
		DRAWN_TO_HAND: #animate card from deck to player hand.
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot*(1-t) + targetrot*t
				#scale.x = orig_scale*abs(2*t-1)
				if t < 0.5:
					scale.x = orig_scale*abs(2*(2*t)-1)
				else:
					scale.x = orig_scale
				if $CardBack.visible:
					if t >= 0.25:
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				position = targetpos
				rotation = targetrot
				t = 0
				state = IN_HAND
		REORGANIZE_HAND:
			pass
