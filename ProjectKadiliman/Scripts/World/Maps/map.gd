extends Node2D

@onready var playable_character = $PlayableCharacter

func _ready() -> void:
	apply_character_data()

func apply_character_data() -> void:
	if playable_character and PlayerCharacterData.validate_data(PlayerCharacterData.player_character_data):
		playable_character.apply_character_data(PlayerCharacterData.player_character_data)
	else:
		push_error("Failed to apply character data: invalid character or data")
