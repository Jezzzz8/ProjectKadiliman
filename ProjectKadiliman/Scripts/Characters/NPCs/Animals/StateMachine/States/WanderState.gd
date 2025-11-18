# WanderState.gd
class_name WanderState
extends AnimalState

var wander_target_reached: bool = false

func enter():
	if not animal:
		return
		
	animal.is_moving = true
	animal.is_eating = false
	animal.is_sleeping = false
	animal.is_running = false
	animal.current_speed = animal.movement_speed
	
	# Set a new target position away from current position
	var random_angle = randf() * 2 * PI
	var random_distance = randf_range(50, 150)
	var random_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	animal.target_position = animal.global_position + random_offset
	wander_target_reached = false
	
	print(animal.animal_name + " started wandering to: " + str(animal.target_position) + 
		  " from: " + str(animal.global_position))

func physics_update(delta: float):
	if not animal or wander_target_reached:
		return
	
	# Calculate direction to target
	var direction = (animal.target_position - animal.global_position).normalized()
	var distance_to_target = animal.global_position.distance_to(animal.target_position)
	
	# Update direction for animation
	if direction.length() > 0.1:
		animal.last_direction = direction
	
	# Apply movement
	animal.velocity = direction * animal.current_speed
	
	# Check if we've reached the target
	if distance_to_target < 15.0:
		wander_target_reached = true
		animal.state_machine.transition_to("idle")
		animal.wander_timer = randf_range(2.0, 5.0)
		print(animal.animal_name + " reached wander target after moving " + str(distance_to_target) + " units")

func exit():
	wander_target_reached = false

func get_state_name() -> String:
	return "Wandering"
