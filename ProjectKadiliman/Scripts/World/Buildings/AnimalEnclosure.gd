# Barn.gd
class_name AnimalEnclosure
extends Area2D

# Configuration
@export var enclosure_name: String = "Barn"
@export var max_animals: int = 4
@export var allowed_animal_types: Array[String] = ["Livestock", "Poultry"]  # Animal types allowed
@export var sprite_texture: Texture2D

# Runtime data
var current_animals: Array[Node] = []
var is_full: bool = false

# Visual components
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal animal_added(animal: Node, enclosure: AnimalEnclosure)
signal animal_removed(animal: Node, enclosure: AnimalEnclosure)
signal enclosure_full(enclosure: AnimalEnclosure)
signal enclosure_has_space(enclosure: AnimalEnclosure)

func _ready():
	add_to_group("enclosures")
	
	setup_enclosure()
	area_entered.connect(_on_animal_entered)
	area_exited.connect(_on_animal_exited)
	
	if sprite and sprite_texture:
		sprite.texture = sprite_texture

func setup_enclosure():
	update_display()

func update_display():
	if label:
		label.text = "%s\n%d/%d" % [enclosure_name, current_animals.size(), max_animals]

# Check if animal can be added to this enclosure
func can_accommodate_animal(animal: Node) -> bool:
	var is_full_check = current_animals.size() < max_animals
	var type_allowed = is_animal_type_allowed(animal)
	var result = is_full_check and type_allowed
	
	print("DEBUG: %s.can_accommodate_animal(%s) = %s (space: %d/%d, type_allowed: %s)" % [
		enclosure_name,
		animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown",
		result,
		current_animals.size(),
		max_animals,
		type_allowed
	])
	
	return result

func is_animal_type_allowed(animal: Node) -> bool:
	if animal.has_method("get_animal_type"):
		var animal_type = animal.get_animal_type()
		return animal_type in allowed_animal_types
	return false

func add_animal(animal: Node) -> bool:
	var result = can_accommodate_animal(animal) and not current_animals.has(animal)
	
	if result:
		current_animals.append(animal)
		update_enclosure_state()
		animal_added.emit(animal, self)
		print("SUCCESS: %s added to %s" % [
			animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown",
			enclosure_name
		])
	else:
		print("FAILED: Could not add %s to %s" % [
			animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown",
			enclosure_name
		])
	
	return result

func remove_animal(animal: Node) -> bool:
	if current_animals.has(animal):
		current_animals.erase(animal)
		update_enclosure_state()
		animal_removed.emit(animal, self)
		return true
	return false

func update_enclosure_state():
	is_full = current_animals.size() >= max_animals
	update_display()
	
	if is_full:
		enclosure_full.emit(self)
	else:
		enclosure_has_space.emit(self)

func get_available_space() -> int:
	return max_animals - current_animals.size()

func get_animal_count() -> int:
	return current_animals.size()

func get_animal_list() -> Array:
	return current_animals.duplicate()

func _on_animal_entered(area: Area2D):
	# Try to get the animal node - this depends on your scene structure
	var animal = area.get_parent()
	if animal and animal.is_in_group("animals"):
		if can_accommodate_animal(animal):
			add_animal(animal)
	else:
		# Also check if the body itself is an animal
		animal = area
		if animal and animal.is_in_group("animals"):
			if can_accommodate_animal(animal):
				add_animal(animal)

func _on_animal_exited(area: Area2D):
	var animal = area.get_parent()
	if animal and animal.is_in_group("animals"):
		remove_animal(animal)
	else:
		animal = area
		if animal and animal.is_in_group("animals"):
			remove_animal(animal)

# Debug function
func print_enclosure_status():
	print("=== %s Status ===" % enclosure_name)
	print("Animals: %d/%d" % [current_animals.size(), max_animals])
	print("Full: %s" % is_full)
	print("Allowed Types: %s" % allowed_animal_types)
	print("Current Animals:")
	for animal in current_animals:
		if animal.has_method("get_animal_name"):
			print("  - %s (%s)" % [animal.get_animal_name(), animal.get_animal_type()])
	print("=================")
