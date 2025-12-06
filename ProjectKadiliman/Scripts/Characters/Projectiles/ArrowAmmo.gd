extends Area2D

var speed = 1200
var max_distance = 800  # Maximum travel distance
var distance_traveled = 0.0
var direction: float
var has_hit_something = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func setup(spawn_position: Vector2, angle: float) -> void:
	global_position = spawn_position
	global_rotation = angle + PI/2
	direction = angle

func _physics_process(delta: float) -> void:
	if has_hit_something:
		return
		
	var movement = Vector2(speed, 0).rotated(direction) * delta
	position += movement
	distance_traveled += movement.length()
	
	# Check if exceeded max distance
	if distance_traveled >= max_distance:
		try_drop_item()
		queue_free()
		return

func _on_body_entered(body: Node2D) -> void:
	print("Arrow hit: ", body)
	
	# NEW: Check if hitting TileMapLayer
	if body is TileMapLayer:
		print("Arrow hit TileMapLayer, checking for drop...")
		try_drop_item_on_terrain()
	
	has_hit_something = true
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("Arrow hit area: ", area)
	has_hit_something = true
	queue_free()

func try_drop_item():
	# 30% chance to drop an arrow item when reaching max distance
	if randf() < 0.3:
		drop_item("Arrow", 1)

# NEW: Special drop function for terrain hits
func try_drop_item_on_terrain():
	# Only drop items that we know exist
	var valid_drops = get_valid_drop_items()
	if valid_drops.size() > 0:
		var random_drop = valid_drops[randi() % valid_drops.size()]
		drop_item(random_drop, 1)

func get_valid_drop_items() -> Array:
	# Only return items that actually exist in your game
	var possible_drops = []
	
	# Test if items exist before adding them
	var test_items = ["Arrow"]  # Only use items you know exist
	
	for item_name in test_items:
		# Check if item exists in Resource data
		if PlayerInventory.has_item(item_name):
			possible_drops.append(item_name)
		else:
			print("Drop item not available: ", item_name)
			
	return possible_drops

func drop_item(item_name: String, quantity: int):
	var item_drop_scene = preload("res://Scenes/World/Environment/Item/Drop/ItemDrop.tscn")
	var item_drop = item_drop_scene.instantiate()
	
	item_drop.item_name = item_name
	item_drop.item_quantity = quantity
	item_drop.global_position = global_position
	
	# Add to the current scene
	get_parent().add_child(item_drop)
	print("Dropped item: ", item_name, " x", quantity)
