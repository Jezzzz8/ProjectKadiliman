extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var speed = 1000
var max_distance = 500  # Maximum travel distance
var distance_traveled = 0.0

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	global_position = pos
	global_rotation = rota

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	var movement = velocity * delta
	distance_traveled += movement.length()
	
	# Check if exceeded max distance
	if distance_traveled >= max_distance:
		queue_free()
		return
	
	var collision = move_and_collide(movement)
	
	# Handle collision
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision2D) -> void:
	# You can add collision effects here
	# For example: play sound, spawn particles, damage enemies, etc.
	print("Peeble hit: ", collision.get_collider())
	
	# Remove the projectile after collision
	queue_free()
