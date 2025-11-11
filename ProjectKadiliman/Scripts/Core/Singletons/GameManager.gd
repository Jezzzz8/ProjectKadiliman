extends Node

func _ready():
	# Initialize all systems
	print("GameManager: Initializing game systems")
	
	# Ensure PlayerInventory is ready
	if PlayerInventory:
		print("GameManager: PlayerInventory loaded")
	
	# Ensure PlayerCharacterData is ready  
	if PlayerCharacterData:
		print("GameManager: PlayerCharacterData loaded")
	
	# Ensure JsonData is ready
	if JsonData:
		print("GameManager: JsonData loaded")
		
	# Ensure CompositeSprites is ready
	if CompositeSprites:
		print("GameManager: CompositeSprites loaded")
		
	# Ensure JsonData is ready
	if JsonData:
		print("GameManager: JsonData loaded")
	
	# Ensure CharacterUtils is ready
	if CharacterUtils:
		print("GameManager: CharacterUtils loaded")
