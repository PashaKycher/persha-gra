#class_name ItemDatabase
extends Node


var items: Dictionary = {}


func _ready() -> void:
	register_item(preload("res://data/items/wood.tres"))


func register_item(item: ItemData) -> void:
	items[item.id] = item


func get_item(item_id: String) -> ItemData:
	return items.get(item_id)
