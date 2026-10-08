extends CanvasLayer


@onready var energy_bar: ProgressBar = $HUDPanel/VBoxContainer/EnergyBar
@onready var energy_label: Label = $HUDPanel/VBoxContainer/EnergyLabel
#@onready var wood_label: Label = $HUDPanel/VBoxContainer/WoodLabel


var player: CharacterBody2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if player == null:
		return

	update_energy()
	update_inventory()


func update_energy() -> void:
	energy_bar.max_value = player.max_energy
	energy_bar.value = player.energy

	energy_label.text = "ENERGY: %d / %d" % [
		player.energy,
		player.max_energy
	]


func update_inventory() -> void:
	var wood_amount = player.inventory.get_amount("wood")

	#wood_label.text = "Деревина: %d" % wood_amount
