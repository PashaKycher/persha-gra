class_name ResourceNode
extends StaticBody2D


@export var required_tool_id: String = ""
@export var resource_item: ItemData
@export var resource_amount: int = 1

@export var hits_required: int = 1
@export var energy_cost: int = 10


var hits_left: int


func _ready() -> void:
	hits_left = hits_required


func interact() -> void:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if not can_use_tool(player):
		return

	if not player.spend_energy(energy_cost):
		return

	hits_left -= 1

	print(
		"Удар по ресурсу. Залишилось: ",
		hits_left
	)

	if hits_left <= 0:
		collect_resource(player)


func can_use_tool(player: Node) -> bool:
	if required_tool_id == "":
		return true

	if required_tool_id == "axe":
		if player.has_axe:
			return true

	if required_tool_id == "pickaxe":
		if player.has_pickaxe:
			return true

	if required_tool_id == "hand":
		if player.has_hand:
			return true
	
	print("Потрібен інструмент: ", required_tool_id)

	return false


func collect_resource(player: Node) -> void:
	if resource_item == null:
		return

	player.inventory.add_item(
		resource_item,
		resource_amount
	)

	print(
		"Отримано: ",
		resource_item.display_name,
		" x",
		resource_amount
	)

	queue_free()
