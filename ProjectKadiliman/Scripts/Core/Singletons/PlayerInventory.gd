# PlayerInventory.gd (FIXED version)
extends Node

signal active_item_updated
signal hotbar_updated
signal inventory_updated

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")
const NUM_INVENTORY_SLOTS = 30
const NUM_HOTBAR_SLOTS = 10

var inventory = {}
var hotbar = {}
var equips = {}
var trash = {}  # Trash storage
var active_item_slot = -1

var item_resources = {}  # Will hold all ItemResource instances
var item_resources_by_id = {}  # For quick lookup by item_id

func _ready():
	load_item_resources()
	print("Loaded ", item_resources.size(), " item resources")
	
	# Add test items if inventory is empty
	if inventory.is_empty() and hotbar.is_empty():
		add_test_items()

# Function to add test items
func add_test_items():
	print("Adding test items to inventory...")
	
	# List of test items to add
	var test_items = [
		# Format: ["Item Name", quantity]
		["Shovel", 1],
		["Hoe", 1],
		["Watering Can", 1],
		["Peeble", 25],
		["Arrow", 10],
		["Cross Bow", 1],
		["Slingshot", 1],
		["Black Shirt", 1],
		["Blue Pants", 1],
		["Brown Shoes", 1],
		["Egg", 5],
		["Milk", 2],
		["Bracelet", 1]
	]
	
	var added_count = 0
	for test_item in test_items:
		var item_name = test_item[0]
		var quantity = test_item[1]
		
		# Check if item exists in resources before adding
		if has_item_resource(item_name):
			var success = add_item(item_name, quantity)
			if success:
				added_count += 1
				print("✓ Added test item: ", item_name, " x", quantity)
			else:
				print("✗ Failed to add test item: ", item_name, " (inventory full)")
		else:
			print("✗ Test item not found in resources: ", item_name)
	
	print("Added ", added_count, "/", test_items.size(), " test items successfully")
	
	# Add some items to hotbar directly for testing
	if hotbar.is_empty():
		# Put some useful tools in hotbar slots
		var hotbar_items = [
			[0, "Shovel", 1],
			[1, "Hoe", 1],
			[2, "Watering Can", 1],
			[3, "Cross Bow", 1],
			[4, "Slingshot", 1],
			[5, "Peeble", 15],
			[6, "Arrow", 5]
		]
		
		for hotbar_item in hotbar_items:
			var slot_index = hotbar_item[0]
			var item_name = hotbar_item[1]
			var quantity = hotbar_item[2]
			
			if has_item_resource(item_name):
				hotbar[slot_index] = [item_name, quantity]
				print("✓ Added to hotbar slot ", slot_index, ": ", item_name, " x", quantity)
		
		hotbar_updated.emit()
	
	# Initialize equipment from customizer
	initialize_equipment_from_customizer()
	
	# Set active item to first hotbar slot
	if hotbar.has(0):
		active_item_slot = 0
		print("Active item set to hotbar slot 0: ", hotbar[0][0])
		active_item_updated.emit()
	
	# Force update of inventory UI
	inventory_updated.emit()

# Load all ItemResource files
func load_item_resources():
	var items_folder = "res://Scripts/Data/Resource/Items/"
	var dir = DirAccess.open(items_folder)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource_path = items_folder + file_name
				var item_resource = load(resource_path)
				if item_resource is ItemResource:
					item_resources[item_resource.display_name] = item_resource
					item_resources_by_id[item_resource.item_id] = item_resource
					print("Loaded item resource: ", item_resource.display_name, " (ID: ", item_resource.item_id, ")")
			file_name = dir.get_next()
	else:
		print("Error: Could not open items folder: ", items_folder)

func get_item_resource(item_name: String) -> ItemResource:
	if item_resources.has(item_name):
		return item_resources[item_name]
	
	# Fallback: try to find by item_id
	if item_resources_by_id.has(item_name):
		return item_resources_by_id[item_name]
	
	# Try to find by item_id (case-insensitive)
	for resource in item_resources.values():
		if resource.item_id.to_lower() == item_name.to_lower():
			return resource
	
	print("Warning: Item resource not found: ", item_name)
	return null

func get_item_resource_by_id(item_id: String) -> ItemResource:
	return item_resources_by_id.get(item_id)

func has_item_resource(item_name: String) -> bool:
	return get_item_resource(item_name) != null

func get_stack_size(item_name: String) -> int:
	var resource = get_item_resource(item_name)
	if resource:
		return resource.stack_size  # FIXED: Use dot notation
	return 1

func get_item_category(item_name: String) -> String:
	var resource = get_item_resource(item_name)
	if resource:
		return resource.item_category  # FIXED: Use dot notation
	return ""

# FIXED: Sync equipment to player using Resource properties
func sync_equipment_to_player():
	if not PlayerCharacterData:
		print("PlayerCharacterData not found for equipment sync")
		return
	
	print("Syncing equipment to player character...")
	
	# Clear current equipment
	PlayerCharacterData.player_character_data.current_tool = "none"
	PlayerCharacterData.player_character_data.current_weapon = "none" 
	PlayerCharacterData.player_character_data.current_range_weapon = "none"
	
	# Reset clothing to "none" first
	PlayerCharacterData.player_character_data.shirts = 0  # 0 = "none"
	PlayerCharacterData.player_character_data.pants = 0   # 0 = "none" 
	PlayerCharacterData.player_character_data.shoes = 0   # 0 = "none"
	
	# Update equipment based on what's equipped
	for slot_index in equips:
		var item_data = equips[slot_index]
		var item_name = item_data[0]
		
		print("Processing equipped item: ", item_name, " in slot ", slot_index)
		
		var resource = get_item_resource(item_name)
		if resource:
			var item_category = resource.item_category  # FIXED: Use dot notation
			
			match item_category:
				"Tool":
					PlayerCharacterData.player_character_data.current_tool = item_name
					print("  -> Set as current tool: ", item_name)
				"Weapon":
					PlayerCharacterData.player_character_data.current_weapon = item_name
					print("  -> Set as current weapon: ", item_name)
				"Range Weapon":
					PlayerCharacterData.player_character_data.current_range_weapon = item_name
					print("  -> Set as current range weapon: ", item_name)
				"Shirts", "Pants", "Shoes":
					# Clothing is handled through the customizer data
					update_clothing_from_equipment(item_name, item_category)
		else:
			print("  -> Item resource not found: ", item_name)
	
	print("Equipment sync complete")
	print("  Current tool: ", PlayerCharacterData.player_character_data.current_tool)
	print("  Current weapon: ", PlayerCharacterData.player_character_data.current_weapon)
	print("  Current range weapon: ", PlayerCharacterData.player_character_data.current_range_weapon)
	print("  Shirt index: ", PlayerCharacterData.player_character_data.shirts)
	print("  Pants index: ", PlayerCharacterData.player_character_data.pants)
	print("  Shoes index: ", PlayerCharacterData.player_character_data.shoes)
	
	# Emit signal to update all character displays
	inventory_updated.emit()

# FIXED: Update clothing when equipment changes
func update_clothing_from_equipment(item_name: String, item_category: String):
	var data = PlayerCharacterData.player_character_data
	var is_female = data.is_female
	
	match item_category:
		"Shirts":
			# Find the index for this shirt
			var spritesheet = CompositeSprites.get_shirts_spritesheet(is_female)
			var keys = spritesheet.keys()
			var shirt_index = keys.find(item_name)
			if shirt_index != -1:
				data.shirts = shirt_index
				print("Updated shirt to: ", item_name, " (index: ", shirt_index, ")")
		
		"Pants":
			# Find the index for these pants
			var spritesheet = CompositeSprites.get_pants_spritesheet(is_female)
			var keys = spritesheet.keys()
			var pants_index = keys.find(item_name)
			if pants_index != -1:
				data.pants = pants_index
				print("Updated pants to: ", item_name, " (index: ", pants_index, ")")
		
		"Shoes":
			# Find the index for these shoes
			var spritesheet = CompositeSprites.get_shoes_spritesheet(is_female)
			var keys = spritesheet.keys()
			var shoes_index = keys.find(item_name)
			if shoes_index != -1:
				data.shoes = shoes_index
				print("Updated shoes to: ", item_name, " (index: ", shoes_index, ")")

# FIXED: Handle unequipping clothing
func unequip_clothing(slot_index: int):
	if equips.has(slot_index):
		var item_name = equips[slot_index][0]
		var resource = get_item_resource(item_name)
		var item_category = resource.item_category if resource else ""  # FIXED: Use dot notation
		
		# Remove from equipment
		equips.erase(slot_index)
		
		# Update player character data to show "none"
		var data = PlayerCharacterData.player_character_data
		
		match item_category:
			"Shirts":
				data.shirts = 0  # This will correspond to "none" since we added it as first entry
			"Pants":
				data.pants = 0   # This will correspond to "none"
			"Shoes":
				data.shoes = 0   # This will correspond to "none"
		
		print("Unequipped: ", item_name)
		sync_equipment_to_player()
		return true
	
	return false

# NEW: Initialize equipment based on character customization data
func initialize_equipment_from_customizer():
	if not PlayerCharacterData:
		print("PlayerCharacterData not found!")
		return
	
	var data = PlayerCharacterData.player_character_data
	var is_female = data.is_female
	
	# Clear existing equips
	equips.clear()
	
	print("Initializing equipment from customizer:")
	print("  Shirts index: ", data.shirts)
	print("  Pants index: ", data.pants)
	print("  Shoes index: ", data.shoes)
	
	# Get clothing names based on indices from customizer
	# Note: Index 0 now means "none" (no clothing equipped)
	var shirt_name = get_shirt_name(data.shirts, is_female)
	var pants_name = get_pants_name(data.pants, is_female) 
	var shoes_name = get_shoes_name(data.shoes, is_female)
	
	print("  Shirt name: ", shirt_name)
	print("  Pants name: ", pants_name)
	print("  Shoes name: ", shoes_name)
	
	# Set equipment slots only if we have actual clothing (not "none")
	# Slot 1: Shirt (BODY equipment slot)
	# Slot 2: Pants (LEGS equipment slot) 
	# Slot 3: Shoes (FOOT equipment slot)
	if shirt_name != "none" and shirt_name != "":
		equips[1] = [shirt_name, 1]  # BODY slot
	if pants_name != "none" and pants_name != "":
		equips[3] = [pants_name, 1]  # LEGS slot
	if shoes_name != "none" and shoes_name != "":
		equips[5] = [shoes_name, 1]  # FOOT slot
	
	print("Equipment initialized from customizer:")
	print("  Equips: ", equips)
	
	# Sync to player character
	sync_equipment_to_player()

# Helper functions to get clothing names from customizer indices
func get_shirt_name(shirt_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_shirts_spritesheet(is_female)
	var keys = spritesheet.keys()
	
	if shirt_index < keys.size():
		return keys[shirt_index]
	return "none"

func get_pants_name(pants_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_pants_spritesheet(is_female)
	var keys = spritesheet.keys()
	
	if pants_index < keys.size():
		return keys[pants_index]
	return "none"

func get_shoes_name(shoes_index: int, is_female: bool) -> String:
	var spritesheet = CompositeSprites.get_shoes_spritesheet(is_female)
	var keys = spritesheet.keys()
	
	if shoes_index < keys.size():
		return keys[shoes_index]
	return "none"

# Update equipment when character data changes
func update_equipment_from_customizer():
	initialize_equipment_from_customizer()
	# Emit signal to update inventory UI if needed
	print("Equipment updated from customizer")

# FIXED: Add item function using Resource properties
func add_item(item_name, item_quantity):
	print("Adding item to inventory: ", item_name, " x", item_quantity)
	
	# First, try to add to existing stacks in inventory
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = get_stack_size(item_name)  # FIXED: Use helper function
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				print("Added to existing stack: ", inventory[item][1])
				inventory_updated.emit()
				return true
			elif able_to_add > 0:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
				print("Partially added to existing stack, remaining: ", item_quantity)
				inventory_updated.emit()
	
	# Try to add to existing stacks in hotbar
	for item in hotbar:
		if hotbar[item][0] == item_name:
			var stack_size = get_stack_size(item_name)  # FIXED: Use helper function
			var able_to_add = stack_size - hotbar[item][1]
			if able_to_add >= item_quantity:
				hotbar[item][1] += item_quantity
				hotbar_updated.emit()
				print("Added to existing hotbar stack: ", hotbar[item][1])
				inventory_updated.emit()
				return true
			elif able_to_add > 0:
				hotbar[item][1] += able_to_add
				hotbar_updated.emit()
				item_quantity = item_quantity - able_to_add
				print("Partially added to hotbar stack, remaining: ", item_quantity)
				inventory_updated.emit()
	
	# Item doesn't exist in inventory yet, so add it to an empty slot
	# First try inventory slots
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			print("Added to new inventory slot ", i, ": ", item_name, " x", item_quantity)
			inventory_updated.emit()
			return true
	
	# If inventory is full, try hotbar slots
	for i in range(NUM_HOTBAR_SLOTS):
		if not hotbar.has(i):
			hotbar[i] = [item_name, item_quantity]
			hotbar_updated.emit()
			print("Added to new hotbar slot ", i, ": ", item_name, " x", item_quantity)
			inventory_updated.emit()
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
		inventory_updated.emit()
	
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
				inventory_updated.emit()
				return true
		SlotClass.SlotType.INVENTORY:
			if not inventory.has(slot_index):
				inventory[slot_index] = [item.item_name, item.item_quantity]
				print("Added to inventory slot ", slot_index)
				inventory_updated.emit()
				return true
		SlotClass.SlotType.TRASH:
			# Trash always uses index 0 - overwrite any existing trash
			trash[0] = [item.item_name, item.item_quantity]
			print("Added to trash slot: ", item.item_name)
			inventory_updated.emit()
			return true
		_:
			if not equips.has(slot_index):
				equips[slot_index] = [item.item_name, item.item_quantity]
				print("Added to equipment slot ", slot_index)
				inventory_updated.emit()
				return true
	
	print("Failed to add item to slot - slot may already be occupied")
	return false

func add_item_quantity(slot: SlotClass, quantity_to_add: int):
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity_to_add
			hotbar_updated.emit()
			inventory_updated.emit()
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add
			inventory_updated.emit()
		_:
			equips[slot.slot_index][1] += quantity_to_add
			inventory_updated.emit()

### Trash Related Functions
func add_trash_quantity(slot: SlotClass, quantity_to_add: int):
	if trash.has(slot.slot_index):
		trash[slot.slot_index][1] += quantity_to_add
		inventory_updated.emit()

func remove_trash_item(slot: SlotClass) -> bool:
	# Trash always uses index 0
	var existed = trash.has(0)
	if existed:
		print("Removing trash item: ", trash[0][0], " x", trash[0][1])
	trash.erase(0)
	if existed:
		inventory_updated.emit()
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

# Keep the old ammo functions for backward compatibility
func has_ammo(ammo_type: String) -> bool:
	return has_item(ammo_type)

func get_ammo_count(ammo_type: String) -> int:
	return get_item_count(ammo_type)

func consume_ammo(ammo_type: String, amount: int = 1) -> bool:
	return consume_item(ammo_type, amount)
