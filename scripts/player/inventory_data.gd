class_name Inventory
extends Node

var items: Dictionary = {} # Словник {"wood": 2, ...}

func add_item(item: ItemData, amount: int = 1) -> void:
	if items.has(item.id):
		items[item.id] += amount
	else:
		items[item.id] = amount

func get_amount(item_id: String) -> int:
	return items.get(item_id, 0)
	
func remove_item(item_id: String, amount: int = 1) -> bool:
	if not items.has(item_id):
		return false

	if items[item_id] < amount:
		return false

	items[item_id] -= amount

	if items[item_id] <= 0:
		items.erase(item_id)

	return true
