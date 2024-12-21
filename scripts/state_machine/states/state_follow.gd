@tool
extends StateEntity
##Makes an entity follow a target. The entity won't avoids obstacles. Use a StateNavigation instead.
class_name StateFollow

@export_category("Target")
@export var target_player_id := 0: ## If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		notify_property_list_changed()
		_init_target.call_deferred()
@export var target: Node2D = null: ## The node to follow.
	set(value):
		target = value
		notify_property_list_changed()
		if is_node_ready():
			if not flee:
				print("%s is following: %s" % [entity_name, target])
			else:
				print("%s is fleeing from: %s" % [entity_name, target])
@export_category("Settings")
@export var flee := false: ## If true, entity will flee away from the target instead of following it.
	set(value):
		flee = value
		if entity:
			entity.invert_moving_direction = value

func enter():
	super.enter()
	entity.invert_moving_direction = flee
	_init_target.call_deferred()

func exit():
	super.exit()
	entity.invert_moving_direction = false

func physics_update(_delta):
	_follow()

func _follow():
	if is_instance_valid(target) and entity:
		entity.move_towards(target.global_position)

func _init_target():
	if Engine.is_editor_hint():
		return
	await get_tree().physics_frame
	if target_player_id > 0:
		target = Globals.get_player(target_player_id)
	elif target:
		target = target

func _validate_property(property: Dictionary) -> void:
	if property.name == "target":
		if target_player_id > 0:
			property.usage = PROPERTY_USAGE_NONE
	if property.name == "target_player_id":
		if target != null:
			property.usage = PROPERTY_USAGE_NONE