extends CharacterBody2D


@export var speed: float = 150.0
@export var max_energy: int = 10000
@export var has_axe: bool = true

@export var has_pickaxe: bool = true
@export var has_hand: bool = true

var energy: int = 1000

@onready var interaction_detector: Area2D = $InteractionDetector
@onready var inventory: Inventory = $Inventory
@onready var crafting_system: CraftingSystem = $CraftingSystem


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

#test craft
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("craft"):
		#test_craft()
		#
#func test_craft() -> void:
	#var recipe := preload(
		#"res://data/recipes/stone_knife_recipe.tres"
	#) as RecipeData
#
	#if crafting_system.craft(recipe, inventory):
		#print("Предмет створено: ", recipe.result_item.display_name)
	#else:
		#print("Недостатньо ресурсів для крафту.")
