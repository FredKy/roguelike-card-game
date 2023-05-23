extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= $'../../'.CARD_SIZE/size
	scale *= 0.5
	disabled = true # Replace with function body.
