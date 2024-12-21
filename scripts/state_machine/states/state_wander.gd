extends StateEntity
##Makes an entity wander around randomly.
class_name StateWander

@export var wander_time_range: = Vector2.ZERO ##Min (x) and max (y) range time values.

var wander_time: float
var direction = Vector2.ZERO

func enter():
	super.enter()
	_wander()

func update(delta: float):
	if wander_time > 0 and not entity.is_blocked:
		wander_time -= delta
	else:
		_wander()

func physics_update(_delta: float):
	entity.move(direction)

func _wander():
	direction = Vector2(randf_range(-1, 1), randf_range(-1 , 1)).normalized()
	wander_time = randf_range(wander_time_range.x, wander_time_range.y)
