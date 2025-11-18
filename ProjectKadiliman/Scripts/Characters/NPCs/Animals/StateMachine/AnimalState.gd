# AnimalState.gd
class_name AnimalState
extends Node

var animal: BaseAnimal

# FIX: Remove constructor and use setter instead
func set_animal(animal_ref: BaseAnimal):
	animal = animal_ref

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func get_state_name() -> String:
	return "Unknown"
