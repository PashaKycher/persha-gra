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
	if hits_left <= 0:
		collect_resource(player)


func can_use_tool(player: Node) -> bool:
	# Якщо інструмент не потрібен — взаємодія дозволена.
	if required_tool_id == "":
		return true
	# Руки доступні гравцю від самого початку.
	if required_tool_id == "hand":
		return true
	# Для сокири та кірки перевіряємо фактичне спорядження.
	var equipment: Equipment = player.get("equipment") as Equipment
	if equipment == null:
		return false
	if equipment.is_tool_type_equipped(StringName(required_tool_id)):
		return true
	print("Потрібен екіпірований інструмент: ", required_tool_id)
	return false

func collect_resource(player: Node) -> void:
	if resource_item == null:
		return
	player.inventory.add_item(
		resource_item,
		resource_amount
	)
	queue_free()
