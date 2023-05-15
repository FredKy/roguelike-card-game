extends Control



func init(value = "0"):
	$Label.text = value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_label_text(txt):
	$Label.text = str(txt)
