extends Node

var items = {
	"Peeble": preload("res://Assets/Environment/Items/Peeble.png"),
	"Slingshot": preload("res://Assets/Environment/Items/Slingshot.png"),
	"Shovel": preload("res://Assets/Environment/Items/Shovel.png"),
	"Hoe": preload("res://Assets/Environment/Items/Hoe.png"),
	"Cross Bow": preload("res://Assets/Environment/Items/Cross Bow.png"),
	"Watering Can": preload("res://Assets/Environment/Items/Watering Can.png"),
}

# Tools/Equipment
var tools = {
	"none": null,
	
	"Hoe": preload("res://Assets/Characters/Player/MainHand/hoe_universal.png"),
	"Shovel": preload("res://Assets/Characters/Player/MainHand/shovel_universal.png"),
	"Watering Can": preload("res://Assets/Characters/Player/MainHand/watering_can_universal.png"),
}

var weapons = {
	"None": null,
	
}

var range_weapons = {
	"None": null,
	
	"Slingshot": preload("res://Assets/Characters/Player/MainHand/slingshot_universal.png")
}

# Male spritesheets
var male_body_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Body/5_universal.png")
}

var male_hair_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Hair/8_universal.png")
}

var male_pants_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Pants/8_universal.png")
}

var male_shirts_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shirts/8_universal.png")
}

var male_shoes_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteMale/Shoes/8_universal.png")
}

# Female spritesheets
var female_body_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Body/5_universal.png")
}

var female_hair_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Hair/8_universal.png")
}

var female_pants_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Pants/8_universal.png")
}

var female_shirts_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shirts/8_universal.png")
}

var female_shoes_spritesheet = {
	0 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/1_universal.png"),
	1 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/2_universal.png"),
	2 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/3_universal.png"),
	3 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/4_universal.png"),
	4 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/5_universal.png"),
	5 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/6_universal.png"),
	6 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/7_universal.png"),
	7 : preload("res://Assets/Characters/Player/CompositeSpriteFemale/Shoes/8_universal.png")
}

# Texture getters for each category
func get_tool_texture(tool_name: String):
	return tools.get(tool_name, null)

func get_weapon_texture(weapon_name: String):
	return weapons.get(weapon_name, null)

func get_range_weapon_texture(range_weapon_name: String):
	return range_weapons.get(range_weapon_name, null)

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

func get_item_texture(item_name: String):
	return items.get(item_name, null)
