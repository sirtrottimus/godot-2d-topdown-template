extends CanvasLayer

@export var player: PlayerEntity
@export var action_trigger = "ui_cancel"

@onready var item_list: ItemList = $MarginContainer/ItemList

var is_open := false

func _ready() -> void:
	visible = is_open

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action_trigger):
		toggle_inventory()

func toggle_inventory():
	is_open = !is_open
	visible = is_open
	get_tree().paused = is_open
	if is_open:
		_update_item_list()
	else:
		item_list.clear()

func _update_item_list():
	if !player:
		return
	for content: ContentItem in player.inventory:
		var item = content.item
		var item_name = "%s x%s" %[item.resource_name, content.quantity]
		item_list.add_item(item_name, item.icon)
