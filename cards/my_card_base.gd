extends MarginContainer


# Declare member variables here.
@onready var card_database = preload("res://assets/cards/my_cards_database.gd").new()
#var card_name = 'ice_cannon'
#var card_name = 'warp_time'
var card_name = 'cold_touch'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]

# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_info)
	$HiddenPanel/Image.region_rect = card_info[4]
	print($HiddenPanel/Image.region_rect)
	$CostRect/CostRect2/Cost.text = str(card_info[1])
	$VBoxContainer/Name.text = card_info[2]
	$VBoxContainer/Info.text = card_info[3]
	
