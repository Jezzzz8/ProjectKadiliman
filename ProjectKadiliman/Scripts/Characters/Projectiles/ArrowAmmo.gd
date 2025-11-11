extends Area2D

var speed = 1200
var max_distance = 800  # Maximum travel distance
var distance_traveled = 0.0
var direction: float

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func setup(spawn_position: Vector2, angle: float) -> void:
	global_position = spawn_position
	global_rotation = angle + PI/2
	direction = angle

func _physics_process(delta: float) -> void:
	var movement = Vector2(speed, 0).rotated(direction) * delta
	position += movement
	distance_traveled += movement.length()
	
	# Check if exceeded max distance
	if distance_traveled >= max_distance:
		queue_free()
		return

func _on_body_entered(body: Node2D) -> void:
	print("Peeble hit: ", body)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("Peeble hit area: ", area)
	queue_free()
