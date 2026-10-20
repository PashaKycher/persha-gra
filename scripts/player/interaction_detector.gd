extends Area2D

var interactable_objects: Array[Node] = []

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("interact"):
		if not interactable_objects.has(body):
			interactable_objects.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body in interactable_objects:
		interactable_objects.erase(body)

func get_interactable() -> Node:
	_remove_invalid_objects()
	if interactable_objects.is_empty():
		return null
	return interactable_objects[0]

func get_hint_target() -> Node:
	return get_interactable()

func _remove_invalid_objects() -> void:
	for i in range(interactable_objects.size() - 1, -1, -1):
		var target: Node = interactable_objects[i]
		if not is_instance_valid(target) or target.is_queued_for_deletion():
			interactable_objects.remove_at(i)
