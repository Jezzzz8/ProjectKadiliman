# CharacterUtils.gd - Shared character utility functions
extends Node

static func update_sprites(data: Dictionary, sprites: Dictionary) -> void:
	if not PlayerCharacterData.validate_data(data):
		push_error("Invalid character data")
		return
	
	for sprite_name in sprites:
		var sprite = sprites[sprite_name]
		if sprite and sprite is Sprite2D:
			match sprite_name:
				"body":
					sprite.texture = CompositeSprites.get_body_spritesheet(data.is_female).get(data.body)
				"hair":
					sprite.texture = CompositeSprites.get_hair_spritesheet(data.is_female).get(data.hair)
				"pants":
					sprite.texture = CompositeSprites.get_pants_spritesheet(data.is_female).get(data.pants)
				"shirts":
					sprite.texture = CompositeSprites.get_shirts_spritesheet(data.is_female).get(data.shirts)
				"shoes":
					sprite.texture = CompositeSprites.get_shoes_spritesheet(data.is_female).get(data.shoes)
				"main_hand":
					sprite.texture = PlayerCharacterData.get_current_equipment_texture()

static func update_direction(input_vector: Vector2) -> String:
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			return "right" if input_vector.x > 0 else "left"
		else:
			return "down" if input_vector.y > 0 else "up"
	return "down"  # default direction

static func get_animation_name(last_direction: String, is_moving: bool, is_running: bool = false, is_using_equipment: bool = false) -> String:
	if is_using_equipment:
		# This is a generic placeholder - the actual animation is handled in PlayableCharacter
		return "idle_" + last_direction
	elif not is_moving:
		return "idle_" + last_direction
	else:
		var prefix = "run_" if is_running else "walk_"
		return prefix + last_direction

static func play_animation(anim: AnimationPlayer, anim_name: String) -> void:
	if anim and anim.has_animation(anim_name) and anim.current_animation != anim_name:
		anim.play(anim_name)
