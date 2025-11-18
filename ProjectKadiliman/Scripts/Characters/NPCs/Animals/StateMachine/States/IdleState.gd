# IdleState.gd
class_name IdleState
extends AnimalState

func enter():
	if animal:
		animal.is_moving = false
		animal.is_eating = false
		animal.is_sleeping = false
		animal.is_running = false
		animal.current_speed = 0
		print(animal.animal_name + " is idling")

func update(delta: float):
	if not animal:
		return
	
	# After idling for a bit, wander
	if animal.wander_timer <= 0:
		animal.change_state_randomly()

func get_state_name() -> String:
	return "Idle"
