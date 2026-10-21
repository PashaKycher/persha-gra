extends CanvasLayer

@onready var energy_bar: ProgressBar = $HUDPanel/VBoxContainer/EnergyBar
@onready var energy_label: Label = $HUDPanel/VBoxContainer/EnergyLabel
@onready var interaction_message: Label = $HUDPanel/VBoxContainer/InteractionMessage
@onready var interaction_hint: Label = $HUDPanel/VBoxContainer/InteractionHint

var message_tween: Tween
var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if player == null:
		return
	update_energy()
	#update_inventory()

func update_energy() -> void:
	energy_bar.max_value = player.max_energy
	energy_bar.value = player.energy
	energy_label.text = "ENERGY: %d / %d" % [
		player.energy,
		player.max_energy
	]

#func update_inventory() -> void:
	#var wood_amount = player.inventory.get_amount("wood")

func show_interaction_message(message: String) -> void:
	interaction_message.text = message
	interaction_message.show()
	if message_tween and message_tween.is_running():
		message_tween.kill()
	message_tween = create_tween()
	message_tween.tween_interval(2.5)
	message_tween.tween_callback(
		func() -> void: interaction_message.hide()
	)

func set_interaction_hint(hint: String) -> void:
	if hint.is_empty():
		interaction_hint.hide()
		interaction_hint.text = ""
		return
	interaction_hint.text = hint
	interaction_hint.show()
