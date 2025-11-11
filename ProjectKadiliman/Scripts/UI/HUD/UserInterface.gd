extends CanvasLayer
var holding_item = null

func _input(event):
	if event.is_action_pressed("inventory"):
		if $Inventory.visible:
			# Inventory is currently open, about to close it
			# First, return any held item to its original slot
			if holding_item != null:
				print("Closing inventory with held item - returning to original slot")
				$Inventory.return_held_item_to_original_slot()
			
			# Then close the inventory
			$Inventory.visible = false
			$Hotbar.visible = true
			get_tree().call_group("hotbar", "refresh_hotbar")
		else:
			# Opening inventory - refresh everything
			$Inventory.visible = true
			$Hotbar.visible = false
			$Inventory.initialize_inventory()
			$Inventory.initialize_equips()  # ADDED: Refresh equipment slots
	
	if event.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_down()
	elif event.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_up()

	elif event.is_action_pressed("hotbar_1"):
		toggle_hotbar_slot(0)
	elif event.is_action_pressed("hotbar_2"):
		toggle_hotbar_slot(1)
	elif event.is_action_pressed("hotbar_3"):
		toggle_hotbar_slot(2)
	elif event.is_action_pressed("hotbar_4"):
		toggle_hotbar_slot(3)
	elif event.is_action_pressed("hotbar_5"):
		toggle_hotbar_slot(4)
	elif event.is_action_pressed("hotbar_6"):
		toggle_hotbar_slot(5)
	elif event.is_action_pressed("hotbar_7"):
		toggle_hotbar_slot(6)
	elif event.is_action_pressed("hotbar_8"):
		toggle_hotbar_slot(7)
	elif event.is_action_pressed("hotbar_9"):
		toggle_hotbar_slot(8)
	elif event.is_action_pressed("hotbar_0"):
		toggle_hotbar_slot(9)

func toggle_hotbar_slot(slot_index: int):
	var hotbar = $Hotbar
	if hotbar and hotbar.has_method("select_slot"):
		hotbar.select_slot(slot_index)

func _ready():
	pass
