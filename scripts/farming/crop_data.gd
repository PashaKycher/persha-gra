class_name CropData
extends Resource

@export var id: StringName
@export var crop_name: String = ""
@export var seed_item_id: String = ""
@export var days_to_grow: int = 3
@export var harvest_item_id: String = ""
@export var harvest_amount: int = 2
@export_range(0.0, 100.0, 1.0) var seed_return_chance: float = 30.0
