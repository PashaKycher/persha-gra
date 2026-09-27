extends Control


@onready var item_label: Label = $ItemLabel
@onready var amount_label: Label = $AmountLabel


func set_item_name(item_name: String, amount: int) -> void:
	item_label.text = item_name
	amount_label.text = "x%d" % amount


func clear_slot() -> void:
	item_label.text = ""
	amount_label.text = ""
