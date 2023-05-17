extends Node

##unneeded functions, to_snake_case and capitalize do these things
##Changes "Ice Cannon" to "ice_cannon"
#func card_name_converter(string):
#	return string.to_lower().replace(' ', '_')
#
##Changes "ice_cannon" to "Ice Cannon"
#func snake_to_display_text(string):
#	return string.capitalize()

#Custom ease in and ease out-like curve
#https://stackoverflow.com/questions/13462001/ease-in-and-ease-out-animation-formula
func parametric_blend(x):
	var sq = x * x
	return sq / (2.0 * (sq - x) + 1.0)
