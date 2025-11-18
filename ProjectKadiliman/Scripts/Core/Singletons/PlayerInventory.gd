extends Node

signal active_item_updated
signal hotbar_updated
signal inventory_updated  # NEW: Signal for general inventory updates

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")
const NUM_INVENTORY_SLOTS = 30
const NUM_HOTBAR_SLOTS = 10

var active_item_slot = -1

var inventory = {
	0: ["Peeble", 50],
	1: ["Arrow", 50],
}

var hotbar = {
	0: ["Watering Can", 1],
	1: ["Hoe", 1],
	2: ["Shovel", 1],
	3: ["Slingshot", 1],
	4: ["Cross Bow", 1],
}

# UPDATED: Equipment will be populated from character customizer
var equips = {}

# NEW: Add trash storage
var trash = {}  # Store trash items separately

func _ready():
	# NEW: Initialize equipment from character customizer
	initialize_equipment_from_customizer()

# NEW: Initialize equipment based on character customization data
func initialize_equipment_from_customizer():
	if not PlayerCharacterData:
		print("PlayerCharacterData not found!")
		return
	
	var data = PlayerCharacterData.player_character_data
	var is_female = data.is_female
	
	# Clear existing equips
	equips.clear()
	
	# Get clothing names based on indices from customizer
	var shirt_name = get_shirt_name(data.shirts, is_female)
	var pants_name = get_pants_name(data.pants, is_female) 
	var shoes_name = get_shoes_name(data.shoes, is_female)
	
	# Set equipment slots 
	# Slot 1: Shirt (BODY equipment slot)
	# Slot 2: Pants (LEGS equipment slot) 
	# Slot 3: Shoes (FOOT equipment slot)
	equips[1] = [shirt_name, 1]  # BODY slot
	equips[3] = [pants_name, 1]  # LEGS slot
	equips[5] = [shoes_name, 1]  # FOOT slot
	
	print("Equipment initialized from customizer:")
	print("  Shirt: ", shirt_name, " (Slot 1 - BODY)")
	print("  Pants: ", pants_name, " (Slot 3 - LEGS)")
	print("  Shoes: ", shoes_name, " (Slot 5 - FOOT)")

# NEW: Helper functions to get clothing names from customizer indices
func get_shirt_name(shirt_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_shirts_spritesheet(is_female)
	var keys = spritesheet.keys()
	if shirt_index < keys.size():
		return keys[shirt_index]
	return "Black Shirt"  # Default fallback

func get_pants_name(pants_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_pants_spritesheet(is_female)
	var keys = spritesheet.keys()
	if pants_index < keys.size():
		return keys[pants_index]
	return "Black Pants"  # Default fallback

func get_shoes_name(shoes_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_shoes_spritesheet(is_female)
	var keys = spritesheet.keys()
	if shoes_index < keys.size():
		return keys[shoes_index]
	return "Black Shoes"  # Default fallback

# NEW: Update equipment when character data changes (for real-time updates)
func update_equipment_from_customizer():
	initialize_equipment_from_customizer()
	# Emit signal to update inventory UI if needed
	print("Equipment updated from customizer")

func add_item(item_name, item_quantity):
	print("Adding item to inventory: ", item_name, " x", item_quantity)
	
	# First, try to add to existing stacks in inventory
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				print("Added to existing stack: ", inventory[item][1])
				inventory_updated.emit()  # NEW: Emit update signal
				return true
			elif able_to_add > 0:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
				print("Partially added to existing stack, remaining: ", item_quantity)
				inventory_updated.emit()  # NEW: Emit update signal
	
	# Try to add to existing stacks in hotbar
	for item in hotbar:
		if hotbar[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - hotbar[item][1]
			if able_to_add >= item_quantity:
				hotbar[item][1] += item_quantity
				hotbar_updated.emit()
				print("Added to existing hotbar stack: ", hotbar[item][1])
				inventory_updated.emit()  # NEW: Emit update signal
				return true
			elif able_to_add > 0:
				hotbar[item][1] += able_to_add
				hotbar_updated.emit()
				item_quantity = item_quantity - able_to_add
				print("Partially added to hotbar stack, remaining: ", item_quantity)
				inventory_updated.emit()  # NEW: Emit update signal
	
	# Item doesn't exist in inventory yet, so add it to an empty slot
	# First try inventory slots
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			print("Added to new inventory slot ", i, ": ", item_name, " x", item_quantity)
			inventory_updated.emit()  # NEW: Emit update signal
			return true
	
	# If inventory is full, try hotbar slots
	for i in range(NUM_HOTBAR_SLOTS):
		if not hotbar.has(i):
			hotbar[i] = [item_name, item_quantity]
			hotbar_updated.emit()
			print("Added to new hotbar slot ", i, ": ", item_name, " x", item_quantity)
			inventory_updated.emit()  # NEW: Emit update signal
			return true
	
	# Both inventory and hotbar are full
	print("No empty slots available in inventory or hotbar!")
	return false

func update_slot_visual(slot_index, item_name, new_quantity):
	var slots = get_tree().get_nodes_in_group("Slots")
	if slot_index < 0 or slot_index >= slots.size():
		print("Error: Invalid slot index ", slot_index, " for visual update. Slots count: ", slots.size())
		return
	
	var slot = slots[slot_index]
	if slot == null:
		print("Error: Slot at index ", slot_index, " is null")
		return
	
	if new_quantity <= 0:
		# Item should be removed - just queue_free it
		if slot.item != null:
			print("Queue freeing item from slot ", slot_index)
			slot.item.queue_free()
			slot.item = null
			slot.refresh_style()  # Refresh the slot appearance
	else:
		# Update or create item
		if slot.item != null:
			slot.item.set_item(item_name, new_quantity)
		else:
			slot.initialize_item(item_name, new_quantity)

func remove_item(slot: SlotClass) -> bool:
	var slot_index = slot.slot_index
	var slot_type = slot.slot_type
	var existed = false
	
	print("Removing item from slot - Type: ", slot_type, ", Index: ", slot_index)
	
	match slot_type:
		SlotClass.SlotType.HOTBAR:
			existed = hotbar.has(slot_index)
			if existed:
				print("Removing from hotbar: ", hotbar[slot_index])
				hotbar.erase(slot_index)
				hotbar_updated.emit()
		SlotClass.SlotType.INVENTORY:
			existed = inventory.has(slot_index)
			if existed:
				print("Removing from inventory: ", inventory[slot_index])
				inventory.erase(slot_index)
		SlotClass.SlotType.TRASH:
			# FIXED: Trash items DO exist in PlayerInventory data
			existed = trash.has(0)  # Trash always uses index 0
			if existed:
				print("Removing from trash: ", trash[0])
				trash.erase(0)
		_:
			existed = equips.has(slot_index)
			if existed:
				print("Removing from equipment: ", equips[slot_index])
				equips.erase(slot_index)
	
	if existed:
		inventory_updated.emit()  # NEW: Emit update signal
	
	return existed

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass) -> bool:
	var slot_index = slot.slot_index
	var slot_type = slot.slot_type
	
	print("Adding item to empty slot - Type: ", slot_type, ", Index: ", slot_index, ", Item: ", item.item_name)
	
	match slot_type:
		SlotClass.SlotType.HOTBAR:
			if not hotbar.has(slot_index):
				hotbar[slot_index] = [item.item_name, item.item_quantity]
				hotbar_updated.emit()
				print("Added to hotbar slot ", slot_index)
				inventory_updated.emit()  # NEW: Emit update signal
				return true
		SlotClass.SlotType.INVENTORY:
			if not inventory.has(slot_index):
				inventory[slot_index] = [item.item_name, item.item_quantity]
				print("Added to inventory slot ", slot_index)
				inventory_updated.emit()  # NEW: Emit update signal
				return true
		SlotClass.SlotType.TRASH:
			# Trash always uses index 0 - overwrite any existing trash
			trash[0] = [item.item_name, item.item_quantity]
			print("Added to trash slot: ", item.item_name)
			inventory_updated.emit()  # NEW: Emit update signal
			return true
		_:
			if not equips.has(slot_index):
				equips[slot_index] = [item.item_name, item.item_quantity]
				print("Added to equipment slot ", slot_index)
				inventory_updated.emit()  # NEW: Emit update signal
				return true
	
	print("Failed to add item to slot - slot may already be occupied")
	return false

func add_item_quantity(slot: SlotClass, quantity_to_add: int):
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity_to_add
			hotbar_updated.emit()
			inventory_updated.emit()  # NEW: Emit update signal
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add
			inventory_updated.emit()  # NEW: Emit update signal
		_:
			equips[slot.slot_index][1] += quantity_to_add
			inventory_updated.emit()  # NEW: Emit update signal

### Trash Related Functions
func add_trash_quantity(slot: SlotClass, quantity_to_add: int):
	if trash.has(slot.slot_index):
		trash[slot.slot_index][1] += quantity_to_add
		inventory_updated.emit()  # NEW: Emit update signal

func remove_trash_item(slot: SlotClass) -> bool:
	# Trash always uses index 0
	var existed = trash.has(0)
	if existed:
		print("Removing trash item: ", trash[0][0], " x", trash[0][1])
	trash.erase(0)
	if existed:
		inventory_updated.emit()  # NEW: Emit update signal
	return existed

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

### General Item Checking Functions
func has_item(item_name: String) -> bool:
	"""Check if player has any quantity of the specified item"""
	# Check inventory
	for slot_index in inventory:
		if inventory[slot_index][0] == item_name and inventory[slot_index][1] > 0:
			return true
	
	# Check hotbar
	for slot_index in hotbar:
		if hotbar[slot_index][0] == item_name and hotbar[slot_index][1] > 0:
			return true
	
	# Check equipment (optional - might not want to count equipped items)
	# for slot_index in equips:
	#     if equips[slot_index][0] == item_name and equips[slot_index][1] > 0:
	#         return true
	
	return false

func get_item_count(item_name: String) -> int:
	"""Get total quantity of specified item across inventory and hotbar"""
	var total_count = 0
	
	# Count in inventory
	for slot_index in inventory:
		if inventory[slot_index][0] == item_name:
			total_count += inventory[slot_index][1]
	
	# Count in hotbar
	for slot_index in hotbar:
		if hotbar[slot_index][0] == item_name:
			total_count += hotbar[slot_index][1]
	
	return total_count

func consume_item(item_name: String, quantity: int = 1) -> bool:
	"""Consume specified quantity of item from inventory/hotbar"""
	print("Attempting to consume item: ", item_name, " x", quantity)
	
	# First, check if we have enough
	if get_item_count(item_name) < quantity:
		print("Not enough ", item_name, " to consume")
		return false
	
	var remaining_to_consume = quantity
	
	# Consume from inventory first
	for slot_index in inventory:
		if inventory[slot_index][0] == item_name and inventory[slot_index][1] > 0:
			var available = inventory[slot_index][1]
			var consume_from_slot = min(available, remaining_to_consume)
			
			inventory[slot_index][1] -= consume_from_slot
			remaining_to_consume -= consume_from_slot
			
			print("Consumed ", consume_from_slot, " ", item_name, " from inventory slot ", slot_index)
			
			# Update slot visual or remove if empty
			if inventory[slot_index][1] <= 0:
				inventory.erase(slot_index)
			else:
				update_slot_visual(slot_index, inventory[slot_index][0], inventory[slot_index][1])
			
			if remaining_to_consume <= 0:
				inventory_updated.emit()
				return true
	
	# Consume from hotbar if still needed
	for slot_index in hotbar:
		if hotbar[slot_index][0] == item_name and hotbar[slot_index][1] > 0:
			var available = hotbar[slot_index][1]
			var consume_from_slot = min(available, remaining_to_consume)
			
			hotbar[slot_index][1] -= consume_from_slot
			remaining_to_consume -= consume_from_slot
			
			print("Consumed ", consume_from_slot, " ", item_name, " from hotbar slot ", slot_index)
			
			# Update slot visual or remove if empty
			if hotbar[slot_index][1] <= 0:
				hotbar.erase(slot_index)
				hotbar_updated.emit()
			else:
				update_slot_visual(slot_index, hotbar[slot_index][0], hotbar[slot_index][1])
			
			if remaining_to_consume <= 0:
				inventory_updated.emit()
				hotbar_updated.emit()
				return true
	
	inventory_updated.emit()
	hotbar_updated.emit()
	return remaining_to_consume <= 0

# Keep the old ammo functions for backward compatibility, but make them use the new general functions
func has_ammo(ammo_type: String) -> bool:
	return has_item(ammo_type)

func get_ammo_count(ammo_type: String) -> int:
	return get_item_count(ammo_type)

func consume_ammo(ammo_type: String, amount: int = 1) -> bool:
	return consume_item(ammo_type, amount)
