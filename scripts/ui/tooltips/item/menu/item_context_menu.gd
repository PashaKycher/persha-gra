extends PanelContainer

signal action_selected(action: String)

@onready var equip_button: Button = $MarginContainer/VBoxContainer/EquipButton
@onready var learn_button: Button = $MarginContainer/VBoxContainer/LearnButton
@onready var drop_button: Button = $MarginContainer/VBoxContainer/DropButton
@onready var destroy_button: Button = $MarginContainer/VBoxContainer/DestroyButton

func _ready() -> void:
	hide()
	equip_button.pressed.connect(_on_action_pressed.bind("equip"))
	learn_button.pressed.connect(_on_action_pressed.bind("learn"))
	drop_button.pressed.connect(_on_action_pressed.bind("drop"))
	destroy_button.pressed.connect(_on_action_pressed.bind("destroy"))

func setup_for_item(item: ItemData) -> void:
	equip_button.visible = item != null and item.tool_data != null
	learn_button.visible = item is RecipeScrollData
	drop_button.visible = item != null
	destroy_button.visible = item != null

func _on_action_pressed(action: String) -> void:
	hide()
	action_selected.emit(action)

func popup(rect: Rect2) -> void:
	global_position = rect.position
	show()
