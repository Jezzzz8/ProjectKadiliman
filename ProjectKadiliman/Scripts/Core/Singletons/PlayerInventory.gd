extends Node

signal active_item_updated
signal hotbar_updated

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")
const NUM_INVENTORY_SLOTS = 30
const NUM_HOTBAR_SLOTS = 10

var active_item_slot = -1

var inventory = {
	0: ["Hoe", 1],
	1: ["Shovel", 1],
	2: ["Cross Bow", 1],
	3: ["Watering Can", 1],
	4: ["Slingshot", 1],
	5: ["Peeble", 99]
}

var hotbar = {
	0: ["Watering Can", 1],
	1: ["Hoe", 1],
	2: ["Shovel", 1],
	3: ["Slingshot", 1],
	5: ["Peeble", 99],
}

var equips = {
	1: ["Blue Shirt", 1],
}

func add_item(item_name, item_quantity):
	print("Adding item to inventory: ", item_name, " x", item_quantity)
	
	# First, try to add to existing stacks
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				print("Added to existing stack: ", inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
				print("Partially added to existing stack, remaining: ", item_quantity)
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			print("Added to new slot ", i, ": ", item_name, " x", item_quantity)
			return
	
	print("No empty slots available!")

func update_slot_visual(slot_index, item_name, new_quantity):
	var slots = get_tree().get_nodes_in_group("Slots")
	if slot_index < 0 or slot_index >= slots.size():
		print("Error: Invalid slot index ", slot_index)
		return
	var slot = slots[slot_index]
	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)

func remove_item(slot: SlotClass):
	match slot.slot_type:  # FIX: Changed from slot.SlotType to slot.slot_type
		SlotClass.SlotType.HOTBAR:
			hotbar.erase(slot.slot_index)
		SlotClass.SlotType.INVENTORY:
			inventory.erase(slot.slot_index)
		_:
			equips.erase(slot.slot_index)

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
	match slot.slot_type:  # FIX: Changed from slot.SlotType to slot.slot_type
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
			hotbar_updated.emit()
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index] = [item.item_name, item.item_quantity]
		_:
			equips[slot.slot_index] = [item.item_name, item.item_quantity]

func add_item_quantity(slot: SlotClass, quantity_to_add: int):
	match slot.slot_type:  # FIX: Changed from slot.SlotType to slot.slot_type and removed is_hotbar parameter
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity_to_add
			hotbar_updated.emit()
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add
		_:
			equips[slot.slot_index][1] += quantity_to_add

### Hotbar Related Functions
func active_item_scroll_up() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	print("Active item slot changed to: ", active_item_slot)
	emit_signal("active_item_updated")

func active_item_scroll_down() -> void:
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	print("Active item slot changed to: ", active_item_slot)
	emit_signal("active_item_updated")
