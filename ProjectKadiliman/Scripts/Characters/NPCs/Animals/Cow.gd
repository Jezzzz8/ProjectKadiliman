# Cow.gd
extends BaseAnimal

# Cow-specific properties
@export_category("Cow Settings")
@export var cow_name: String = "Cow"
@export var milk_item_name: String = "Milk"
@export var milk_item_quantity: int = 1
@export var graze_time: float = 1.0

# Visual components
@onready var milk_indicator: Sprite2D = $MilkIndicator if has_node("MilkIndicator") else null

func _ready() -> void:
	# Ensure base initialization happens first
	super._ready()
	
	# Cow-specific properties
	animal_name = cow_name
	animal_type = "Livestock"
	produces_item = milk_item_name
	item_quantity = milk_item_quantity
	production_cooldown = 60.0  # Reduced for testing
	
	# Cow-specific behavior
	movement_speed = 30.0
	run_speed = 60.0
	is_scared_of_player = false
	is_friendly_to_player = true
	
	# Set interaction scenario for milking
	interaction_scenario = "milk"
	interaction_has_button = true
	interaction_auto_trigger = false  # Cows need button press to milk
	
	# DEBUG: Force initialize production timer
	production_timer = production_cooldown  # Start ready for production
	
	_setup_milk_indicator()
	
	add_to_group("animals")
	add_to_group("livestock")
	
	_print_debug_info()

func _process(delta: float) -> void:
	super._process(delta)
	_process_cow_behavior()

func _process_cow_behavior() -> void:
	# DEBUG: Print timer status occasionally
	if randf() < 0.01:  # 1% chance per frame
		print("Cow production timer: " + str(production_timer) + ", Can produce: " + str(can_produce()))
	
	# Update milk indicator based on production status
	if milk_indicator:
		var should_show = is_ready_for_milking()
		if milk_indicator.visible != should_show:
			milk_indicator.visible = should_show
			if should_show:
				print(cow_name + " is ready to be milked!")

# Helper method to check if cow is ready for milking
func is_ready_for_milking() -> bool:
	return produces_item != "" and production_timer <= 0 and can_produce()

# Cow-specific production methods - FIXED
func milk_cow() -> bool:
	print("=== MILK COW CALLED ===")
	print("Production Timer: " + str(production_timer))
	print("Can Produce: " + str(can_produce()))
	
	if can_produce() and production_timer <= 0:
		print(cow_name + " is being milked!")
		spawn_item_drop(global_position)
		
		# Reset production timer
		production_timer = production_cooldown
		print("Reset production timer to: " + str(production_timer))
		
		# Update visual indicator
		if milk_indicator:
			milk_indicator.visible = false
		
		# Cow reaction to being milked
		moo()
		
		return true
	else:
		print(cow_name + " is not ready to be milked!")
		_print_milking_status()
		return false

# Cow-specific methods
func moo() -> void:
	print("Moo!")
	# Add cow sound here

func moo_softly() -> void:
	print("Moo... (softly)")
	# Add soft cow sound here

func moo_loudly() -> void:
	print("MOO! (loudly)")
	# Add loud cow sound here

func graze() -> void:
	if state_machine:
		state_machine.transition_to("eat")
	wander_timer = graze_time
	print(cow_name + " is grazing...")

func lie_down() -> void:
	if state_machine:
		state_machine.transition_to("sleep")
	wander_timer = randf_range(8.0, 15.0)
	print(cow_name + " is lying down...")

# Override virtual methods
func handle_milk_interaction() -> bool:
	print("Attempting to milk " + animal_name)
	var result: bool = milk_cow()
	print("Milking result: " + str(result))
	return result

func handle_egg_interaction() -> bool:
	print("Cows don't lay eggs!")
	return false

func handle_custom_interaction() -> bool:
	# Cow-specific interaction logic
	if not is_scared_of_player:
		moo_softly()
		pet()
	else:
		start_fleeing(player_reference)
	
	return true

# Cow.gd

func can_produce() -> bool:
	# SIMPLIFIED: Just use the base can_produce
	return super.can_produce()

# Override production method
func on_item_produced() -> void:
	moo()
	print("Cow '" + animal_name + "' produced milk!")
	# Add cow-specific milk production effects here

# Override base methods for cow-specific behavior
func start_fleeing(from: Node2D) -> void:
	super.start_fleeing(from)
	moo_loudly()  # Cow moos loudly when scared

func feed(food_value: int = 30) -> void:
	super.feed(food_value)
	moo()  # Happy moo when fed

func pet() -> void:
	super.pet()
	moo_softly()  # Content moo when petted

func force_milk_production() -> bool:
	if can_produce():
		ready_for_production()
		return true
	return false

# FIX: Override ready_for_production for cows
func ready_for_production() -> void:
	if produces_item != "":
		print(animal_name + " is ready to produce " + produces_item + "!")
		production_timer = 0.0
		emit_signal("animal_ready_for_production", animal_name, produces_item, global_position)
		
		# Show milk indicator
		if milk_indicator:
			milk_indicator.visible = true
		moo()

# FIX: Add method that InteractionArea expects
func force_lay_egg() -> bool:
	print("Cows don't lay eggs!")
	return false

# Interaction handler methods
func handle_feed_interaction() -> void:
	print("Feeding " + animal_name)
	feed(30)

func handle_pet_interaction() -> void:
	print("Petting " + animal_name)
	pet()

func handle_scare_interaction() -> void:
	print("Scaring " + animal_name)
	if is_scared_of_player and player_reference:
		start_fleeing(player_reference)

func handle_default_interaction() -> void:
	print("Interacting with " + animal_name)
	moo_softly()

# Helper methods
func _setup_milk_indicator() -> void:
	if milk_indicator:
		milk_indicator.visible = false

func _print_debug_info() -> void:
	print("Cow '" + cow_name + "' fully initialized!")
	print(" - Interaction scenario: " + interaction_scenario)
	print(" - Produces: " + produces_item)
	print(" - Production Cooldown: " + str(production_cooldown))
	print(" - Production Timer: " + str(production_timer))

func _print_milking_status() -> void:
	print("=== MILKING STATUS ===")
	print(" - Production Timer: " + str(production_timer))
	print(" - Can produce: " + str(can_produce()))
	print("====================")
