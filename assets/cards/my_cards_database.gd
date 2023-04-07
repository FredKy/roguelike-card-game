
# Unitinfo = [Type, Attack, Retaliation, Health, Cost, Name, Melee or Ranged, Special Text]
# Eventinfo = [Type, Cost, Effect]
# Spellinfo = [Type, Cost, Name, Effect]
enum {FOOTMAN, ARCHER, SQUAD_LEADER,
WARRIOR, GUARDIAN, KNIGHT, MERCENARY,
SPEARMAN, MENTOR, TREBUCHET, ICE_CANNON}

const DATA = {
	ICE_CANNON :
		["spell", 2, "ice_cannon", "Deal 7 damage\nto a unit"],
	FOOTMAN : 
		["units", 1, 1, 2, 1, "footman", "Melee"],
	ARCHER :
		["units", 2, 1, 3, 2, "archer", "Ranged,\nimmune to\nretaliation"],
	SQUAD_LEADER :
		["units", 2, 2, 3, 3, "squad_leader", "Melee,\ngive all friendly\n+1 attack and \nretaliation"],
	WARRIOR :
		["units", 4, 0, 2, 3, "rogue", "Melee,\nimmune to\nretaliation"],
	GUARDIAN :
		["units", 1, 3, 6, 3, "guardian", "Melee,\nprotector - stops the unit\nbehind it\nbeing attacked"],
	KNIGHT : 
		["units", 2, 3, 6, 4, "knight", "Melee"],
	MERCENARY :
		["units", 2, 2, 0, 2, "mercenary", "Melee,\nalways retaliates\nreturn to supply when damaged\nor at start of next turn\nafter played, increase\ncost by 1"],
	SPEARMAN :
		["units", 2, 2, 5, 3, "spearman", "Melee or ranged"],
	MENTOR :
		["units", 3, 0, 1, 2, "mentor", "Melee,\nwhen played give\nfriendly unit +2 attack\nand retaliation"],
	TREBUCHET :
		["events", 4, "Deal 6 damage\nto a unit"],
	}
