extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_deck_counter_text(txt):
	$Deck/GlobalDeckCounter/Label.text = str(txt)

func set_health_text(txt):
	$Health.text = str(txt)
