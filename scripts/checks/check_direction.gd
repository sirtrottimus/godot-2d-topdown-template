extends Check
class_name CheckDirection

@export_flags(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var direction ## Check if the entity is facing the right direction.

func check(on = null) -> bool:
	if on is not CharacterEntity:
		return true
	var entity_direction = Const.DIR_BIT[on.facing.floor()]
	if direction and direction > 0 and (direction & entity_direction) == 0:
		return false
	else:
		return true
