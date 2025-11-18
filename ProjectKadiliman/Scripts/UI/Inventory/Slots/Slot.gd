extends Panel

var default_tex = null
var empty_tex = null
var selected_tex = preload("res://Assets/Environment/UI/Inventory/Background/Inventory_Slot_Selected.png")
var empty_trash_tex = preload("res://Assets/Environment/UI/Icons/trash.png")
var default_trash_tex = preload("res://Assets/Environment/UI/Inventory/Background/Inventory_Slot_Empty.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null
var empty_trash_style: StyleBoxTexture = null  # Style for empty trash
var default_trash_style: StyleBoxTexture = null  # Style for trash slot with item

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
	ACCESSORY,
	TRASH,
}

var slot_type = null
var is_selected = false  # Track selection state


func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	empty_trash_style = StyleBoxTexture.new()  # Initialize empty trash style
	default_trash_style = StyleBoxTexture.new()  # Initialize default trash style
	
	# Load textures if they exist
	if default_tex:
		default_style.texture = default_tex
	if empty_tex:
		empty_style.texture = empty_tex
	if selected_tex:
		selected_style.texture = selected_tex
	if empty_trash_tex:
		empty_trash_style.texture = empty_trash_tex  # Set empty trash texture
	if default_trash_tex:
		default_trash_style.texture = default_trash_tex  # Set default trash texture
	
	# Add slot to Slots group for easy access
	add_to_group("Slots")
	
	refresh_style()
		
func refresh_style():
	if is_selected:
		# Selected style takes priority for all slot types
		if selected_style:
			set('theme_override_styles/panel', selected_style)
	elif slot_type == SlotType.HOTBAR and PlayerInventory.active_item_slot == slot_index:
		# Hotbar active item styling
		if selected_style:
			set('theme_override_styles/panel', selected_style)
	elif slot_type == SlotType.TRASH:
		# Trash slot specific styling
		if item == null:
			# Empty trash slot - show trash icon
			if empty_trash_style and empty_trash_style.texture:
				set('theme_override_styles/panel', empty_trash_style)
			elif empty_style:
				set('theme_override_styles/panel', empty_style)
		else:
			# Trash slot with item - use default trash background
			if default_trash_style and default_trash_style.texture:
				set('theme_override_styles/panel', default_trash_style)
			elif default_style:
				set('theme_override_styles/panel', default_style)
	elif item == null:
		# Empty regular slot
		if empty_style:
			set('theme_override_styles/panel', empty_style)
	else:
		# Slot with item
		if default_style:
			set('theme_override_styles/panel', default_style)

func set_selected(selected: bool):
	is_selected = selected
	refresh_style()

func pickFromSlot():
	if item != null:
		# Remove from this slot but DON'T queue_free the item
		remove_child(item)
		# Don't destroy the item here - let the receiving slot handle it
		item = null
		refresh_style()

func putIntoSlot(new_item):
	# If there's already an item, remove it first
	if item != null:
		remove_child(item)
		item.queue_free()
		item = null
	
	item = new_item
	
	item.visible = true
	
	# Remove from previous parent and add to this slot
	var old_parent = item.get_parent()
	if old_parent and old_parent != self:
		old_parent.remove_child(item)
	
	add_child(item)
	
	# Force the item to update its visual properties
	if item.has_method("force_visual_update"):
		item.force_visual_update()
	
	# Refresh slot appearance
	refresh_style()
	
func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		# If item already exists, just update its properties
		item.set_item(item_name, item_quantity)
	
	# Force visual update
	item.force_visual_update()
	refresh_style()

# NEW: Force immediate visual update
func force_visual_update():
	if item != null and is_instance_valid(item):
		item.visible = true
	refresh_style()
