extends TextureButton

@onready var game_state = get_node("/root/GameState")
# Node index for easy reference in graph
@export var index: int = 0
@export var texture: Texture = load("res://assets/images/icons/Skull_Icon_(Noun_Project)_modified.png")
@export var battle_scene_path = "res://playspace.tscn"
@export var rest_scene_path = "res://misc_scenes/rest_scene.tscn"
@export var big = false

enum LOCATION_TYPE {
	BATTLE,
	REST,
}

enum {
	BATTLE,
	REST,
}

enum BATTLE_TYPE {
	SKELETON_WARRIOR,
	SKELETON_SPEARMAN,
	WARRIOR_AND_SPEARMAN,
	SKELETON_ARCHER,
	KNIGHT,
}

enum BACKGROUND {
	SUMMER_FOREST,
	WINTER_FOREST,
}

#Determines what kind of location this area is
@export var location_type: LOCATION_TYPE

#Determines what enemies to load in playscape
@export var battle_type: BATTLE_TYPE

#Determines what background to load in playscape
@export var background: BACKGROUND

# Player has visited node
@export var visited = false

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_normal = texture
	texture_disabled = texture

func transparent():
	modulate = Color(1,1,1,0.5)

func player_is_on_node(b):
	$RedDownArrow/ArrowAP.play("move_up_and_down")
	$RedDownArrow.visible = b
	$Wanderer.visible = b
	if b:
		modulate = Color(1,1,1,1)
		self_modulate = Color(1,1,1,0)
	else:
		self_modulate = Color(1,1,1,1)

func play_scale_animation():
	$AnimationPlayer.play("scale")

func _on_pressed():
	game_state.global_current_map_node = index
	game_state.global_visited_nodes.append(index)
	game_state.global_next_location_type = location_type
	game_state.global_next_battle_type = battle_type
	game_state.global_next_background = background
	var transition = load("res://misc_scenes/transition_effect.tscn").instantiate()
	$'../../'.add_child(transition)
	await transition.fade_in()
	match location_type:
		BATTLE:
			get_tree().change_scene_to_file(battle_scene_path)
		REST:
			get_tree().change_scene_to_file(rest_scene_path)
