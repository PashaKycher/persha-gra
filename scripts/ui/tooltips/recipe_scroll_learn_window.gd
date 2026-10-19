class_name RecipeScrollLearnWindow
extends Control

signal scroll_learned(scroll: RecipeScrollData)
signal cancelled

@onready var drag_icon: RecipeScrollDragIcon = $CenterContainer/WindowPanel/MarginContainer/VBoxContainer/DragRow/ScrollDragIcon
@onready var drop_zone: RecipeScrollDropZone = $CenterContainer/WindowPanel/MarginContainer/VBoxContainer/DragRow/DropZone
@onready var status_label: Label = $CenterContainer/WindowPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var close_button: Button = $CenterContainer/WindowPanel/MarginContainer/VBoxContainer/Header/CloseButton

var current_scroll: RecipeScrollData
var is_finishing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	drop_zone.scroll_dropped.connect(_on_scroll_dropped)
	close_button.pressed.connect(close_window)

func open_for_scroll(scroll: RecipeScrollData) -> void:
	if scroll == null or scroll.recipe == null:
		return
	current_scroll = scroll
	is_finishing = false
	status_label.text = "Перетягніть сувій у праву область."
	drag_icon.set_scroll_data(scroll)
	drag_icon.scale = Vector2.ONE
	drag_icon.modulate = Color.WHITE
	drop_zone.set_expected_item(scroll.id)
	show()

func _on_scroll_dropped(item_id: String) -> void:
	if is_finishing or current_scroll == null:
		return
	if item_id != current_scroll.id:
		return
	is_finishing = true
	status_label.text = "Вивчаємо рецепт..."
	var scroll_to_learn: RecipeScrollData = current_scroll
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		drag_icon,
		"scale",
		Vector2(0.15, 0.15),
		0.25
	)
	tween.tween_property(
		drag_icon,
		"modulate:a",
		0.0,
		0.25
	)
	await tween.finished
	hide()
	current_scroll = null
	drop_zone.set_expected_item("")
	scroll_learned.emit(scroll_to_learn)

func close_window() -> void:
	if not visible or is_finishing:
		return
	current_scroll = null
	drop_zone.set_expected_item("")
	hide()
	cancelled.emit()
