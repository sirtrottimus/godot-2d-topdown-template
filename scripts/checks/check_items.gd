extends Check
class_name CheckItems

@export var items: Array[ContentItem] ## Check if the items are present in the player's inventory.
@export var remove_items := true ## Remove the items after a successfull check.

func check(on = null) -> bool:
	if on is not PlayerEntity and items.size() <= 0:
		return true
	for content: ContentItem in items:
		if on.is_item_in_inventory(content.item.resource_name, content.quantity) < 0:
			return false
	_check_inventory_item(on)
	return true

func _check_inventory_item(entity):
	if items.size() > 0 and remove_items and entity.has_method("remove_item_from_inventory"):
		for content: ContentItem in items:
			entity.remove_item_from_inventory(content.item.resource_name, content.quantity)
