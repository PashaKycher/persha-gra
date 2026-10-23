extends Control

@onready var seed_option: OptionButton = $Panel/MainLayout/IngredientsPanel/SeedOption
@onready var fertilizer_option: OptionButton = $Panel/MainLayout/IngredientsPanel/FertilizerOption
@onready var crop_name_label: Label = $Panel/MainLayout/InfoPanel/CropName
@onready var growth_time_label: Label = $Panel/MainLayout/InfoPanel/GrowthTime
@onready var harvest_info_label: Label = $Panel/MainLayout/InfoPanel/HarvestInfo
@onready var bonus_info_label: Label = $Panel/MainLayout/InfoPanel/BonusInfo
@onready var confirm_button: Button = $Panel/Buttons/ConfirmButton
@onready var cancel_button: Button = $Panel/Buttons/CancelButton

var player: Node = null
var farm_plots: FarmPlots = null
var target_cell: Vector2i = Vector2i.ZERO

func _ready() -> void:
	visible = false
	seed_option.item_selected.connect(_on_selection_changed)
	fertilizer_option.item_selected.connect(_on_selection_changed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(close_window)

func open_for_cell(cell: Vector2i, current_player: Node, plots: FarmPlots) -> void:
	player = current_player
	farm_plots = plots
	target_cell = cell
	_refresh_options()
	_update_information()
	visible = true

func close_window() -> void:
	visible = false
	player = null
	farm_plots = null

func _refresh_options() -> void:
	seed_option.clear()
	fertilizer_option.clear()
	var seed_count: int = 0
	for value in ItemDatabase.items.values():
		var item: ItemData = value as ItemData
		if item == null or item.crop_data == null:
			continue
		if player.inventory.get_amount(item.id) <= 0:
			continue
		seed_option.add_item(
			"%s × %d" % [
				item.display_name,
				player.inventory.get_amount(item.id)
			]
		)
		seed_option.set_item_metadata(
			seed_option.item_count - 1,
			item
		)
		seed_count += 1
	if seed_count == 0:
		seed_option.add_item("Немає доступного насіння")
		seed_option.set_item_disabled(0, true)
	fertilizer_option.add_item("Без добрива")
	fertilizer_option.set_item_metadata(0, null)
	for value in ItemDatabase.items.values():
		var item: ItemData = value as ItemData
		if item == null or item.fertilizer_data == null:
			continue
		if player.inventory.get_amount(item.id) <= 0:
			continue
		fertilizer_option.add_item(
			"%s × %d" % [
				item.display_name,
				player.inventory.get_amount(item.id)
			]
		)
		fertilizer_option.set_item_metadata(
			fertilizer_option.item_count - 1,
			item
		)
	confirm_button.disabled = seed_count == 0

func _get_selected_seed() -> ItemData:
	if seed_option.item_count == 0:
		return null
	if seed_option.is_item_disabled(seed_option.selected):
		return null
	return seed_option.get_item_metadata(
		seed_option.selected
	) as ItemData

func _get_selected_fertilizer() -> ItemData:
	if fertilizer_option.selected < 0:
		return null
	return fertilizer_option.get_item_metadata(
		fertilizer_option.selected
	) as ItemData

func _on_selection_changed(_index: int = 0) -> void:
	_update_information()

func _update_information() -> void:
	var seed_item: ItemData = _get_selected_seed()
	if seed_item == null or seed_item.crop_data == null:
		crop_name_label.text = "Рослина: —"
		growth_time_label.text = "Час дозрівання: —"
		harvest_info_label.text = "Урожай: —"
		bonus_info_label.text = "Вибери насіння."
		confirm_button.disabled = true
		return
	var crop: CropData = seed_item.crop_data
	var fertilizer_item: ItemData = _get_selected_fertilizer()
	var growth_days: int = crop.days_to_grow
	var harvest_amount: int = crop.harvest_amount
	var seed_chance: float = crop.seed_return_chance
	var bonus_lines: PackedStringArray = []
	if fertilizer_item != null:
		var fertilizer: FertilizerData = fertilizer_item.fertilizer_data
		match fertilizer.effect_type:
			FertilizerData.EffectType.GROWTH_SPEED:
				growth_days = maxi(
					1,
					growth_days - int(fertilizer.effect_value)
				)
				bonus_lines.append(
					"−%d дн. до дозрівання" % int(fertilizer.effect_value)
				)
			FertilizerData.EffectType.HARVEST_AMOUNT:
				harvest_amount += int(fertilizer.effect_value)
				bonus_lines.append(
					"+%d до врожаю" % int(fertilizer.effect_value)
				)
			FertilizerData.EffectType.SEED_CHANCE:
				seed_chance += fertilizer.effect_value
				bonus_lines.append(
					"+%g відсоткових пунктів до шансу насіння"
					% fertilizer.effect_value
				)

	crop_name_label.text = "Рослина: %s" % crop.crop_name
	growth_time_label.text = "Час дозрівання: %d дн." % growth_days
	#harvest_info_label.text = "Урожай: %d шт. %s\nШанс насіння: %g%%" % [
		#harvest_amount,
		#crop.harvest_item_id,
		#clampf(seed_chance, 0.0, 100.0)
	#]
	harvest_info_label.text = "Урожай: %d шт. %s\nШанс отримати насіння: %.0f%% [%s]" % [
		harvest_amount,
		crop.crop_name,
		clampf(seed_chance, 0.0, 100.0),
		"є шанс" if seed_chance > 0 else "немає шансу"
	]
	if bonus_lines.is_empty():
		bonus_info_label.text = "Без добрива: бонусів немає."
	else:
		bonus_info_label.text = "\n".join(bonus_lines)
	confirm_button.disabled = false

func _on_confirm_pressed() -> void:
	var seed_item: ItemData = _get_selected_seed()
	if seed_item == null:
		return
	if not is_instance_valid(player) or not is_instance_valid(farm_plots):
		close_window()
		return
	var fertilizer_item: ItemData = _get_selected_fertilizer()
	if not farm_plots.plant_crop(
		target_cell,
		player,
		seed_item,
		fertilizer_item
	):
		_refresh_options()
		_update_information()
		return
	close_window()
