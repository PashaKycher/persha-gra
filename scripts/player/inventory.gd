extends Control

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer
@onready var equipment_slots: GridContainer = $Panel/VBoxContainer/EquipmentSlots

@export_group("Позиціювання підказки")
@export var tooltip_offset: Vector2 = Vector2(16, 12)
@export var tooltip_show_on_left_offset: float = 8.0

var player: CharacterBody2D
var equipment_slot_nodes: Array[Control] = []
var context_menu: PanelContainer
var context_item: ItemData = null
var context_source: String = ""
var context_equipment_index: int = -1
var recipe_scroll_tooltip: Control
# своя панель підказки
const RECIPE_SCROLL_TOOLTIP_SCENE: PackedScene = preload(
    "res://ui/tooltips/RecipeScrollTooltip.tscn"
)


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	visible = false
	create_slots()
	setup_equipment_slots()
	setup_context_menu()
	recipe_scroll_tooltip = RECIPE_SCROLL_TOOLTIP_SCENE.instantiate()
	add_child(recipe_scroll_tooltip)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = not visible
		if not visible and context_menu:
			context_menu.hide() # Ховаємо меню при закритті інвентарю
	if Input.is_key_pressed(KEY_ESCAPE):
		visible = false
		if context_menu:
			context_menu.hide() # Ховаємо меню по ESC
	if visible:
		refresh_inventory()
		refresh_equipment()
	get_tree().paused = visible

func create_slots() -> void:
	var slot_scene = preload("res://ui/inventory/InventorySlot.tscn")
	for i in range(36):
		var slot = slot_scene.instantiate()
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		grid.add_child(slot)
		slot.context_requested.connect(_on_inventory_slot_context_requested)

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

func setup_equipment_slots() -> void:
	equipment_slot_nodes.clear()
	for slot in equipment_slots.get_children():
		equipment_slot_nodes.append(slot)
		if not slot.context_requested.is_connected(
			_on_equipment_slot_context_requested
		):
			slot.context_requested.connect(
				_on_equipment_slot_context_requested
			)

func refresh_equipment() -> void:
	if player == null or player.equipment == null:
		return
	for i in range(equipment_slot_nodes.size()):
		var slot: Control = equipment_slot_nodes[i]
		var item: ItemData = player.equipment.get_item(i)
		if item != null:
			slot.set_item(item, 1)
		else:
			slot.clear_slot()

func setup_context_menu() -> void:
	var menu_scene: PackedScene = preload("res://ui/tooltips/ItemContextMenu.tscn")
	context_menu = menu_scene.instantiate() as PanelContainer
	add_child(context_menu)
	context_menu.action_selected.connect(
		_on_context_menu_action_selected
	)


func _on_inventory_slot_context_requested(
	slot: Control,
	item: ItemData
) -> void:
	if item == null or player == null:
		return
	hide_recipe_scroll_tooltip()
	if context_menu.visible:
		context_menu.hide()
	context_item = item
	context_source = "inventory"
	context_equipment_index = -1
	context_menu.setup_for_item(item)
	var slot_rect: Rect2 = slot.get_global_rect()
	var pos: Vector2 = slot_rect.position + slot_rect.size
	context_menu.popup(Rect2(pos, Vector2.ZERO))


func _on_context_menu_action_selected(action: String) -> void:
	if player == null or context_item == null:
		return
	if context_source != "inventory":
		return
	match action:
		"equip":
			_on_context_menu_id_pressed(0)
		"learn":
			_on_context_menu_id_pressed(1)
		"drop":
			print("Дію «Викинути» буде підключено на наступному етапі.")
		"destroy":
			print("Дію «Знищити» буде підключено на наступному етапі.")

func _on_equipment_slot_context_requested(
	slot: Control,
	item: ItemData
) -> void:
	if item == null or player == null:
		return
	var slot_index: int = equipment_slot_nodes.find(slot)
	if slot_index == -1:
		return
	# Знімаємо предмет одразу, без контекстного меню.
	if player.equipment.unequip_item(
		slot_index,
		player.inventory
	):
		refresh_inventory()
		refresh_equipment()
	else:
		return

func _on_context_menu_id_pressed(id: int) -> void:
	if player == null or context_item == null:
		return
	if context_source != "inventory":
		return
	# Вивчення рецепту із сувою
	if id == 1:
		if not context_item is RecipeScrollData:
			return
		var scroll := context_item as RecipeScrollData
		if scroll.recipe == null:
			push_warning("У сувою не прив'язаний рецепт.")
			return
		if player.has_learned_recipe(scroll.recipe):
			context_menu.hide()
			context_item = null
			context_source = ""
			return
		if player.learn_recipe(scroll.recipe):
			player.inventory.remove_item(scroll.id, 1)
			context_menu.hide()
			context_item = null
			context_source = ""
			context_equipment_index = -1
			refresh_inventory()
			var crafting_ui := get_tree().current_scene.get_node_or_null("Hud/CraftingUI")
			if crafting_ui:
				crafting_ui.update_recipe_list()
		return
	# Екіпірування інструмента
	if id != 0:
		return
	if context_item.tool_data == null:
		return
	var tool_type: StringName = context_item.tool_data.tool_type
	if player.equipment.is_tool_type_equipped(tool_type):
		return
	var free_slot: int = -1
	for i in range(player.equipment.SLOT_COUNT):
		if player.equipment.get_item(i) == null:
			free_slot = i
			break
	if free_slot == -1:
		return
	if player.equipment.equip_item(
		context_item,
		player.inventory,
		free_slot
	):
		refresh_inventory()
		refresh_equipment()
	context_item = null
	context_source = ""
	context_equipment_index = -1

func show_recipe_scroll_tooltip(item: ItemData, slot: Control) -> void:
	if not item is RecipeScrollData:
		hide_recipe_scroll_tooltip()
		return
	if recipe_scroll_tooltip == null:
		return
	recipe_scroll_tooltip.show_scroll_tooltip(item as RecipeScrollData)
	var slot_rect: Rect2 = slot.get_global_rect()
	var tooltip_size: Vector2 = recipe_scroll_tooltip.size
	var viewport_size: Vector2 = get_viewport_rect().size
	var position := slot_rect.position + Vector2(
		slot_rect.size.x + tooltip_offset.x,
		tooltip_offset.y
	)
	# Якщо справа недостатньо місця — відкриваємо зліва
	if position.x + tooltip_size.x > viewport_size.x:
		position.x = slot_rect.position.x - tooltip_size.x - tooltip_show_on_left_offset
	# Переводимо координати у локальну систему InventoryUI
	recipe_scroll_tooltip.position = get_global_transform().affine_inverse() * position

func hide_recipe_scroll_tooltip() -> void:
	if recipe_scroll_tooltip != null:
		recipe_scroll_tooltip.hide_tooltip()

func _on_slot_hovered(slot: Control, item: ItemData) -> void:
	show_recipe_scroll_tooltip(item, slot)

func _on_slot_unhovered() -> void:
	hide_recipe_scroll_tooltip()
