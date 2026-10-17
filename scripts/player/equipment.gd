
class_name Equipment
extends Node

const SLOT_COUNT: int = 6

var slots: Array[ItemData] = [
	null, null, null, null, null, null
]


func get_item(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return null

	return slots[slot_index]


func is_equipped(item_id: String) -> bool:
	for item in slots:
		if item != null and item.id == item_id:
			return true

	return false


func is_tool_type_equipped(tool_type: StringName) -> bool:
	for item in slots:
		if item == null or item.tool_data == null:
			continue

		if item.tool_data.tool_type == tool_type:
			return true

	return false


func equip_item(
	item: ItemData,
	inventory: Inventory,
	slot_index: int
) -> bool:
	if item == null or inventory == null:
		return false

	if item.tool_data == null:
		return false

	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false

	if slots[slot_index] != null:
		return false

	if is_tool_type_equipped(item.tool_data.tool_type):
		return false

	if inventory.get_amount(item.id) <= 0:
		return false

	if not inventory.remove_item(item.id, 1):
		return false

	slots[slot_index] = item
	return true


func unequip_item(
	slot_index: int,
	inventory: Inventory
) -> bool:
	if inventory == null:
		return false

	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false

	var item: ItemData = slots[slot_index]

	if item == null:
		return false

	if not inventory.can_add_item(item):
		return false

	inventory.add_item(item, 1)
	slots[slot_index] = null

	return true
