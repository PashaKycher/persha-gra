extends Node2D


@export var wood_item: ItemData
@export var wood_amount: int = 2
@export var hits_required: int = 3
@export var energy_cost: int = 10

var hits_left: int


func _ready() -> void:
	hits_left = hits_required


func interact() -> void:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if not player.has_axe:
		print("Потрібна сокира.")
		return

	if not player.spend_energy(energy_cost):
		return

	hits_left -= 1

	print("Удар по дереву. Залишилось ударів: ", hits_left)

	if hits_left <= 0:
		chop_down(player)


func chop_down(player: Node) -> void:
	player.inventory.add_item(wood_item, wood_amount)

	print("Дерево зрубано!")

	queue_free()
