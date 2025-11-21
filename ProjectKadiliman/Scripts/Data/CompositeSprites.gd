extends Node

var font_style = {
	"Bold": preload("res://Assets/Environment/UI/Fonts/PixelOperator8-Bold.ttf"),
	"Regular": preload("res://Assets/Environment/UI/Fonts/PixelOperator8.ttf"),
	"Baybayin": preload("res://Assets/Environment/UI/Fonts/baybayin-pixel-01.otf"),
}

# Tools/Equipment
var tools_sprite = {
	"none": null,
	"Hoe": preload("res://Assets/Characters/Player/MainHand/hoe_universal.png"),
	"Shovel": preload("res://Assets/Characters/Player/MainHand/shovel_universal.png"),
	"Watering Can": preload("res://Assets/Characters/Player/MainHand/watering_can_universal.png"),
}

var weapons_sprite = {
	"none": null,
}

var range_weapons_sprite = {
	"none": null,
	"Cross Bow": preload("res://Assets/Characters/Player/MainHand/crossbow_universal.png"),
	"Slingshot": preload("res://Assets/Characters/Player/MainHand/slingshot_universal.png"),
}

var accessory_sprite = {
	"none": null,
	# "Bracelet": preload("res://Assets/Characters/Player/Accessories/Bracelet")
}

# Color mapping for equipment and hair
var color_codes = {
	"Black": 0,
	"Blue": 1,
	"Brown": 2,
	"Green": 3,
	"Orange": 4,
	"Purple": 5,
	"Red": 6,
	"Yellow": 7
}

# Male spritesheets
var male_body_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/5_universal.png"),
}

# Male hair spritesheets with colors
var male_hair_spritesheet = {
	# Style 1 with all colors
	"1_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Black_universal.png"),
	"1_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Blue_universal.png"),
	"1_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Brown_universal.png"),
	"1_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Green_universal.png"),
	"1_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Orange_universal.png"),
	"1_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Purple_universal.png"),
	"1_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Red_universal.png"),
	"1_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_Yellow_universal.png"),
	
	# Style 2 with all colors
	"2_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Black_universal.png"),
	"2_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Blue_universal.png"),
	"2_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Brown_universal.png"),
	"2_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Green_universal.png"),
	"2_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Orange_universal.png"),
	"2_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Purple_universal.png"),
	"2_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Red_universal.png"),
	"2_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_Yellow_universal.png"),
	
	# Style 3 with all colors
	"3_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Black_universal.png"),
	"3_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Blue_universal.png"),
	"3_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Brown_universal.png"),
	"3_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Green_universal.png"),
	"3_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Orange_universal.png"),
	"3_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Purple_universal.png"),
	"3_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Red_universal.png"),
	"3_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_Yellow_universal.png"),
	
	# Style 4 with all colors
	"4_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Black_universal.png"),
	"4_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Blue_universal.png"),
	"4_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Brown_universal.png"),
	"4_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Green_universal.png"),
	"4_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Orange_universal.png"),
	"4_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Purple_universal.png"),
	"4_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Red_universal.png"),
	"4_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_Yellow_universal.png"),
	
	# Style 5 with all colors
	"5_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Black_universal.png"),
	"5_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Blue_universal.png"),
	"5_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Brown_universal.png"),
	"5_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Green_universal.png"),
	"5_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Orange_universal.png"),
	"5_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Purple_universal.png"),
	"5_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Red_universal.png"),
	"5_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_Yellow_universal.png"),
	
	# Style 6 with all colors
	"6_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Black_universal.png"),
	"6_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Blue_universal.png"),
	"6_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Brown_universal.png"),
	"6_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Green_universal.png"),
	"6_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Orange_universal.png"),
	"6_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Purple_universal.png"),
	"6_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Red_universal.png"),
	"6_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_Yellow_universal.png"),
	
	# Style 7 with all colors
	"7_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Black_universal.png"),
	"7_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Blue_universal.png"),
	"7_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Brown_universal.png"),
	"7_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Green_universal.png"),
	"7_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Orange_universal.png"),
	"7_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Purple_universal.png"),
	"7_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Red_universal.png"),
	"7_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_Yellow_universal.png"),
	
	# Style 8 with all colors
	"8_Black": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Black_universal.png"),
	"8_Blue": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Blue_universal.png"),
	"8_Brown": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Brown_universal.png"),
	"8_Green": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Green_universal.png"),
	"8_Orange": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Orange_universal.png"),
	"8_Purple": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Purple_universal.png"),
	"8_Red": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Red_universal.png"),
	"8_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_Yellow_universal.png"),
}

var male_pants_spritesheet = {
	"none": null,
	"Black Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/1_universal.png"),
	"Blue Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/2_universal.png"),
	"Brown Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/3_universal.png"),
	"Green Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/4_universal.png"),
	"Orange Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/5_universal.png"),
	"Purple Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/6_universal.png"),
	"Red Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/7_universal.png"),
	"Yellow Pants": preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/8_universal.png"),
}

var male_shirts_spritesheet = {
	"none": null,
	"Black Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/1_universal.png"),
	"Blue Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/2_universal.png"),
	"Brown Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/3_universal.png"),
	"Green Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/4_universal.png"),
	"Orange Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/5_universal.png"),
	"Purple Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/6_universal.png"),
	"Red Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/7_universal.png"),
	"Yellow Shirt": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/8_universal.png"),
}

var male_shoes_spritesheet = {
	"none": null,
	"Black Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/1_universal.png"),
	"Blue Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/2_universal.png"),
	"Brown Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/3_universal.png"),
	"Green Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/4_universal.png"),
	"Orange Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/5_universal.png"),
	"Purple Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/6_universal.png"),
	"Red Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/7_universal.png"),
	"Yellow Shoes": preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/8_universal.png"),
}

# Female spritesheets
var female_body_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/5_universal.png"),
}

# Female hair spritesheets with colors
var female_hair_spritesheet = {
	## Style 1 with all colors
	#"1_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Black_universal.png"),
	#"1_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Blue_universal.png"),
	#"1_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Brown_universal.png"),
	#"1_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Green_universal.png"),
	#"1_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Orange_universal.png"),
	#"1_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Purple_universal.png"),
	#"1_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Red_universal.png"),
	#"1_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_Yellow_universal.png"),
	#
	## Style 2 with all colors
	#"2_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Black_universal.png"),
	#"2_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Blue_universal.png"),
	#"2_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Brown_universal.png"),
	#"2_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Green_universal.png"),
	#"2_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Orange_universal.png"),
	#"2_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Purple_universal.png"),
	#"2_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Red_universal.png"),
	#"2_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_Yellow_universal.png"),
	#
	## Style 3 with all colors
	#"3_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Black_universal.png"),
	#"3_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Blue_universal.png"),
	#"3_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Brown_universal.png"),
	#"3_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Green_universal.png"),
	#"3_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Orange_universal.png"),
	#"3_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Purple_universal.png"),
	#"3_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Red_universal.png"),
	#"3_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_Yellow_universal.png"),
	#
	## Style 4 with all colors
	#"4_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Black_universal.png"),
	#"4_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Blue_universal.png"),
	#"4_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Brown_universal.png"),
	#"4_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Green_universal.png"),
	#"4_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Orange_universal.png"),
	#"4_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Purple_universal.png"),
	#"4_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Red_universal.png"),
	#"4_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_Yellow_universal.png"),
	#
	## Style 5 with all colors
	#"5_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Black_universal.png"),
	#"5_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Blue_universal.png"),
	#"5_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Brown_universal.png"),
	#"5_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Green_universal.png"),
	#"5_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Orange_universal.png"),
	#"5_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Purple_universal.png"),
	#"5_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Red_universal.png"),
	#"5_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_Yellow_universal.png"),
	#
	## Style 6 with all colors
	#"6_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Black_universal.png"),
	#"6_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Blue_universal.png"),
	#"6_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Brown_universal.png"),
	#"6_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Green_universal.png"),
	#"6_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Orange_universal.png"),
	#"6_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Purple_universal.png"),
	#"6_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Red_universal.png"),
	#"6_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_Yellow_universal.png"),
	#
	## Style 7 with all colors
	#"7_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Black_universal.png"),
	#"7_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Blue_universal.png"),
	#"7_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Brown_universal.png"),
	#"7_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Green_universal.png"),
	#"7_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Orange_universal.png"),
	#"7_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Purple_universal.png"),
	#"7_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Red_universal.png"),
	#"7_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_Yellow_universal.png"),
	#
	## Style 8 with all colors
	#"8_Black": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Black_universal.png"),
	#"8_Blue": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Blue_universal.png"),
	#"8_Brown": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Brown_universal.png"),
	#"8_Green": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Green_universal.png"),
	#"8_Orange": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Orange_universal.png"),
	#"8_Purple": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Purple_universal.png"),
	#"8_Red": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Red_universal.png"),
	#"8_Yellow": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_Yellow_universal.png"),
}

var female_pants_spritesheet = {
	"none": null,
	"Black Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/1_universal.png"),
	"Blue Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/2_universal.png"),
	"Brown Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/3_universal.png"),
	"Green Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/4_universal.png"),
	"Orange Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/5_universal.png"),
	"Purple Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/6_universal.png"),
	"Red Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/7_universal.png"),
	"Yellow Pants": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/8_universal.png"),
}

var female_shirts_spritesheet = {
	"none": null,
	"Black Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/1_universal.png"),
	"Blue Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/2_universal.png"),
	"Brown Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/3_universal.png"),
	"Green Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/4_universal.png"),
	"Orange Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/5_universal.png"),
	"Purple Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/6_universal.png"),
	"Red Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/7_universal.png"),
	"Yellow Shirt": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/8_universal.png"),
}

var female_shoes_spritesheet = {
	"none": null,
	"Black Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/1_universal.png"),
	"Blue Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/2_universal.png"),
	"Brown Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/3_universal.png"),
	"Green Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/4_universal.png"),
	"Orange Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/5_universal.png"),
	"Purple Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/6_universal.png"),
	"Red Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/7_universal.png"),
	"Yellow Shoes": preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/8_universal.png"),
}

# Texture getters for each category
func get_tool_texture(tool_name: String):
	return tools_sprite.get(tool_name, null)

func get_weapon_texture(weapon_name: String):
	return weapons_sprite.get(weapon_name, null)

func get_range_weapon_texture(range_weapon_name: String):
	return range_weapons_sprite.get(range_weapon_name, null)

# NEW: Helper function to extract color from item name
func get_color_from_item(item_name: String) -> String:
	for color in color_codes:
		if item_name.find(color) != -1:
			return color
	return ""

# NEW: Helper function to get equipment type from item name
func get_equipment_type(item_name: String) -> String:
	if item_name.find("Shirt") != -1:
		return "shirt"
	elif item_name.find("Pants") != -1:
		return "pants"
	elif item_name.find("Shoes") != -1:
		return "shoes"
	elif item_name.find("Hair") != -1:
		return "hair"
	return ""

# Helper function to get the current spritesheet based on gender
func get_body_spritesheet(is_female: bool):
	return female_body_spritesheet if is_female else male_body_spritesheet

func get_hair_spritesheet(is_female: bool):
	return female_hair_spritesheet if is_female else male_hair_spritesheet

func get_pants_spritesheet(is_female: bool):
	return female_pants_spritesheet if is_female else male_pants_spritesheet

func get_shirts_spritesheet(is_female: bool):
	return female_shirts_spritesheet if is_female else male_shirts_spritesheet

func get_shoes_spritesheet(is_female: bool):
	return female_shoes_spritesheet if is_female else male_shoes_spritesheet

func get_accesory_spritesheet(is_female: bool):
	return accessory_sprite if is_female else accessory_sprite

# NEW: Get equipment texture by item name
func get_equipment_texture(item_name: String, is_female: bool):
	var equipment_type = get_equipment_type(item_name)
	var spritesheet
	
	match equipment_type:
		"shirt":
			spritesheet = get_shirts_spritesheet(is_female)
		"pants":
			spritesheet = get_pants_spritesheet(is_female)
		"shoes":
			spritesheet = get_shoes_spritesheet(is_female)
		"hair":
			spritesheet = get_hair_spritesheet(is_female)
		_:
			return null
	
	return spritesheet.get(item_name, null)

# NEW: Get body texture by index
func get_body_texture(body_index: int, is_female: bool):
	var spritesheet = get_body_spritesheet(is_female)
	return spritesheet.get(body_index, null)

# NEW: Get hair texture by style and color
func get_hair_texture(hair_style: int, color_name: String, is_female: bool):
	var spritesheet = get_hair_spritesheet(is_female)
	var key = str(hair_style) + "_" + color_name
	return spritesheet.get(key, null)

func get_item_texture(item_name: String):
	# Check if the item exists in JSON data
	if JsonData and JsonData.item_data.has(item_name):
		var texture_path = "res://Assets/Environment/Items/" + item_name + ".png"
		if FileAccess.file_exists(texture_path):
			var texture = load(texture_path)
			if texture:
				return texture
			else:
				print("Warning: Failed to load texture for item: ", item_name, " at path: ", texture_path)
				return get_default_texture()
		else:
			print("Warning: Item texture file not found: ", item_name, " at path: ", texture_path)
			return get_default_texture()
	else:
		print("Warning: Item not found in JSON data: ", item_name)
		return get_default_texture()

func get_default_texture():
	# You can create a default "missing" texture or use one of your existing ones
	var default_path = "res://Assets/Environment/Items/Missing.png"
	if FileAccess.file_exists(default_path):
		return load(default_path)
	else:
		# If no missing texture exists, create a simple colored rectangle as fallback
		var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 0, 1))  # Magenta color for missing textures
		var texture = ImageTexture.create_from_image(image)
		return texture
