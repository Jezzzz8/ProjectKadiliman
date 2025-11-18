# CowBarn.gd
extends AnimalEnclosure

func _ready():
	add_to_group("enclosures")

	enclosure_name = "Cow Barn"
	max_animals = 3
	allowed_animal_types = ["Livestock"]
	#sprite_texture = preload("res://Assets/Barns/cow_barn.png")
	super._ready()
