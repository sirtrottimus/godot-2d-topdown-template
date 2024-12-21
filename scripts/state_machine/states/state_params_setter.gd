@tool
extends State
## Set some properties to a node present in the parent StateMachine params.
class_name StateParamsSetter

@export_category("Set Properties")
@export var node: Node2D: ## The node in which you want to set the properties.[br]It has priority over param_key.
	set(value):
		node = value
		notify_property_list_changed()
@export var param_key: String: ## Alternatively to selecting a node, you can indicate an element present in the State Machine params in which to set the properties.
	set(value):
		param_key = value
		notify_property_list_changed()
@export var on_enter: Dictionary[String, Variant] ## Set some properties to the node when entering the state.
@export var on_exit: Dictionary[String, Variant] ## Set some properties to the node when exiting the state.

func enter():
	var set_params_on = _get_node()
	if not set_params_on:
		return
	for prop in on_enter:
		set_params_on.set.call_deferred(prop, on_enter[prop])
	complete()

func exit():
	var set_params_on = _get_node()
	if not set_params_on:
		return
	for prop in on_exit:
		set_params_on.set.call_deferred(prop, on_exit[prop])

func _get_node():
	var set_params_on = null
	if node:
		set_params_on = node
	elif state_machine.params.has(param_key):
		set_params_on = state_machine.params[param_key]
	else:
		push_warning("Node %s not found in %s" % [param_key, get_path()])
	return set_params_on

func _validate_property(property: Dictionary) -> void:
	if property.name == "node":
		if param_key:
			property.usage = PROPERTY_USAGE_NONE
	if property.name == "param_key":
		if node:
			property.usage = PROPERTY_USAGE_NONE