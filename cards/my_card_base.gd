extends MarginContainer


# Declare member variables here.
@onready var card_database = preload("res://assets/cards/my_cards_database.gd").new()
var card_name = 'ice_cannon'
@onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]

# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_info)
	$Image.region_rect = card_info[4]
	print($Image.region_rect)
