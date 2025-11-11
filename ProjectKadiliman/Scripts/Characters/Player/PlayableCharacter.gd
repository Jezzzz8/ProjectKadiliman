extends CharacterBody2D

@onready var bodySprite: Sprite2D = $Sprites/Body
@onready var hairSprite: Sprite2D = $Sprites/Hair
@onready var pantsSprite: Sprite2D = $Sprites/Pants
@onready var shirtsSprite: Sprite2D = $Sprites/Shirts
@onready var shoesSprite: Sprite2D = $Sprites/Shoes
@onready var main_hand: Sprite2D = $Sprites/MainHand
@onready var anim: AnimationPlayer = $PlayerAnimation

@onready var PickupZone: Area2D = $PickupZone

@export var movement_speed: float = 80.0
@export var run_speed: float = 150.0

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

@onready var inventory: Control = $UserInterface/Inventory

func _ready() -> void:
	apply_character_data(PlayerCharacterData.player_character_data)
	add_to_group("player")
	
	# Connect to hotbar updates to change equipped item appearance
	if PlayerInventory:
		PlayerInventory.active_item_updated.connect(_on_active_item_updated)
		PlayerInventory.hotbar_updated.connect(_on_hotbar_updated)
	
	update_equipment_display()

func _on_active_item_updated():
	# Update equipment display when hotbar selection changes
	update_equipment_display()

func _on_hotbar_updated():
	# Update equipment display when hotbar contents change
	update_equipment_display()

func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("use_range_weapon_"):
		is_using_item = false
		spawn_projectile()
	elif anim_name.begins_with("use_tool_"):
		is_using_item = false
		# Check if this is actually Cross Bow using tool animation
		var active_item = get_active_hotbar_item()
		var range_weapon_name = active_item if active_item else PlayerCharacterData.player_character_data.current_range_weapon
		
		if range_weapon_name == "Cross Bow":
			spawn_projectile()  # Cross Bow uses tool animation but spawns projectile
		else:
			perform_tool_action()  # Regular tools perform tool actions
	elif anim_name.begins_with("use_weapon_"):
		is_using_item = false

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
		var sprites = {
			"main_hand": main_hand
		}
		CharacterUtils.update_sprites(PlayerCharacterData.player_character_data, sprites)

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
	var data = PlayerCharacterData.player_character_data
	
	# Check ammo availability for range weapons
	if data.current_range_weapon != "none":
		if data.current_range_weapon == "Slingshot" and not PlayerCharacterData.has_item_in_inventory("Peeble"):
			print("No peeble ammo available!")
			return
		elif data.current_range_weapon == "Cross Bow" and not PlayerCharacterData.has_item_in_inventory("Arrow"):
			print("No Arrow ammo available!")
			return
	
	# Update direction based on mouse position for relevant items
	if data.current_range_weapon != "none" or data.current_tool != "none" or data.current_weapon != "none":
		update_direction_from_mouse()
	
	# Priority logic with proper category handling
	if data.current_range_weapon != "none":
		use_range_weapon(data.current_range_weapon)
	elif data.current_tool != "none":
		use_tool(data.current_tool)
	elif data.current_weapon != "none":
		use_weapon(data.current_weapon)

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
	
	match range_weapon_name:
		"Slingshot":
			projectile_scene = peeble_ammo_scene
			print("Firing slingshot with peeble")
			consume_ammo("Peeble", 1)
		"Cross Bow":
			projectile_scene = arrow_ammo_scene
			print("Firing cross bow with arrow")
			consume_ammo("Arrow", 1)
		_:
			print("No projectile defined for: ", range_weapon_name)
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

# Consume ammo from inventory
func consume_ammo(ammo_name: String, quantity: int):
	if PlayerInventory:
		# Find ammo in hotbar first, then inventory
		for slot_index in PlayerInventory.hotbar:
			if PlayerInventory.hotbar[slot_index][0] == ammo_name:
				PlayerInventory.hotbar[slot_index][1] -= quantity
				if PlayerInventory.hotbar[slot_index][1] <= 0:
					PlayerInventory.hotbar.erase(slot_index)
				PlayerInventory.hotbar_updated.emit()
				return
		
		for slot_index in PlayerInventory.inventory:
			if PlayerInventory.inventory[slot_index][0] == ammo_name:
				PlayerInventory.inventory[slot_index][1] -= quantity
				if PlayerInventory.inventory[slot_index][1] <= 0:
					PlayerInventory.inventory.erase(slot_index)
				return

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
