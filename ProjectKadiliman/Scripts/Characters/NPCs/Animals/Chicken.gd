# Chicken.gd
extends BaseAnimal

# Chicken-specific properties
@export_category("Chicken Settings")
@export var chicken_name: String = "Chicken"
@export var egg_item_name: String = "Egg"
@export var egg_item_quantity: int = 1
@export var peck_frequency: float = 5.0

# Chicken behavior
var peck_timer: float = 0.0

func _ready() -> void:
	# Ensure base initialization happens first
	super._ready()
	
	# Chicken-specific properties
	animal_name = chicken_name
	animal_type = "Poultry"
	produces_item = egg_item_name
	item_quantity = egg_item_quantity
	production_cooldown = 30.0  # Reduced for testing
	
	# Chicken-specific behavior
	movement_speed = 50.0
	run_speed = 60.0
	is_scared_of_player = true
	
	# FIX: Change interaction scenario to "egg" for auto-production
	interaction_scenario = "egg"  # Changed from "scare" to "egg"
	interaction_has_button = false  # No button needed for auto-production
	interaction_auto_trigger = true  # Auto-produce when ready
	
	# FIX: Initialize production timer to start producing immediately
	production_timer = production_cooldown
	
	add_to_group("animals")
	add_to_group("poultry")
	
	_print_debug_info()

func _process(delta: float) -> void:
	super._process(delta)
	_process_chicken_behavior(delta)

func _process_chicken_behavior(delta: float) -> void:
	peck_timer -= delta
	if peck_timer <= 0 and _is_in_wandering_state():
		if randf() < 0.3:  # 30% chance to peck while wandering
			peck()
		peck_timer = peck_frequency

func _is_in_wandering_state() -> bool:
	return state_machine and state_machine.current_state and \
		   state_machine.current_state.get_state_name() == "Wandering"

# Chicken-specific methods
func cluck() -> void:
	print("Cluck cluck!")
	# Add chicken sound here

func peck() -> void:
	print(chicken_name + " is pecking at the ground!")
	if state_machine:
		state_machine.transition_to("eat")
	wander_timer = 2.0

# Override animation for chicken-specific behaviors
func update_animation() -> void:
	if _should_play_peck_animation():
		return
	
	# Fall back to base animation
	super.update_animation()

func _should_play_peck_animation() -> bool:
	if not (state_machine and state_machine.current_state and animated_sprite):
		return false
	
	var state_name: String = state_machine.current_state.get_state_name()
	return state_name == "Eating" and animated_sprite.sprite_frames.has_animation("peck")

# Override virtual methods
func handle_egg_interaction() -> bool:
	print("Attempting to collect egg from " + animal_name)
	if can_produce() and production_timer <= 0:
		var result: bool = force_lay_egg()
		print("Egg collection result: " + str(result))
		return result
	else:
		_print_cannot_produce_reason()
		return false

func handle_custom_interaction() -> bool:
	# Chicken-specific interaction logic
	if is_scared_of_player and player_reference:
		start_fleeing(player_reference)
	
	cluck()  # Always cluck when interacted with
	return true

func can_produce() -> bool:
	return super.can_produce()

# Override production method
func on_item_produced() -> void:
	cluck()
	print("Chicken '" + animal_name + "' laid an egg!")
	# Add chicken-specific egg laying effects here

# Override base methods for chicken-specific behavior
func start_fleeing(from: Node2D) -> void:
	super.start_fleeing(from)
	cluck()  # Chicken clucks when scared

func feed(food_value: int = 25) -> void:
	super.feed(food_value)
	cluck()  # Happy cluck when fed

func pet() -> void:
	super.pet()
	cluck()  # Content cluck when petted

func force_lay_egg() -> bool:
	if can_produce():
		print("Chicken force laying egg")
		ready_for_production()
		return true
	return false

# FIX: Override ready_for_production for chickens (they auto-produce)
func ready_for_production():
	if produces_item != "":
		print(animal_name + " is ready to produce " + produces_item + "!")
		production_timer = production_cooldown
		emit_signal("animal_ready_for_production", animal_name, produces_item, global_position)
		
		# Chickens auto-produce eggs (no interaction needed)
		spawn_item_drop(global_position)
		print("Chicken auto-produced an egg!")

# FIX: Add methods that InteractionArea expects
func milk_cow() -> bool:
	print("Chickens don't produce milk!")
	return false

# Interaction handler methods
func handle_milk_interaction() -> bool:
	print("Chickens don't produce milk!")
	return false

func handle_feed_interaction() -> void:
	print("Feeding " + animal_name)
	feed(25)

func handle_pet_interaction() -> void:
	print("Petting " + animal_name)
	pet()

func handle_scare_interaction() -> void:
	print("Scaring " + animal_name)
	if is_scared_of_player and player_reference:
		start_fleeing(player_reference)

func handle_default_interaction() -> void:
	print("Interacting with " + animal_name)
	cluck()

# Helper methods
func _print_debug_info() -> void:
	print("Chicken '" + chicken_name + "' fully initialized!")
	print(" - Scared of player: " + str(is_scared_of_player))
	print(" - Auto-trigger: " + str(interaction_auto_trigger))
	print(" - Produces: " + produces_item)
	print(" - Production Cooldown: " + str(production_cooldown))
	print(" - Production Timer: " + str(production_timer))

func _print_cannot_produce_reason() -> void:
	print("Chicken cannot produce eggs right now")
	print(" - Production Timer: " + str(production_timer))
	print(" - Can produce: " + str(can_produce()))
