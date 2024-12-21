extends State
class_name StateTween

@export var object: Node2D
@export var tweens: Array[TweenData]
@export var parallel := true
@export var loops := 1

func enter():
	if not object:
		return
	for t in tweens:
		t.start_value = object.get(t.property)
		t.target_value = t.start_value + str_to_var(t.end_value)
	var tween: Tween = create_tween().set_parallel(parallel).set_loops(loops)
	tween.finished.connect(complete)
	for t in tweens:
		tween.tween_method(
			func(v): object.set(t.property, lerp(t.start_value, t.target_value, t.curve.sample_baked(v))),
			0.0, 1.0, t.duration).set_delay(t.delay)

func exit():
	for t in tweens:
		object.set(t.property, t.start_value)