extends Control

const STARTING_ENERGY = 4
const MAX_ENERGY = 4
var energy

# Called when the node enters the scene tree for the first time.
func _ready():
	energy = STARTING_ENERGY
	$MarginContainer/BG/Amount.text = str(STARTING_ENERGY) + "/" + str(MAX_ENERGY)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reduce_energy(n):
	energy -= n
	$MarginContainer/BG/Amount.text = str(energy) + "/" + str(MAX_ENERGY)

func reset_energy():
	energy = STARTING_ENERGY
	$MarginContainer/BG/Amount.text = str(energy) + "/" + str(MAX_ENERGY)
