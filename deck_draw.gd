extends TextureButton

var deck_size = INF
# Called when the node enters the scene tree for the first time.
func _ready():
	#rect_scale *= $'../../'.CardSize/rect_size
#	scale *= $'../../'.CARD_SIZE/size
	scale *= 0.6*Vector2(290,400)/size
	pivot_offset.x = size.x/2
	pivot_offset.y = size.y/2


func _gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		if deck_size > 0:
			deck_size = $'../../'.draw_card()
			if deck_size == 0:
				disabled = true
