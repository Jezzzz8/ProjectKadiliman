extends Control

var item_name
var item_quantity

@onready var item_texture: TextureRect = $ItemTexture
@onready var quantity: Label = $ItemTexture/Quantity

func _ready():
	pass

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	
	# FIXED: Add error handling for missing textures
	var texture_path = "res://Assets/Environment/Items/" + item_name + ".png"
	if FileAccess.file_exists(texture_path):
		item_texture.texture = load(texture_path)
	else:
		# Fallback texture or warning
		print("Warning: Item texture not found: ", texture_path)
		# You can set a default missing texture here
		# item_texture.texture = preload("res://Assets/Environment/Items/Missing.png")
	
	# FIXED: Add error handling for JSON data
	if JsonData.item_data.has(item_name):
		var stack_size = int(JsonData.item_data[item_name]["StackSize"])
		if stack_size == 1:
			quantity.visible = false
		else:
			quantity.visible = true
			quantity.text = str(item_quantity)
	else:
		# Fallback for items not in JSON data
		print("Warning: Item not found in JSON data: ", item_name)
		quantity.visible = true
		quantity.text = str(item_quantity)

func force_visual_update():
	# Ensure the item texture and quantity are properly displayed
	if item_name and item_quantity:
		set_item(item_name, item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	quantity.text = str(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	quantity.text = str(item_quantity)
