@tool
@icon("./icons/StateMachine.svg")
extends Node
##Main controller for the states. States should be placed as children of a StateMachine node.
class_name StateMachine

@export_category("Config")
@export var current_state: State = null: ##The currenlty active state. You can also set here the initial state of the StateMachine.
	set(value):
		current_state = value
		current_state_name = current_state.name if current_state else StringName()
		update_configuration_warnings()
@export var disabled := false ## Determines if disable this StateMachine

@onready var n_of_states = get_child_count()

var initialized := false
var previous_state: State = null
var states: Array[State]
var params = {}
var current_state_name

signal state_changed(old_state, new_state)

func _ready():
	if Engine.is_editor_hint():
		set_process_input(false)
		set_process_shortcut_input(false)
		set_process_unhandled_input(false)
		set_physics_process(false)
		return
	await owner.ready
	_init_states()
	_get_states()
	_enter_states()

func _init_states():
	var children = get_children(true).filter(func(node): return node is State)
	for state in children:
		state.state_machine = self
	initialized = true
	Globals.state_machine_initialized.emit(self)

func _get_states():
	if !current_state or current_state and current_state.disabled:
		return
	states = []
	states.append(current_state)
	for child in current_state.get_children():
		if child is State and !child.disabled:
			states.append(child)

func enable_state(state: State):
	if state == current_state:
		return
	if current_state:
		previous_state = current_state
	_exit_states()
	current_state = state
	state_changed.emit(previous_state, current_state)
	_get_states()
	_enter_states()

func disable_state(_state: State):
	_exit_states()
	states = []
	current_state = null

func _process(delta):
	_update_states(delta)

func _physics_process(delta):
	_physics_update_states(delta)

func _enter_states():
	for state in states:
		state.enter()
		state.active = !disabled
	print("%s entered states: %s" % [get_parent().name, states.map(func(state): return state.name)])

func _exit_states():
	for state in states:
		state.exit()
		state.active = false

func _update_states(delta):
	if disabled or !initialized:
		return
	for state in states:
		if state.active:
			state.update(delta)

func _physics_update_states(delta):
	if disabled or !initialized:
		return
	for state in states:
		if state.active:
			state.physics_update(delta)

func receive_data(data: DataState):
	if data:
		var state_node: State = get_child(data.state_index)
		state_node.enable(params)

func enable_state_by_name(state_name: String):
	var state_node: State = get_node_or_null(state_name)
	if state_node:
		state_node.enable(params)
	else:
		push_warning("Can't find state with name: %s." % [state_name])

func enable_next_state(_params = null):
	var next_index = 0
	if current_state:
		var current_state_index = current_state.get_index()
		next_index = current_state_index + 1
	if next_index < n_of_states:
		var next_state: State = get_child(next_index)
		if next_state:
			next_state.enable(_params)
	elif current_state:
		current_state.disable()

func enable_previous_state():
	if previous_state:
		previous_state.enable(params)

func _get_configuration_warnings() -> PackedStringArray:
	if !current_state:
		return ["Initial state not set."]
	return []