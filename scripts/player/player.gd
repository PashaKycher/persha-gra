extends CharacterBody2D

@export var speed: float = 150.0
#Енергія
@export var max_energy: int = 100
@export var has_hand: bool = true
@onready var interaction_detector: Area2D = $InteractionDetector
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var inventory: Inventory = $Inventory
@onready var crafting_system: CraftingSystem = $CraftingSystem
@onready var equipment: Equipment = $"../Hud/Equipment"
@onready var hud: CanvasLayer = $"../Hud"
var current_hint_target: Node = null
var is_attacking: bool = false
var pending_interaction_target: Node = null
var facing_direction: Vector2 = Vector2.UP
# Енергія 
var energy: int = 1 
# Рецепти, які гравець уже вивчив
var learned_recipe_ids: Array[String] = []

#Енергія
func _ready() -> void:
	energy = max_energy
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
    	"move_down"
)
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			facing_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		else:
			facing_direction = Vector2.DOWN if direction.y > 0 else Vector2.UP
	velocity = direction * speed
	move_and_slide()
	update_movement_animation()
	update_interaction_detector()

func _process(_delta: float) -> void:
	update_interaction_hint()
	if Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	if is_attacking:
		return
	var target: Node = interaction_detector.get_interactable()
	if target == null:
		return
	if target.has_method("can_interact"):
		if not target.can_interact(self):
			return
	elif target.has_method("get_interaction_hint"):
		var hint: String = target.get_interaction_hint()
		if hint == "Інвентар заповнений":
			return

	pending_interaction_target = target
	play_slash_animation()

func spend_energy(amount: int) -> bool:
	if energy < amount:
		return false
	energy -= amount
	return true

func has_learned_recipe(recipe: RecipeData) -> bool:
	if recipe == null:
		return false

	return learned_recipe_ids.has(recipe.resource_path)

func learn_recipe(recipe: RecipeData) -> bool:
	if recipe == null:
		return false
	var recipe_id: String = recipe.resource_path
	if recipe_id.is_empty():
		push_warning("У рецепту немає шляху до ресурсу.")
		return false
	if learned_recipe_ids.has(recipe_id):
		return false
	learned_recipe_ids.append(recipe_id)
	return true

func update_interaction_hint() -> void:
	var target: Node = interaction_detector.get_hint_target()
	if target == null:
		current_hint_target = null
		hud.set_interaction_hint("")
		return
	current_hint_target = target
	if target.has_method("get_interaction_hint"):
		hud.set_interaction_hint(target.get_interaction_hint())
	else:
		hud.set_interaction_hint("E: взаємодія")

func show_interaction_message(message: String) -> void:
	if hud != null:
		hud.show_interaction_message(message)


func get_interact_key_name() -> String:
	var events := InputMap.action_get_events("interact")
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(
				event.physical_keycode if event.physical_keycode != 0 else event.keycode
				)
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					return "Ліва кнопка миші"
				MOUSE_BUTTON_RIGHT:
					return "Права кнопка миші"
				MOUSE_BUTTON_MIDDLE:
					return "Середня кнопка миші"
	return "Взаємодія"

func update_movement_animation() -> void:
	if is_attacking:
		return
	if velocity.length() > 0.1:
		if facing_direction == Vector2.LEFT:
			sprite.play("walk_left")
		elif facing_direction == Vector2.RIGHT:
			sprite.play("walk_right")
		elif facing_direction == Vector2.UP:
			sprite.play("walk_up")
		elif facing_direction == Vector2.DOWN:
			sprite.play("walk_down")
	else:
		if facing_direction == Vector2.LEFT:
			sprite.play("idle_left")
		elif facing_direction == Vector2.RIGHT:
			sprite.play("idle_right")
		elif facing_direction == Vector2.UP:
			sprite.play("idle_up")
		elif facing_direction == Vector2.DOWN:
			sprite.play("idle_down")

func update_interaction_detector() -> void:
	var horizontal_distance := 26.0
	var vertical_distance := 30.0
	if facing_direction == Vector2.LEFT:
		interaction_detector.position = Vector2(
			-horizontal_distance, 0
		)
	elif facing_direction == Vector2.RIGHT:
		interaction_detector.position = Vector2(
			horizontal_distance, 0
		)
	elif facing_direction == Vector2.UP:
		interaction_detector.position = Vector2(
			0, -vertical_distance
		)
	elif facing_direction == Vector2.DOWN:
		interaction_detector.position = Vector2(
			0, vertical_distance + 4
		)

func play_slash_animation() -> void:
	if is_attacking:
		return
	is_attacking = true
	if facing_direction == Vector2.LEFT:
		sprite.play("slash_left")
	elif facing_direction == Vector2.RIGHT:
		sprite.play("slash_right")
	elif facing_direction == Vector2.UP:
		sprite.play("slash_up")
	else:
		sprite.play("slash_down")

func _on_animation_finished() -> void:
	if not is_attacking:
		return

	is_attacking = false

	var target := pending_interaction_target
	pending_interaction_target = null

	if is_instance_valid(target) and not target.is_queued_for_deletion():
		if target.has_method("interact"):
			target.interact()
