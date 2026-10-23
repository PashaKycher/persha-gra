class_name ToolData
extends Resource

@export var id: String
@export var display_name: String
@export var tool_type: StringName
@export var material_id: StringName
@export_range(0.1, 100.0, 0.1) var power: float = 1.0
@export_range(0, 1000, 1) var energy_cost: int = 10
