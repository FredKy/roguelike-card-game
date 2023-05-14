extends TextureButton

@onready var game_state = get_node("/root/GameState")
# Node index for easy reference in graph
@export var index: int = 0
@export var texture: Texture = load("res://assets/images/icons/Skull_Icon_(Noun_Project)_modified.png")
@export var scene_path = "res://playspace.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	texture_normal = texture
	texture_disabled = texture

func player_is_on_node(b):
	$RedDownArrow/ArrowAP.play("move_up_and_down")
	$RedDownArrow.visible = b
	$Wanderer.visible = b
	if b:
		self_modulate = Color(1,1,1,0)
	else:
		self_modulate = Color(1,1,1,1)

func play_scale_animation():
	$AnimationPlayer.play("scale")

func _on_pressed():
	game_state.global_current_map_node = index
	get_tree().change_scene_to_file(scene_path)
