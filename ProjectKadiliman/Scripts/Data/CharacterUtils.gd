# CharacterUtils.gd - Shared character utility functions
extends Node

static func update_sprites(data: Dictionary, sprites: Dictionary) -> void:
	if not PlayerCharacterData.validate_data(data):
		push_error("Invalid character data")
		return
	
	var is_female = data.is_female
	
	for sprite_name in sprites:
		var sprite = sprites[sprite_name]
		if sprite and sprite is Sprite2D:
			match sprite_name:
				"body":
					sprite.texture = CompositeSprites.get_body_spritesheet(is_female).get(data.body)
				"hair":
					# Use the hair color system
					var hair_texture = CompositeSprites.get_hair_texture(data.hair + 1, data.hair_color, is_female)
					sprite.texture = hair_texture
				"pants":
					var pants_spritesheet = CompositeSprites.get_pants_spritesheet(is_female)
					var pants_keys = pants_spritesheet.keys()
					if data.pants < pants_keys.size():
						sprite.texture = pants_spritesheet[pants_keys[data.pants]]
				"shirts":
					var shirts_spritesheet = CompositeSprites.get_shirts_spritesheet(is_female)
					var shirts_keys = shirts_spritesheet.keys()
					if data.shirts < shirts_keys.size():
						sprite.texture = shirts_spritesheet[shirts_keys[data.shirts]]
				"shoes":
					var shoes_spritesheet = CompositeSprites.get_shoes_spritesheet(is_female)
					var shoes_keys = shoes_spritesheet.keys()
					if data.shoes < shoes_keys.size():
						sprite.texture = shoes_spritesheet[shoes_keys[data.shoes]]
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
	# Don't override specific use animations - let PlayableCharacter handle them
	if not is_moving:
		return "idle_" + last_direction
	else:
		var prefix = "run_" if is_running else "walk_"
		return prefix + last_direction

static func play_animation(anim: AnimationPlayer, anim_name: String) -> void:
	if anim and anim.has_animation(anim_name) and anim.current_animation != anim_name:
		anim.play(anim_name)
