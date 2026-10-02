extends Control


@onready var item_icon: TextureRect = $ItemIcon
@onready var amount_label: Label = $AmountLabel


func set_item(item: ItemData, amount: int) -> void:
	item_icon.texture = item.icon
	amount_label.text = "x%d" % amount


func clear_slot() -> void:
	item_icon.texture = null
	amount_label.text = ""
