extends Control

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
const ItemClass = preload("res://Scripts/UI/Inventory/Items/Item.gd")
const ItemDropClass = preload("res://Scenes/World/Environment/Item/Drop/ItemDrop.tscn")

@onready var inventory_slots: GridContainer = $TextureRect/GridContainer
@onready var integrated_hotbar: GridContainer = $TextureRect/IntegratedHotbar
@onready var equip_slots: = $TextureRect/EquipSlots.get_children()
@onready var selected_item_name: Label = $TextureRect/SelectedItemName
@onready var selected_item_description: Label = $TextureRect/SelectedItemDescription
@onready var selected_item_stats: Label = $TextureRect/SelectedItemStats
@onready var trash_slot_container: PanelContainer = $TextureRect/TrashSlotContainer
@onready var trash_slot: Panel = $TextureRect/TrashSlotContainer/TrashSlot

var selected_item_slot = null
var selected_item = null

func _ready():
	add_to_group("inventory")
	
	setup_font_styles()
	
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
	equip_slots[2].slot_type = SlotClass.SlotType.ACCESSORY
	equip_slots[3].slot_type = SlotClass.SlotType.LEGS
	equip_slots[4].slot_type = SlotClass.SlotType.ACCESSORY
	equip_slots[5].slot_type = SlotClass.SlotType.FOOT
	
	# Setup trash slot directly
	if trash_slot:
		print("Trash slot found and initializing: ", trash_slot)
		trash_slot.gui_input.connect(slot_gui_input.bind(trash_slot))
		trash_slot.slot_index = -1  # Use -1 for trash slot
		trash_slot.slot_type = SlotClass.SlotType.TRASH
		
		# Apply trash-specific styling
		setup_trash_slot_appearance()
	else:
		print("ERROR: Trash slot node not found!")
	
	initialize_inventory()
	initialize_equips()

# NEW: Setup trash slot appearance
func setup_trash_slot_appearance():
	if trash_slot:
		# Apply visual distinction for trash slot
		trash_slot.modulate = Color(1, 0.8, 0.8)  # Light red tint
		
		# Optional: Set a custom style for the trash slot
		var trash_style = StyleBoxTexture.new()
		var trash_texture = preload("res://Assets/Environment/UI/Icons/trash.png")
		if trash_texture:
			trash_style.texture = trash_texture
			trash_slot.set('theme_override_styles/panel', trash_style)

# NEW: Setup font styles for different text elements
func setup_font_styles():
	# Item Name - Bold font for emphasis
	if CompositeSprites.font_style.has("Bold"):
		var bold_font = CompositeSprites.font_style["Bold"]
		selected_item_name.label_settings = LabelSettings.new()
		selected_item_name.label_settings.font = bold_font
		selected_item_name.label_settings.font_size = 16
		selected_item_name.label_settings.font_color = Color.BLACK
	
	# Item Description - Regular font for readability
	if CompositeSprites.font_style.has("Regular"):
		var regular_font = CompositeSprites.font_style["Regular"]
		selected_item_description.label_settings = LabelSettings.new()
		selected_item_description.label_settings.font = regular_font
		selected_item_description.label_settings.font_size = 8
		selected_item_description.label_settings.font_color = Color.BLACK
	
	# Item Stats - Use Bold font for the entire stats section
	if CompositeSprites.font_style.has("Bold"):
		var bold_font = CompositeSprites.font_style["Bold"]
		selected_item_stats.label_settings = LabelSettings.new()
		selected_item_stats.label_settings.font = bold_font
		selected_item_stats.label_settings.font_size = 8
		selected_item_stats.label_settings.font_color = Color.BLACK

func initialize_equips():
	for i in range(equip_slots.size()):
		if PlayerInventory.equips.has(i):
			equip_slots[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])
		else:
			if equip_slots[i].item:
				equip_slots[i].item.queue_free()
				equip_slots[i].item = null
	
	# NEW: Sync equipment to player after initializing
	PlayerInventory.sync_equipment_to_player()

func initialize_inventory():
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
	
	# Initialize trash slot - use fixed index 0 for trash storage
	if trash_slot:
		if PlayerInventory.trash.has(0):  # Trash always uses index 0
			var trash_item = PlayerInventory.trash[0]
			trash_slot.initialize_item(trash_item[0], trash_item[1])
		else:
			if trash_slot.item:
				trash_slot.item.queue_free()
				trash_slot.item = null
	
	# Clear selection when inventory is initialized
	clear_selection()

func clear_selection():
	if selected_item_slot:
		selected_item_slot.set_selected(false)
	selected_item_slot = null
	selected_item = null
	update_selected_item_display()

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if selected_item_slot == null:
				if slot.item:
					select_slot(slot)
				else:
					# Allow selecting empty trash slot
					if slot.slot_type == SlotClass.SlotType.TRASH:
						select_slot(slot)
			else:
				if selected_item_slot != slot:
					# FIXED: Allow moving items to trash even if can_swap_items returns false
					if slot.slot_type == SlotClass.SlotType.TRASH or selected_item_slot.slot_type == SlotClass.SlotType.TRASH:
						move_selected_item_to_slot(slot)
					elif can_swap_items(selected_item_slot, slot):
						move_selected_item_to_slot(slot)
					else:
						selected_item_description.text = "Cannot swap items between these slots"
						clear_selection()
				else:
					clear_selection()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			handle_right_click(slot)

func handle_right_click(clicked_slot: SlotClass):
	if selected_item_slot == null:
		return
	
	if selected_item_slot == clicked_slot:
		return
	
	if (selected_item_slot.slot_type != SlotClass.SlotType.INVENTORY and selected_item_slot.slot_type != SlotClass.SlotType.HOTBAR) or (clicked_slot.slot_type != SlotClass.SlotType.INVENTORY and clicked_slot.slot_type != SlotClass.SlotType.HOTBAR):
		selected_item_description.text = "Quantity transfer only allowed between inventory/hotbar slots"
		return
	
	if clicked_slot.item != null:
		if selected_item.item_name != clicked_slot.item.item_name:
			selected_item_description.text = "Items are not the same type"
			return
		
		var stack_size = int(JsonData.item_data[selected_item.item_name]["StackSize"])
		if clicked_slot.item.item_quantity >= stack_size:
			selected_item_description.text = "Target stack is already full"
			return
	
	if selected_item_slot.item.item_quantity <= 1:
		selected_item_description.text = "Source stack has only 1 item, cannot transfer"
		return
	
	transfer_single_quantity(selected_item_slot, clicked_slot)

func transfer_single_quantity(source_slot: SlotClass, target_slot: SlotClass):
	var source_item = source_slot.item
	
	if target_slot.item == null:
		target_slot.initialize_item(source_item.item_name, 1)
		PlayerInventory.add_item_to_empty_slot(target_slot.item, target_slot)
		PlayerInventory.add_item_quantity(source_slot, -1)
		source_item.decrease_item_quantity(1)
	else:
		var target_item = target_slot.item
		PlayerInventory.add_item_quantity(source_slot, -1)
		PlayerInventory.add_item_quantity(target_slot, 1)
		source_item.decrease_item_quantity(1)
		target_item.add_item_quantity(1)
	
	if source_item.item_quantity <= 0:
		PlayerInventory.remove_item(source_slot)
		source_slot.pickFromSlot()
		if source_slot.item:
			source_slot.item.queue_free()
			source_slot.item = null
		clear_selection()
	else:
		selected_item.item_quantity = source_item.item_quantity
		update_selected_item_display()
	
	refresh_appropriate_displays(source_slot, target_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")

func can_swap_items(source_slot: SlotClass, target_slot: SlotClass) -> bool:
	if selected_item_slot == null:
		return false
	
	# Safety check for empty item names
	if selected_item.item_name == "":
		return false
	
	if source_slot.slot_type == SlotClass.SlotType.TRASH or target_slot.slot_type == SlotClass.SlotType.TRASH:
		selected_item_description.text = "Cannot swap items with trash slot - use move instead"
		return false
	
	var source_item_name = selected_item.item_name
	var source_item_category = JsonData.item_data[source_item_name]["ItemCategory"]
	
	var target_item_name = target_slot.item.item_name if target_slot.item else ""
	var target_item_category = JsonData.item_data[target_item_name]["ItemCategory"] if target_slot.item else ""
	
	selected_item_stats.text = "Swap: %s (%s) -> %s (%s)" % [
		source_item_name, source_slot.slot_type,
		target_item_name, target_slot.slot_type
	]
	
	if target_slot.item == null:
		return can_move_to_slot(source_slot, target_slot, source_item_name, source_item_category)
	
	var can_source_move_to_target = can_move_to_slot(source_slot, target_slot, source_item_name, source_item_category)
	var can_target_move_to_source = can_move_to_slot(target_slot, source_slot, target_item_name, target_item_category)
	
	selected_item_description.text = "Swap validation: %s -> %s" % [
		"Allowed" if can_source_move_to_target else "Blocked",
		"Allowed" if can_target_move_to_source else "Blocked"
	]
	
	return can_source_move_to_target and can_target_move_to_source

func can_move_to_slot(from_slot: SlotClass, to_slot: SlotClass, item_name: String, item_category: String) -> bool:
	# Safety check for empty item names
	if item_name == "":
		return false
	
	selected_item_stats.text = "Move: %s (%s) -> %s" % [item_name, from_slot.slot_type, to_slot.slot_type]

	
	# Handle trash slot specifically
	if from_slot.slot_type == SlotClass.SlotType.TRASH:
		# Can retrieve from trash to inventory, hotbar, or appropriate equipment slots
		if to_slot.slot_type == SlotClass.SlotType.INVENTORY or to_slot.slot_type == SlotClass.SlotType.HOTBAR:
			return true
		elif to_slot.slot_type != SlotClass.SlotType.INVENTORY and to_slot.slot_type != SlotClass.SlotType.HOTBAR:
			# Check if item can be equipped to this slot type
			var can_equip = false
			match to_slot.slot_type:
				SlotClass.SlotType.HEAD:
					can_equip = item_category == "Head" or item_category == "Hat"
				SlotClass.SlotType.BODY:
					can_equip = item_category == "Body" or item_category == "Shirts" or item_category == "Chest"
				SlotClass.SlotType.LEGS:
					can_equip = item_category == "Legs" or item_category == "Pants"
				SlotClass.SlotType.FOOT:
					can_equip = item_category == "Feet" or item_category == "Boots" or item_category == "Shoes"
				SlotClass.SlotType.ACCESSORY:
					can_equip = item_category == "Accessory"
				_:
					can_equip = false
			
			if not can_equip:
				selected_item_description.text = "Item %s (%s) cannot be equipped to %s" % [item_name, item_category, to_slot.slot_type]
			
			return can_equip
	
	if to_slot.slot_type == SlotClass.SlotType.TRASH:
		# Can only dispose from inventory or hotbar to trash
		var allowed = from_slot.slot_type == SlotClass.SlotType.INVENTORY or from_slot.slot_type == SlotClass.SlotType.HOTBAR
		if not allowed:
			selected_item_description.text = "Can only dispose from inventory/hotbar"
		return allowed
	
	if from_slot.slot_type != SlotClass.SlotType.INVENTORY and from_slot.slot_type != SlotClass.SlotType.HOTBAR:
		if to_slot.slot_type == SlotClass.SlotType.INVENTORY or to_slot.slot_type == SlotClass.SlotType.HOTBAR:
			return true
		else:
			selected_item_description.text = "Cannot move equipment from %s to %s" % [from_slot.slot_type, to_slot.slot_type]
			return false
	
	if to_slot.slot_type != SlotClass.SlotType.INVENTORY and to_slot.slot_type != SlotClass.SlotType.HOTBAR:
		var can_equip = false
		match to_slot.slot_type:
			SlotClass.SlotType.HEAD:
				can_equip = item_category == "Head" or item_category == "Hat"
			SlotClass.SlotType.BODY:
				can_equip = item_category == "Body" or item_category == "Shirts" or item_category == "Chest"
			SlotClass.SlotType.LEGS:
				can_equip = item_category == "Legs" or item_category == "Pants"
			SlotClass.SlotType.FOOT:
				can_equip = item_category == "Feet" or item_category == "Boots" or item_category == "Shoes"
			SlotClass.SlotType.ACCESSORY:
				can_equip = item_category == "Accessory"
			_:
				can_equip = false
		
		if not can_equip:
			selected_item_description.text = "Item %s (%s) cannot be equipped to %s" % [item_name, item_category, to_slot.slot_type]
		
		return can_equip
	
	selected_item_description.text = "Move allowed: Inventory/Hotbar transfer"
	return true

func select_slot(slot: SlotClass):
	if selected_item_slot:
		selected_item_slot.set_selected(false)
	
	selected_item_slot = slot
	
	# Handle empty slots (like empty trash slot)
	if slot.item:
		selected_item = {
			"item_name": slot.item.item_name,
			"item_quantity": slot.item.item_quantity,
			"slot_type": slot.slot_type,
			"slot_index": slot.slot_index
		}
		slot.set_selected(true)
		update_selected_item_display()
	else:
		# Allow selecting empty trash slot
		if slot.slot_type == SlotClass.SlotType.TRASH:
			selected_item = {
				"item_name": "",
				"item_quantity": 0,
				"slot_type": slot.slot_type,
				"slot_index": slot.slot_index
			}
			slot.set_selected(true)
			update_selected_item_display()
		else:
			# Don't select empty non-trash slots
			selected_item_slot = null

func update_selected_item_display():
	if selected_item:
		var item_name = selected_item.item_name
		var item_quantity = selected_item.item_quantity
		
		# Check if item_name is valid before accessing JSON data
		if item_name != "" and JsonData.item_data.has(item_name):
			var item_data = JsonData.item_data[item_name]
			
			if item_quantity > 1:
				selected_item_name.text = "%s x%d" % [item_name, item_quantity]
			else:
				selected_item_name.text = item_name
			
			update_item_description(item_data)
			update_item_stats(item_data, item_quantity)
		else:
			# Handle empty or invalid items (like empty trash slot)
			if item_name == "":
				selected_item_name.text = "Empty Trash Slot"
			else:
				selected_item_name.text = "Unknown Item: " + item_name
			selected_item_description.text = "No item information available"
			selected_item_stats.text = ""
	else:
		selected_item_name.text = "No Item"
		selected_item_description.text = "Select an item to inspect its details"
		selected_item_stats.text = ""

func update_item_description(item_data: Dictionary):
	var description_parts = []
	if item_data.has("Description"):
		description_parts.append(item_data["Description"])
	selected_item_description.text = "\n".join(description_parts)

func update_item_stats(item_data: Dictionary, quantity: int):
	var stats_parts = []
	if item_data.has("ItemCategory"):
		stats_parts.append("Category: " + item_data["ItemCategory"])
	if item_data.has("Damage"):
		stats_parts.append("Damage: %d" % item_data["Damage"])
	if item_data.has("Defense"):
		stats_parts.append("Defense: %d" % item_data["Defense"])
	selected_item_stats.text = "\n".join(stats_parts)

func move_selected_item_to_slot(target_slot: SlotClass):
	var source_slot = selected_item_slot
	var source_item_data = selected_item
	
	print("Moving item - Source: ", source_slot.slot_type, " -> Target: ", target_slot.slot_type)
	
	# Handle trash operations directly without validation
	if target_slot.slot_type == SlotClass.SlotType.TRASH:
		selected_item_description.text = "Moving item to trash..."
		handle_trash_disposal(source_slot, target_slot, source_item_data)
		# NEW: Sync equipment after trash disposal
		PlayerInventory.sync_equipment_to_player()
		return
	
	if source_slot.slot_type == SlotClass.SlotType.TRASH:
		selected_item_description.text = "Retrieving item from trash..."
		handle_trash_retrieval(source_slot, target_slot, source_item_data)
		# NEW: Sync equipment after trash retrieval
		PlayerInventory.sync_equipment_to_player()
		return
	
	clear_selection()
	
	# For non-trash operations, use the existing logic
	if target_slot.item == null:
		selected_item_description.text = "Moving to empty slot..."
		move_to_empty_slot(source_slot, target_slot, source_item_data)
	else:
		if source_item_data.item_name == target_slot.item.item_name:
			selected_item_description.text = "Stacking items..."
			stack_items(source_slot, target_slot, source_item_data)
		else:
			selected_item_description.text = "Swapping items..."
			swap_items(source_slot, target_slot, source_item_data)
	
	# NEW: Sync equipment changes to player
	PlayerInventory.sync_equipment_to_player()

# FIXED: Improved trash retrieval to handle swaps properly
func handle_trash_retrieval(trash_slot: SlotClass, target_slot: SlotClass, source_item_data):
	print("=== TRASH RETRIEVAL START ===")
	print("Retrieving from trash: ", source_item_data.item_name, " to target: ", target_slot.slot_type)
	
	# Check if we can move the item to the target slot
	var item_name = source_item_data.item_name
	var item_category = JsonData.item_data[item_name]["ItemCategory"] if JsonData.item_data.has(item_name) else ""
	
	if not can_move_to_slot(trash_slot, target_slot, item_name, item_category):
		selected_item_description.text = "Cannot move trash item to this slot type"
		clear_selection()
		return
	
	var trash_item = trash_slot.item
	
	# Check if target slot has an item (swap scenario)
	if target_slot.item:
		print("Swap scenario: Trash item -> Target slot with item")
		var target_item = target_slot.item
		
		# Remove both items from their current slots
		trash_slot.pickFromSlot()
		target_slot.pickFromSlot()
		
		# Put items into new slots
		target_slot.putIntoSlot(trash_item)
		trash_slot.putIntoSlot(target_item)
		
		# Update inventory data for swap
		PlayerInventory.remove_trash_item(trash_slot)
		PlayerInventory.add_item_to_empty_slot(trash_item, target_slot)
		PlayerInventory.add_item_to_empty_slot(target_item, trash_slot)
		
		print("Swapped trash item with target slot item")
	else:
		print("Move scenario: Trash item -> Empty target slot")
		# Simple move to empty slot
		trash_slot.pickFromSlot()
		target_slot.putIntoSlot(trash_item)
		
		PlayerInventory.remove_trash_item(trash_slot)
		PlayerInventory.add_item_to_empty_slot(trash_item, target_slot)
	
	clear_selection()
	trash_slot.force_visual_update()
	target_slot.force_visual_update()
	refresh_appropriate_displays(trash_slot, target_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")
	
	selected_item_description.text = "Item retrieved from trash: " + source_item_data.item_name
	print("=== TRASH RETRIEVAL COMPLETE ===")

func handle_trash_disposal(source_slot: SlotClass, trash_slot: SlotClass, source_item_data):
	print("=== TRASH DISPOSAL START ===")
	
	# Store the source item before any operations
	var source_item = source_slot.item
	
	# If trash slot already has an item, DELETE it completely
	if trash_slot.item:
		print("Trash slot has existing item, DELETING it")
		delete_trash_item(trash_slot)
	
	print("Moving item from source to trash: ", source_item.item_name)
	
	# Remove the item from source slot (but don't destroy it)
	source_slot.pickFromSlot()
	
	# Put the source item into trash slot
	trash_slot.putIntoSlot(source_item)
	
	print("Updating inventory data...")
	# Remove from source inventory and add to trash
	PlayerInventory.remove_item(source_slot)
	PlayerInventory.add_item_to_empty_slot(source_item, trash_slot)
	
	clear_selection()
	source_slot.force_visual_update()
	trash_slot.force_visual_update()
	refresh_appropriate_displays(source_slot, trash_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")
	
	selected_item_description.text = "Item moved to trash: " + source_item_data.item_name
	print("=== TRASH DISPOSAL COMPLETE ===")

func drop_trash_item(trash_slot: SlotClass):
	if trash_slot.item:
		var item_name = trash_slot.item.item_name
		var quantity = trash_slot.item.item_quantity
		print("DELETING trash item: ", item_name, " x", quantity)
		selected_item_description.text = "DELETING trash item: %s x%d" % [item_name, quantity]
		
		# Remove from trash inventory
		PlayerInventory.remove_trash_item(trash_slot)
		
		# Remove from the slot visually
		trash_slot.pickFromSlot()
		if trash_slot.item:
			trash_slot.item.queue_free()
			trash_slot.item = null
		
		# NO LONGER spawn the item drop - item is completely deleted
		print("Item permanently deleted: ", item_name)
		
		# Force refresh the display
		refresh_appropriate_displays(trash_slot, trash_slot)
	else:
		print("No item in trash slot to delete")

func delete_trash_item(trash_slot: SlotClass):
	if trash_slot.item:
		var item_name = trash_slot.item.item_name
		var quantity = trash_slot.item.item_quantity
		print("PERMANENTLY DELETING item: ", item_name, " x", quantity)
		selected_item_description.text = "PERMANENTLY DELETING item: %s x%d" % [item_name, quantity]
		
		# Remove from trash inventory
		PlayerInventory.remove_trash_item(trash_slot)
		
		# Remove from the slot visually
		trash_slot.pickFromSlot()
		if trash_slot.item:
			trash_slot.item.queue_free()
			trash_slot.item = null
		
		print("Item permanently deleted from game: ", item_name)
		
		# Force refresh the display
		refresh_appropriate_displays(trash_slot, trash_slot)
	else:
		print("No item in trash slot to delete")

func move_to_empty_slot(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	print("Moving to empty slot - Source: ", source_slot.slot_type, ", Target: ", target_slot.slot_type)
	
	# Store the item reference BEFORE removing it from source
	var item = source_slot.item
	
	# Handle trash slot as source
	if source_slot.slot_type == SlotClass.SlotType.TRASH:
		PlayerInventory.remove_trash_item(source_slot)
	else:
		PlayerInventory.remove_item(source_slot)
	
	# Remove from source slot visually (but don't destroy the item)
	source_slot.pickFromSlot()
	
	# Add to target slot in inventory data
	PlayerInventory.add_item_to_empty_slot(item, target_slot)
	
	# Put the SAME item into target slot (don't recreate it)
	target_slot.putIntoSlot(item)
	
	# Force visual updates
	source_slot.force_visual_update()
	target_slot.force_visual_update()
	refresh_appropriate_displays(source_slot, target_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")

func swap_items(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	var target_item = target_slot.item
	var source_item = source_slot.item
	
	# Store item references
	print("Swapping items: ", source_item.item_name, " with ", target_item.item_name)
	
	# Update inventory data first
	PlayerInventory.remove_item(source_slot)
	PlayerInventory.remove_item(target_slot)
	PlayerInventory.add_item_to_empty_slot(source_item, target_slot)
	PlayerInventory.add_item_to_empty_slot(target_item, source_slot)
	
	# Remove items from slots visually
	source_slot.pickFromSlot()
	target_slot.pickFromSlot()
	
	# Put items into new slots
	target_slot.putIntoSlot(source_item)
	source_slot.putIntoSlot(target_item)
	
	# Force visual updates
	source_slot.force_visual_update()
	target_slot.force_visual_update()
	refresh_appropriate_displays(source_slot, target_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")

func stack_items(source_slot: SlotClass, target_slot: SlotClass, source_item_data):
	var stack_size = int(JsonData.item_data[source_item_data.item_name]["StackSize"])
	var able_to_add = stack_size - target_slot.item.item_quantity
	
	if able_to_add >= source_item_data.item_quantity:
		PlayerInventory.add_item_quantity(target_slot, source_item_data.item_quantity)
		target_slot.item.add_item_quantity(source_item_data.item_quantity)
		PlayerInventory.remove_item(source_slot)
		
		var item_to_remove = source_slot.item
		source_slot.pickFromSlot()
		if item_to_remove:
			item_to_remove.queue_free()
	else:
		PlayerInventory.add_item_quantity(target_slot, able_to_add)
		target_slot.item.add_item_quantity(able_to_add)
		PlayerInventory.add_item_quantity(source_slot, -able_to_add)
		source_slot.item.decrease_item_quantity(able_to_add)
	
	refresh_appropriate_displays(source_slot, target_slot)
	get_tree().call_group("hotbar", "refresh_hotbar")

func refresh_appropriate_displays(source_slot: SlotClass, target_slot: SlotClass):
	if source_slot.slot_type == SlotClass.SlotType.HOTBAR or target_slot.slot_type == SlotClass.SlotType.HOTBAR:
		get_tree().call_group("hotbar", "refresh_hotbar")
	
	get_tree().call_group("hotbar", "refresh_hotbar")
	
	if source_slot.slot_type != SlotClass.SlotType.INVENTORY or target_slot.slot_type != SlotClass.SlotType.INVENTORY:
		initialize_equips()
