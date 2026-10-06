extends Node

var recipes: Array[RecipeData] = []


func _ready() -> void:
	register_recipe(preload("res://data/recipes/stone_knife_recipe.tres"))


func register_recipe(recipe: RecipeData) -> void:
	if recipe == null:
		return

	recipes.append(recipe)


func get_all_recipes() -> Array[RecipeData]:
	return recipes
