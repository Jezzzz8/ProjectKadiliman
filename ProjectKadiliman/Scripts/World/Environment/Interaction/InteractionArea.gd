# InteractionArea.gd
extends Area2D

@export_category("Interaction Settings")
@export var has_button: bool = true
@export var show_indicator: bool = true
@export var interaction_range: float = 100.0
@export var auto_trigger: bool = false  # Automatically trigger when player enters

@export_category("Visual Settings")
@export var indicator_text: String = "Interact"
@export var indicator_offset: Vector2 = Vector2(0, -50)
@export var indicator_color: Color = Color.WHITE

@export_category("Interaction Scenarios")
@export var scenario_type: String = "default"  # default, milk, egg, feed, pet, scare

# Signals
signal player_entered_range(player: Node2D)
signal player_exited_range(player: Node2D)
signal interaction_triggered(player: Node2D)
signal button_pressed(player: Node2D)

# References
var current_player: Node2D = null
var interaction_indicator: Control = null
var is_player_in_range: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision shape if it exists
	if collision_shape:
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = interaction_range * 0.5
		elif collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size = Vector2(interaction_range, interaction_range)
	
	# Create interaction indicator if needed
	if show_indicator and has_button:
		create_interaction_indicator()
	
	print("AnimalInteractionArea initialized - Scenario: %s, Has Button: %s" % [scenario_type, has_button])

func _input(event: InputEvent):
	if not is_player_in_range or not current_player:
		return
	
	# Handle button press interaction
	if has_button and event.is_action_pressed("interact"):  # You can map this to your input
		handle_button_press()
	
	# Auto-trigger when player enters range
	if auto_trigger and not has_button:
		handle_auto_interaction()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		current_player = body
		is_player_in_range = true
		player_entered_range.emit(body)
		
		print("Player entered interaction range - Scenario: %s, Auto-trigger: %s" % [scenario_type, auto_trigger])
		
		# Show indicator if available
		if interaction_indicator:
			interaction_indicator.visible = true
		
		# Auto-trigger if configured - FIXED LOGIC
		if auto_trigger:
			call_deferred("handle_auto_interaction")

func _on_body_exited(body: Node2D):
	if body.is_in_group("player") and body == current_player:
		player_exited_range.emit(body)
		is_player_in_range = false
		current_player = null
		
		print("Player exited interaction range")
		
		# Hide indicator
		if interaction_indicator:
			interaction_indicator.visible = false

func handle_button_press():
	if not current_player or not is_player_in_range:
		return
	
	print("Interaction button pressed - Scenario: %s" % scenario_type)
	button_pressed.emit(current_player)
	
	# Handle different scenarios
	match scenario_type:
		"milk":
			handle_milk_scenario()
		"egg":
			handle_egg_scenario()
		"feed":
			handle_feed_scenario()
		"pet":
			handle_pet_scenario()
		"scare":
			handle_scare_scenario()
		"default":
			handle_default_scenario()
	
	interaction_triggered.emit(current_player)

func handle_auto_interaction():
	if not current_player or not is_player_in_range:
		return
	
	print("Auto-interaction triggered - Scenario: %s" % scenario_type)
	interaction_triggered.emit(current_player)
	
	# Handle different scenarios for auto-interaction
	match scenario_type:
		"scare":
			handle_scare_scenario()
		"default":
			handle_default_scenario()

func create_interaction_indicator():
	# Create a simple indicator (you can replace this with your own UI)
	interaction_indicator = Label.new()
	interaction_indicator.text = "[F] " + indicator_text  # Assuming 'F' is your interact key
	interaction_indicator.label_settings = LabelSettings.new()
	interaction_indicator.label_settings.font_color = indicator_color
	interaction_indicator.label_settings.font_size = 16
	interaction_indicator.position = indicator_offset
	interaction_indicator.visible = false
	interaction_indicator.z_index = 100  # Make sure it's on top
	
	add_child(interaction_indicator)

# Scenario Handlers - You can customize these based on your needs
func handle_milk_scenario():
	print("Milk scenario triggered for ", get_animal_reference())
	var animal = get_animal_reference()
	if animal:
		if animal.has_method("milk_cow"):
			var result = animal.milk_cow()
			print("Milking result: ", result)
		elif animal.has_method("handle_milk_interaction"):
			var result = animal.handle_milk_interaction()
			print("Milk interaction result: ", result)
		else:
			print("Animal cannot be milked: ", animal.get_animal_name())
	else:
		print("No animal found for milking")

func handle_egg_scenario():
	print("Egg scenario triggered")
	var animal = get_animal_reference()
	if animal:
		if animal.has_method("force_lay_egg"):
			var result = animal.force_lay_egg()
			print("Egg laying result: ", result)
		elif animal.has_method("handle_egg_interaction"):
			var result = animal.handle_egg_interaction()
			print("Egg interaction result: ", result)
		else:
			print("Animal cannot lay eggs: ", animal.get_animal_name())
	else:
		print("No animal found for egg collection")

func handle_feed_scenario():
	print("Feed scenario triggered")
	var animal = get_animal_reference()
	if animal:
		if animal.has_method("handle_feed_interaction"):
			animal.handle_feed_interaction()
		elif animal.has_method("feed"):
			animal.feed(25)
		else:
			print("Animal cannot be fed: ", animal.get_animal_name())
	else:
		print("No animal found for feeding")

func handle_pet_scenario():
	print("Pet scenario triggered")
	var animal = get_animal_reference()
	if animal:
		if animal.has_method("handle_pet_interaction"):
			animal.handle_pet_interaction()
		elif animal.has_method("pet"):
			animal.pet()
		else:
			print("Animal cannot be petted: ", animal.get_animal_name())
	else:
		print("No animal found for petting")

func handle_scare_scenario():
	print("Scare scenario triggered")
	var animal = get_animal_reference()
	if animal:
		if animal.has_method("handle_scare_interaction"):
			animal.handle_scare_interaction()
		elif animal.has_method("start_fleeing") and current_player:
			animal.start_fleeing(current_player)
		else:
			print("Animal cannot be scared: ", animal.get_animal_name())
	else:
		print("No animal found for scaring")

func handle_default_scenario():
	print("Default interaction triggered")
	var animal = get_animal_reference()
	if animal and animal.has_method("get_animal_name"):
		print("Interacting with: " + animal.get_animal_name())
	else:
		print("Interaction failed")

func get_animal_reference() -> Node:
	# Method 1: Direct parent (most common)
	var parent = get_parent()
	if parent and parent.has_method("get_animal_name"):
		return parent
	
	# Method 2: Look in owner
	if owner and owner.has_method("get_animal_name"):
		return owner
	
	# Method 3: Look for animal in proximity
	var animals = get_tree().get_nodes_in_group("animals")
	var closest_animal = null
	var closest_distance = 50.0  # Increased range
	
	for animal in animals:
		var distance = global_position.distance_to(animal.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_animal = animal
	
	if closest_animal:
		return closest_animal
	
	# Method 4: Check if parent's parent is animal (for nested scenes)
	if get_parent() and get_parent().get_parent():
		var grandparent = get_parent().get_parent()
		if grandparent and grandparent.has_method("get_animal_name"):
			return grandparent
	
	print("No animal reference found for interaction area")
	return null

# Public methods to configure the interaction area dynamically
func set_scenario(new_scenario: String):
	scenario_type = new_scenario
	update_indicator_text()

func set_has_button(button_enabled: bool):
	has_button = button_enabled
	if interaction_indicator:
		interaction_indicator.visible = button_enabled and is_player_in_range

func set_show_indicator(show: bool):
	show_indicator = show
	if interaction_indicator:
		interaction_indicator.visible = show and is_player_in_range and has_button

func update_indicator_text():
	if interaction_indicator:
		match scenario_type:
			"milk":
				indicator_text = "Milk"
			"egg":
				indicator_text = "Collect Egg"
			"feed":
				indicator_text = "Feed"
			"pet":
				indicator_text = "Pet"
			"scare":
				indicator_text = "Scare"
			_:
				indicator_text = "Interact"
		
		interaction_indicator.text = "[F] " + indicator_text

# Method to manually trigger interaction (useful for UI buttons)
func trigger_interaction():
	if current_player:
		handle_button_press()

# Debug function
func print_interaction_status():
	print("=== Animal Interaction Area Status ===")
	print("Scenario Type: ", scenario_type)
	print("Has Button: ", has_button)
	print("Show Indicator: ", show_indicator)
	print("Auto Trigger: ", auto_trigger)
	print("Player in Range: ", is_player_in_range)
	print("Current Player: ", current_player.get_animal_name() if current_player and current_player.has_method("get_animal_name") else "None")
	print("================================")

func _on_interaction_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_player_in_range and current_player:
			handle_button_press()
