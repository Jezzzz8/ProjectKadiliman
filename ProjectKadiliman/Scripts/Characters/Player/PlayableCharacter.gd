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
var is_using_tool: bool = false
var is_using_weapon: bool = false
var is_using_range_weapon: bool = false
var last_direction: String = "down"

# Projectile scenes
var peeble_ammo_scene = preload("res://Scenes/Characters/Projectiles/PeebleAmmo.tscn")
# var crossbow_bolt_scene = preload("res://Scenes/Characters/Projectiles/CrossbowBolt.tscn")

# Store the target position for the projectile (captured at animation start)
var projectile_target_position: Vector2 = Vector2.ZERO

@onready var inventory: Control = $UserInterface/Inventory

func _ready() -> void:
	apply_character_data(PlayerCharacterData.player_character_data)
	# Add player to a group so items can find us
	add_to_group("player")
	

func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("use_range_weapon_"):
		is_using_range_weapon = false
		# Spawn projectile after animation finishes using the stored target position
		spawn_projectile()
	elif anim_name.begins_with("use_tool_"):
		is_using_tool = false
		# Perform tool action after animation
		perform_tool_action()
	elif anim_name.begins_with("use_weapon_"):
		is_using_weapon = false

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_tool"):
		PlayerCharacterData.cycle_tool()
		apply_character_data(PlayerCharacterData.player_character_data)
	
	if event.is_action_pressed("change_weapon"):
		PlayerCharacterData.cycle_weapon()
		apply_character_data(PlayerCharacterData.player_character_data)
	
	if event.is_action_pressed("change_range_weapon"):
		PlayerCharacterData.cycle_range_weapon()
		apply_character_data(PlayerCharacterData.player_character_data)
	
	if event.is_action_pressed("use_tool") and not is_using_any_equipment():
		use_equipment()

func is_using_any_equipment() -> bool:
	return is_using_tool or is_using_weapon or is_using_range_weapon

func use_equipment() -> void:
	var data = PlayerCharacterData.player_character_data
	
	# Update direction based on mouse position for range weapons and tools
	if data.current_range_weapon != "none" or data.current_tool != "none":
		update_direction_from_mouse()
	
	# Priority: range weapon > tool > melee weapon
	if data.current_range_weapon != "none":
		use_range_weapon()
	elif data.current_tool != "none":
		use_tool()
	elif data.current_weapon != "none":
		use_weapon()

func update_direction_from_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var character_pos = global_position
	var direction_vector = mouse_pos - character_pos
	
	# Update last_direction based on mouse position
	if abs(direction_vector.x) > abs(direction_vector.y):
		last_direction = "right" if direction_vector.x > 0 else "left"
	else:
		last_direction = "down" if direction_vector.y > 0 else "up"

func use_tool() -> void:
	var current_tool = PlayerCharacterData.player_character_data.current_tool
	print("Using tool: ", current_tool)
	
	var tool_anim_name = "use_tool_" + last_direction
	if anim.has_animation(tool_anim_name):
		is_using_tool = true
		CharacterUtils.play_animation(anim, tool_anim_name)
	else:
		print("No animation found for: ", tool_anim_name)
		is_using_tool = false

func use_weapon() -> void:
	var weapon_anim_name = "use_weapon_" + last_direction
	if anim.has_animation(weapon_anim_name):
		is_using_weapon = true
		CharacterUtils.play_animation(anim, weapon_anim_name)

func use_range_weapon() -> void:
	var current_range_weapon = PlayerCharacterData.player_character_data.current_range_weapon
	print("Using range weapon: ", current_range_weapon)
	
	var range_anim_name = "use_range_weapon_" + last_direction
	if anim.has_animation(range_anim_name):
		# Capture the mouse position at the start of the animation
		projectile_target_position = get_global_mouse_position()
		is_using_range_weapon = true
		CharacterUtils.play_animation(anim, range_anim_name)
		# Projectile will be spawned after animation finishes in _on_animation_finished

func spawn_projectile():
	var current_range_weapon = PlayerCharacterData.player_character_data.current_range_weapon
	var projectile_scene = null
	
	match current_range_weapon:
		"slingshot":
			projectile_scene = peeble_ammo_scene
			print("Firing slingshot with peeble")
		#"crossbow":
			#projectile_scene = crossbow_bolt_scene
			#print("Firing crossbow with bolt")
		_:
			print("No projectile defined for: ", current_range_weapon)
			return
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Use the stored target position captured at animation start
		var character_pos = global_position
		var direction_vector = (projectile_target_position - character_pos).normalized()
		
		# Calculate angle in radians
		var angle = direction_vector.angle()
		
		# Set spawn position (slightly in front of character)
		var spawn_offset = Vector2(20, 0).rotated(angle)
		var spawn_position = character_pos + spawn_offset
		
		# Set projectile properties
		if projectile.has_method("setup"):
			projectile.setup(spawn_position, angle)
		else:
			# Fallback for existing peeble ammo
			projectile.pos = spawn_position
			projectile.dir = angle
			projectile.rota = angle
		
		# Add to scene
		get_parent().add_child(projectile)

func perform_tool_action():
	var current_tool = PlayerCharacterData.player_character_data.current_tool
	print("Performing tool action: ", current_tool)
	
	match current_tool:
		"shovel":
			# Digging action - check for diggable terrain
			check_for_diggable_terrain()
		"hoe":
			# Tilling action - check for tillable soil
			check_for_tillable_soil()
		"watering can":
			# Watering action - check for plants to water
			check_for_plants_to_water()
		_:
			print("No specific action defined for tool: ", current_tool)

func check_for_diggable_terrain():
	# Raycast or area check in front of player for diggable terrain
	var dig_position = global_position + get_direction_vector() * 40
	print("Attempting to dig at position: ", dig_position)
	# Implement your digging logic here

func check_for_tillable_soil():
	# Raycast or area check in front of player for soil to till
	var till_position = global_position + get_direction_vector() * 40
	print("Attempting to till at position: ", till_position)
	# Implement your tilling logic here

func check_for_plants_to_water():
	# Raycast or area check in front of player for plants to water
	var water_position = global_position + get_direction_vector() * 40
	print("Attempting to water at position: ", water_position)
	# Implement your watering logic here

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
	if not is_using_any_equipment():
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
		is_using_any_equipment()
	)
	CharacterUtils.play_animation(anim, anim_name)
