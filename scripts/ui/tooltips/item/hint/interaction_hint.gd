extends Label

@export var cursor_offset: Vector2 = Vector2(18, 18)

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + cursor_offset

func show_hint(hint: String) -> void:
	if hint.is_empty():
		hide()
		text = ""
		return
	text = hint
	show()

func hide_hint() -> void:
	hide()
	text = ""
