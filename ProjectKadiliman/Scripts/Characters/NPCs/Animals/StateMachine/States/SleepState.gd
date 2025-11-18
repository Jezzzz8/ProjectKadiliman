class_name SleepState
extends AnimalState

func enter():
	animal.is_moving = false
	animal.is_eating = false
	animal.is_sleeping = true
	animal.is_running = false
	animal.current_speed = 0

func update(delta: float):
	animal.health = min(animal.max_health, animal.health + delta * 1)
	animal.happiness = min(animal.max_happiness, animal.happiness + delta * 2)

func get_state_name() -> String:
	return "Sleeping"
