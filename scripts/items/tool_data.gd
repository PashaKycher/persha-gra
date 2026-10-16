
class_name ToolData
extends Resource


@export var id: String
@export var display_name: String

# Тип інструмента: axe, pickaxe, knife, hammer
@export var tool_type: StringName

# Матеріал: stone, copper, iron тощо
@export var material_id: StringName

# Базова ефективність інструмента
@export_range(0.1, 100.0, 0.1) var power: float = 1.0

# Витрати енергії за використання
@export_range(0, 1000, 1) var energy_cost: int = 10
