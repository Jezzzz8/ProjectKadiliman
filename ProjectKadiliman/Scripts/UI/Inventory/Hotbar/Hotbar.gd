extends Control

const SlotClass = preload("res://Scripts/UI/Inventory/Slots/Slot.gd")
@onready var hotbar: GridContainer = $TextureRect/HotbarSlots
@onready var active_item_label: Label = $ActiveItemLabel
@onready var slots = hotbar.get_children()

# Fade effect variables
var fade_tween: Tween

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
	
	# Initialize tween
	fade_tween = create_tween()
	fade_tween.kill() # Start with a clean slate

func update_active_item_label():
	if PlayerInventory.active_item_slot >= 0 and PlayerInventory.active_item_slot < slots.size() and slots[PlayerInventory.active_item_slot].item != null:
		var item_name = slots[PlayerInventory.active_item_slot].item.item_name
		show_item_label_with_fade(item_name)
	else:
		hide_item_label_with_fade()

# NEW: Show label with fade-in effect
func show_item_label_with_fade(item_name: String):
	# Set the text first
	active_item_label.text = item_name
	
	# Ensure label is visible but transparent
	active_item_label.modulate.a = 0.0
	active_item_label.visible = true
	
	# Create fade in effect
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.set_parallel(true) # Allow multiple properties to tween simultaneously
	
	# Fade in
	fade_tween.tween_property(active_item_label, "modulate:a", 1.0, 0.3)
	
	# Optional: Add a slight scale effect for more visual appeal
	active_item_label.scale = Vector2(0.9, 0.9)
	fade_tween.tween_property(active_item_label, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT)

# NEW: Hide label with fade-out effect
func hide_item_label_with_fade():
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Fade out
	fade_tween.tween_property(active_item_label, "modulate:a", 0.0, 0.3)
	
	# Optional: Add slight scale down effect
	fade_tween.tween_property(active_item_label, "scale", Vector2(0.9, 0.9), 0.3).set_ease(Tween.EASE_IN)
	
	# Hide the label after fade out completes
	fade_tween.tween_callback(func(): 
		if active_item_label.modulate.a == 0.0:
			active_item_label.visible = false
			active_item_label.text = ""
	).set_delay(0.3)

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
			# Check if inventory is open - if it is, don't allow hotbar selection
			var inventory = get_tree().get_first_node_in_group("inventory")
			if inventory and inventory.visible:
				print("Close inventory to select hotbar slots")
				return
			
			# Allow selection in the hotbar
			select_slot(slot.slot_index)

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
