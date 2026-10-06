class_name CraftingSystem
extends Node


func can_craft(recipe: RecipeData, inventory: Inventory) -> bool:
	if recipe == null:
		return false

	if recipe.ingredients.size() != recipe.ingredient_amounts.size():
		return false

	for i in recipe.ingredients.size():
		var item := recipe.ingredients[i]
		var required_amount := recipe.ingredient_amounts[i]

		if inventory.get_amount(item.id) < required_amount:
			return false

	return true


func craft(recipe: RecipeData, inventory: Inventory) -> bool:
	if not can_craft(recipe, inventory):
		return false

	for i in recipe.ingredients.size():
		var item := recipe.ingredients[i]
		var required_amount := recipe.ingredient_amounts[i]

		inventory.remove_item(item.id, required_amount)

	inventory.add_item(
		recipe.result_item,
		recipe.result_amount
	)

	return true
