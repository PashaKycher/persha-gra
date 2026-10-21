extends CanvasModulate

const DAWN_MINUTES: float = 6.0 * 60.0
const DAY_MINUTES: float = 8.0 * 60.0
const EVENING_MINUTES: float = 19.0 * 60.0
const NIGHT_MINUTES: float = 21.0 * 60.0
const DAWN_COLOR := Color(0.72, 0.66, 0.62)
const DAY_COLOR := Color(1.0, 1.0, 1.0)
const EVENING_COLOR := Color(0.95, 0.68, 0.48)
const NIGHT_COLOR := Color(0.30, 0.34, 0.50)

func _ready() -> void:
	GameTime.time_changed.connect(_on_time_changed)
	update_lighting()

func _on_time_changed(
	_day: int,
	_hour: int,
	_minute: int
) -> void:
	update_lighting()

func update_lighting() -> void:
	var minutes: float = GameTime.current_time_minutes
	if minutes < DAY_MINUTES:
		var weight := inverse_lerp(
			DAWN_MINUTES,
			DAY_MINUTES,
			minutes
		)
		color = DAWN_COLOR.lerp(DAY_COLOR, weight)
	elif minutes < EVENING_MINUTES:
		color = DAY_COLOR
	elif minutes < NIGHT_MINUTES:
		var weight := inverse_lerp(
			EVENING_MINUTES,
			NIGHT_MINUTES,
			minutes
		)
		color = DAY_COLOR.lerp(EVENING_COLOR, weight)
	else:
		var weight := inverse_lerp(
			NIGHT_MINUTES,
			GameTime.DAY_END_MINUTES,
			minutes
		)
		color = EVENING_COLOR.lerp(NIGHT_COLOR, weight)
