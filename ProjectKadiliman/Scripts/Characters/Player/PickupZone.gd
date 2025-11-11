extends Area2D

func _ready():
	# Make sure monitoring is enabled and set up for area detection
	monitoring = true
	monitorable = true
	# We're now detecting areas (ItemDrop) instead of bodies
	area_entered.connect(_on_area_entered)
	
	print("PickupZone ready - monitoring areas")

func _on_area_entered(area):
	print("PickupZone: Area entered - ", area.name)
	# This will now detect ItemDrop areas
	if area.has_method("pick_up_item"):
		print("Found item that can be picked up")
