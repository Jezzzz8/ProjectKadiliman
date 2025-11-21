class_name BaseAnimal
extends CharacterBody2D

# Animal properties - export variables for customization
@export var animal_name: String = "Animal"
@export var animal_type: String = "Livestock"  # Livestock, Pet, Wild, etc.
@export var movement_speed: float = 40.0
@export var run_speed: float = 80.0
@export var health: int = 100
@export var max_health: int = 100
@export var hunger: int = 100
@export var max_hunger: int = 100
@export var happiness: int = 100
@export var max_happiness: int = 100
@export var produces_item: String = ""  # e.g., "Milk", "Egg", "Wool"
@export var production_cooldown: float = 3.0  # seconds between productions
@export var item_quantity: int = 1  # Quantity of item produced

# Behavior settingss
@export var is_scared_of_player: bool = false
@export var is_friendly_to_player: bool = true
@export var detection_range: float = 80.0
@export var interaction_range: float = 100.0  # Maximum distance for interaction

@export var separation_force: float = 30.0
@export var separation_radius: float = 60.0

# Animation and visual components - NOW EXPORTED
@export var collision_shape: CollisionShape2D
@export var animated_sprite: AnimatedSprite2D
@export var state_label: Label
@export var detection_area: Area2D
@export var interaction_area: Area2D  # This should be your InteractionArea scene

# State Machine Node - Use @export to ensure it's properly assigned
@export var state_machine: AnimalStateMachine

# Interaction area configuration
@export_category("Interaction Settings")
@export var interaction_has_button: bool = true
@export var interaction_show_indicator: bool = true
@export var interaction_auto_trigger: bool = false
@export var interaction_scenario: String = "default"  # default, milk, egg, feed, pet, scare

var current_enclosure: AnimalEnclosure = null

# State variables
var current_speed: float = 0.0
var is_moving: bool = false
var is_running: bool = false
var is_eating: bool = false
var is_sleeping: bool = false
var last_direction: Vector2 = Vector2.DOWN
var target_position: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var production_timer: float = 0.0
var stuck_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO
var escape_attempts: int = 0
var collision_redirect_timer: float = 0.0

var player_reference: Node2D = null

# Signal declarations
signal animal_clicked(animal_name)
signal animal_ready_for_production(animal_name, item_type, position)
signal item_produced(item_name: String, quantity: int, position: Vector2)

func _ready():
	add_to_group("animals")
	
	# Initialize references FIRST
	initialize_references()
	
	# Debug collision info
	print(animal_name + " initialization:")
	print(" - AnimatedSprite: " + str(animated_sprite != null))
	print(" - CollisionShape: " + str(collision_shape != null))
	print(" - StateMachine: " + str(state_machine != null))
	print(" - MovementSpeed: " + str(movement_speed))
	
	# Configure interaction area
	setup_interaction_area()
	
	# Initialize animal properties
	current_speed = movement_speed
	randomize()
	
	# Set initial target position
	target_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	last_position = global_position
	
	print(animal_name + " initialized at: " + str(global_position))
	print(animal_name + " initial target: " + str(target_position))

func initialize_references():
	# Only initialize if not already set via export
	if not animated_sprite:
		animated_sprite = $AnimatedSprite2D
	
	if not state_label and has_node("StateLabel"):
		state_label = $StateLabel
	
	if not detection_area:
		detection_area = $DetectionArea
	
	if not interaction_area:
		interaction_area = $InteractionArea
	
	if not collision_shape and has_node("CollisionShape2D"):
		collision_shape = $CollisionShape2D

func is_in_state(state_names: Array) -> bool:
	if not state_machine or not state_machine.current_state:
		return false
	
	var current_state_name = state_machine.current_state.get_state_name()
	return state_names.has(current_state_name)

func setup_interaction_area():
	if interaction_area:
		# Configure the interaction area based on animal type and behavior
		var scenario = determine_interaction_scenario()
		interaction_area.set_scenario(scenario)
		interaction_area.set_has_button(interaction_has_button)
		interaction_area.set_show_indicator(interaction_show_indicator)
		interaction_area.auto_trigger = interaction_auto_trigger
		
		# Connect to interaction area signals
		if not interaction_area.interaction_triggered.is_connected(_on_interaction_triggered):
			interaction_area.interaction_triggered.connect(_on_interaction_triggered)
		if not interaction_area.button_pressed.is_connected(_on_interaction_button_pressed):
			interaction_area.button_pressed.connect(_on_interaction_button_pressed)
		if not interaction_area.player_entered_range.is_connected(_on_player_entered_interaction_range):
			interaction_area.player_entered_range.connect(_on_player_entered_interaction_range)
		if not interaction_area.player_exited_range.is_connected(_on_player_exited_interaction_range):
			interaction_area.player_exited_range.connect(_on_player_exited_interaction_range)
		
		# DEBUG: Print interaction configuration
		print(animal_name + " interaction area configured:")
		print(" - Scenario: " + scenario)
		print(" - Has Button: " + str(interaction_has_button))
		print(" - Auto Trigger: " + str(interaction_auto_trigger))
		print(" - Show Indicator: " + str(interaction_show_indicator))
	else:
		print("ERROR: No interaction area found for " + animal_name)

func _on_interaction_triggered(player: Node2D):
	print("Interaction triggered with " + animal_name)
	player_reference = player
	
	# Handle auto-triggered interactions
	if interaction_auto_trigger:
		handle_auto_interaction(player)

func _on_interaction_button_pressed(player: Node2D):
	print("Interaction button pressed for " + animal_name)
	player_reference = player
	handle_button_interaction(player)

func _on_player_entered_interaction_range(player: Node2D):
	print("Player entered interaction range of " + animal_name)
	player_reference = player
	
	# Auto-trigger if configured and animal is scared
	if interaction_auto_trigger and is_scared_of_player:
		print("Auto-triggering flee for scared animal")
		start_fleeing(player)

func _on_player_exited_interaction_range(player: Node2D):
	print("Player exited interaction range of " + animal_name)
	if player == player_reference:
		player_reference = null

func handle_auto_interaction(player: Node2D):
	# Handle interactions that happen automatically when player enters range
	print(animal_name + " auto-interaction triggered with player")
	
	if is_scared_of_player:
		print(animal_name + " is scared! Starting to flee...")
		start_fleeing(player)
	else:
		# Default auto-interaction behavior
		print(animal_name + " noticed player")

func handle_button_interaction(player: Node2D):
	player_reference = player
	print(animal_name + " button interaction handled")
	
	# Handle different interaction types based on scenario
	match determine_interaction_scenario():
		"milk":
			handle_milk_interaction()
		"egg":
			handle_egg_interaction()
		"feed":
			handle_feed_interaction()
		"pet":
			handle_pet_interaction()
		"scare":
			handle_scare_interaction()
		_:
			handle_default_interaction()

func handle_milk_interaction() -> bool:
	print("Base milk interaction - override in child classes")
	return false

func handle_egg_interaction() -> bool:
	print("Base egg interaction - override in child classes")
	return false

# BaseAnimal.gd

func can_produce() -> bool:
	# SIMPLIFIED: Only check if the animal produces an item
	return produces_item != ""

func handle_custom_interaction() -> bool:
	# Default implementation - child classes should override
	return false

func handle_feed_interaction():
	print("Base feed interaction")
	feed(25)

func handle_pet_interaction():
	print("Base pet interaction")
	pet()

func handle_scare_interaction():
	print("Base scare interaction")
	if is_scared_of_player and player_reference:
		start_fleeing(player_reference)

func handle_default_interaction():
	print("Base default interaction")
	if is_friendly_to_player:
		pet()
	else:
		print(animal_name + " ignores the interaction")

func determine_interaction_scenario() -> String:
	# Determine the appropriate interaction scenario based on animal properties
	if interaction_scenario != "default":
		return interaction_scenario
	
	if produces_item != "":
		match produces_item:
			"Milk":
				return "Milk"
			"Egg":
				return "Egg"
	
	if is_scared_of_player:
		return "scare"
	elif is_friendly_to_player:
		return "pet"
	else:
		return "default"

func _process(delta):
	# Base animal process logic
	pass

func _physics_process(delta):
	# Update timers
	update_timers(delta)
	
	# Reset velocity at the start of each physics frame
	velocity = Vector2.ZERO
	
	# Check for player proximity during sleep/eating to interrupt
	check_player_proximity_interruption()
	
	if is_scared_of_player:
		check_for_nearby_players()

	# Update current state - FIX: Call state machine updates BEFORE applying movement
	if state_machine:
		state_machine.update(delta)
		state_machine.physics_update(delta)
	
	# Apply separation force from other animals
	var separation = calculate_separation_force()
	velocity += separation * separation_force
	
	# FIX: Only move if we have velocity and are supposed to be moving
	if velocity != Vector2.ZERO and is_moving:
		var collision = move_and_slide()
		
		# FIX: Handle collisions by redirecting if stuck
		if get_slide_collision_count() > 0:
			handle_collision_redirect()
	
	# Update animation and collision shape rotation
	update_animation()
	update_collision_shape_rotation()
	
	# Check if stuck
	check_if_stuck(delta)

func handle_collision_redirect():
	if collision_redirect_timer > 0:
		return
	
	# Find a new direction away from collision
	var collision = get_slide_collision(0)
	if collision:
		var normal = collision.get_normal()
		var new_direction = last_direction.bounce(normal).normalized()
		
		# Set new target position in the new direction
		target_position = global_position + new_direction * 100.0
		last_direction = new_direction
		
		collision_redirect_timer = 1.0  # Prevent rapid redirection
		print(animal_name + " redirected due to collision")

func check_for_nearby_players():
	# Don't check if already fleeing or state machine not ready
	if not state_machine or state_machine.current_state is FleeState:
		return
	
	# Look for players in the detection area or nearby
	var players = get_tree().get_nodes_in_group("player")
	var closest_player = null
	var closest_distance = detection_range
	
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player = player
	
	# If player is close enough and we're scared, start fleeing
	if closest_player and closest_distance < detection_range:
		start_fleeing(closest_player)
		print(animal_name + " detected player and started fleeing! Distance: " + str(closest_distance))

func calculate_separation_force() -> Vector2:
	var separation = Vector2.ZERO
	var neighbor_count = 0
	
	# Get all animals in the area
	var animals = get_tree().get_nodes_in_group("animals")
	
	for animal in animals:
		if animal != self and global_position.distance_to(animal.global_position) < separation_radius:
			var away_direction = (global_position - animal.global_position).normalized()
			var distance = global_position.distance_to(animal.global_position)
			separation += away_direction * (1.0 - distance / separation_radius)
			neighbor_count += 1
	
	if neighbor_count > 0:
		separation /= neighbor_count
	
	return separation.normalized()

func check_if_stuck(delta):
	# Only check if we're supposed to be moving
	if not is_moving:
		stuck_timer = 0.0
		last_position = global_position
		return
	
	# Check if we've moved significantly since last frame
	var distance_moved = global_position.distance_to(last_position)
	
	if distance_moved < 2.0:  # Increased threshold for stuck detection
		stuck_timer += delta
	else:
		stuck_timer = 0.0
		last_position = global_position
	
	# If stuck for too long, find new target
	if stuck_timer > 3.0:  # Increased to 3 seconds
		print(animal_name + " is stuck! Finding new target...")
		# Find a completely new position away from current location
		var angle = randf() * 2 * PI
		var distance = randf_range(50, 100)
		target_position = global_position + Vector2(cos(angle), sin(angle)) * distance
		stuck_timer = 0.0
		escape_attempts += 1
		
		# If still stuck after multiple attempts, try a more drastic solution
		if escape_attempts > 3:
			print(animal_name + " is really stuck! Trying teleport...")
			# Small teleport to unstuck
			global_position += Vector2(randf_range(-10, 10), randf_range(-10, 10))
			escape_attempts = 0

func check_player_proximity_interruption():
	# If player is nearby and animal is scared, interrupt current state
	if player_reference and is_scared_of_player and state_machine and state_machine.current_state:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		var state_name = state_machine.current_state.get_state_name()
		
		# If player is too close during eating or sleeping, start fleeing
		if distance_to_player < detection_range * 0.7:
			if state_name == "Eating" or state_name == "Sleeping":
				start_fleeing(player_reference)
				print(animal_name + " was interrupted by player and started fleeing!")

func update_timers(delta):
	# Update wander timer for state changes
	wander_timer -= delta
	
	# DEBUG: Print timer status occasionally
	if randf() < 0.01:  # 1% chance per frame to print debug info
		print(animal_name + " wander_timer: " + str(wander_timer) + 
			  ", production_timer: " + str(production_timer) + 
			  ", State: " + (state_machine.current_state.get_state_name() if state_machine and state_machine.current_state else "None"))
	
	if wander_timer <= 0:
		print(animal_name + " wander timer expired, changing state...")
		change_state_randomly()
	
	# FIX: Update production timer - only if it's greater than 0
	if produces_item != "":
		if production_timer > 0:
			production_timer -= delta
			
			# Check if timer just reached zero
			if production_timer <= 0:
				production_timer = 0.0  # Clamp to zero
				print(animal_name + " production timer reached zero, calling ready_for_production")
				ready_for_production()
		else:
			# Timer is already at or below zero, don't decrement further
			production_timer = 0.0
	
	# Update collision redirect timer
	if collision_redirect_timer > 0:
		collision_redirect_timer -= delta
	
	# Update needs (hunger, happiness) over time
	update_needs(delta)

func update_needs(delta):
	# REMOVED: No more hunger/happiness depletion
	# Only keep health effects if needed for other systems
	pass

# BaseAnimal.gd - Replace the change_state_randomly method
func change_state_randomly():
	if not state_machine or not state_machine.current_state:
		return
	
	var current_state_name = state_machine.current_state.get_state_name()
	
	# Don't change state if fleeing or following
	if current_state_name == "Fleeing!" or current_state_name == "Following":
		return
	
	# Get all possible states
	var possible_states = ["idle", "wander", "eat", "sleep"]
	
	# Remove current state from possibilities to avoid immediate state repetition
	var available_states = []
	for state in possible_states:
		if state != current_state_name:
			available_states.append(state)
	
	# If no available states (shouldn't happen), use all states
	if available_states.size() == 0:
		available_states = possible_states
	
	# Randomly select a new state
	var random_index = randi() % available_states.size()
	var new_state = available_states[random_index]
	
	match new_state:
		"idle":
			state_machine.transition_to("idle")
			wander_timer = randf_range(2.0, 5.0)
			print(animal_name + " randomly changed to idle")
		
		"wander":
			state_machine.transition_to("wander")
			target_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			wander_timer = randf_range(4.0, 8.0)
			print(animal_name + " randomly changed to wander")
		
		"eat":
			if hunger < 25 or randf() < 0.3:  # Only eat if actually hungry
				state_machine.transition_to("eat")
				wander_timer = randf_range(5.0, 10.0)
				print(animal_name + " randomly changed to eat (hungry)")
			else:
				# If not hungry, try another state
				change_state_randomly()
		
		"sleep":
			if happiness < 80 or randf() < 0.3:  # Sleep if unhappy or 30% chance
				state_machine.transition_to("sleep")
				wander_timer = randf_range(8.0, 15.0)
				print(animal_name + " randomly changed to sleep")
			else:
				# Try another state
				change_state_randomly()

func update_animation():
	if not animated_sprite or not state_machine:
		return
	
	var animation_name = ""
	
	# Determine animation based on state
	if state_machine.current_state is SleepState:
		animation_name = "sleep"
	elif state_machine.current_state is EatState:
		animation_name = "eat"
	elif is_moving:
		if is_running:
			animation_name = "run"
		else:
			animation_name = "walk"
	else:
		animation_name = "idle"
	
	# Get direction suffix
	var direction_suffix = get_direction_suffix()
	
	# Try different animation combinations in order of preference
	var animation_attempts = [
		animation_name + direction_suffix,  # walk_down, run_left, etc.
		animation_name,                     # walk, run, idle (no direction)
		"idle" + direction_suffix,          # idle_down, idle_left, etc.
		"idle"                              # final fallback
	]
	
	# Find the first valid animation
	for attempt in animation_attempts:
		if animated_sprite.sprite_frames.has_animation(attempt):
			if animated_sprite.animation != attempt:
				animated_sprite.play(attempt)
			break

func update_collision_shape_rotation():
	if not collision_shape:
		return
	
	# Only rotate if it's a capsule shape
	if collision_shape.shape is CapsuleShape2D:
		var threshold = 0.1
		
		# If not moving significantly, keep current rotation
		if last_direction.length() < threshold and not is_moving:
			return
		
		# Determine if we're moving primarily horizontally or vertically
		var is_moving_horizontal = abs(last_direction.x) > abs(last_direction.y)
		var target_rotation = 0.0
		
		if is_moving_horizontal:
			# Horizontal movement - rotate capsule 90 degrees
			target_rotation = 90.0
		else:
			# Vertical movement - keep capsule vertical (0 degrees)
			target_rotation = 0.0
		
		# Only update if rotation actually changed
		if collision_shape.rotation_degrees != target_rotation:
			collision_shape.rotation_degrees = target_rotation
	else:
		# For CircleShape2D, no rotation needed
		if collision_shape.rotation_degrees != 0:
			collision_shape.rotation_degrees = 0

func get_direction_suffix() -> String:
	# Convert direction vector to string suffix with proper 4-direction handling
	if last_direction == Vector2.ZERO:
		return "_down"  # Default direction when not moving
	
	# FIX: Use a threshold to determine primary direction
	var abs_x = abs(last_direction.x)
	var abs_y = abs(last_direction.y)
	
	# Use a small bias toward horizontal to prevent flickering
	if abs_x > abs_y * 0.8:  # 0.8 bias factor
		# Horizontal movement is dominant
		if last_direction.x > 0:
			return "_right"
		else:
			return "_left"
	else:
		# Vertical movement is dominant
		if last_direction.y > 0:
			return "_down"
		else:
			return "_up"

func update_state_label():
	if state_label and state_machine and state_machine.current_state:
		state_label.text = animal_name + " " + state_machine.current_state.get_state_name()

# Public methods for interaction
func feed(food_value: int = 25):
	hunger = min(max_hunger, hunger + food_value)
	happiness = min(max_happiness, happiness + 10)
	state_machine.transition_to("eat")
	wander_timer = 3.0
	print(animal_name + " was fed!")

func pet():
	happiness = min(max_hunger, happiness + 15)
	print(animal_name + " was petted!")

func start_following(player: Node2D):
	player_reference = player
	state_machine.transition_to("follow")
	print(animal_name + " is now following!")

func start_fleeing(from: Node2D):
	if from and from.is_in_group("player"):
		player_reference = from
		state_machine.transition_to("flee")
		print(animal_name + " is fleeing!")

func ready_for_production():
	if produces_item != "":
		print(animal_name + " is ready to produce " + produces_item + "!")
		production_timer = production_cooldown
		emit_signal("animal_ready_for_production", animal_name, produces_item, global_position)
		
		# Spawn the item
		spawn_item_drop(global_position)

func spawn_item_drop(position: Vector2):
	if produces_item == "":
		return
	
	var item_drop_scene = preload("res://Scenes/World/Environment/Item/Drop/ItemDrop.tscn")
	if item_drop_scene:
		var item_drop = item_drop_scene.instantiate()
		
		item_drop.item_name = produces_item
		item_drop.item_quantity = item_quantity
		item_drop.global_position = position
		
		get_tree().current_scene.add_child(item_drop)
		print(produces_item + " item drop spawned at: ", position)
		
		# Emit signal for item production
		emit_signal("item_produced", produces_item, item_quantity, position)
		
		# Call virtual method for animal-specific behavior
		on_item_produced()
	else:
		print("Error: ItemDrop scene not found!")

func on_item_produced():
	# Override this in child classes for specific behavior
	pass

func take_damage(amount: int):
	health = max(0, health - amount)
	happiness = max(0, happiness - 10)
	if health <= 0:
		die()

func die():
	print(animal_name + " has died!")
	queue_free()

func interrupt_sleep() -> bool:
	if state_machine and state_machine.current_state and state_machine.current_state.get_state_name() == "Sleeping" and is_scared_of_player and player_reference:
		print(animal_name + " was woken up by player interaction!")
		start_fleeing(player_reference)
		return true
	return false

func get_animal_type() -> String:
	return animal_type

func get_animal_name() -> String:
	return animal_name

func set_enclosure(enclosure: AnimalEnclosure):
	if current_enclosure:
		current_enclosure.remove_animal(self)
	
	current_enclosure = enclosure
	if enclosure:
		enclosure.add_animal(self)

func get_enclosure() -> AnimalEnclosure:
	return current_enclosure

func is_in_enclosure() -> bool:
	return current_enclosure != null
