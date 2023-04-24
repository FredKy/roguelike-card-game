extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= $'../../'.CARD_SIZE/size
	disabled = true # Replace with function body.
