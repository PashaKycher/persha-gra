extends Node

var items: Dictionary = {}

func _ready() -> void:
	register_item(preload("res://data/items/objects/wood.tres"))
	register_item(preload("res://data/items/objects/stone.tres"))
	register_item(preload("res://data/items/objects/branch.tres"))
	register_item(preload("res://data/items/objects/turnip_seed.tres"))
	register_item(preload("res://data/items/tool/stone_knife.tres"))
	register_item(preload("res://data/items/tool/stone_hammer.tres"))
	register_item(preload("res://data/items/tool/stone_axe.tres"))
	register_item(preload("res://data/items/tool/stone_pickaxe.tres"))
	register_item(preload("res://data/items/tool/stone_hoe.tres"))
	register_item(preload("res://data/items/scroll/stone_knife_scroll.tres"))
	register_item(preload("res://data/items/scroll/stone_hammer_scroll.tres"))
	register_item(preload("res://data/items/scroll/stone_pickaxe_scroll.tres"))
	register_item(preload("res://data/items/scroll/stone_axe_scroll.tres"))
	register_item(preload("res://data/items/scroll/stone_hoe_scroll.tres"))

func register_item(item: ItemData) -> void:
	items[item.id] = item

func get_item(item_id: String) -> ItemData:
	return items.get(item_id)
