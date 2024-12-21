extends CharacterEntity
class_name PlayerEntity
##Script attached to the Player node, specifically made to represent the player entities of the game.
##The Player node is used as a base to create the main players.

@export_group("States")
@export var on_transfer_start: State ## State to enable when player starts transfering.
@export var on_transfer_end: State ## State to enable when player ends transfering.

var player_id: int = 1 ## A unique id that is assigned to the player on creation. Player 1 will have player_id = 1 and each additional player will have an incremental id, 2, 3, 4, and so on.
var equipped = 0 ## The id of the weapon equipped by the player.
var inventory: Array[ContentItem] = [] ## The items this player has in its inventory.

func _ready():
	super._ready()
	Globals.transfer_start.connect(func(): 
		on_transfer_start.enable()
	)
	Globals.transfer_complete.connect(func(): on_transfer_end.enable())
	Globals.destination_found.connect(func(destination_path): _move_to_destination(destination_path))
	receive_data(DataManager.get_player_data(player_id))

##Get the index of the item in inventory, -1 if not found.
func is_item_in_inventory(item_name: String, quantity := 1) -> int:
	var item_index := -1
	for i in inventory.size():
		var content: ContentItem = inventory[i]
		if content.item.resource_name == item_name and content.quantity >= quantity:
			item_index = i
	return item_index

##Adds an item to the inventory.
func add_item_to_inventory(item: DataItem, quantity: int):
	var item_index = is_item_in_inventory(item.resource_name)
	if item_index >= 0:
		inventory[item_index].quantity += quantity
		print("%s updated in %s's inventory! q: %s" % [item.resource_name, self.name, inventory[item_index].quantity])
	else:
		var content = ContentItem.new()
		content.item = item
		content.quantity = quantity
		inventory.append(content)
		print("%s added to %s's inventory! q: %s" % [item.resource_name, self.name, quantity])

##Removes an item from the inventory, if the item already exists in inventory.
func remove_item_from_inventory(item_name: String, quantity: int):
	var item_index = is_item_in_inventory(item_name)
	if item_index >= 0:
		inventory[item_index].quantity -= quantity
		if inventory[item_index].quantity > 0:
			print("%s updated in %s's inventory! q: %s" % [item_name, self.name, inventory[item_index].quantity])
		else:
			inventory.remove_at(item_index)
			print("%s removed from %s's inventory! q: 0" % [item_name, self.name])

##Get the player data to save.
func get_data():
	var data = DataPlayer.new()
	var player_data = DataManager.get_player_data(player_id)
	if player_data:
		data = player_data
	data.position = position
	data.facing = facing
	data.hp = health_controller.hp
	data.max_hp = health_controller.max_hp
	data.inventory = inventory
	data.equipped = equipped
	return data

##Handle the received player data (from a save file or when moving to another level).
func receive_data(data):
	if data:
		global_position = data.position
		facing = data.facing
		health_controller.hp = data.hp
		health_controller.max_hp = data.max_hp
		inventory = data.inventory
		equipped = data.equipped

func _move_to_destination(destination_path: String):
	if !destination_path:
		return
	var destination = get_tree().root.get_node(destination_path)
	if !destination:
		return
	var direction = facing
	if destination is Transfer and destination.facing:
		direction = Const.DIR_VECTOR[destination.facing]
	DataManager.save_player_data(player_id, {
		position = destination.global_position,
		facing = direction
	})

func disable_entity(value: bool, delay = 0.0):
	await get_tree().create_timer(delay).timeout
	stop()
	input_enabled = !value
