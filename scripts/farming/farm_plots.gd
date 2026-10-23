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

func plant_crop(
	cell: Vector2i,
	player,
	seed_item: ItemData,
	fertilizer_item: ItemData = null
) -> bool:
	if player == null or seed_item == null:
		return false
	if not tilled_cells.has(cell):
		player.show_interaction_message("Спочатку оброби землю.")
		return false
	if planted_cells.has(cell):
		player.show_interaction_message("Тут уже росте рослина.")
		return false
	if seed_item.crop_data == null:
		player.show_interaction_message("Це не насіння.")
		return false
	if player.inventory.get_amount(seed_item.id) < 1:
		player.show_interaction_message("Насіння більше немає.")
		return false
	if fertilizer_item != null:
		if fertilizer_item.fertilizer_data == null:
			return false
		if player.inventory.get_amount(fertilizer_item.id) < 1:
			player.show_interaction_message("Добрива більше немає.")
			return false
	var crop: CropData = seed_item.crop_data
	var growth_days: int = crop.days_to_grow
	var harvest_amount: int = crop.harvest_amount
	var seed_chance: float = crop.seed_return_chance
	if fertilizer_item != null:
		var fertilizer: FertilizerData = fertilizer_item.fertilizer_data
		match fertilizer.effect_type:
			FertilizerData.EffectType.GROWTH_SPEED:
				growth_days = maxi(
					1,
					growth_days - int(fertilizer.effect_value)
				)
			FertilizerData.EffectType.HARVEST_AMOUNT:
				harvest_amount += int(fertilizer.effect_value)
			FertilizerData.EffectType.SEED_CHANCE:
				seed_chance += fertilizer.effect_value
	# Спочатку перевірено всі потрібні предмети.
	if not player.inventory.remove_item(seed_item.id, 1):
		return false
	if fertilizer_item != null:
		if not player.inventory.remove_item(fertilizer_item.id, 1):
			# Повертаємо насіння, якщо списання добрива не вдалося.
			player.inventory.add_item(seed_item, 1)
			return false
	planted_cells[cell] = {
		"crop_data": crop,
		"seed_item_id": seed_item.id,
		"fertilizer_id": (
			fertilizer_item.id if fertilizer_item != null else ""
		),
		"growth_days": growth_days,
		"days_grown": 0,
		"harvest_amount": harvest_amount,
		"seed_return_chance": clampf(seed_chance, 0.0, 100.0),
		"watered": false,
		"quality": 0
	}
	if seed_item.icon != null:
		var plant_sprite := Sprite2D.new()
		plant_sprite.texture = seed_item.icon
		plant_sprite.position = map_to_local(cell)
		plant_sprite.scale = Vector2(0.15, 0.15)
		add_child(plant_sprite)
		plant_visuals[cell] = plant_sprite
	player.show_interaction_message(
		"%s посаджено." % crop.crop_name
	)
	return true
