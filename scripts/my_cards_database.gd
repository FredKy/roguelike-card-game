# Spellinfo = [Type, Cost, Name, Effect, Image, Damage, Shield, ]
enum {ICE_CANNON, WARP_TIME, COLD_TOUCH, ENERGY_SHIELD}

const DATA = {
	COLD_TOUCH:
		["spell", 1, "Cold Touch", "Apply 2 chill\nto an enemy", Rect2(9728,64,256,192), 2 ,0],
	ICE_CANNON :
		["attack", 2, "Ice Cannon", "Deal 7 damage\nto an enemy", Rect2(4864,0,256,192), 7, 0],
	WARP_TIME:
		["spell", 3, "Warp Time", "Target enemy passes\n a turn", Rect2(7424,64,256,192), 0, 0],
	ENERGY_SHIELD:
		["shield", 1, "Energy Shield", "Add 6 to shield", Rect2(1280,64,256,192), 0, 6]
	}
