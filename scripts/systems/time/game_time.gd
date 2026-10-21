extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_changed(new_day: int)

const DAY_START_MINUTES: int = 6 * 60
const DAY_END_MINUTES: int = 22 * 60
const SECONDS_PER_GAME_MINUTE: float = 0.1

var current_day: int = 1
var current_time_minutes: float = DAY_START_MINUTES
var _elapsed_seconds: float = 0.0

func _process(delta: float) -> void:
	_elapsed_seconds += delta
	while _elapsed_seconds >= SECONDS_PER_GAME_MINUTE:
		_elapsed_seconds -= SECONDS_PER_GAME_MINUTE
		advance_minute()

func advance_minute() -> void:
	if current_time_minutes >= DAY_END_MINUTES:
		advance_day()
		return
	current_time_minutes += 1.0
	if current_time_minutes >= DAY_END_MINUTES:
		current_time_minutes = DAY_END_MINUTES
	_emit_time_changed()
	if current_time_minutes >= DAY_END_MINUTES:
		advance_day()

func advance_day() -> void:
	current_day += 1
	current_time_minutes = DAY_START_MINUTES
	_elapsed_seconds = 0.0
	day_changed.emit(current_day)
	_emit_time_changed()

func sleep_until_next_day() -> void:
	advance_day()
	
func get_hour() -> int:
	return int(float(current_time_minutes) / 60.0)

func get_minute() -> int:
	return int(current_time_minutes) % 60

func get_formatted_time() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]

func _emit_time_changed() -> void:
	time_changed.emit(
		current_day,
		get_hour(),
		get_minute()
	)
