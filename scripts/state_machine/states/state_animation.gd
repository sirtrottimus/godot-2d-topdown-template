@tool
@icon("../icons/StateAnimation.svg")
extends State
##Starts an animation from AnimationPlayer or AnimationTree.
class_name StateAnimation

@export var animation_player: AnimationPlayer:
	set(value):
		animation_player = value
		notify_property_list_changed()
@export var animation_tree: AnimationTree:
	set(value):
		animation_tree = value
		notify_property_list_changed()
@export var animation: String
@export var sync_animations := false

var saved_position: float
var animation_state: AnimationNodeStateMachinePlayback

func enter():
	if animation_player and not animation.is_empty():
		animation_player.play(animation)
		await animation_player.animation_finished
		complete()
	if animation_tree and not animation.is_empty():
		animation_state = animation_tree.get("parameters/playback") if not animation_state else animation_state
		animation_state.start(animation)
		await animation_tree.animation_finished
		complete()
	if saved_position:
		animation_player.seek(saved_position)

func exit():
	if sync_animations and animation_player and animation_player.current_animation:
		saved_position = animation_player.current_animation_position

func _validate_property(property: Dictionary) -> void:
	if property.name == "animation_player":
		if animation_tree:
			property.usage = PROPERTY_USAGE_NONE
	if property.name == "animation_tree":
		if animation_player:
			property.usage = PROPERTY_USAGE_NONE