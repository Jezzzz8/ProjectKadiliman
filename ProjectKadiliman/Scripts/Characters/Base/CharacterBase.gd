extends Node2D

# Sprite references - should be set in derived classes
var bodySprite: Sprite2D
var hairSprite: Sprite2D
var pantsSprite: Sprite2D
var shirtsSprite: Sprite2D
var shoesSprite: Sprite2D
var main_hand: Sprite2D
var anim: AnimationPlayer

# Character state
var last_direction: String = "down"
var is_using_tool: bool = false
var is_female: bool = false

# Equipment
var available_tools: Array = ["None", "Hoe", "Shovel", "Watering Can", "Slingshot"]
var current_tool_index: int = 0

func setup_sprites(body: Sprite2D, hair: Sprite2D, pants: Sprite2D, shirts: Sprite2D, shoes: Sprite2D, hand: Sprite2D, animation: AnimationPlayer) -> void:
	bodySprite = body
	hairSprite = hair
	pantsSprite = pants
	shirtsSprite = shirts
	shoesSprite = shoes
	main_hand = hand
	anim = animation

func update_sprites(data: Dictionary) -> void:
	if not data.has("is_female"):
		push_error("Character data missing 'is_female' key")
		return
	
	is_female = data.is_female
	
	if bodySprite: bodySprite.texture = CompositeSprites.get_body_spritesheet(is_female).get(data.body)
	if hairSprite: hairSprite.texture = CompositeSprites.get_hair_spritesheet(is_female).get(data.hair)
	if pantsSprite: pantsSprite.texture = CompositeSprites.get_pants_spritesheet(is_female).get(data.pants)
	if shirtsSprite: shirtsSprite.texture = CompositeSprites.get_shirts_spritesheet(is_female).get(data.shirts)
	if shoesSprite: shoesSprite.texture = CompositeSprites.get_shoes_spritesheet(is_female).get(data.shoes)

func update_tool() -> void:
	if main_hand:
		var current_tool = available_tools[current_tool_index]
		main_hand.texture = CompositeSprites.get_tool_texture(current_tool)

func cycle_tool() -> String:
	current_tool_index = (current_tool_index + 1) % available_tools.size()
	update_tool()
	return available_tools[current_tool_index]

func use_tool() -> bool:
	if is_using_tool or available_tools[current_tool_index] == "None":
		return false
	
	var tool_anim_name = "use_tool_" + last_direction
	if anim and anim.has_animation(tool_anim_name):
		is_using_tool = true
		anim.play(tool_anim_name)
		return true
	return false

func on_tool_animation_finished() -> void:
	is_using_tool = false

func update_direction(input_vector: Vector2) -> void:
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			last_direction = "right" if input_vector.x > 0 else "left"
		else:
			last_direction = "down" if input_vector.y > 0 else "up"

func get_animation_name(is_moving: bool, is_running: bool = false) -> String:
	if is_using_tool:
		return "use_tool_" + last_direction
	elif not is_moving:
		return "idle_" + last_direction
	else:
		var prefix = "run_" if is_running else "walk_"
		return prefix + last_direction

func play_animation(anim_name: String) -> void:
	if anim and anim.has_animation(anim_name) and anim.current_animation != anim_name:
		anim.play(anim_name)
