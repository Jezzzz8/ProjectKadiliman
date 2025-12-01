extends Area2D

var player = null
var is_moving_to_player = false
var speed = 150
var pickup_cooldown = 0.0  # NEW: Cooldown timer

@export var item_name = "Peeble"
@export var item_quantity = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("pickup_items")
	area_entered.connect(_on_area_entered)
	update_sprite_texture()

func _physics_process(delta: float) -> void:
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
				
				# Try to add item to inventory/hotbar
				var success = PlayerInventory.add_item(item_name, item_quantity)
				
				if success:
					# Item was successfully added
					print("Item successfully added to inventory/hotbar")
					
					# NEW: Announce the item pickup
					if player.has_method("announce_item_pickup"):
						player.announce_item_pickup(item_name, item_quantity)
					
					# NEW: Sync equipment if this is an equippable item
					if PlayerCharacterData:
						PlayerCharacterData.sync_equipment_from_inventory()
					
					var inventory_ui = get_tree().get_first_node_in_group("inventory")
					if inventory_ui and inventory_ui.has_method("initialize_inventory"):
						print("Refreshing inventory UI")
						inventory_ui.initialize_inventory()
					
					# Destroy the item drop
					queue_free()
				else:
					# Inventory and hotbar are both full - reject the item
					print("Inventory and hotbar are full! Item rejected.")
					
					# NEW: Announce that inventory is full
					if player.has_method("announce_inventory_full"):
						player.announce_inventory_full()
					
					# Stop moving towards player and re-enable collision
					is_moving_to_player = false
					collision.disabled = false
					
					# Optional: Add a small bounce effect to show rejection
					var bounce_direction = (global_position - player.global_position).normalized()
					var bounce_tween = create_tween()
					bounce_tween.tween_property(self, "position", position + bounce_direction * 20, 0.2)
					bounce_tween.tween_property(self, "position", position, 0.2)
			else:
				print("PlayerInventory singleton not found!")

func _on_area_entered(area):
	print("ItemDrop: Area entered - ", area.name)
	if area.name == "PickupZone":
		print("Player pickup zone detected - starting pickup")
		player = area.get_parent()
		is_moving_to_player = true
		collision.disabled = true

func update_sprite_texture():
	print("Updating sprite texture for item: ", item_name)
	if CompositeSprites:
		print("CompositeSprites autoload found")
		var texture = CompositeSprites.get_item_texture(item_name)
		if texture:
			print("Texture found: ", texture)
			sprite.texture = texture
		else:
			print("Warning: No texture found for item: ", item_name)
			# Use a default texture
			sprite.texture = CompositeSprites.get_default_texture()
	else:
		print("Error: CompositeSprites autoload not found")
		# Use a default texture even if CompositeSprites is not available
		sprite.texture = preload("res://Assets/Environment/Items/Missing.png")

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	
	# Use the centralized texture system
	if CompositeSprites:
		var texture = CompositeSprites.get_item_texture(item_name)
		if texture:
			sprite.texture = texture
		else:
			print("Warning: No texture found for item: ", item_name)
			# Set a default missing texture
			sprite.texture = CompositeSprites.get_default_texture()
	else:
		print("Error: CompositeSprites autoload not found")
		# Set a default missing texture
		sprite.texture = preload("res://Assets/Environment/Items/Missing.png")
	
	# Handle quantity display
	if PlayerInventory and PlayerInventory.has_item_resource(item_name):
		var resource = PlayerInventory.get_item_resource(item_name)
		var stack_size = resource.stack_size
		if stack_size == 1:
			# Hide quantity label if it exists
			var quantity_label = get_node_or_null("Quantity")
			if quantity_label:
				quantity_label.visible = false
		else:
			# Show quantity label if it exists
			var quantity_label = get_node_or_null("Quantity")
			if quantity_label:
				quantity_label.visible = true
				quantity_label.text = str(item_quantity)
	else:
		var stack_size = 1
		# Fallback for items not in JSON data or if JsonData not available
		print("Warning: Item not found in JSON data or JsonData not available: ", item_name)
		# Show quantity label if it exists
		var quantity_label = get_node_or_null("Quantity")
		if quantity_label:
			quantity_label.visible = true
			quantity_label.text = str(item_quantity)
