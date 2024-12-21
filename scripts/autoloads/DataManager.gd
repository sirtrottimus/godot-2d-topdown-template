# Takes care of loading or creating a new save game and provides appropriate
# resources to the user interface and the entity.
extends Node

# We always keep a reference to the SaveFileManager resource here to prevent it from unloading.
var _file: SaveFileManager

signal game_saved
signal game_loaded

func _ready():
	reset_file_data()

func get_file_data():
	return _file

## Called when starting anew game
func reset_file_data():
	_file = SaveFileManager.new()

## Called when loading a game
func load_file_data():
	_file = SaveFileManager.load_save_file()

func get_player_data(player_id: int):
	var player_data = get_file_data().player_data if _file else null
	if player_data and player_data.size() >= player_id:
		return player_data[player_id]
	return null

## Used to save nodes state data of the level and players data before removing the level.
func save_level_data():
	_save_nodes_data()
	_save_players_data()

## Used to load nodes state data of the level when entering the level.
func load_level_data():
	_load_nodes_data()
	_load_players_data()

func load_game() -> void:
	print("loading...")
	load_file_data()
	_load_game_data()
	game_loaded.emit()

func save_game() -> void:
	print("saving...")
	_save_game_data()
	_save_nodes_data()
	_save_players_data()
	get_file_data().write_save_file()
	game_saved.emit()

func _load_game_data():
	if !get_file_data().game_data:
		return
	var current_level = Globals.get_current_level()
	if current_level and get_file_data().game_data.level != current_level.scene_file_path or !current_level:
		Globals.load_last_saved_level()

func _load_nodes_data():
	for node: Node in _get_save_nodes():
		var path = String(node.get_path())
		if path not in get_file_data().nodes_data:
			get_file_data().nodes_data[path] = _get_node_data(node)
		if node.has_method("receive_data"):
			node.receive_data(get_file_data().nodes_data[path])

func _load_players_data():
	var players = Globals.get_players()
	print_debug("level_loaded %s" % [players.size()])
	for player in players:
		print_debug(player)

func _save_nodes_data():
	for node in _get_save_nodes():
		if node != null:
			var path = String(node.get_path())
			get_file_data().nodes_data[path] = _get_node_data(node)

func _save_players_data():
	var players = Globals.get_players()
	for player in players:
		if player.has_method("get_data"):
			get_file_data().player_data[player.player_id] = player.get_data()

func save_player_data(player_id: int, data: Dictionary):
	var player_data: DataPlayer = get_player_data(player_id)
	if player_data:
		for key in data.keys():
			player_data[key] = data[key]

func _save_game_data():
	get_file_data().game_data = _get_game_data()

func _get_game_data():
	var game_data := DataGame.new()
	game_data.level = Globals.get_current_level().scene_file_path
	return game_data

func _get_node_data(node):
	if node is CharacterEntity:
		return _get_entity_data(node)
	elif node is StateMachine:
		return _get_state_data(node)

func _get_entity_data(entity: CharacterEntity) -> DataEntity:
	var data := DataEntity.new()
	data.position = entity.global_position
	data.facing = entity.facing
	return data

func _get_state_data(state: StateMachine) -> DataState:
	var data := DataState.new()
	data.state_index = state.current_state.get_index()
	return data

func _get_save_nodes():
	var nodes: Array[Node] = get_tree().get_nodes_in_group(Const.GROUP.SAVE)
	return nodes
