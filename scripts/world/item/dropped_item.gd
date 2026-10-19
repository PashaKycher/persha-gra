extends StaticBody2D

@export var item_data: ItemData
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	update_visual()

func setup_item(item: ItemData, item_amount: int) -> void:
	item_data = item
	amount = item_amount
	if is_node_ready():
		update_visual()

func update_visual() -> void:
	if item_data == null:
		return
	sprite.texture = item_data.icon

func interact() -> void:
	if item_data == null or amount <= 0:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.inventory == null:
		return
	# Не забираємо предмет, якщо в інвентарі немає місця.
	if not player.inventory.can_add_item(item_data):
		return
	player.inventory.add_item(item_data, amount)
	queue_free()
