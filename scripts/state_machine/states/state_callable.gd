@tool
@icon("../icons/StateCallable.svg")
extends State
##Call a method by name from any node.
class_name StateCallable

@export var node: Node2D ## The node from which to call the method.
@export var method_name: String ## The name of the method to call in the node.
@export var method_params: Array[Variant] = []
@export var send_statemachine_params := true: ## If true, it will call the method sending the params present in the state machine.
	set(value):
		send_statemachine_params = value
		notify_property_list_changed()
@export var await_signal_to_complete := "" ## Await for a signal to be emitted on the referenced node before set this state as completed.

func enter():
	if await_signal_to_complete != "":
		if node.has_signal(await_signal_to_complete):
			if !node.is_connected(await_signal_to_complete, complete):
				node.connect(await_signal_to_complete, complete)
		else:
			push_warning("No signal '%s' in %s" % [await_signal_to_complete, node.get_path()])
	else:
		complete.call_deferred()
	_call_method_by_name()

func _call_method_by_name():
	var callable = Callable(node, method_name)
	if is_instance_valid(node) and callable.is_valid():
		print("Calling method %s from %s" % [method_name, node.name])
		if method_params.size() > 0:
			callable.callv.call_deferred(method_params)
		elif send_statemachine_params:
			callable.call.call_deferred(state_machine.params)
		else:
			callable.call.call_deferred()
	else:
		push_warning("%s: Invalid method name" % [get_path()])

func _validate_property(property: Dictionary) -> void:
	if property.name == "method_params":
		if send_statemachine_params:
			property.usage = PROPERTY_USAGE_NONE
