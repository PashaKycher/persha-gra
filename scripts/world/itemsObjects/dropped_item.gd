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
	if amount > 1:
		sprite.texture = preload(
			"res://assets/itemsObjects/dropped_item_textura.svg"
		)

	else:
		sprite.texture = item_data.icon
	sprite.scale = Vector2(0.20, 0.20)

func interact() -> void:
	if item_data == null or amount <= 0:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.inventory == null:
		return
	if not player.inventory.can_add_item(item_data):
		player.show_interaction_message("Інвентар заповнений")
		return
	player.inventory.add_item(item_data, amount)
	player.show_interaction_message(
		"Отримано: %s ×%d" % [
			item_data.display_name,
			amount
		]
	)
	queue_free()

func get_interaction_hint() -> String:
	if item_data == null or amount <= 0:
		return ""
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.inventory == null:
		return ""
	if not player.inventory.can_add_item(item_data):
		return "Інвентар заповнений"
	var key_name: String = player.get_interact_key_name()
	return "%s ×%d — %s: підібрати" % [
		item_data.display_name,
		amount,
		key_name
	]
