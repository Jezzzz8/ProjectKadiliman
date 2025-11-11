extends Control

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
@onready var hotbar: GridContainer = $TextureRect/HotbarSlots
@onready var active_item_label: Label = $ActiveItemLabel
@onready var slots = hotbar.get_children()

func _ready():
	PlayerInventory.active_item_updated.connect(self.update_active_item_label)
	for i in range(slots.size()):
		# RE-ADD: gui_input connection for selection only (not inventory management)
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		PlayerInventory.active_item_updated.connect(slots[i].refresh_style)
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
		
		# Keep slots interactive for selection, but not for inventory management
		# slots[i].mouse_filter = Control.MOUSE_FILTER_PASS (default)
	
	add_to_group("hotbar")
	PlayerInventory.hotbar_updated.connect(refresh_hotbar)
	initialize_hotbar()

func update_active_item_label():
	if PlayerInventory.active_item_slot >= 0 and PlayerInventory.active_item_slot < slots.size() and slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
	else:
		active_item_label.text = ""

func initialize_hotbar():
	update_active_item_label()
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
		else:
			if slots[i].item:
				slots[i].item.queue_free()
				slots[i].item = null

# NEW: Handle click selection only
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			# Only allow selection if we're not holding an item
			if find_parent("UserInterface").holding_item == null:
				select_slot(slot.slot_index)
			else:
				# If holding an item, ignore the click to prevent inventory management
				# The player should use the inventory UI for hotbar management
				print("Use inventory to manage hotbar items")

# NEW: Function to select a specific slot
func select_slot(slot_index: int):
	if slot_index >= 0 and slot_index < slots.size():
		# FIX: Toggle selection - if clicking the same slot, deselect it
		if PlayerInventory.active_item_slot == slot_index:
			# Clicking the same slot - deselect it
			PlayerInventory.active_item_slot = -1
			print("Deselected hotbar slot")
		else:
			# Clicking a different slot - select it
			PlayerInventory.active_item_slot = slot_index
			print("Selected hotbar slot: ", slot_index)
		
		PlayerInventory.active_item_updated.emit()

func refresh_hotbar():
	print("Refreshing main hotbar display")
	initialize_hotbar()
