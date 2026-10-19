extends Control

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer
@onready var equipment_slots: GridContainer = $Panel/VBoxContainer/EquipmentSlots

@export_group("Позиціювання підказки")
@export var tooltip_offset: Vector2 = Vector2(16, 12)
@export var tooltip_show_on_left_offset: float = 8.0
var amount_dialog: PanelContainer
var pending_item_action: String = ""
var player: CharacterBody2D
var equipment_slot_nodes: Array[Control] = []
var context_menu: PanelContainer
var context_item: ItemData = null
var context_source: String = ""
var context_equipment_index: int = -1
var recipe_scroll_tooltip: Control
var recipe_scroll_learn_window: RecipeScrollLearnWindow
const RECIPE_SCROLL_TOOLTIP_SCENE: PackedScene = preload(
    "res://ui/tooltips/RecipeScrollTooltip.tscn"
)
const DROPPED_ITEM_SCENE: PackedScene = preload(
	"res://scenes/world/item/DroppedItem.tscn"
)
const ITEM_AMOUNT_DIALOG_SCENE: PackedScene = preload(
	"res://ui/tooltips/ItemAmountDialog.tscn"
)
const RECIPE_SCROLL_LEARN_WINDOW_SCENE: PackedScene = preload(
	"res://ui/tooltips/RecipeScrollLearnWindow.tscn.tscn"
)


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	visible = false
	create_slots()
	setup_equipment_slots()
	setup_context_menu()
	recipe_scroll_tooltip = RECIPE_SCROLL_TOOLTIP_SCENE.instantiate()
	amount_dialog = ITEM_AMOUNT_DIALOG_SCENE.instantiate() as PanelContainer
	add_child(amount_dialog)
	amount_dialog.confirmed.connect(_on_amount_dialog_confirmed)
	amount_dialog.cancelled.connect(_on_amount_dialog_cancelled)
	add_child(recipe_scroll_tooltip)
	recipe_scroll_learn_window = (
		RECIPE_SCROLL_LEARN_WINDOW_SCENE.instantiate()
		as RecipeScrollLearnWindow
	)
	add_child(recipe_scroll_learn_window)
	recipe_scroll_learn_window.scroll_learned.connect(
		_on_recipe_scroll_learned
	)
	recipe_scroll_learn_window.cancelled.connect(
		_on_recipe_scroll_learning_cancelled
)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = not visible
	if not visible:
		if context_menu:
			context_menu.hide()
		if recipe_scroll_learn_window:
			recipe_scroll_learn_window.close_window()
	if Input.is_key_pressed(KEY_ESCAPE):
		visible = false
		if context_menu:
			context_menu.hide()
		if recipe_scroll_learn_window:
			recipe_scroll_learn_window.close_window()
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
			request_item_action("drop")
		"destroy":
			request_item_action("destroy")

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
		# Якщо рецепт уже вивчений — нічого не відкриваємо.
		if player.has_learned_recipe(scroll.recipe):
			clear_context_item()
			return
		hide_recipe_scroll_tooltip()
		context_menu.hide()
		recipe_scroll_learn_window.open_for_scroll(scroll)
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

func request_item_action(action: String) -> void:
	if player == null or context_item == null:
		return
	var available_amount: int = player.inventory.get_amount(context_item.id)
	if available_amount <= 0:
		clear_context_item()
		refresh_inventory()
		return
	# Одну одиницю обробляємо без додаткового вікна.
	if available_amount == 1:
		execute_item_action(action, 1)
		return
	# Якщо предметів декілька — просимо вибрати кількість.
	pending_item_action = action
	var dialog_title: String
	match action:
		"drop":
			dialog_title = "Викинути предмет"
		"destroy":
			dialog_title = "Знищити предмет"
		_:
			return
	amount_dialog.global_position = context_menu.global_position
	amount_dialog.open_dialog(dialog_title, available_amount)

func _on_amount_dialog_confirmed(selected_amount: int) -> void:
	if pending_item_action.is_empty():
		return
	var action := pending_item_action
	pending_item_action = ""
	execute_item_action(action, selected_amount)

func _on_amount_dialog_cancelled() -> void:
	pending_item_action = ""
	clear_context_item()

func execute_item_action(action: String, selected_amount: int) -> void:
	if player == null or context_item == null:
		return
	if context_source != "inventory":
		return
	var item: ItemData = context_item
	var available_amount: int = player.inventory.get_amount(item.id)
	if selected_amount <= 0 or selected_amount > available_amount:
		return
	match action:
		"drop":
			drop_item(item, selected_amount)
		"destroy":
			if player.inventory.remove_item(item.id, selected_amount):
				refresh_inventory()
				clear_context_item()

func drop_item(item: ItemData, selected_amount: int) -> void:
	if item == null or selected_amount <= 0:
		return
	# Спочатку створюємо предмет на землі.
	var dropped_item = DROPPED_ITEM_SCENE.instantiate()
	dropped_item.setup_item(item, selected_amount)
	var world := get_tree().current_scene
	world.add_child(dropped_item)
	# Поки що викидаємо праворуч від гравця.
	dropped_item.global_position = player.global_position + Vector2(24, 0)
	# Вилучаємо предмет з інвентаря.
	if player.inventory.remove_item(item.id, selected_amount):
		refresh_inventory()
		clear_context_item()
	else:
		# Якщо вилучення не вдалося, прибираємо створений об'єкт.
		dropped_item.queue_free()

func clear_context_item() -> void:
	context_item = null
	context_source = ""
	context_equipment_index = -1
	if context_menu != null:
		context_menu.hide()

func _input(event: InputEvent) -> void:
	if not context_menu or not context_menu.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_position: Vector2 = event.position
			var menu_rect: Rect2 = context_menu.get_global_rect()
			if not menu_rect.has_point(mouse_position):
				context_menu.hide()
				clear_context_item()

func _on_recipe_scroll_learned(scroll: RecipeScrollData) -> void:
	if player == null or scroll == null:
		clear_context_item()
		return
	if scroll.recipe == null:
		clear_context_item()
		return
	# Повторно перевіряємо, чи рецепт ще не вивчений.
	if player.has_learned_recipe(scroll.recipe):
		clear_context_item()
		return
	# Перевіряємо наявність сувою перед вивченням.
	if player.inventory.get_amount(scroll.id) <= 0:
		clear_context_item()
		return
	if player.learn_recipe(scroll.recipe):
		player.inventory.remove_item(scroll.id, 1)
		refresh_inventory()
		var crafting_ui := get_tree().current_scene.get_node_or_null(
			"Hud/CraftingUI"
		)
		if crafting_ui:
			crafting_ui.update_recipe_list()
	clear_context_item()

func _on_recipe_scroll_learning_cancelled() -> void:
	clear_context_item()
