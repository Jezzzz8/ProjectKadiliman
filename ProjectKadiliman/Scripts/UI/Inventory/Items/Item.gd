# Item.gd (updated for Resource-based)
extends Control

var item_name
var item_quantity
var item_resource: ItemResource

@onready var item_texture: TextureRect = $ItemTexture
@onready var quantity: Label = $ItemTexture/Quantity

func _ready():
	pass

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	
	# Get the item resource
	var resource = PlayerInventory.get_item_resource(item_name)
	
	if resource:
		item_resource = resource
		# Use texture from resource if available
		if resource.item_texture:
			item_texture.texture = resource.item_texture
		else:
			# Fallback to file-based texture
			var texture_path = "res://Assets/Environment/Items/" + item_name + ".png"
			if FileAccess.file_exists(texture_path):
				item_texture.texture = load(texture_path)
			else:
				print("Warning: Item texture not found: ", texture_path)
		
		# Set quantity visibility based on stack size
		if resource.stack_size == 1:
			quantity.visible = false
		else:
			quantity.visible = true
			quantity.text = str(item_quantity)
	else:
		print("Warning: Item resource not found: ", item_name)
		# Fallback behavior
		var texture_path = "res://Assets/Environment/Items/" + item_name + ".png"
		if FileAccess.file_exists(texture_path):
			item_texture.texture = load(texture_path)
		quantity.visible = true
		quantity.text = str(item_quantity)

func force_visual_update():
	if item_name and item_quantity:
		set_item(item_name, item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	quantity.text = str(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	quantity.text = str(item_quantity)

# Get item resource for this item
func get_resource() -> ItemResource:
	return item_resource
