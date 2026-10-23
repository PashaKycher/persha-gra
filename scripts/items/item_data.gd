class_name ItemData
extends Resource

@export var id: String
@export var display_name: String
@export var max_stack: int = 99
@export var icon: Texture2D
@export var tool_data: ToolData
@export_group("Farming")
@export var crop_data: CropData
@export var fertilizer_data: FertilizerData
