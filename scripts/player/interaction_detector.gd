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
	return get_target_under_mouse()

func get_target_under_mouse() -> Node:
	_remove_invalid_objects()
	var mouse_position: Vector2 = get_global_mouse_position()
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_position
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var results: Array[Dictionary] = (
		get_world_2d().direct_space_state.intersect_point(query, 32)
	)
	for result in results:
		var collider: Object = result.get("collider")
		if collider is Node and interactable_objects.has(collider):
			return collider
	return null

func _remove_invalid_objects() -> void:
	for i in range(interactable_objects.size() - 1, -1, -1):
		var target: Node = interactable_objects[i]
		if not is_instance_valid(target) or target.is_queued_for_deletion():
			interactable_objects.remove_at(i)

func is_mouse_inside() -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_bodies = false
	query.collide_with_areas = true
	var results := get_world_2d().direct_space_state.intersect_point(
		query,
		32
	)
	for result in results:
		if result.get("collider") == self:
			return true
	return false
