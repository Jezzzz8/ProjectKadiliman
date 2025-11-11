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

static var available_tools: Array = ["None", "Hoe", "Shovel", "Watering Can"]
static var available_weapons: Array = ["None"]
static var available_range_weapons: Array = ["None", "Slingshot"]

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

# Tool cycling
static func cycle_tool() -> void:
	var current_index = available_tools.find(player_character_data.current_tool)
	if current_index == -1:
		current_index = 0
	
	var new_index = (current_index + 1) % available_tools.size()
	player_character_data.current_tool = available_tools[new_index]

# Weapon cycling
static func cycle_weapon() -> void:
	var current_index = available_weapons.find(player_character_data.current_weapon)
	if current_index == -1:
		current_index = 0
	
	var new_index = (current_index + 1) % available_weapons.size()
	player_character_data.current_weapon = available_weapons[new_index]

# Range weapon cycling
static func cycle_range_weapon() -> void:
	var current_index = available_range_weapons.find(player_character_data.current_range_weapon)
	if current_index == -1:
		current_index = 0
	
	var new_index = (current_index + 1) % available_range_weapons.size()
	player_character_data.current_range_weapon = available_range_weapons[new_index]

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
	if player_character_data.current_range_weapon != "None":
		return get_current_range_weapon_texture()
	elif player_character_data.current_weapon != "None":
		return get_current_weapon_texture()
	else:
		return get_current_tool_texture()

static func get_item_texture(item_name: String):
	if CompositeSprites:
		return CompositeSprites.get_item_texture(item_name)
	else:
		print("Error: CompositeSprites autoload not found")
		return null
