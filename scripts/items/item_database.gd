#class_name ItemDatabase
extends Node


var items: Dictionary = {}


func _ready() -> void:
	register_item(preload("res://data/items/objects/wood.tres"))
	register_item(preload("res://data/items/objects/stone.tres"))
	register_item(preload("res://data/items/objects/branch.tres"))
	register_item(preload("res://data/items/tool/stone_knife.tres"))
	register_item(preload("res://data/items/tool/stone_hammer.tres"))
	register_item(preload("res://data/items/tool/stone_axe.tres"))
	register_item(preload("res://data/items/tool/stone_pickaxe.tres"))


func register_item(item: ItemData) -> void:
	items[item.id] = item


func get_item(item_id: String) -> ItemData:
	return items.get(item_id)
