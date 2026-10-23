class_name RecipeScrollDropZone
extends PanelContainer

signal scroll_dropped(item_id: String)

var expected_item_id: String = ""

func set_expected_item(item_id: String) -> void:
	expected_item_id = item_id

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	return (
		data.get("type", "") == "recipe_scroll"
		and data.get("item_id", "") == expected_item_id
		and not expected_item_id.is_empty()
	)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		scroll_dropped.emit(expected_item_id)
