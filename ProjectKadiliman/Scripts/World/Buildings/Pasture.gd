# Pasture.gd
extends AnimalEnclosure

@export var fence_strength: int = 100  # How well it contains animals

func _ready():
	add_to_group("enclosures")
	
	enclosure_name = "Pasture"
	max_animals = 6
	allowed_animal_types = ["Livestock", "Poultry"]
	#sprite_texture = preload("res://Assets/Fences/pasture_fence.png")
	super._ready()
