extends Control

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")

@onready var inventory_slots: GridContainer = $TextureRect/GridContainer
@onready var integrated_hotbar: GridContainer = $TextureRect/IntegratedHotbar
@onready var equip_slots: = $TextureRect/EquipSlots.get_children()

func _ready():
	add_to_group("inventory")
	
	# Setup inventory slots
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	
	# Setup integrated hotbar slots
	var hotbar_slots = integrated_hotbar.get_children()
	for i in range(hotbar_slots.size()):
		hotbar_slots[i].gui_input.connect(slot_gui_input.bind(hotbar_slots[i]))
		hotbar_slots[i].slot_index = i
		hotbar_slots[i].slot_type = SlotClass.SlotType.HOTBAR
	
	for i in range(equip_slots.size()):
		equip_slots[i].gui_input.connect(slot_gui_input.bind(equip_slots[i]))
		equip_slots[i].slot_index = i
	equip_slots[0].slot_type = SlotClass.SlotType.HEAD
	equip_slots[1].slot_type = SlotClass.SlotType.BODY
	equip_slots[2].slot_type = SlotClass.SlotType.LEGS
	equip_slots[3].slot_type = SlotClass.SlotType.FOOT
		
	initialize_inventory()
	initialize_equips()

func initialize_equips():
	for i in range(equip_slots.size()):
		if PlayerInventory.equips.has(i):
			equip_slots[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])
		else:
			if equip_slots[i].item:
				equip_slots[i].item.queue_free()
				equip_slots[i].item = null

func initialize_inventory():
	print("Initializing inventory UI with data: ", PlayerInventory.inventory)
	
	# Initialize inventory slots
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])
		else:
			if slots[i].item:
				slots[i].item.queue_free()
				slots[i].item = null
	
	# Initialize integrated hotbar slots
	var hotbar_slots = integrated_hotbar.get_children()
	for i in range(hotbar_slots.size()):
		if PlayerInventory.hotbar.has(i):
			hotbar_slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
		else:
			if hotbar_slots[i].item:
				hotbar_slots[i].item.queue_free()
				hotbar_slots[i].item = null

func return_held_item_to_original_slot():
	var holding_item = find_parent("UserInterface").holding_item
	if holding_item != null:
		print("Returning held item to original slot before closing inventory")
		var success = holding_item.return_to_original_slot()
		if success:
			find_parent("UserInterface").holding_item = null
			initialize_inventory()
			initialize_equips()
			get_tree().call_group("hotbar", "refresh_hotbar")
		return success
	return true

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("UserInterface").holding_item != null:
				# FIX: Check if we can put the item in this slot first
				if able_to_put_into_slot(slot):
					if !slot.item:
						left_click_empty_slot(slot)
					else:
						if find_parent("UserInterface").holding_item.item_name != slot.item.item_name:
							left_click_different_item(event, slot)
						else:
							left_click_same_item(slot)
				else:
					print("Cannot put this item in equipment slot: ", slot.slot_type)
			elif slot.item:
				left_click_not_holding(slot)
				
func _input(event):
	if find_parent("UserInterface").holding_item:
		find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()
		
func able_to_put_into_slot(slot: SlotClass):
	var holding_item = find_parent("UserInterface").holding_item
	if holding_item == null:
		return true
	
	# FIX: Add equipment slot validation
	var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
	
	# Check if this is an equipment slot and if the item category matches
	match slot.slot_type:
		SlotClass.SlotType.HEAD:
			return holding_item_category == "Head" or holding_item_category == "Helmet" or holding_item_category == "Hat"
		SlotClass.SlotType.BODY:
			return holding_item_category == "Body" or holding_item_category == "Chest" or holding_item_category == "Shirt"
		SlotClass.SlotType.LEGS:
			return holding_item_category == "Legs" or holding_item_category == "Pants"
		SlotClass.SlotType.FOOT:
			return holding_item_category == "Feet" or holding_item_category == "Boots" or holding_item_category == "Shoes"
		_:  # Inventory and Hotbar slots accept all items
			return true
		
func left_click_empty_slot(slot: SlotClass):
	if able_to_put_into_slot(slot):
		PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
		slot.putIntoSlot(find_parent("UserInterface").holding_item)
		find_parent("UserInterface").holding_item.clear_original_slot()
		find_parent("UserInterface").holding_item = null
		
		# Refresh appropriate displays based on slot type
		if slot.slot_type == SlotClass.SlotType.HOTBAR:
			get_tree().call_group("hotbar", "refresh_hotbar")
		elif slot.slot_type != SlotClass.SlotType.INVENTORY:  # Equipment slot
			initialize_equips()
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	if able_to_put_into_slot(slot):
		# Store both items and their original slots
		var held_item = find_parent("UserInterface").holding_item
		var slot_item = slot.item
		var held_original_slot = held_item.original_slot
		var held_original_slot_type = held_item.original_slot_type
		var held_original_slot_index = held_item.original_slot_index
		
		PlayerInventory.remove_item(slot)
		if held_original_slot_type == SlotClass.SlotType.HOTBAR:
			PlayerInventory.hotbar.erase(held_original_slot_index)
		elif held_original_slot_type == SlotClass.SlotType.INVENTORY:
			PlayerInventory.inventory.erase(held_original_slot_index)
		else:
			PlayerInventory.equips.erase(held_original_slot_index)
		
		PlayerInventory.add_item_to_empty_slot(held_item, slot)
		if held_original_slot != null:
			if held_original_slot_type == SlotClass.SlotType.HOTBAR:
				PlayerInventory.hotbar[held_original_slot_index] = [slot_item.item_name, slot_item.item_quantity]
			elif held_original_slot_type == SlotClass.SlotType.INVENTORY:
				PlayerInventory.inventory[held_original_slot_index] = [slot_item.item_name, slot_item.item_quantity]
			else:
				PlayerInventory.equips[held_original_slot_index] = [slot_item.item_name, slot_item.item_quantity]
		
		# Swap the items visually
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = event.global_position
		slot.putIntoSlot(held_item)
		
		# Update original slots for both items after swap
		held_item.clear_original_slot()
		temp_item.set_original_slot(held_original_slot, held_original_slot_type, held_original_slot_index)
		
		find_parent("UserInterface").holding_item = temp_item
		
		# Refresh appropriate displays based on slot type
		if slot.slot_type == SlotClass.SlotType.HOTBAR:
			get_tree().call_group("hotbar", "refresh_hotbar")
		elif slot.slot_type != SlotClass.SlotType.INVENTORY:
			initialize_equips()

func left_click_same_item(slot: SlotClass):
	if able_to_put_into_slot(slot):
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_quantity
		if able_to_add >= find_parent("UserInterface").holding_item.item_quantity:
			PlayerInventory.add_item_quantity(slot, find_parent("UserInterface").holding_item.item_quantity)
			slot.item.add_item_quantity(find_parent("UserInterface").holding_item.item_quantity)
			find_parent("UserInterface").holding_item.clear_original_slot()
			find_parent("UserInterface").holding_item.queue_free()
			find_parent("UserInterface").holding_item = null
		else:
			PlayerInventory.add_item_quantity(slot, able_to_add)
			slot.item.add_item_quantity(able_to_add)
			find_parent("UserInterface").holding_item.decrease_item_quantity(able_to_add)
			initialize_inventory()
		
func left_click_not_holding(slot: SlotClass):
	print("Attempting to pick up item from slot: ", slot.slot_index, " type: ", slot.slot_type)
	
	PlayerInventory.remove_item(slot)
	find_parent("UserInterface").holding_item = slot.item
	
	print("Item picked up: ", slot.item.item_name if slot.item else "null")
	
	slot.pickFromSlot()
	find_parent("UserInterface").holding_item.set_original_slot(slot, slot.slot_type, slot.slot_index)
	find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()
	
	# Refresh appropriate displays based on slot type
	if slot.slot_type == SlotClass.SlotType.HOTBAR:
		get_tree().call_group("hotbar", "refresh_hotbar")
	elif slot.slot_type != SlotClass.SlotType.INVENTORY:
		initialize_equips()
