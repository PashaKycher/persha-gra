class_name Inventory
extends Control


@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer

var player: CharacterBody2D

# Словник для збереження кількості предметів: {"wood": 5, "stone": 2}
var items: Dictionary = {}


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	visible = false

	create_slots()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory()


func toggle_inventory() -> void:
	visible = not visible


func create_slots() -> void:
	var slot_scene := preload("res://ui/inventory/InventorySlot.tscn")
	
	for i in range(12):
		var slot := slot_scene.instantiate()
		grid.add_child(slot)


# Функція, яку викликає HUD для відображення кількості ресурсів
func get_amount(item_name: String) -> int:
	if items.has(item_name):
		return items[item_name]
	return 0


# Функція для додавання предметів в інвентар (знадобиться далі за туторіалом)
func add_item(item_name: String, amount: int = 1) -> void:
	if items.has(item_name):
		items[item_name] += amount
	else:
		items[item_name] = amount
