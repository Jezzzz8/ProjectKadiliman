extends CanvasLayer

@onready var inventory: Control = $Inventory
@onready var hotbar: Control = $Hotbar
@onready var inventory_open: Button = $Hotbar/InventoryOpen
@onready var inventory_close: Button = $Inventory/InventoryClose

# Hotkey actions mapped to slot indices
const HOTKEY_ACTIONS := {
	"hotbar_1": 0, "hotbar_2": 1, "hotbar_3": 2, "hotbar_4": 3, "hotbar_5": 4,
	"hotbar_6": 5, "hotbar_7": 6, "hotbar_8": 7, "hotbar_9": 8, "hotbar_0": 9
}

func _ready() -> void:
	# Connect button signals
	inventory_open.pressed.connect(_on_inventory_open_pressed)
	inventory_close.pressed.connect(_on_inventory_close_pressed)
	
	# Ensure initial state
	inventory.visible = false
	hotbar.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	
	# Only process hotbar inputs if inventory is NOT visible
	if not inventory.visible:
		_process_hotbar_input(event)

func _process_hotbar_input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_down()
	elif event.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_up()
	else:
		# Check for hotkey inputs
		for action in HOTKEY_ACTIONS:
			if event.is_action_pressed(action):
				toggle_hotbar_slot(HOTKEY_ACTIONS[action])
				break

func toggle_inventory() -> void:
	if inventory.visible:
		close_inventory()
	else:
		open_inventory()

func open_inventory() -> void:
	inventory.visible = true
	hotbar.visible = false
	
	if inventory.has_method("initialize_inventory"):
		inventory.initialize_inventory()
	if inventory.has_method("initialize_equips"):
		inventory.initialize_equips()

func close_inventory() -> void:
	# Clear any selection before closing
	if inventory.has_method("clear_selection"):
		inventory.clear_selection()
	
	inventory.visible = false
	hotbar.visible = true
	get_tree().call_group("hotbar", "refresh_hotbar")

func toggle_hotbar_slot(slot_index: int) -> void:
	if hotbar and hotbar.has_method("select_slot"):
		hotbar.select_slot(slot_index)

func _on_inventory_open_pressed() -> void:
	open_inventory()

func _on_inventory_close_pressed() -> void:
	close_inventory()
