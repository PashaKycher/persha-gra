class_name FarmPlots
extends TileMapLayer

const HOE_TOOL_TYPE: StringName = &"hoe"
const TILLED_SOURCE_ID: int = 1
const TILLED_ATLAS_COORDS: Vector2i = Vector2i(3, 0)
const DEFAULT_HOE_ENERGY_COST: int = 5
const TURNIP_SEED_ID: String = "turnip_seed"

@onready var ground: TileMapLayer = $"../Ground"
@onready var farmable_ground: TileMapLayer = $"../FarmableGround"

var tilled_cells: Dictionary = {}
var planted_cells: Dictionary = {}
var plant_visuals: Dictionary = {}

func till_cell(cell: Vector2i, player) -> bool:
	if player == null:
		return false
	if farmable_ground.get_cell_source_id(cell) == -1:
		player.show_interaction_message(
			"Тут не можна обробляти землю."
		)
		return false
	if ground.get_cell_source_id(cell) == -1:
		player.show_interaction_message(
			"Тут немає землі для обробки."
		)
		return false
	if tilled_cells.has(cell):
		player.show_interaction_message(
			"Ця земля вже оброблена."
		)
		return false
	if not player.equipment.is_tool_type_equipped(HOE_TOOL_TYPE):
		player.show_interaction_message(
			"Потрібно екіпірувати мотику."
		)
		return false
	var hoe_energy_cost: int = DEFAULT_HOE_ENERGY_COST
	for item in player.equipment.slots:
		if item == null or item.tool_data == null:
			continue
		if item.tool_data.tool_type == HOE_TOOL_TYPE:
			hoe_energy_cost = item.tool_data.energy_cost
			break
	if not player.spend_energy(hoe_energy_cost):
		player.show_interaction_message(
			"Недостатньо енергії."
		)
		return false
	tilled_cells[cell] = true
	set_cell(cell, TILLED_SOURCE_ID, TILLED_ATLAS_COORDS)
	player.show_interaction_message("Землю оброблено.")
	return true

func can_plant_seed(cell: Vector2i, player) -> bool:
	if player == null:
		return false
	if not tilled_cells.has(cell):
		return false
	if planted_cells.has(cell):
		player.show_interaction_message(
			"Тут уже росте рослина."
		)
		return false
	if player.inventory.get_amount(TURNIP_SEED_ID) <= 0:
		player.show_interaction_message(
			"Потрібне насіння ріпи."
		)
		return false
	return true

func plant_seed(cell: Vector2i, player) -> bool:
	if not can_plant_seed(cell, player):
		return false
	var seed_data: ItemData = ItemDatabase.get_item(
		TURNIP_SEED_ID
	)
	if seed_data == null:
		push_warning("Не знайдено предмет turnip_seed.")
		player.show_interaction_message(
			"Не вдалося знайти насіння."
		)
		return false

	# Списуємо насіння тільки після перевірок.
	if not player.inventory.remove_item(TURNIP_SEED_ID, 1):
		player.show_interaction_message(
			"Насіння більше немає в інвентарі."
		)
		return false
	# Зберігаємо стан рослини для наступних етапів.
	planted_cells[cell] = {
		"seed_id": TURNIP_SEED_ID,
		"watered": false,
		"growth_days": 0,
		"quality": 0
	}

	# Тимчасове відображення рослини іконкою насіння.
	if seed_data.icon != null:
		var plant_sprite := Sprite2D.new()
		plant_sprite.texture = seed_data.icon
		plant_sprite.position = map_to_local(cell)
		plant_sprite.scale = Vector2(0.2, 0.2)
		add_child(plant_sprite)
		plant_visuals[cell] = plant_sprite
	player.show_interaction_message("Насіння ріпи посаджено.")
	return true
