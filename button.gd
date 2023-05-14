extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		print("Hej")
		print($'../../'.player_deck.card_list)
		print($'../../Cards'.get_children())
		print($'../../Cards'.get_child_count())
		print($'../../DiscardedCards'.get_children())
		print($'../../DiscardedCards'.get_child_count())
		#$'../../'.reshuffle_card()
		if $'../../'.player_deck.card_list.size() == 0 and $'../../DiscardedCards'.get_child_count() > 5:
			$'../../'.reshuffle_x_cards($'../../DiscardedCards'.get_child_count(), 0.11)
			$'../../'.draw_x_cards(6, 0.2)
