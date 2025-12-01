# ItemResource.gd
extends Resource
class_name ItemResource

@export var item_id: String = ""  # Must match JSON key

@export_enum("Tool", "Range Weapon", "Weapon", "Resource", "Shirts", "Pants", "Shoes", "Accessory",) 
var item_category: String = "Resource"

@export var stack_size: int = 1
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary",) 
var rarity: String = "Common"

@export var value: int = 0

@export_enum("Dig", "Water", "Till", "Shoot", "Equip", "Consume", "Ammo",)
var use_effect: String = "Consume"

@export var item_texture: Texture2D = preload("res://Assets/Environment/Items/Missing.png")
@export var animation_texture: Texture2D

@export_enum("tool", "range_weapon", "shirt", "pants", "shoes", "accessory",) 
var equip_type: String = ""

@export var color: String = ""  # For colored items like shirts/pants

@export_enum("Arrow", "Peeble",) 
var ammo_type: String = ""

@export var ammo_for: String = ""  # For ammo items
@export var damage: int = 0
@export var defense: int = 0

# Crafting ingredients (for crafting system)
@export var crafting_ingredients: Dictionary = {}  # {"ItemID": quantity}
@export var crafting_time: float = 0.0  # Time to craft in seconds

@export_enum("Workbench", "Forge", "Kitchen", "Loom") 
var crafted_at: String = ""
