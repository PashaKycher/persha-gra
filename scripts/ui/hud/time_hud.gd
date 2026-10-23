extends CanvasLayer

@onready var day_label: Label = $Panel/VBoxContainer/DayLabel
@onready var time_label: Label = $Panel/VBoxContainer/TimeLabel
@onready var period_label: Label = $Panel/VBoxContainer/PeriodLabel
@onready var calendar_label: Label = $Panel/VBoxContainer/CalendarLabel

func _ready() -> void:
	GameTime.time_changed.connect(_on_time_changed)
	GameTime.day_changed.connect(_on_day_changed)
	_update_display()

func _on_time_changed(
	_day: int,
	_hour: int,
	_minute: int
) -> void:
	_update_display()

func _on_day_changed(_new_day: int) -> void:
	_update_display()

func _update_display() -> void:
	day_label.text = "День %d" % GameTime.current_day
	time_label.text = GameTime.get_formatted_time()
	var hour := GameTime.get_hour()
	if hour >= 6 and hour < 12:
		period_label.text = "Ранок"
	elif hour >= 12 and hour < 18:
		period_label.text = "День"
	elif hour >= 18 and hour < 21:
		period_label.text = "Вечір"
	else:
		period_label.text = "Ніч"
	calendar_label.text = "Календар: день %d" % GameTime.current_day
