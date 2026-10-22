class_name FarmPlots
extends TileMapLayer

const HOE_TOOL_TYPE: StringName = &"hoe"
const TILLED_SOURCE_ID: int = 1
const TILLED_ATLAS_COORDS: Vector2i = Vector2i(3, 0)
const DEFAULT_HOE_ENERGY_COST: int = 5

@onready var ground: TileMapLayer = $"../Ground"
@onready var farmable_ground: TileMapLayer = $"../FarmableGround"

var tilled_cells: Dictionary = {}

func till_cell(cell: Vector2i, player) -> bool:
	if player == null:
		return false
	# Обробляти землю дозволено лише у визначеній зоні.
	if farmable_ground.get_cell_source_id(cell) == -1:
		player.show_interaction_message("Тут не можна обробляти землю.")
		return false
	# Перевіряємо, чи є під ділянкою основна земля.
	if ground.get_cell_source_id(cell) == -1:
		player.show_interaction_message("Тут немає землі для обробки.")
		return false
	if tilled_cells.has(cell):
		player.show_interaction_message("Ця земля вже оброблена.")
		return false
	if not player.equipment.is_tool_type_equipped(HOE_TOOL_TYPE):
		player.show_interaction_message("Потрібно екіпірувати мотику.")
		return false
	var hoe_energy_cost: int = DEFAULT_HOE_ENERGY_COST
	for item in player.equipment.slots:
		if item == null or item.tool_data == null:
			continue
		if item.tool_data.tool_type == HOE_TOOL_TYPE:
			hoe_energy_cost = item.tool_data.energy_cost
			break
	if not player.spend_energy(hoe_energy_cost):
		player.show_interaction_message("Недостатньо енергії.")
		return false
	tilled_cells[cell] = true
	set_cell(cell, TILLED_SOURCE_ID, TILLED_ATLAS_COORDS)
	player.show_interaction_message("Землю оброблено.")
	return true
