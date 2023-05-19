extends Node2D

func set_deck_counter_text(txt):
	$Deck/GlobalDeckCounter/Label.text = str(txt)

func set_health_text(txt):
	$Health.text = str(txt)
