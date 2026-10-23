class_name ResourceNode
extends StaticBody2D

@export var required_tool_id: String = ""
@export var resource_item: ItemData
@export var resource_amount: int = 1
@export var hits_required: int = 1
@export var energy_cost: int = 10
@export_group("Resource Behavior")
@export var is_pickup: bool = true
@export var dropped_resource_scene: PackedScene

var hits_left: int

func _ready() -> void:
	hits_left = hits_required

func interact() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if not can_use_tool(player):
		player.show_interaction_message(
			"Потрібен інструмент: %s" % get_tool_name()
		)
		return
	if player.energy < energy_cost:
		player.show_interaction_message("Недостатньо енергії")
		return
	if not player.spend_energy(energy_cost):
		return
	hits_left -= 1
	if hits_left <= 0:
		collect_resource(player)

func can_use_tool(player: Node) -> bool:
	if required_tool_id == "" or required_tool_id == "hand":
		return true
	var equipment: Equipment = player.get("equipment") as Equipment
	if equipment == null:
		return false
	return equipment.is_tool_type_equipped(
		StringName(required_tool_id)
	)

func get_tool_name() -> String:
	match required_tool_id:
		"axe": return "сокира"
		"pickaxe": return "кірка"
		"hammer": return "молот"
		"knife": return "ніж"
		"hand": return "руки"
		_: return required_tool_id

func collect_resource(player: Node) -> void:
	if resource_item == null:
		player.show_interaction_message(
			"Помилка: не задано предмет ресурсу"
		)
		return
	# Підбирання предмета, який уже лежить на землі.
	if is_pickup:
		if not player.inventory.can_add_item(resource_item):
			player.show_interaction_message("Інвентар заповнений")
			return
		player.inventory.add_item(resource_item, resource_amount)
		player.show_interaction_message(
			"Отримано: %s ×%d" % [
				resource_item.display_name,
				resource_amount
			]
		)
		queue_free()
		return
	# Добування ресурсу з валуна або дерева.
	if dropped_resource_scene == null:
		player.show_interaction_message(
			"Помилка: не задано сцену випадіння ресурсу"
		)
		return
	var parent := get_parent()
	if parent == null:
		return
	for i in range(resource_amount):
		var dropped_resource := dropped_resource_scene.instantiate()
		parent.add_child(dropped_resource)
		if dropped_resource is Node2D:
			var offset := Vector2(
				randf_range(-20.0, 20.0),
				randf_range(-20.0, 20.0)
			)
			dropped_resource.global_position = global_position + offset
	player.show_interaction_message(
		"Отримано: %s ×%d" % [
			resource_item.display_name,
			resource_amount
		]
	)
	queue_free()

func get_interaction_hint() -> String:
	var resource_name := "Ресурс"
	if resource_item != null:
		resource_name = resource_item.display_name
	var player := get_tree().get_first_node_in_group("player")
	var key_name := "Взаємодія"
	if player != null:
		key_name = player.get_interact_key_name()
	if required_tool_id == "" or required_tool_id == "hand":
		return "%s — %s: взаємодія" % [
			resource_name,
			key_name
		]
	var tool_name := get_tool_name()
	var equipment: Equipment = null
	if player != null:
		equipment = player.get("equipment") as Equipment
	if equipment != null and equipment.is_tool_type_equipped(
		StringName(required_tool_id)
	):
		return "%s — %s: добути" % [
			resource_name,
			key_name
		]
	return "%s — потрібен інструмент: %s" % [
		resource_name,
		tool_name
	]

func can_interact(player: Node) -> bool:
	if not can_use_tool(player):
		return false
	if player.energy < energy_cost:
		return false
	if resource_item == null:
		return false
	if not player.inventory.can_add_item(resource_item):
		return false
	return true
