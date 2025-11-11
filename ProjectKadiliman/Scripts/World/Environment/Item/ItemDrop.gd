extends Area2D

var player = null
var is_moving_to_player = false
var speed = 150

@export var item_name = "Peeble"
@export var item_quantity = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("pickup_items")
	area_entered.connect(_on_area_entered)
	update_sprite_texture()

func _on_area_entered(area):
	print("ItemDrop: Area entered - ", area.name)
	if area.name == "PickupZone":
		print("Player pickup zone detected - starting pickup")
		player = area.get_parent()
		is_moving_to_player = true
		collision.disabled = true

func _physics_process(delta):
	if is_moving_to_player and player != null:
		print("Item moving towards player")
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * speed * delta
		
		var distance = global_position.distance_to(player.global_position)
		print("Distance to player: ", distance)
		if distance < 5:
			print("Item reached player, adding to inventory")
			if PlayerInventory:
				print("PlayerInventory singleton found, adding item: ", item_name)
				PlayerInventory.add_item(item_name, item_quantity)
				
				# NEW: Sync equipment if this is an equippable item
				if PlayerCharacterData:
					PlayerCharacterData.sync_equipment_from_inventory()
				
				var inventory_ui = get_tree().get_first_node_in_group("inventory")
				if inventory_ui and inventory_ui.has_method("initialize_inventory"):
					print("Refreshing inventory UI")
					inventory_ui.initialize_inventory()
			else:
				print("PlayerInventory singleton not found!")
			queue_free()

func update_sprite_texture():
	print("Updating sprite texture for item: ", item_name)
	if PlayerCharacterData:
		print("PlayerCharacterData autoload found")
		var texture = PlayerCharacterData.get_item_texture(item_name)
		if texture:
			print("Texture found: ", texture)
			sprite.texture = texture
		else:
			print("Warning: No texture found for item: ", item_name)
	else:
		print("Error: PlayerCharacterData autoload not found")
