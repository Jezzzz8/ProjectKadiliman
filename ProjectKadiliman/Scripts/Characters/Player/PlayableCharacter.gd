extends CharacterBody2D

@onready var bodySprite: Sprite2D = $Sprites/Body
@onready var hairSprite: Sprite2D = $Sprites/Hair
@onready var pantsSprite: Sprite2D = $Sprites/Pants
@onready var shirtsSprite: Sprite2D = $Sprites/Shirts
@onready var shoesSprite: Sprite2D = $Sprites/Shoes
@onready var main_hand: Sprite2D = $Sprites/MainHand
@onready var anim: AnimationPlayer = $PlayerAnimation

@onready var picked_item_container: VBoxContainer = $PickedItemLabel/VBoxContainer
@onready var PickupZone: Area2D = $PickupZone
@onready var trash_slot: PanelContainer = $UserInterface/Inventory/TrashSlot

@export var movement_speed: float = 60.0
@export var run_speed: float = 100.0

var current_speed: float = 80.0
var is_moving: bool = false
var is_running: bool = false
var is_using_item: bool = false
var last_direction: String = "down"

# Projectile scenes
var peeble_ammo_scene = preload("res://Scenes/Characters/Projectiles/PeebleAmmo.tscn")
var arrow_ammo_scene = preload("res://Scenes/Characters/Projectiles/ArrowAmmo.tscn")

# Store the target position for the projectile (captured at animation start)
var projectile_target_position: Vector2 = Vector2.ZERO

# Item pickup announcement system
var active_pickup_labels: Array = []  # Track currently displayed labels
var max_displayed_items: int = 3      # Maximum number of items to show
var pickup_timers: Dictionary = {}    # Track timers for each label

# NEW: Inventory full announcement
var inventory_full_label: Control = null
var inventory_full_timer: Timer = null

@onready var inventory: Control = $UserInterface/Inventory

func _ready() -> void:
	apply_character_data(PlayerCharacterData.player_character_data)
	add_to_group("player")
	
	# Connect to hotbar updates to change equipped item appearance
	if PlayerInventory:
		PlayerInventory.active_item_updated.connect(_on_active_item_updated)
		PlayerInventory.hotbar_updated.connect(_on_hotbar_updated)
		PlayerInventory.inventory_updated.connect(_on_inventory_updated)  # NEW: Connect to general inventory updates
	
	update_equipment_display()

# NEW: Function to announce inventory full
func announce_inventory_full():
	print("Inventory is full! Cannot pick up item.")
	
	# Create or update inventory full label
	if not inventory_full_label:
		create_inventory_full_label()
	else:
		reset_inventory_full_timer()
	
	# Show the label
	inventory_full_label.visible = true
	inventory_full_label.modulate.a = 1.0

# NEW: Create inventory full label
func create_inventory_full_label():
	var pickup_label_scene = preload("res://Scenes/World/Environment/Item/PickupLabel.tscn")
	inventory_full_label = pickup_label_scene.instantiate()
	
	# Set the text and color (red for warning)
	inventory_full_label.get_node("ItemName").text = "Inventory Full!"
	inventory_full_label.get_node("ItemName").modulate = Color.RED
	
	# Add to container
	picked_item_container.add_child(inventory_full_label)
	
	# Start timer
	start_inventory_full_timer()

# NEW: Start timer for inventory full message
func start_inventory_full_timer():
	if inventory_full_timer and inventory_full_timer.is_inside_tree():
		inventory_full_timer.queue_free()
	
	inventory_full_timer = Timer.new()
	inventory_full_timer.wait_time = 2.0  # 2 seconds for warning message
	inventory_full_timer.one_shot = true
	add_child(inventory_full_timer)
	
	inventory_full_timer.timeout.connect(_on_inventory_full_timeout)
	inventory_full_timer.start()

# NEW: Reset the inventory full timer
func reset_inventory_full_timer():
	if inventory_full_timer:
		inventory_full_timer.start()

# NEW: Handle inventory full timeout
func _on_inventory_full_timeout():
	if inventory_full_label:
		# Fade out the label
		var tween = create_tween()
		tween.tween_property(inventory_full_label, "modulate:a", 0.0, 0.5)
		tween.tween_callback(hide_inventory_full_label)

# NEW: Hide inventory full label
func hide_inventory_full_label():
	if inventory_full_label:
		inventory_full_label.visible = false
		inventory_full_label.modulate.a = 0.0

# NEW: Function to announce picked up items
func announce_item_pickup(item_name: String, quantity: int):
	print("Announcing item pickup: ", item_name, " x", quantity)
	
	# Check if we already have a label for this item
	var existing_label = find_existing_label(item_name)
	
	if existing_label:
		# Update existing label with new quantity
		update_existing_label(existing_label, item_name, quantity)
	else:
		# Create new label
		create_new_label(item_name, quantity)
	
	# Ensure we don't exceed the maximum displayed items
	cleanup_old_labels()

# Find if we already have a label for this item type
func find_existing_label(item_name: String) -> Control:
	for label_data in active_pickup_labels:
		if label_data["item_name"] == item_name:
			return label_data["label"]
	return null

# Update an existing label with new quantity
func update_existing_label(label: Control, item_name: String, additional_quantity: int):
	# Find the label data
	var label_data = null
	for data in active_pickup_labels:
		if data["label"] == label:
			label_data = data
			break
	
	if label_data:
		# Update the quantity
		label_data["quantity"] += additional_quantity
		
		# Update the label text WITH "+" sign
		if label_data["quantity"] > 1:
			label.get_node("ItemName").text = "+%s x%d" % [item_name, label_data["quantity"]]
		else:
			label.get_node("ItemName").text = "+" + item_name
		
		# Reset the timer for this label
		reset_label_timer(label_data)
		
		# Move to top (most recent)
		move_label_to_top(label)

# Create a new label for the item
func create_new_label(item_name: String, quantity: int):
	var pickup_label_scene = preload("res://Scenes/World/Environment/Item/PickupLabel.tscn")
	var new_label = pickup_label_scene.instantiate()
	
	# Set the text
	if quantity > 1:
		new_label.get_node("ItemName").text = "+%s x%d" % [item_name, quantity]
	else:
		new_label.get_node("ItemName").text = "+" + item_name
	
	# Add to container at the bottom
	picked_item_container.add_child(new_label)
	
	# Create label data
	var label_data = {
		"label": new_label,
		"item_name": item_name,
		"quantity": quantity,
		"timer": null
	}
	
	# Add to active labels
	active_pickup_labels.append(label_data)
	
	# Start fade timer for this label
	start_label_timer(label_data)
	
	# Move to top (most recent)
	move_label_to_top(new_label)

# Move a label to the top (most recent position)
func move_label_to_top(label: Control):
	# Remove from current position
	picked_item_container.remove_child(label)
	# Add back at the top (bottom of array = top visually)
	picked_item_container.add_child(label)

# Start the fade timer for a label
func start_label_timer(label_data: Dictionary):
	# Remove existing timer if any
	if label_data["timer"] and label_data["timer"].is_inside_tree():
		label_data["timer"].queue_free()
	
	# Create new timer
	var timer = Timer.new()
	timer.wait_time = 3.0  # 3 seconds before fading
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(_on_pickup_label_timeout.bind(label_data))
	timer.start()
	
	label_data["timer"] = timer

# Reset the timer for an existing label
func reset_label_timer(label_data: Dictionary):
	if label_data["timer"]:
		label_data["timer"].start()

# Timer timeout - fade out the label
func _on_pickup_label_timeout(label_data: Dictionary):
	var label = label_data["label"]
	
	# Create fade animation
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(remove_pickup_label.bind(label_data))

# Remove a pickup label completely
func remove_pickup_label(label_data: Dictionary):
	var label = label_data["label"]
	
	# Remove from active labels
	var index = -1
	for i in range(active_pickup_labels.size()):
		if active_pickup_labels[i]["label"] == label:
			index = i
			break
	
	if index != -1:
		active_pickup_labels.remove_at(index)
	
	# Remove timer if it exists
	if label_data["timer"] and label_data["timer"].is_inside_tree():
		label_data["timer"].queue_free()
	
	# Remove the label
	if label and label.is_inside_tree():
		label.queue_free()

# Clean up old labels if we exceed the maximum
func cleanup_old_labels():
	if active_pickup_labels.size() > max_displayed_items:
		# Remove the oldest one (first in array)
		var oldest_label = active_pickup_labels[0]
		remove_pickup_label(oldest_label)

func _on_active_item_updated():
	# Update equipment display when hotbar selection changes
	update_equipment_display()

func _on_hotbar_updated():
	# Update equipment display when hotbar contents change
	update_equipment_display()

func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("use_range_weapon_") or anim_name.begins_with("use_tool_") or anim_name.begins_with("use_weapon_"):
		is_using_item = false
		
		# Handle specific animation types
		if anim_name.begins_with("use_range_weapon_"):
			spawn_projectile()
		elif anim_name.begins_with("use_tool_"):
			var active_item = get_active_hotbar_item()
			var range_weapon_name = active_item if active_item else PlayerCharacterData.player_character_data.current_range_weapon
			
			if range_weapon_name == "Cross Bow":
				spawn_projectile()
			else:
				perform_tool_action()

func apply_character_data(data: Dictionary) -> void:
	if PlayerCharacterData.validate_data(data):
		var sprites = {
			"body": bodySprite,
			"hair": hairSprite, 
			"pants": pantsSprite,
			"shirts": shirtsSprite,
			"shoes": shoesSprite,
			"main_hand": main_hand
		}
		CharacterUtils.update_sprites(data, sprites)
	else:
		push_error("Invalid character data provided")

# Update equipment display based on current hotbar selection or equipped items
func update_equipment_display():
	var active_item = get_active_hotbar_item()
	
	if active_item and not active_item.is_empty():
		# Show the active hotbar item in main hand
		update_main_hand_texture(active_item)
	else:
		# Fall back to equipped items from PlayerCharacterData
		update_main_hand_from_equipped()

func update_main_hand_from_equipped():
	if not main_hand:
		return
	
	var data = PlayerCharacterData.player_character_data
	var texture = null
	
	# Use the same priority logic as use_equipped_item()
	if data.current_range_weapon != "none":
		texture = CompositeSprites.get_range_weapon_texture(data.current_range_weapon)
	elif data.current_weapon != "none":
		texture = CompositeSprites.get_weapon_texture(data.current_weapon)
	elif data.current_tool != "none":
		texture = CompositeSprites.get_tool_texture(data.current_tool)
	
	main_hand.texture = texture

func update_main_hand_texture(item_name: String):
	if not main_hand:
		return
	
	var texture = null
	var item_category = JsonData.item_data[item_name]["ItemCategory"]
	
	# Get the appropriate sprite based on item category
	match item_category:
		"Tool":
			texture = CompositeSprites.get_tool_texture(item_name)
		"Weapon":
			texture = CompositeSprites.get_weapon_texture(item_name)
		"Range Weapon":
			texture = CompositeSprites.get_range_weapon_texture(item_name)
		_:
			# For other item types, try to get generic item texture
			texture = CompositeSprites.get_item_texture(item_name)
	
	if texture:
		main_hand.texture = texture
	else:
		main_hand.texture = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item") and not is_using_item:
		use_item()

func is_using_any_equipment() -> bool:
	return is_using_item

func use_item() -> void:
	var active_item = get_active_hotbar_item()
	
	if active_item and not active_item.is_empty():
		use_active_item(active_item)
	else:
		use_equipped_item()

func get_active_hotbar_item() -> String:
	if PlayerInventory and PlayerInventory.active_item_slot >= 0:
		var slot_index = PlayerInventory.active_item_slot
		if PlayerInventory.hotbar.has(slot_index):
			return PlayerInventory.hotbar[slot_index][0]
	return ""

func use_active_item(item_name: String) -> void:
	if item_name.is_empty():
		return
	
	# Get item category from JSON data
	var item_category = JsonData.item_data[item_name]["ItemCategory"]
	
	# Update direction based on mouse position for relevant items
	if item_category != "Resource":  # Resources don't need direction update
		update_direction_from_mouse()
	
	match item_category:
		"Tool":
			use_tool(item_name)  # Tool animation and action
		"Weapon":
			use_weapon(item_name)  # Weapon animation and action
		"Range Weapon":
			use_range_weapon(item_name)  # Range weapon animation and action
		"Resource":
			# Resources have no animation or action
			print("Resource item used (no action): ", item_name)
			return  # Don't trigger any animation
		"Body":
			print("Cannot use clothing directly: ", item_name)
			return
		_:
			print("Unknown item category for: ", item_name)
			return

func use_equipped_item() -> void:
	if is_using_item:
		return
	
	var data = PlayerCharacterData.player_character_data
	
	# Update direction based on mouse position
	update_direction_from_mouse()
	
	# Check ammo for range weapons first using new inventory functions
	if data.current_range_weapon != "none":
		var ammo_type = get_ammo_type_for_weapon(data.current_range_weapon)
		if ammo_type and not PlayerInventory.has_item(ammo_type):
			print("No %s ammo available for %s!" % [ammo_type, data.current_range_weapon])
			return
		
		use_range_weapon(data.current_range_weapon)
		return
	
	# Then check for tools
	if data.current_tool != "none":
		use_tool(data.current_tool)
		return
	
	# Finally check for weapons
	if data.current_weapon != "none":
		use_weapon(data.current_weapon)
		return
	
	print("No equipped item to use")

# NEW: Helper function to get ammo type for weapons
func get_ammo_type_for_weapon(weapon_name: String) -> String:
	match weapon_name:
		"Slingshot":
			return "Peeble"
		"Cross Bow":
			return "Arrow"
		_:
			return ""

func update_direction_from_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var character_pos = global_position
	var direction_vector = mouse_pos - character_pos
	
	if abs(direction_vector.x) > abs(direction_vector.y):
		last_direction = "right" if direction_vector.x > 0 else "left"
	else:
		last_direction = "down" if direction_vector.y > 0 else "up"

func use_tool(tool_name: String) -> void:
	print("Using tool: ", tool_name)
	
	var tool_anim_name = "use_tool_" + last_direction
	if anim.has_animation(tool_anim_name):
		is_using_item = true
		CharacterUtils.play_animation(anim, tool_anim_name)
	else:
		print("No animation found for: ", tool_anim_name)
		is_using_item = false

func use_weapon(weapon_name: String) -> void:
	print("Using weapon: ", weapon_name)
	
	var weapon_anim_name = "use_weapon_" + last_direction
	if anim.has_animation(weapon_anim_name):
		is_using_item = true
		CharacterUtils.play_animation(anim, weapon_anim_name)
	else:
		print("No animation found for: ", weapon_anim_name)
		is_using_item = false

func use_range_weapon(range_weapon_name: String) -> void:
	print("Using range weapon: ", range_weapon_name)
	
	# Special handling for Cross Bow - it uses tool animations
	var anim_name = ""
	if range_weapon_name == "Cross Bow":
		anim_name = "use_tool_" + last_direction  # Cross Bow uses tool animations
	else:
		anim_name = "use_range_weapon_" + last_direction  # Other range weapons use range animations
	
	if anim.has_animation(anim_name):
		projectile_target_position = get_global_mouse_position()
		is_using_item = true
		CharacterUtils.play_animation(anim, anim_name)
	else:
		print("No animation found for: ", anim_name)
		is_using_item = false

func spawn_projectile():
	var active_item = get_active_hotbar_item()
	var range_weapon_name = active_item if active_item else PlayerCharacterData.player_character_data.current_range_weapon
	
	var projectile_scene = null
	var ammo_type = get_ammo_type_for_weapon(range_weapon_name)
	
	match range_weapon_name:
		"Slingshot":
			projectile_scene = peeble_ammo_scene
			print("Firing slingshot with peeble")
		"Cross Bow":
			projectile_scene = arrow_ammo_scene
			print("Firing cross bow with arrow")
		_:
			print("No projectile defined for: ", range_weapon_name)
			return
	
	# Consume ammo using the new inventory function
	if ammo_type and PlayerInventory:
		if not PlayerInventory.consume_item(ammo_type, 1):
			print("Failed to consume ammo: ", ammo_type)
			return
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		var character_pos = global_position
		var direction_vector = (projectile_target_position - character_pos).normalized()
		var angle = direction_vector.angle()
		var spawn_offset = Vector2(20, 0).rotated(angle)
		var spawn_position = character_pos + spawn_offset
		
		if projectile.has_method("setup"):
			projectile.setup(spawn_position, angle)
		else:
			projectile.position = spawn_position
			projectile.direction = angle
			projectile.rotation = angle
		
		get_parent().add_child(projectile)

# UPDATED: Remove old consume_ammo function since we're now using PlayerInventory.consume_item()

func perform_tool_action():
	var active_item = get_active_hotbar_item()
	var tool_name = active_item if active_item else PlayerCharacterData.player_character_data.current_tool
	print("Performing tool action: ", tool_name)
	
	match tool_name:
		"Shovel":
			check_for_diggable_terrain()
		"Hoe":
			check_for_tillable_soil()
		"Watering Can":
			check_for_plants_to_water()
		_:
			print("No specific action defined for tool: ", tool_name)

func check_for_diggable_terrain():
	var dig_position = global_position + get_direction_vector() * 40
	print("Attempting to dig at position: ", dig_position)

func check_for_tillable_soil():
	var till_position = global_position + get_direction_vector() * 40
	print("Attempting to till at position: ", till_position)

func check_for_plants_to_water():
	var water_position = global_position + get_direction_vector() * 40
	print("Attempting to water at position: ", water_position)

func get_direction_vector() -> Vector2:
	match last_direction:
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		_:
			return Vector2.DOWN

func _physics_process(delta: float) -> void:
	if not is_using_item:
		handle_movement()
		handle_animations()
		move_and_slide()

func handle_movement() -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("go_right") - Input.get_action_strength("go_left")
	input_vector.y = Input.get_action_strength("go_down") - Input.get_action_strength("go_up")
	
	is_moving = input_vector.length() > 0
	is_running = Input.is_action_pressed("run")
	current_speed = run_speed if is_running else movement_speed
	
	if is_moving:
		last_direction = CharacterUtils.update_direction(input_vector)
		velocity = input_vector.normalized() * current_speed
	else:
		velocity = Vector2.ZERO

func handle_animations() -> void:
	var anim_name = CharacterUtils.get_animation_name(
		last_direction, 
		is_moving, 
		is_running, 
		is_using_item
	)
	CharacterUtils.play_animation(anim, anim_name)

func _on_inventory_updated():
	print("Inventory updated - refreshing character appearance")
	apply_character_data(PlayerCharacterData.player_character_data)
	update_equipment_display()
