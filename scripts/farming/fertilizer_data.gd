class_name FertilizerData
extends Resource

enum EffectType {
	GROWTH_SPEED,
	HARVEST_AMOUNT,
	SEED_CHANCE
}

@export var id: StringName
@export var fertilizer_name: String = ""
@export var effect_type: EffectType = EffectType.GROWTH_SPEED
@export var effect_value: float = 1.0
