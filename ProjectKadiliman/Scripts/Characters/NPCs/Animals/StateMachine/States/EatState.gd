class_name EatState
extends AnimalState

func enter():
	animal.is_moving = false
	animal.is_eating = true
	animal.is_sleeping = false
	animal.is_running = false
	animal.current_speed = 0

func update(delta: float):
	animal.hunger = min(animal.max_hunger, animal.hunger + delta * 5)

func get_state_name() -> String:
	return "Eating"
