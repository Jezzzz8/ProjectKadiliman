# FarmManager.gd
extends Node

@export_category("Farm Settings")
@export var max_total_animals: int = 20
@export var auto_assign_on_animal_added: bool = true
@export var reassignment_cooldown: float = 5.0  # Seconds between auto-assignments

var all_enclosures: Array[AnimalEnclosure] = []
var all_animals: Array[Node] = []
var reassignment_timer: float = 0.0
var is_initialized: bool = false

signal animal_count_changed(current: int, max_allowed: int)
signal enclosure_added(enclosure: AnimalEnclosure)
signal enclosure_removed(enclosure: AnimalEnclosure)
signal animal_assigned(animal: Node, enclosure: AnimalEnclosure)
signal assignment_failed(animal: Node)

func _ready():
	# Wait two frames for everything to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("=== FarmManager Initializing ===")
	collect_existing_enclosures()
	collect_existing_animals()
	is_initialized = true
	
	# Auto-assign any homeless animals after initialization
	if get_homeless_animals().size() > 0:
		auto_assign_animals_to_enclosures()
	
	print("Initialization Complete - Animals: %d, Enclosures: %d" % [all_animals.size(), all_enclosures.size()])

func _process(delta):
	if reassignment_timer > 0:
		reassignment_timer -= delta
		if reassignment_timer <= 0 and get_homeless_animals().size() > 0:
			auto_assign_animals_to_enclosures()

func collect_existing_enclosures():
	all_enclosures.clear()
	var enclosure_nodes = get_tree().get_nodes_in_group("enclosures")
	print("Found %d nodes in 'enclosures' group" % enclosure_nodes.size())
	
	for i in range(enclosure_nodes.size()):
		var node = enclosure_nodes[i]
		if node is AnimalEnclosure:
			if not all_enclosures.has(node):
				all_enclosures.append(node)
				enclosure_added.emit(node)
				print("Enclosure %d: %s (Max: %d, Types: %s)" % [i, node.enclosure_name, node.max_animals, node.allowed_animal_types])
		else:
			print("WARNING: Node %s in 'enclosures' group is not AnimalEnclosure" % node.name)

func collect_existing_animals():
	var animal_nodes = get_tree().get_nodes_in_group("animals")
	print("Found %d nodes in 'animals' group" % animal_nodes.size())
	
	all_animals.clear()
	for i in range(animal_nodes.size()):
		var animal = animal_nodes[i]
		if not all_animals.has(animal):
			all_animals.append(animal)
			
			var animal_name = "Unknown"
			var animal_type = "Unknown"
			
			if animal.has_method("get_animal_name"):
				animal_name = animal.get_animal_name()
			if animal.has_method("get_animal_type"):
				animal_type = animal.get_animal_type()
				
			print("Animal %d: %s (Type: %s)" % [i, animal_name, animal_type])
	
	update_animal_count()

func register_enclosure(enclosure: AnimalEnclosure):
	if not all_enclosures.has(enclosure):
		all_enclosures.append(enclosure)
		enclosure_added.emit(enclosure)
		print("New enclosure registered: %s" % enclosure.enclosure_name)
		
		# Try to assign homeless animals to new enclosure
		if is_initialized and get_homeless_animals().size() > 0:
			reassignment_timer = 1.0  # Small delay to ensure enclosure is ready

func unregister_enclosure(enclosure: AnimalEnclosure):
	if all_enclosures.has(enclosure):
		all_enclosures.erase(enclosure)
		enclosure_removed.emit(enclosure)
		print("Enclosure unregistered: %s" % enclosure.enclosure_name)

func register_animal(animal: Node):
	if not all_animals.has(animal):
		all_animals.append(animal)
		update_animal_count()
		print("New animal registered: %s" % (
			animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown"
		))
		
		# Auto-assign if enabled
		if is_initialized and auto_assign_on_animal_added:
			reassignment_timer = 0.5  # Small delay to ensure animal is ready

func unregister_animal(animal: Node):
	if all_animals.has(animal):
		all_animals.erase(animal)
		update_animal_count()
		print("Animal unregistered: %s" % (
			animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown"
		))

func update_animal_count():
	animal_count_changed.emit(all_animals.size(), max_total_animals)

func can_add_more_animals() -> bool:
	return all_animals.size() < max_total_animals

func get_available_enclosures_for_animal(animal: Node) -> Array[AnimalEnclosure]:
	var available: Array[AnimalEnclosure] = []
	var animal_type = animal.get_animal_type() if animal.has_method("get_animal_type") else "Unknown"
	
	for enclosure in all_enclosures:
		if enclosure.can_accommodate_animal(animal):
			available.append(enclosure)
	
	return available

func get_best_enclosure_for_animal(animal: Node) -> AnimalEnclosure:
	var available = get_available_enclosures_for_animal(animal)
	if available.size() == 0:
		return null
	
	# Sort by available space (most space first), then by proximity to animal
	available.sort_custom(sort_enclosures_by_priority.bind(animal))
	return available[0]

func sort_enclosures_by_priority(a: AnimalEnclosure, b: AnimalEnclosure, animal: Node) -> bool:
	# First priority: available space
	if a.get_available_space() != b.get_available_space():
		return a.get_available_space() > b.get_available_space()
	
	# Second priority: proximity to animal (if animal has position)
	if animal.has_method("global_position"):
		var dist_a = a.global_position.distance_to(animal.global_position)
		var dist_b = b.global_position.distance_to(animal.global_position)
		return dist_a < dist_b
	
	return false

func auto_assign_animals_to_enclosures():
	if reassignment_timer > 0:
		return
	
	print("\n--- Starting Auto Assignment ---")
	var homeless_animals = get_homeless_animals()
	print("Homeless animals found: %d" % homeless_animals.size())
	
	if homeless_animals.size() == 0:
		print("No homeless animals to assign!")
		return
	
	var assignments_made = 0
	
	for animal in homeless_animals:
		var target_enclosure = get_best_enclosure_for_animal(animal)
		
		if target_enclosure:
			if assign_animal_to_enclosure(animal, target_enclosure):
				assignments_made += 1
		else:
			assignment_failed.emit(animal)
			var animal_name = animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown"
			print("NO suitable enclosure found for %s" % animal_name)
	
	print("Auto Assignment Complete - %d animals assigned" % assignments_made)
	reassignment_timer = reassignment_cooldown

func assign_animal_to_enclosure(animal: Node, enclosure: AnimalEnclosure) -> bool:
	if not animal.has_method("set_enclosure"):
		print("ERROR: Animal doesn't have set_enclosure method!")
		return false
	
	var animal_name = animal.get_animal_name() if animal.has_method("get_animal_name") else "Unknown"
	
	animal.set_enclosure(enclosure)
	
	# Verify assignment was successful
	if animal.is_in_enclosure() and animal.get_enclosure() == enclosure:
		animal_assigned.emit(animal, enclosure)
		print("SUCCESS: %s assigned to %s" % [animal_name, enclosure.enclosure_name])
		return true
	else:
		print("FAILED: %s could not be assigned to %s" % [animal_name, enclosure.enclosure_name])
		return false

func get_homeless_animals() -> Array[Node]:
	var homeless: Array[Node] = []
	
	for animal in all_animals:
		if not animal.is_in_enclosure():
			homeless.append(animal)
	
	return homeless

func get_total_animal_capacity() -> int:
	var total_capacity = 0
	for enclosure in all_enclosures:
		total_capacity += enclosure.max_animals
	return total_capacity

func get_total_animals_in_enclosures() -> int:
	var total = 0
	for enclosure in all_enclosures:
		total += enclosure.get_animal_count()
	return total

func get_enclosure_utilization_percentage() -> float:
	var total_capacity = get_total_animal_capacity()
	if total_capacity == 0:
		return 0.0
	return float(get_total_animals_in_enclosures()) / float(total_capacity) * 100.0

# Debug functions
func print_farm_status():
	print("=== FARM STATUS ===")
	print("Total Animals: %d/%d" % [all_animals.size(), max_total_animals])
	print("Total Capacity: %d" % get_total_animal_capacity())
	print("Animals in Enclosures: %d" % get_total_animals_in_enclosures())
	print("Homeless Animals: %d" % get_homeless_animals().size())
	print("Enclosure Utilization: %.1f%%" % get_enclosure_utilization_percentage())
	print("Enclosures: %d" % all_enclosures.size())
	
	for enclosure in all_enclosures:
		enclosure.print_enclosure_status()
	
	print("==================")

# Manual assignment trigger (for debugging)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Use Enter key for manual assignment
		print("\n=== MANUAL ASSIGNMENT TRIGGERED ===")
		auto_assign_animals_to_enclosures()
		print_farm_status()
