extends MarginContainer

# Declare member variables here.
@onready var card_database = preload("res://assets/cards/cards_database.gd").new()
var card_name = 'mentor'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]
@onready var card_img = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_img)
	$Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(card_img)
	$Card.scale *= size/$Card.texture.get_size()
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
#func _process(delta):
#	pass
