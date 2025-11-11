extends Node

static var player_character_data: Dictionary = {
	"body": 0,
	"hair": 0,
	"pants": 0,
	"shirts": 0,
	"shoes": 0,
	"is_female": false,
	"current_tool": "none",
	"current_weapon": "none",
	"current_range_weapon": "none"
}

static var available_tools: Array = ["none", "Hoe", "Shovel", "Watering Can"]
static var available_weapons: Array = ["none"]
static var available_range_weapons: Array = ["none", "Slingshot"]

static func validate_data(data: Dictionary) -> bool:
	return data.has_all(["body", "hair", "pants", "shirts", "shoes", "is_female", "current_tool", "current_weapon", "current_range_weapon"])

static func get_default_data() -> Dictionary:
	return {
		"body": 0,
		"hair": 0,
		"pants": 0,
		"shirts": 0,
		"shoes": 0,
		"is_female": false,
		"current_tool": "none",
		"current_weapon": "none",
		"current_range_weapon": "none"
	}

# NEW: Sync equipment from inventory
static func sync_equipment_from_inventory():
	if not PlayerInventory:
		print("PlayerInventory not found for equipment sync")
		return
	
	# Check equipped items and update current equipment
	for slot_index in PlayerInventory.equips:
		var item_data = PlayerInventory.equips[slot_index]
		var item_name = item_data[0]
		var item_category = JsonData.item_data[item_name]["ItemCategory"]
		
		match item_category:
			"Tool":
				if item_name in available_tools:
					player_character_data.current_tool = item_name
			"Range Weapon":
				if item_name in available_range_weapons:
					player_character_data.current_range_weapon = item_name
			# Add more categories as needed

# Tool cycling - FIXED: No infinite recursion
static func cycle_tool() -> void:
	var current_index = available_tools.find(player_character_data.current_tool)
	if current_index == -1:
		current_index = 0
	
	# FIX: Use iterative approach instead of recursion
	var attempts = 0
	var max_attempts = available_tools.size()
	
	while attempts < max_attempts:
		var new_index = (current_index + 1) % available_tools.size()
		player_character_data.current_tool = available_tools[new_index]
		
		# If player has this tool or it's "none", we're done
		if player_character_data.current_tool == "none" or has_item_in_inventory(available_tools[new_index]):
			return
		
		# Otherwise, continue to next tool
		current_index = new_index
		attempts += 1
	
	# If we exhausted all options, set to "none"
	player_character_data.current_tool = "none"

# Weapon cycling - FIXED: No infinite recursion
static func cycle_weapon() -> void:
	var current_index = available_weapons.find(player_character_data.current_weapon)
	if current_index == -1:
		current_index = 0
	
	# FIX: Use iterative approach instead of recursion
	var attempts = 0
	var max_attempts = available_weapons.size()
	
	while attempts < max_attempts:
		var new_index = (current_index + 1) % available_weapons.size()
		player_character_data.current_weapon = available_weapons[new_index]
		
		# If player has this weapon or it's "none", we're done
		if player_character_data.current_weapon == "none" or has_item_in_inventory(available_weapons[new_index]):
			return
		
		# Otherwise, continue to next weapon
		current_index = new_index
		attempts += 1
	
	# If we exhausted all options, set to "none"
	player_character_data.current_weapon = "none"

# Range weapon cycling - FIXED: No infinite recursion
static func cycle_range_weapon() -> void:
	var current_index = available_range_weapons.find(player_character_data.current_range_weapon)
	if current_index == -1:
		current_index = 0
	
	# FIX: Use iterative approach instead of recursion
	var attempts = 0
	var max_attempts = available_range_weapons.size()
	
	while attempts < max_attempts:
		var new_index = (current_index + 1) % available_range_weapons.size()
		player_character_data.current_range_weapon = available_range_weapons[new_index]
		
		# If player has this weapon or it's "none", we're done
		if player_character_data.current_range_weapon == "none" or has_item_in_inventory(available_range_weapons[new_index]):
			return
		
		# Otherwise, continue to next weapon
		current_index = new_index
		attempts += 1
	
	# If we exhausted all options, set to "none"
	player_character_data.current_range_weapon = "none"

# NEW: Check if item exists in player's inventory
static func has_item_in_inventory(item_name: String) -> bool:
	if not PlayerInventory:
		return false
	
	# Check hotbar
	for slot_index in PlayerInventory.hotbar:
		if PlayerInventory.hotbar[slot_index][0] == item_name:
			return true
	
	# Check inventory
	for slot_index in PlayerInventory.inventory:
		if PlayerInventory.inventory[slot_index][0] == item_name:
			return true
	
	# Check equipped items
	for slot_index in PlayerInventory.equips:
		if PlayerInventory.equips[slot_index][0] == item_name:
			return true
	
	return false

# Texture getters
static func get_current_tool_texture():
	return CompositeSprites.get_tool_texture(player_character_data.current_tool)

static func get_current_weapon_texture():
	return CompositeSprites.get_weapon_texture(player_character_data.current_weapon)

static func get_current_range_weapon_texture():
	return CompositeSprites.get_range_weapon_texture(player_character_data.current_range_weapon)

# Get currently equipped item texture (prioritizes weapons over tools)
static func get_current_equipment_texture():
	# Priority: range weapon > melee weapon > tool
	if player_character_data.current_range_weapon != "none":
		return get_current_range_weapon_texture()
	elif player_character_data.current_weapon != "none":
		return get_current_weapon_texture()
	else:
		return get_current_tool_texture()

static func get_item_texture(item_name: String):
	if CompositeSprites:
		return CompositeSprites.get_item_texture(item_name)
	else:
		print("Error: CompositeSprites autoload not found")
		return null
