extends Area2D

var speed = 1000
var max_distance = 500  # Maximum travel distance
var distance_traveled = 0.0
var direction: float
var has_hit_something = false

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

func setup(spawn_position: Vector2, angle: float) -> void:
	global_position = spawn_position
	global_rotation = angle
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
	# Handle collision with physics bodiesDDDDDDD
	print("Peeble hit: ", body)
	
	# NEW: Check if hitting TileMapLayer
	if body is TileMapLayer:
		print("Peeble hit TileMapLayer, checking for drop...")
		try_drop_item_on_terrain()
	
	has_hit_something = true
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("Peeble hit area: ", area)
	has_hit_something = true
	queue_free()

func try_drop_item():
	# 30% chance to drop a peeble item when reaching max distance
	if randf() < 0.3:
		drop_item("Peeble", 1)

# NEW: Special drop function for terrain hits
func try_drop_item_on_terrain():
	# 60% chance to drop a peeble when hitting terrain (higher than arrow)
	if randf() < 0.6:
		drop_item("Peeble", 1)
	# Additional 30% chance to drop stone from terrain (since pebbles are stones)
	elif randf() < 0.3:
		drop_item("Stone", 1)

func drop_item(item_name: String, quantity: int):
	var item_drop_scene = preload("res://Scenes/World/Environment/Item/Drop/ItemDrop.tscn")
	var item_drop = item_drop_scene.instantiate()
	
	item_drop.item_name = item_name
	item_drop.item_quantity = quantity
	item_drop.global_position = global_position
	
	# Add to the current scene
	get_parent().add_child(item_drop)
	print("Dropped item: ", item_name, " x", quantity)
