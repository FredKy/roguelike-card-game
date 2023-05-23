extends TextureButton

var deck_size = INF
# Called when the node enters the scene tree for the first time.
func _ready():
#	scale *= 0.5*0.5
	print(scale)
	scale *= $'../../'.CARD_SIZE/size
	print(scale)
	scale *= 0.5
	print(size)
	print(scale)
	print(size)


# No need for input now.
#func _gui_input(_event):
#	#deck_size = $'../../'.player_deck.card_list.size()
#	deck_size = $'../../'.player_deck.size()
#	if Input.is_action_just_released("leftclick"):
#		if deck_size > 0:
#			deck_size = $'../../'.draw_card()
#			if deck_size == 0:
#				disabled = true
