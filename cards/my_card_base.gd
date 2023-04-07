extends MarginContainer


# Declare member variables here.
onready var card_database = preload("res://assets/cards/cards_database.gd")
var card_name = 'footman'
onready var card_info = card_database.DATA[card_database.get(card_name.to_upper())]
onready var card_img = str("res://assets/cards/", card_info[0], "/", card_name, ".png")

# Called when the node enters the scene tree for the first time.
func _ready():
	print(card_img)
	#$Border.scale *= rect_size/$Border.texture.get_size()
#	$Card.texture = load(card_img)
#	$Card.scale *= rect_size/$Card.texture.get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
