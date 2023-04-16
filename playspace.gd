extends Node2D

const CARD_BASE := preload("res://cards/card_base.tscn")
var player_hand := preload("res://cards/player_hand.gd").new()
var card_selected = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_released("leftclick"):
		var new_card = CARD_BASE.instantiate()
		var deck_size = player_hand.card_list.size()
		if (deck_size < 1):
			return
		card_selected = randi() % player_hand.card_list.size()
		new_card.card_name = player_hand.card_list[card_selected]
		new_card.position = get_global_mouse_position()
		new_card.scale *= 0.6
		$Cards.add_child(new_card)
		player_hand.card_list.erase(player_hand.card_list[card_selected])
		

