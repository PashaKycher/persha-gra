extends Node

var items: Dictionary = {}

func _ready() -> void:
	register_item(preload("res://data/resource/objects/wood.tres"))
	register_item(preload("res://data/resource/objects/stone.tres"))
	register_item(preload("res://data/resource/objects/branch.tres"))
	register_item(preload("res://data/tools/objects/stoneTools/stone_axe.tres"))
	register_item(preload("res://data/tools/objects/stoneTools/stone_hammer.tres"))
	register_item(preload("res://data/tools/objects/stoneTools/stone_hoe.tres"))
	register_item(preload("res://data/tools/objects/stoneTools/stone_knife.tres"))
	register_item(preload("res://data/tools/objects/stoneTools/stone_pickaxe.tres"))
	register_item(preload("res://data/recipes/objects/stone_axe_scroll.tres"))
	register_item(preload("res://data/recipes/objects/stone_hammer_scroll.tres"))
	register_item(preload("res://data/recipes/objects/stone_hoe_scroll.tres"))
	register_item(preload("res://data/recipes/objects/stone_knife_scroll.tres"))
	register_item(preload("res://data/recipes/objects/stone_pickaxe_scroll.tres"))
	register_item(preload("res://data/farming/objects/fertilizer/growth_fertilizer.tres"))
	register_item(preload("res://data/farming/objects/fertilizer/yield_fertilizer.tres"))
	register_item(preload("res://data/farming/objects/resource/tomato.tres"))
	register_item(preload("res://data/farming/objects/resource/turnip.tres"))
	register_item(preload("res://data/farming/objects/seed/turnip_seed.tres"))
	register_item(preload("res://data/farming/objects/seed/tomato_seed.tres"))

func register_item(item: ItemData) -> void:
	items[item.id] = item

func get_item(item_id: String) -> ItemData:
	return items.get(item_id)
