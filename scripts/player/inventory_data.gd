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
