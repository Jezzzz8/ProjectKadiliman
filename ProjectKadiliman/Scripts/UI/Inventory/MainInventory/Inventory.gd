extends Control

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")

@onready var inventory_slots: GridContainer = $TextureRect/GridContainer
@onready var integrated_hotbar: GridContainer = $TextureRect/IntegratedHotbar
@onready var equip_slots: = $TextureRect/EquipSlots.get_children()
@onready var selected_item_label: Label = $SelectedItemLabel

var selected_item_slot = null  # Track which slot is currently selected
var selected_item = null       # Track the selected item data

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
	
	# Clear selection when inventory is initialized
	clear_selection()

func clear_selection():
	if selected_item_slot:
		selected_item_slot.set_selected(false)
	selected_item_slot = null
	selected_item = null
	update_selected_item_label()  # Update label when clearing selection

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if selected_item_slot == null:
				# No item selected yet - select this slot if it has an item
				if slot.item:
					select_slot(slot)
			else:
				# Already have a selected item - try to move it to this slot
				if selected_item_slot != slot:
					move_selected_item_to_slot(slot)
				else:
					# Clicking the same slot - deselect it
					clear_selection()
				
func select_slot(slot: SlotClass):
	# Clear previous selection
	if selected_item_slot:
		selected_item_slot.set_selected(false)
	
	# Select new slot
	selected_item_slot = slot
	selected_item = {
		"item_name": slot.item.item_name,
		"item_quantity": slot.item.item_quantity,
		"slot_type": slot.slot_type,
		"slot_index": slot.slot_index
	}
	slot.set_selected(true)
	print("Selected item: ", selected_item.item_name, " from slot ", selected_item.slot_index)
	update_selected_item_label()  # Update label when selecting

func update_selected_item_label():
	if selected_item:
		# Show selected item name and quantity
		selected_item_label.text = "%s x%d" % [selected_item.item_name, selected_item.item_quantity]
	else:
		# No item selected
		selected_item_label.text = ""

func move_selected_item_to_slot(target_slot: SlotClass):
	if not can_move_to_slot(target_slot):
		print("Cannot move item to this slot")
		return
	
	var source_slot = selected_item_slot
	var source_item_data = selected_item
	
	# Clear selection first
	clear_selection()
	
	# Handle different cases based on target slot content
	if target_slot.item == null:
		# Moving to empty slot
		move_to_empty_slot(source_slot, target_slot, source_item_data)
	else:
		if source_item_data.item_name == target_slot.item.item_name:
			# Same item type - try to stack
			stack_items(source_slot, target_slot, source_item_data)
		else:
			# Different items - swap them
			swap_items(source_slot, target_slot, source_item_data)

func can_move_to_slot(slot: SlotClass) -> bool:
	if selected_item_slot == null:
		return false
	
	# Check equipment slot restrictions
	if slot.slot_type != SlotClass.SlotType.INVENTORY and slot.slot_type != SlotClass.SlotType.HOTBAR:
		var item_category = JsonData.item_data[selected_item.item_name]["ItemCategory"]
		match slot.slot_type:
			SlotClass.SlotType.HEAD:
				return item_category == "Head" or item_category == "Helmet" or item_category == "Hat"
			SlotClass.SlotType.BODY:
				return item_category == "Body" or item_category == "Chest" or item_category == "Shirt"
			SlotClass.SlotType.LEGS:
				return item_category == "Legs" or item_category == "Pants"
			SlotClass.SlotType.FOOT:
				return item_category == "Feet" or item_category == "Boots" or item_category == "Shoes"
	
	return true

func move_to_empty_slot(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	# Remove from source
	PlayerInventory.remove_item(source_slot)
	
	# Add to target
	PlayerInventory.add_item_to_empty_slot(source_slot.item, target_slot)
	
	# Move item visually
	var item = source_slot.item
	source_slot.pickFromSlot()
	target_slot.putIntoSlot(item)
	
	refresh_appropriate_displays(source_slot, target_slot)

func swap_items(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	var target_item = target_slot.item
	var target_item_data = {
		"item_name": target_item.item_name,
		"item_quantity": target_item.item_quantity
	}
	
	# Remove both items from inventory
	PlayerInventory.remove_item(source_slot)
	PlayerInventory.remove_item(target_slot)
	
	# Add items to new slots
	PlayerInventory.add_item_to_empty_slot(source_slot.item, target_slot)
	PlayerInventory.add_item_to_empty_slot(target_item, source_slot)
	
	# Swap items visually
	var source_item = source_slot.item
	source_slot.pickFromSlot()
	target_slot.pickFromSlot()
	
	target_slot.putIntoSlot(source_item)
	source_slot.putIntoSlot(target_item)
	
	refresh_appropriate_displays(source_slot, target_slot)

func stack_items(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	var stack_size = int(JsonData.item_data[source_item_data.item_name]["StackSize"])
	var able_to_add = stack_size - target_slot.item.item_quantity
	
	if able_to_add >= source_item_data.item_quantity:
		# Can stack all
		PlayerInventory.add_item_quantity(target_slot, source_item_data.item_quantity)
		target_slot.item.add_item_quantity(source_item_data.item_quantity)
		PlayerInventory.remove_item(source_slot)
		source_slot.pickFromSlot()
		source_slot.item.queue_free()
	else:
		# Can only stack partially
		PlayerInventory.add_item_quantity(target_slot, able_to_add)
		target_slot.item.add_item_quantity(able_to_add)
		PlayerInventory.add_item_quantity(source_slot, -able_to_add)
		source_slot.item.decrease_item_quantity(able_to_add)
	
	refresh_appropriate_displays(source_slot, target_slot)

func refresh_appropriate_displays(source_slot: SlotClass, target_slot: SlotClass):
	# Refresh displays based on which slots were involved
	if source_slot.slot_type == SlotClass.SlotType.HOTBAR or target_slot.slot_type == SlotClass.SlotType.HOTBAR:
		get_tree().call_group("hotbar", "refresh_hotbar")
	
	if source_slot.slot_type != SlotClass.SlotType.INVENTORY or target_slot.slot_type != SlotClass.SlotType.INVENTORY:
		initialize_equips()
