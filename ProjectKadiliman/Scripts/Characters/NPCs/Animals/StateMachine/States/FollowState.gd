# FollowState.gd
class_name FollowState
extends AnimalState

func enter():
	animal.is_moving = true
	animal.is_running = false
	animal.is_eating = false
	animal.is_sleeping = false
	animal.current_speed = animal.movement_speed
	print(animal.animal_name + " started following player!")

func physics_update(delta: float):
	if not animal.player_reference:
		# No player to follow, go back to idle
		animal.state_machine.transition_to("idle")
		return
	
	var follow_direction = (animal.player_reference.global_position - animal.global_position).normalized()
	var distance_to_player = animal.global_position.distance_to(animal.player_reference.global_position)
	
	# Only update last_direction if we're actually moving significantly
	if follow_direction.length() > 0.1:
		animal.last_direction = follow_direction
	
	# FIX: Apply velocity
	animal.velocity = follow_direction * animal.current_speed
	
	# Stop following if close enough to player
	if distance_to_player < 50:
		animal.state_machine.transition_to("idle")
		print(animal.animal_name + " stopped following - close enough to player")

func get_state_name() -> String:
	return "Following"
