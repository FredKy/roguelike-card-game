# Unitinfo = [Type, Attack, Retaliation, Health, Cost, Name, Melee or Ranged, Special Text]
# Eventinfo = [Type, Cost, Effect]
# Spellinfo = [Type, Cost, Name, Effect]
enum {ICE_CANNON, WARP_TIME, COLD_TOUCH}

const DATA = {
	COLD_TOUCH:
		["spell", 1, "Cold Touch", "Apply 2 chill\nto an enemy", Rect2(9728,64,256,192)],
	ICE_CANNON :
		["spell", 2, "Ice Cannon", "Deal 7 damage\nto an enemy", Rect2(4864,0,256,192)],
	WARP_TIME:
		["spell", 3, "Warp Time", "Target enemy passes\n a turn", Rect2(7424,64,256,192)],
	}
