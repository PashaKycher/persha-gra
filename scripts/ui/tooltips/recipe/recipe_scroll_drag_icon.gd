class_name RecipeScrollDragIcon
extends TextureRect

var scroll_data: RecipeScrollData

func set_scroll_data(scroll: RecipeScrollData) -> void:
	scroll_data = scroll
	texture = scroll.icon

func _get_drag_data(_at_position: Vector2) -> Variant:
	if scroll_data == null:
		return null
	var preview := TextureRect.new()
	preview.texture = scroll_data.icon
	preview.custom_minimum_size = Vector2(64, 64)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {
		"type": "recipe_scroll",
		"item_id": scroll_data.id
	}
