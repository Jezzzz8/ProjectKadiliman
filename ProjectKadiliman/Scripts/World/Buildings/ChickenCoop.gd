# ChickenCoop.gd
extends AnimalEnclosure

func _ready():
	add_to_group("enclosures")
	
	enclosure_name = "Chicken Coop"
	max_animals = 8
	allowed_animal_types = ["Poultry"]
	#sprite_texture = preload("res://Assets/Barns/chicken_coop.png")
	super._ready()
