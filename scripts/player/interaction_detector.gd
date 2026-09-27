extends Area2D


var interactable_objects: Array[Node] = []


func _on_body_entered(body) -> void:
	if body.has_method("interact"):
		interactable_objects.append(body)


func _on_body_exited(body) -> void:
	if body in interactable_objects:
		interactable_objects.erase(body)


func get_interactable() -> Node:
	if interactable_objects.is_empty():
		return null

	return interactable_objects[0]
