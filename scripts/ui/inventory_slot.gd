extends Control

signal context_requested(slot: Control, item: ItemData)

@onready var item_icon: TextureRect = $ItemIcon
@onready var amount_label: Label = $AmountLabel

var current_item: ItemData = null

func set_item(item: ItemData, amount: int) -> void:
	current_item = item
	item_icon.texture = item.icon
	amount_label.text = "x%d" % amount

func clear_slot() -> void:
	current_item = null
	item_icon.texture = null
	amount_label.text = ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if current_item != null:
				context_requested.emit(self, current_item)
				accept_event()
