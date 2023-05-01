extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_gui_input(event):
	if Input.is_action_just_released("leftclick"):
		print("Hej")
		print($'../../'.player_deck.card_list)
		print($'../../Cards'.get_children())
		print($'../../Cards'.get_child_count())
		print($'../../DiscardedCards'.get_children())
		print($'../../DiscardedCards'.get_child_count())
		#$'../../'.reshuffle_card()
		$'../../'.reshuffle_x_cards($'../../DiscardedCards'.get_child_count(), 0.11)
