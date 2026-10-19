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
# Рецепти, які гравець уже вивчив
var learned_recipe_ids: Array[String] = []

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
		return false
	energy -= amount
	return true

func has_learned_recipe(recipe: RecipeData) -> bool:
	if recipe == null:
		return false

	return learned_recipe_ids.has(recipe.resource_path)

func learn_recipe(recipe: RecipeData) -> bool:
	if recipe == null:
		return false

	var recipe_id: String = recipe.resource_path

	if recipe_id.is_empty():
		push_warning("У рецепту немає шляху до ресурсу.")
		return false

	if learned_recipe_ids.has(recipe_id):
		return false
	learned_recipe_ids.append(recipe_id)
	return true
