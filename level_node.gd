extends TextureButton

@onready var game_state = get_node("/root/GameState")
# Node index for easy reference in graph
@export var index: int = 0
@export var texture: Texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/images/icons/Skull_Icon_(Noun_Project)_modified.png"))
@export var scene_path = "res://playspace.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	texture_normal = texture
	texture_disabled = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_scale_animation():
	$AnimationPlayer.play("scale")

func _on_pressed():
	game_state.global_current_map_node = index
	get_tree().change_scene_to_file(scene_path)
