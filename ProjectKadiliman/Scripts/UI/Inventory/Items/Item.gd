extends Control

var item_name
var item_quantity
var original_slot = null
var original_slot_type = null
var original_slot_index = null

@onready var item_texture: TextureRect = $ItemTexture
@onready var quantity: Label = $Quantity

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")

func _ready():
	var rand_val = randi() % 5
	if rand_val == 0:
		item_name = "Hoe"
	elif rand_val == 1:
		item_name = "Shovel"
	elif rand_val == 2:
		item_name = "Cross Bow"
	elif rand_val == 3:
		item_name = "Peeble"
	elif rand_val == 4:
		item_name = "Watering Can"
	elif rand_val == 5:
		item_name = "Slingshot"
	
	item_texture.texture = load("res://Assets/Environment/Items/" + item_name + ".png")
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	item_quantity = randi() % stack_size + 1
	
	if stack_size == 1:
		quantity.visible = false
	else:
		quantity.text = str(item_quantity)

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

# NEW: Set the original slot information when picked up
func set_original_slot(slot: SlotClass, slot_type: int, slot_index: int):
	original_slot = slot
	original_slot_type = slot_type
	original_slot_index = slot_index

# NEW: Clear original slot when placed in a new slot
func clear_original_slot():
	original_slot = null
	original_slot_type = null
	original_slot_index = null
	
func return_to_original_slot():
	if original_slot != null and is_instance_valid(original_slot):
		# Check if the original slot already has an item
		if original_slot.item != null and original_slot.item != self:
			# The original slot has a different item - this means we swapped
			# In this case, we need to find an empty slot or handle it differently
			print("Original slot is occupied by another item, finding alternative...")
			# For now, let's just put it back in any empty slot
			var slots = get_tree().get_nodes_in_group("Slots")
			for slot in slots:
				if slot.item == null and slot.slot_type == original_slot_type:
					# Found an empty slot of the same type
					return_to_slot(slot)
					return true
			# No empty slot found, destroy the item
			print("No empty slot found for returned item, destroying")
			queue_free()
			return false
		else:
			# Original slot is empty or has this item, return normally
			return return_to_slot(original_slot)
	else:
		# No original slot or original slot is invalid
		print("No valid original slot found, destroying held item")
		queue_free()
		return false

func return_to_slot(slot: SlotClass):
	# Safely remove from current parent if it exists
	var current_parent = get_parent()
	if current_parent != null:
		current_parent.remove_child(self)
	
	# Add to the target slot
	slot.add_child(self)
	slot.item = self
	position = Vector2.ZERO
	
	# UPDATED: Update the inventory data for all slot types
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			PlayerInventory.hotbar[slot.slot_index] = [item_name, item_quantity]
		SlotClass.SlotType.INVENTORY:
			PlayerInventory.inventory[slot.slot_index] = [item_name, item_quantity]
		_:  # Equipment slots
			PlayerInventory.equips[slot.slot_index] = [item_name, item_quantity]
	
	slot.refresh_style()
	clear_original_slot()
	print("Item returned to slot: ", slot.slot_index, " type: ", slot.slot_type)
	return true
