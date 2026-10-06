extends Control


@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer

var player: CharacterBody2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	visible = false

	create_slots()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = not visible

	if Input.is_key_pressed(KEY_ESCAPE):
		visible = false

	if visible:
		refresh_inventory()

	get_tree().paused = visible


func create_slots() -> void:
	var slot_scene = preload("res://ui/inventory/InventorySlot.tscn")

	for i in range(36):
		var slot = slot_scene.instantiate()

		grid.add_child(slot)


func refresh_inventory() -> void:
	var slots := grid.get_children()
	var inventory_items: Dictionary = player.inventory.items

	var index := 0

	for item_id in inventory_items:
		if index >= slots.size():
			break

		var amount: int = inventory_items[item_id]

		if amount <= 0:
			continue

		var item: ItemData = ItemDatabase.get_item(item_id)

		if item == null:
			continue

		slots[index].set_item(
			item,
			amount
		)

		index += 1

	for i in range(index, slots.size()):
		slots[i].clear_slot()
