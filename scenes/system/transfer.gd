@icon("res://icons/Transfer.svg")
extends Node2D
##Transfers an entity to a different level or position.
class_name Transfer

@export_file("*.tscn") var level_path = "" ## Leave empty to transfer inside the same level.
@export var destination_name: String = "" ## The name of the destnation. NOTE: destination must be in the "destination" group.
##Force the player to face this direction upon arriving to this destination. [br]
##Leave empty to keep the same facing direction.
@export_category("Destination settings")
@export_enum(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var facing

func _ready() -> void:
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.scene_added.connect(func(incoming_scene, _loading_screen): _complete_transfer(incoming_scene))

func _complete_transfer(incoming_scene):
	_check_transfer(incoming_scene)
	Globals.transfer_complete.emit()

func transfer(params):
	var entity: CharacterEntity = params["entity"]
	if entity is PlayerEntity and level_path:
		_transfer_to_level(entity, level_path)
	elif entity and destination_name:
		_transfer_to_position(entity)

func _transfer_to_level(player, scene_to_load):
	var current_level: Level = Globals.get_current_level()
	if current_level:
		current_level.receive_data({
			destination_name = destination_name,
			player_id = player.player_id
		})
		DataManager.save_level_data()
		SceneManager.swap_scenes(
			scene_to_load,
			current_level.get_parent(),
			current_level,
			Const.TRANSITION.FADE_TO_BLACK
		)

func _transfer_to_position(entity):
	Globals.transfer_start.emit()
	var destination = Globals.get_destination(destination_name)
	if destination:
		entity.move_and_face(destination.position, destination.facing)
	else:
		push_warning("%s: destination %s not found!" % [get_path(), destination])
	await get_tree().create_timer(0.5).timeout
	Globals.transfer_complete.emit()

func _check_transfer(incoming_scene):
	if incoming_scene is not Level:
		return
	var current_level: Level = incoming_scene
	if !current_level:
		return
	var level_data = current_level.get_data()
	if level_data and level_data.destination_name == name:
		Globals.destination_found.emit(get_path())
