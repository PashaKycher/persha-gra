extends PanelContainer

signal confirmed(amount: int)
signal cancelled

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var amount_slider: HSlider = $MarginContainer/VBoxContainer/AmountSlider
@onready var amount_label: Label = $MarginContainer/VBoxContainer/AmountLabel
@onready var confirm_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/ConfirmButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/CancelButton

var max_amount: int = 1

func _ready() -> void:
	amount_slider.value_changed.connect(_on_amount_changed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	hide()


func open_dialog(dialog_title: String, available_amount: int) -> void:
	max_amount = maxi(available_amount, 1)
	title_label.text = dialog_title
	amount_slider.min_value = 1
	amount_slider.max_value = max_amount
	amount_slider.step = 1
	amount_slider.value = 1
	amount_slider.editable = max_amount > 1
	_update_amount_label()
	show()

func _on_amount_changed(_value: float) -> void:
	_update_amount_label()

func _update_amount_label() -> void:
	var selected_amount: int = int(amount_slider.value)
	amount_label.text = "%d / %d" % [selected_amount, max_amount]

func _on_confirm_pressed() -> void:
	var selected_amount: int = int(amount_slider.value)
	confirmed.emit(selected_amount)
	hide()

func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide()
