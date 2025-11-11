extends Control

var item_name
var item_quantity

@onready var item_texture: TextureRect = $ItemTexture
@onready var quantity: Label = $Quantity

func _ready():
	pass

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	item_texture.texture = load("res://Assets/Environment/Items/" + item_name + ".png")
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		quantity.visible = false
	else:
		quantity.visible = true
		quantity.text = str(item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	quantity.text = str(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	quantity.text = str(item_quantity)
