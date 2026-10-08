extends Panel


@onready var recipe_buttons: VBoxContainer = $RecipeList/RecipeButtons
@onready var craft_feedback: Label = $CraftFeedback
@onready var recipe_name: Label = $RecipeDetails/DetailsContent/RecipeName
@onready var ingredients: Label = $RecipeDetails/DetailsContent/Ingredients
@onready var result: Label = $RecipeDetails/DetailsContent/Result
@onready var craft_button: Button = $RecipeDetails/DetailsContent/CraftButton
@onready var feedback_timer: Timer = $Timer
@onready var inventory: Inventory = get_tree().current_scene.get_node("Player/Inventory")
@onready var crafting_system: CraftingSystem = get_tree().current_scene.get_node("Player/CraftingSystem")
@onready var inventory_ui: Control = $"../InventoryUI"

var selected_recipe: RecipeData


func _ready() -> void:
	visible = false
	update_recipe_list()
	craft_button.pressed.connect(_on_craft_pressed)
	craft_feedback.text = ""
	feedback_timer.timeout.connect(_on_feedback_timer_timeout)

func _on_craft_pressed() -> void:
	if selected_recipe == null:
		return

	if crafting_system.craft(selected_recipe, inventory):
		update_recipe_details()
		inventory_ui.refresh_inventory()

		craft_feedback.text = "Створено: %s ×%d" % [
			selected_recipe.result_item.display_name,
			selected_recipe.result_amount
		]
		feedback_timer.start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_crafting"):
		visible = not visible
	if Input.is_key_pressed(KEY_ESCAPE):
		visible = false
	if visible and selected_recipe != null:
		update_recipe_details()


func update_recipe_list() -> void:
	for recipe in RecipeDatabase.get_all_recipes():
		var button := Button.new()
		button.text = recipe.result_item.display_name
		button.pressed.connect(_on_recipe_selected.bind(recipe))
		recipe_buttons.add_child(button)


func _on_recipe_selected(recipe: RecipeData) -> void:
	selected_recipe = recipe
	update_recipe_details()


func update_recipe_details() -> void:
	if selected_recipe == null:
		return

	recipe_name.text = selected_recipe.result_item.display_name

	ingredients.text = "Необхідно:\n"

	for i in selected_recipe.ingredients.size():
		var item := selected_recipe.ingredients[i]
		var required_amount := selected_recipe.ingredient_amounts[i]
		var current_amount := inventory.get_amount(item.id)

		ingredients.text += "%s: %d / %d\n" % [
			item.display_name,
			current_amount,
			required_amount
		]

	result.text = "Результат:\n%s ×%d" % [
		selected_recipe.result_item.display_name,
		selected_recipe.result_amount
	]

	craft_button.disabled = not crafting_system.can_craft(
		selected_recipe,
		inventory
	)

func _on_feedback_timer_timeout() -> void:
	craft_feedback.text = ""
