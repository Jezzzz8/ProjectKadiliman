# FleeState.gd
class_name FleeState
extends AnimalState

var flee_direction: Vector2 = Vector2.ZERO

func enter():
	animal.is_moving = true
	animal.is_running = true
	animal.is_eating = false
	animal.is_sleeping = false
	animal.current_speed = animal.run_speed
	
	# FIX: Calculate initial flee direction
	if animal.player_reference:
		flee_direction = (animal.global_position - animal.player_reference.global_position).normalized()
		animal.last_direction = flee_direction
		print(animal.animal_name + " started fleeing from player!")

func physics_update(delta: float):
	if not animal.player_reference:
		# No player to flee from, go back to idle
		animal.state_machine.transition_to("idle")
		animal.is_running = false
		animal.current_speed = animal.movement_speed
		return
	
	# FIX: Recalculate flee direction each frame
	flee_direction = (animal.global_position - animal.player_reference.global_position).normalized()
	
	# Only update last_direction if we're actually moving significantly
	if flee_direction.length() > 0.1:
		animal.last_direction = flee_direction
	
	# FIX: Apply velocity
	animal.velocity = flee_direction * animal.current_speed
	
	# If player is far enough, stop fleeing
	var distance_to_player = animal.global_position.distance_to(animal.player_reference.global_position)
	if distance_to_player > 200:
		animal.state_machine.transition_to("idle")
		animal.is_running = false
		animal.current_speed = animal.movement_speed
		print(animal.animal_name + " stopped fleeing - player is far enough")

func get_state_name() -> String:
	return "Fleeing!"
