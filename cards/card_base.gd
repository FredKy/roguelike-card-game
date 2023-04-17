extends MarginContainer

# Declare member variables here.
@onready var card_database = preload("res://assets/cards/cards_database.gd").new()
var card_name = 'mentor'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]
@onready var card_img = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

var startpos = 0
var targetpos = 0
var startrot = 0
var targetrot = 0
var t = 0
var orig_scale = 0
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
	print(card_img)
	$Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(card_img)
	$Card.scale *= size/$Card.texture.get_size()
	$CardBack.scale *= size/$CardBack.texture.get_size()
	orig_scale = scale.x
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
