extends Panel

var default_tex = null
var empty_tex = null
var selected_tex = preload("res://Assets/Environment/UI/Inventory/Background/Inventory_Slot_Selected.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://Scenes/Systems/Inventory/Item.tscn")
var item = null
var slot_index

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	HEAD,
	BODY,
	LEGS,
	FOOT,
}

var slot_type = null
var is_selected = false  # Track selection state


func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()

	default_style.texture = default_tex
	empty_style.texture = empty_tex
	selected_style.texture = selected_tex
	
	# Add slot to Slots group for easy access
	add_to_group("Slots")
	
	refresh_style()
		
func refresh_style():
	if is_selected:
		set('theme_override_styles/panel', selected_style)
	elif slot_type == SlotType.HOTBAR and PlayerInventory.active_item_slot == slot_index:
		set('theme_override_styles/panel', selected_style)
	elif item == null:
		set('theme_override_styles/panel', empty_style)
	else:
		set('theme_override_styles/panel', default_style)

func set_selected(selected: bool):
	is_selected = selected
	refresh_style()

func pickFromSlot():
	if item != null:
		remove_child(item)
		find_parent("UserInterface").add_child(item)
		item = null
		refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	find_parent("UserInterface").remove_child(item)
	add_child(item)
	refresh_style()
	
func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
	refresh_style()
