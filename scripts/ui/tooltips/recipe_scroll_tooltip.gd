
extends PanelContainer

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var recipe_label: Label = $VBoxContainer/RecipeLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_scroll_tooltip(item: RecipeScrollData) -> void:
	if item == null:
		hide_tooltip()
		return

	title_label.text = item.display_name

	if item.recipe == null:
		recipe_label.text = "Рецепт: невідомий"
		description_label.text = "Цей сувій не містить доступного рецепта."
	elif item.recipe.result_item == null:
		recipe_label.text = "Рецепт: невідомий"
		description_label.text = "Рецепт сувою налаштовано неправильно."
	else:
		recipe_label.text = "Рецепт: " + item.recipe.result_item.display_name
		description_label.text = "Містить знання, необхідні для вивчення рецепта."

	visible = true


func hide_tooltip() -> void:
	visible = false
