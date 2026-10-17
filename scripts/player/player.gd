extends CharacterBody2D

@export var speed: float = 150.0
@export var max_energy: int = 10000
@export var has_axe: bool = true
@export var has_pickaxe: bool = true
@export var has_hand: bool = true
@onready var interaction_detector: Area2D = $InteractionDetector
@onready var inventory: Inventory = $Inventory
@onready var crafting_system: CraftingSystem = $CraftingSystem
@onready var equipment: Equipment = $"../Hud/Equipment"
var energy: int = 100

func _ready() -> void:
	energy = max_energy

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = direction * speed
	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	var target = interaction_detector.get_interactable()
	if target:
		target.interact()

func spend_energy(amount: int) -> bool:
	if energy < amount:
		print("Недостатньо енергії.")
		return false
	energy -= amount
	print("Енергія: ", energy, "/", max_energy)
	return true

func test_equipment() -> void:
	var item: ItemData = ItemDatabase.get_item("stone_axe")
	if item == null:
		print("Помилка: stone_axe не знайдено в ItemDatabase.")
		return
	if equipment.equip_item(item, inventory, 0):
		print("Екіпіровано: ", item.display_name)
		print("Залишок в інвентарі: ", inventory.get_amount(item.id))
	else:
		print("Не вдалося екіпірувати предмет.")
