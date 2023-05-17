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

func append_value_to_queue(name_of_queue: String, value, dict):
	if not name_of_queue in dict:
		dict[name_of_queue] = [value]
		print("Queue with name " + name_of_queue + " created: " + str(dict))
	else:
		print("Before append: " + str(dict))
		dict[name_of_queue].append(value)
		print("After append: " + str(dict))
