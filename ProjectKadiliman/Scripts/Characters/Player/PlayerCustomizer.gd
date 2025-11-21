# PlayerCustomizer.gd
extends Control

@onready var bodySprite: Sprite2D = $Sprites/Body
@onready var hairSprite: Sprite2D = $Sprites/Hair
@onready var pantsSprite: Sprite2D = $Sprites/Pants
@onready var shirtsSprite: Sprite2D = $Sprites/Shirts
@onready var shoesSprite: Sprite2D = $Sprites/Shoes
@onready var main_hand: Sprite2D = $Sprites/MainHand
@onready var anim: AnimationPlayer = $PlayerAnimation
@onready var UI: Control = $Customizer

@export var sprite_scale = Vector2(0.5, 0.5)
@export var can_customize = false

var last_direction: String = "down"
var rng = RandomNumberGenerator.new()
var player_node: Node2D = null
var is_preview_mode: bool = false

func _ready() -> void:
	load_character_data()
	update_sprites()
	CharacterUtils.play_animation(anim, "idle_down")
	
	bodySprite.scale = sprite_scale
	hairSprite.scale = sprite_scale
	pantsSprite.scale = sprite_scale
	shirtsSprite.scale = sprite_scale
	shoesSprite.scale = sprite_scale
	main_hand.scale = sprite_scale
	
	UI.visible = can_customize
	
	# Connect to inventory updates to track equipment changes
	if PlayerInventory:
		PlayerInventory.inventory_updated.connect(_on_inventory_updated_preview)
	
	# If not in customization mode, find and track the player
	if !can_customize:
		setup_preview_mode()

func _on_inventory_updated_preview():
	print("PlayerCustomizer: Inventory updated, refreshing character appearance")
	update_sprites()
	update_equipment_display()

func setup_preview_mode():
	is_preview_mode = true
	
	# Connect to inventory updates to track equipment changes
	if PlayerInventory:
		PlayerInventory.hotbar_updated.connect(_on_hotbar_updated_preview)
		PlayerInventory.active_item_updated.connect(_on_active_item_updated_preview)
		PlayerInventory.inventory_updated.connect(_on_inventory_updated_preview)
	
	# Try to find the player node in the scene
	find_player_node()

func find_player_node():
	# Look for the player in the scene tree
	player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		print("PlayerCustomizer: Found player node, starting preview mode")
	else:
		# If player not found yet, try again later
		call_deferred("find_player_node")

func _on_hotbar_updated_preview():
	# Update equipment display when hotbar changes
	update_equipment_display()

func _on_active_item_updated_preview():
	# Update equipment display when active item changes
	update_equipment_display()

func load_character_data() -> void:
	# Data is already in the singleton, just update visuals
	update_sprites()

# UPDATED: Update sprites to include hair color
func update_sprites() -> void:
	var data = PlayerCharacterData.player_character_data
	var is_female = data.is_female
	
	# Update body
	if bodySprite:
		var body_texture = CompositeSprites.get_body_texture(data.body, is_female)
		bodySprite.texture = body_texture
	
	# Update hair with color
	update_hair_with_color()
	
	# Update shirts
	if shirtsSprite:
		var shirts_spritesheet = CompositeSprites.get_shirts_spritesheet(is_female)
		var shirt_keys = shirts_spritesheet.keys()
		if data.shirts < shirt_keys.size():
			var shirt_key = shirt_keys[data.shirts]
			shirtsSprite.texture = shirts_spritesheet[shirt_key]
			print("Shirt: ", shirt_key, " (index: ", data.shirts, ")")
		else:
			shirtsSprite.texture = null
			print("Shirt: invalid index ", data.shirts)
	
	# Update pants
	if pantsSprite:
		var pants_spritesheet = CompositeSprites.get_pants_spritesheet(is_female)
		var pants_keys = pants_spritesheet.keys()
		if data.pants < pants_keys.size():
			var pants_key = pants_keys[data.pants]
			pantsSprite.texture = pants_spritesheet[pants_key]
			print("Pants: ", pants_key, " (index: ", data.pants, ")")
		else:
			pantsSprite.texture = null
			print("Pants: invalid index ", data.pants)
	
	# Update shoes
	if shoesSprite:
		var shoes_spritesheet = CompositeSprites.get_shoes_spritesheet(is_female)
		var shoes_keys = shoes_spritesheet.keys()
		if data.shoes < shoes_keys.size():
			var shoes_key = shoes_keys[data.shoes]
			shoesSprite.texture = shoes_spritesheet[shoes_key]
			print("Shoes: ", shoes_key, " (index: ", data.shoes, ")")
		else:
			shoesSprite.texture = null
			print("Shoes: invalid index ", data.shoes)

# NEW: Update hair sprite with current color
func update_hair_with_color():
	if not hairSprite:
		return
	
	var hair_style = PlayerCharacterData.player_character_data.hair
	var current_color = PlayerCharacterData.get_current_hair_color()  # Use the autoload
	var is_female = PlayerCharacterData.player_character_data.is_female
	
	# Get the hair texture with current color
	var hair_texture = CompositeSprites.get_hair_texture(hair_style + 1, current_color, is_female)
	
	if hair_texture:
		hairSprite.texture = hair_texture
		print("Hair updated: Style ", hair_style + 1, " Color: ", current_color)
	else:
		print("Hair texture not found for style ", hair_style + 1, " color ", current_color)

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

func get_active_hotbar_item() -> String:
	if PlayerInventory and PlayerInventory.active_item_slot >= 0:
		var slot_index = PlayerInventory.active_item_slot
		if PlayerInventory.hotbar.has(slot_index):
			return PlayerInventory.hotbar[slot_index][0]
	return ""

func _process(delta: float) -> void:
	if is_preview_mode:
		handle_preview_updates()
	else:
		handle_preview_input()

func handle_preview_updates():
	# In preview mode, mimic the player's state
	if player_node:
		# Copy the player's direction and movement state
		last_direction = player_node.last_direction
		
		# Check if player is moving or using item
		var is_moving = player_node.is_moving
		var is_running = player_node.is_running
		var is_using_item = player_node.is_using_item
		
		# Update animation based on player state
		var anim_name = CharacterUtils.get_animation_name(
			last_direction, 
			is_moving, 
			is_running, 
			is_using_item
		)
		CharacterUtils.play_animation(anim, anim_name)
		
		# Update equipment display in case it changed
		update_equipment_display()

func handle_preview_input() -> void:
	var input_vector = Vector2.ZERO
	var is_moving = false
	
	# Check for movement input
	if Input.is_action_pressed("go_right"):
		input_vector.x += 1
		is_moving = true
	if Input.is_action_pressed("go_left"):
		input_vector.x -= 1
		is_moving = true
	if Input.is_action_pressed("go_down"):
		input_vector.y += 1
		is_moving = true
	if Input.is_action_pressed("go_up"):
		input_vector.y -= 1
		is_moving = true
	
	if is_moving:
		last_direction = CharacterUtils.update_direction(input_vector)
	
	# Determine animation
	var is_running = Input.is_action_pressed("run")
	var anim_name = CharacterUtils.get_animation_name(last_direction, is_moving, is_running)
	CharacterUtils.play_animation(anim, anim_name)

# UI Button handlers (updated with hair color)

func _on_change_body_pressed() -> void:
	var spritesheet = CompositeSprites.get_body_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.body = (PlayerCharacterData.player_character_data.body + 1) % spritesheet.size()
	update_sprites()

# UPDATED: Change Hair button now shows black base color
func _on_change_hair_pressed() -> void:
	# Change hair style but always show black color for the base
	var spritesheet = CompositeSprites.get_hair_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.hair = (PlayerCharacterData.player_character_data.hair + 1) % 8  # 8 hair styles
	
	# NEW: Temporarily show black color when changing hair style using autoload
	var temp_hair_color = PlayerCharacterData.get_current_hair_color()  # Store current color
	update_hair_with_color()
	PlayerCharacterData.set_hair_color(temp_hair_color)  # Restore original color
	
	print("Changed hair style to: ", PlayerCharacterData.player_character_data.hair + 1, " (showing black base)")

# NEW: Implement hair color change - keeps the current hair style but changes color
func _on_change_hair_color_pressed() -> void:
	# Use the autoload function
	PlayerCharacterData.cycle_hair_color()
	print("Changing hair color to: ", PlayerCharacterData.get_current_hair_color(), " on style ", PlayerCharacterData.player_character_data.hair + 1)
	update_hair_with_color()

func _on_change_shirts_pressed() -> void:
	var spritesheet = CompositeSprites.get_shirts_spritesheet(PlayerCharacterData.player_character_data.is_female)
	var keys = spritesheet.keys()
	PlayerCharacterData.player_character_data.shirts = (PlayerCharacterData.player_character_data.shirts + 1) % keys.size()
	update_sprites()
	print("Changed shirt to index: ", PlayerCharacterData.player_character_data.shirts)

func _on_change_pants_pressed() -> void:
	var spritesheet = CompositeSprites.get_pants_spritesheet(PlayerCharacterData.player_character_data.is_female)
	var keys = spritesheet.keys()
	PlayerCharacterData.player_character_data.pants = (PlayerCharacterData.player_character_data.pants + 1) % keys.size()
	update_sprites()
	print("Changed pants to index: ", PlayerCharacterData.player_character_data.pants)

func _on_change_shoes_pressed() -> void:
	var spritesheet = CompositeSprites.get_shoes_spritesheet(PlayerCharacterData.player_character_data.is_female)
	var keys = spritesheet.keys()
	PlayerCharacterData.player_character_data.shoes = (PlayerCharacterData.player_character_data.shoes + 1) % keys.size()
	update_sprites()
	print("Changed shoes to index: ", PlayerCharacterData.player_character_data.shoes)

# UPDATED: Randomize to include hair color
func _on_randomize_button_pressed() -> void:
	var data = PlayerCharacterData.player_character_data
	
	# Randomize body (0-4)
	data.body = rng.randi_range(0, 4)
	
	# Randomize hair style (0-7 for 8 styles)
	data.hair = rng.randi_range(0, 7)
	
	# Randomize clothing - use actual sprite sheet sizes
	var shirts_spritesheet = CompositeSprites.get_shirts_spritesheet(data.is_female)
	var pants_spritesheet = CompositeSprites.get_pants_spritesheet(data.is_female)
	var shoes_spritesheet = CompositeSprites.get_shoes_spritesheet(data.is_female)
	
	data.shirts = rng.randi_range(1, shirts_spritesheet.keys().size() - 1)
	data.pants = rng.randi_range(1, pants_spritesheet.keys().size() - 1)
	data.shoes = rng.randi_range(1, shoes_spritesheet.keys().size() - 1)
	
	# Randomize hair color
	var random_color_index = rng.randi_range(0, PlayerCharacterData.available_hair_colors.size() - 1)
	PlayerCharacterData.set_hair_color(PlayerCharacterData.available_hair_colors[random_color_index])
	
	print("Randomized character:")
	print("  Body: ", data.body)
	print("  Hair Style: ", data.hair + 1)
	print("  Hair Color: ", PlayerCharacterData.get_current_hair_color())
	print("  Shirt index: ", data.shirts)
	print("  Pants index: ", data.pants)
	print("  Shoes index: ", data.shoes)
	
	update_sprites()

# UPDATED: Gender change to reset hair color
func _on_change_sex_pressed() -> void:
	PlayerCharacterData.player_character_data.is_female = !PlayerCharacterData.player_character_data.is_female
	# Reset to first variant when changing gender
	PlayerCharacterData.player_character_data.body = 0
	PlayerCharacterData.player_character_data.hair = 0
	PlayerCharacterData.player_character_data.pants = 0  # This will be "none"
	PlayerCharacterData.player_character_data.shirts = 0  # This will be "none"
	PlayerCharacterData.player_character_data.shoes = 0  # This will be "none"
	
	# Reset hair color to black using autoload
	PlayerCharacterData.set_hair_color("Black")
	
	update_sprites()

func _on_finish_customization_pressed() -> void:
	# Ensure all data is properly set
	print("Final character data:")
	print("  Body: ", PlayerCharacterData.player_character_data.body)
	print("  Hair: ", PlayerCharacterData.player_character_data.hair)
	print("  Hair Color: ", PlayerCharacterData.player_character_data.hair_color)
	print("  Shirts: ", PlayerCharacterData.player_character_data.shirts)
	print("  Pants: ", PlayerCharacterData.player_character_data.pants)
	print("  Shoes: ", PlayerCharacterData.player_character_data.shoes)
	print("  Is Female: ", PlayerCharacterData.player_character_data.is_female)
	
	# NEW: Sync equipment with inventory
	if PlayerInventory:
		PlayerInventory.update_equipment_from_customizer()
		print("Equipment synced with inventory")
	
	get_tree().change_scene_to_file("res://Scenes/Core/Forest.tscn")

func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
