extends StaticBody2D


var player_inside := false


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		print("Player can interact with tree")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		interact()


func interact() -> void:
	print("Це дерево.")
