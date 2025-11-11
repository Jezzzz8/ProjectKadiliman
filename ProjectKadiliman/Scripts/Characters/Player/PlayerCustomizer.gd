# PlayerCustomizer.gd
extends Control

@onready var bodySprite: Sprite2D = $Sprites/Body
@onready var hairSprite: Sprite2D = $Sprites/Hair
@onready var pantsSprite: Sprite2D = $Sprites/Pants
@onready var shirtsSprite: Sprite2D = $Sprites/Shirts
@onready var shoesSprite: Sprite2D = $Sprites/Shoes
@onready var main_hand: Sprite2D = $Sprites/MainHand
@onready var anim: AnimationPlayer = $PlayerAnimation
@onready var UI: Control = $Customizer

@export var sprite_scale = Vector2(0.5, 0.5)
@export var can_customize = false

var last_direction: String = "down"
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	load_character_data()
	update_sprites()
	CharacterUtils.play_animation(anim, "idle_down")
	
	bodySprite.scale = sprite_scale
	hairSprite.scale = sprite_scale
	pantsSprite.scale = sprite_scale
	shirtsSprite.scale = sprite_scale
	shoesSprite.scale = sprite_scale
	main_hand.scale = sprite_scale
	
	UI.visible = can_customize

func load_character_data() -> void:
	# Data is already in the singleton, just update visuals
	update_sprites()

func update_sprites() -> void:
	var sprites = {
		"body": bodySprite,
		"hair": hairSprite,
		"pants": pantsSprite,
		"shirts": shirtsSprite,
		"shoes": shoesSprite,
		"main_hand": main_hand
	}
	CharacterUtils.update_sprites(PlayerCharacterData.player_character_data, sprites)

func _process(delta: float) -> void:
	handle_preview_input()

func handle_preview_input() -> void:
	
	var input_vector = Vector2.ZERO
	var is_moving = false
	
	# Check for movement input
	if Input.is_action_pressed("go_right"):
		input_vector.x += 1
		is_moving = true
	if Input.is_action_pressed("go_left"):
		input_vector.x -= 1
		is_moving = true
	if Input.is_action_pressed("go_down"):
		input_vector.y += 1
		is_moving = true
	if Input.is_action_pressed("go_up"):
		input_vector.y -= 1
		is_moving = true
	
	
	if is_moving:
		last_direction = CharacterUtils.update_direction(input_vector)
	
	# Check for equipment changes
	if Input.is_action_just_pressed("change_tool"):
		PlayerCharacterData.cycle_tool()
		update_sprites()
	
	if Input.is_action_just_pressed("change_weapon"):
		PlayerCharacterData.cycle_weapon()
		update_sprites()
	
	if Input.is_action_just_pressed("change_range_weapon"):
		PlayerCharacterData.cycle_range_weapon()
		update_sprites()
	
	# Determine animation
	var is_running = Input.is_action_pressed("run")
	var anim_name = CharacterUtils.get_animation_name(last_direction, is_moving, is_running)
	CharacterUtils.play_animation(anim, anim_name)

# UI Button handlers (keep your existing ones)
func _on_change_body_pressed() -> void:
	var spritesheet = CompositeSprites.get_body_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.body = (PlayerCharacterData.player_character_data.body + 1) % spritesheet.size()
	update_sprites()

func _on_change_hair_pressed() -> void:
	var spritesheet = CompositeSprites.get_hair_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.hair = (PlayerCharacterData.player_character_data.hair + 1) % spritesheet.size()
	update_sprites()

func _on_change_shirts_pressed() -> void:
	var spritesheet = CompositeSprites.get_shirts_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.shirts = (PlayerCharacterData.player_character_data.shirts + 1) % spritesheet.size()
	update_sprites()

func _on_change_pants_pressed() -> void:
	var spritesheet = CompositeSprites.get_pants_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.pants = (PlayerCharacterData.player_character_data.pants + 1) % spritesheet.size()
	update_sprites()

func _on_change_shoes_pressed() -> void:
	var spritesheet = CompositeSprites.get_shoes_spritesheet(PlayerCharacterData.player_character_data.is_female)
	PlayerCharacterData.player_character_data.shoes = (PlayerCharacterData.player_character_data.shoes + 1) % spritesheet.size()
	update_sprites()

func _on_randomize_button_pressed() -> void:
	var data = PlayerCharacterData.player_character_data
	data.body = rng.randi_range(0, CompositeSprites.get_body_spritesheet(data.is_female).size() - 1)
	data.hair = rng.randi_range(0, CompositeSprites.get_hair_spritesheet(data.is_female).size() - 1)
	data.pants = rng.randi_range(0, CompositeSprites.get_pants_spritesheet(data.is_female).size() - 1)
	data.shirts = rng.randi_range(0, CompositeSprites.get_shirts_spritesheet(data.is_female).size() - 1)
	data.shoes = rng.randi_range(0, CompositeSprites.get_shoes_spritesheet(data.is_female).size() - 1)
	update_sprites()

func _on_change_sex_pressed() -> void:
	PlayerCharacterData.player_character_data.is_female = !PlayerCharacterData.player_character_data.is_female
	# Reset to first variant when changing gender
	PlayerCharacterData.player_character_data.body = 0
	PlayerCharacterData.player_character_data.hair = 0
	PlayerCharacterData.player_character_data.pants = 0
	PlayerCharacterData.player_character_data.shirts = 0
	PlayerCharacterData.player_character_data.shoes = 0
	update_sprites()

func _on_finish_customization_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Core/map.tscn")


func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
