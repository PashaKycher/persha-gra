extends StaticBody2D

const SLEEP_START_HOUR: int = 20

func interact() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if GameTime.get_hour() < SLEEP_START_HOUR and player.energy > 0:
		player.show_interaction_message(
			"Спати можна після 20:00 або коли енергія закінчиться"
		)
		return
	GameTime.sleep_until_next_day()
	player.energy = player.max_energy
	player.show_interaction_message(
		"Ти відпочив. Настав новий день!"
	)

func get_interaction_hint() -> String:
	var player := get_tree().get_first_node_in_group("player")
	var key_name := "Взаємодія"
	if player != null:
		key_name = player.get_interact_key_name()
	return "%s — поспати" % key_name
