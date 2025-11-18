# AnimalStateMachine.gd
class_name AnimalStateMachine
extends Node

var states: Dictionary = {}
var current_state: AnimalState
var animal: BaseAnimal

func _ready():
	# Wait until next frame to ensure animal is fully initialized
	call_deferred("setup_states")

func setup_states():
	# Get the animal reference from parent
	animal = get_parent() as BaseAnimal
	if not animal:
		push_error("AnimalStateMachine: No animal parent found!")
		return
	
	print("Setting up state machine for: " + animal.animal_name)
	
	# Create all state instances
	states["idle"] = IdleState.new()
	states["wander"] = WanderState.new()
	states["eat"] = EatState.new()
	states["sleep"] = SleepState.new()
	states["flee"] = FleeState.new()
	states["follow"] = FollowState.new()
	
	# Initialize states with animal reference
	for state_name in states:
		var state = states[state_name]
		state.animal = animal
		add_child(state)
		print(" - Added state: " + state_name)
	
	# Start with wander state to ensure movement works
	transition_to("wander")
	print(animal.animal_name + " state machine ready with " + str(states.size()) + " states!")

func transition_to(state_name: String):
	if not states.has(state_name):
		push_error("State '" + state_name + "' doesn't exist in: " + str(states.keys()))
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter()
	
	if animal:
		animal.update_state_label()
		print(animal.animal_name + " transitioned to: " + state_name)

func update(delta: float):
	if current_state:
		current_state.update(delta)

func physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func get_current_state_name() -> String:
	if current_state:
		return current_state.get_state_name()
	return "None"
