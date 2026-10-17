extends Control

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer
@onready var equipment_slots: GridContainer = $Panel/VBoxContainer/EquipmentSlots

var player: CharacterBody2D
var equipment_slot_nodes: Array[Control] = []
var context_menu: PopupMenu
var context_item: ItemData = null
var context_source: String = ""
var context_equipment_index: int = -1

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	visible = false
	create_slots()
	setup_equipment_slots()
	setup_context_menu()

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
	print("Слотів спорядження: ", equipment_slot_nodes.size())

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
	context_menu = PopupMenu.new()
	add_child(context_menu)
	context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	
	# 1. Розмір шрифту (наприклад, 10 пікселів для читачності в ретро-стилі)
	context_menu.add_theme_font_size_override("font_size", 4)
	
	## Задаємо мінімальний розмір (ширина, висота)
	#context_menu.set_max_size(Vector2i(30, 40))
	
	# 2. Відступи між пунктами меню вертикально
	context_menu.add_theme_constant_override("v_separation", 2)
	
	# 3. Налаштування фону, рамки та внутрішніх відступів (падінгів) через StyleBoxFlat
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_color = Color(0.3, 0.3, 0.3)
	style.set_border_width_all(1)
	
	# Внутрішні відступи (падінги) від тексту до країв рамки меню
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	style.content_margin_left = 2
	style.content_margin_right = 2
	
	context_menu.add_theme_stylebox_override("panel", style)


func _on_inventory_slot_context_requested(slot: Control, item: ItemData) -> void:
	if item == null:
		return

	# ПУНКТ 2: Завжди одразу ховаємо попереднє меню, якщо воно було відкрите.
	# Це дозволяє при кліку на другий об'єкт закрити старе меню і відкрити нове.
	if context_menu.visible:
		context_menu.hide()

	context_item = item
	context_source = "inventory"
	context_equipment_index = -1

	var is_tool: bool = item.tool_data != null

	# Очищаємо пункти перед заповненням
	context_menu.clear()

	# Додаємо пункти залежно від типу предмета (або спільні для всіх)
	if is_tool:
		context_menu.add_item("Надіти", 0)
	
	# Якщо в майбутньому тут з'явиться загальний пункт "Викинути", наприклад:
	# context_menu.add_item("Викинути", 1)

	# Якщо після всіх перевірок у меню немає жодного пункту — не відкриваємо його
	if context_menu.item_count == 0:
		return

	# Відкриваємо меню чітко біля правого нижнього кута слота
	var slot_rect: Rect2 = slot.get_global_rect()
	var pos: Vector2 = slot_rect.position + Vector2(slot_rect.size.x, slot_rect.size.y)
	context_menu.popup(Rect2(pos, Vector2.ZERO))


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
		print("Інвентар заповнений. Не вдалося зняти предмет.")



func _on_context_menu_id_pressed(id: int) -> void:
	if player == null or context_item == null:
		return

	if context_source != "inventory":
		return

	if id != 0:
		return

	if context_item.tool_data == null:
		return

	var tool_type: StringName = context_item.tool_data.tool_type

	if player.equipment.is_tool_type_equipped(tool_type):
		print("Інструмент цього типу вже екіпірований.")
		return

	var free_slot: int = -1

	for i in range(player.equipment.SLOT_COUNT):
		if player.equipment.get_item(i) == null:
			free_slot = i
			break

	if free_slot == -1:
		print("Немає вільних слотів спорядження.")
		return

	if player.equipment.equip_item(
		context_item,
		player.inventory,
		free_slot
	):
		refresh_inventory()
		refresh_equipment()
		print("Предмет екіпіровано: ", context_item.display_name)

	context_item = null
	context_source = ""
	context_equipment_index = -1
