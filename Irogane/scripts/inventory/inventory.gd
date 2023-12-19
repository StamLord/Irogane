extends Panel
class_name inventory

const item_base = preload("res://scripts/ui/item_base.tscn")
const pickup_base = preload("res://prefabs/pickups/pickup.tscn")

@onready var equipment_slots = $"equipment_slots"
@onready var grid = $"grid_inventory"
@onready var quick_slots = $"quick_slots"
@onready var base = $"ReferenceRect"

@onready var drop_origin = PlayerEntity.player_node
var drop_offset = Vector3(0, 1.5, -1.5)

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()

func _ready():
	pickup_item("katana")
	pickup_item("robes")
	pickup_item("onigiri")
	pickup_item("godot cube")
	pickup_item("godot cube")
	pickup_item("godot cube")
	#pickup_item("test")w
	#pickup_item("test")
	
func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	
	if item_held != null:
		item_held.global_position = cursor_pos + item_offset * item_held.scale
		item_held.scale = get_container_scale(get_container_under_cursor(cursor_pos), item_held)

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			grab(get_global_mouse_position())
		else:
			release(get_global_mouse_position())
			
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = item_held.global_position
			item_offset = (item_held.global_position - cursor_pos) / get_container_scale(c, item_held)
			move_child(item_held, get_child_count())
			
			# Highlight/De-highlight valid slots
			equipment_slots.highlight_valid_slots(item_held)
			quick_slots.highlight_valid_slots(item_held)

func get_container_under_cursor(cursor_pos):
	var containers = [grid, equipment_slots, quick_slots, base]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
		
	# Highlight/De-highlight valid slots
	equipment_slots.highlight_valid_slots(item_held)
	quick_slots.highlight_valid_slots(item_held)

func drop_item():
	var item_id = item_held.get_meta("id")
	if item_id:
		#ItemDB.get_item(item_id)["pickup"])
		var pickup = pickup_base.instantiate()
		get_tree().get_root().add_child(pickup)
		
		pickup.global_position = drop_origin.global_position + drop_origin.get_global_transform().basis * drop_offset
		
		# Set item
		for child in pickup.get_children():
			if child is Pickup:
				child.item_id = item_id
		print(pickup.get_parent())
	# Destroy gui item
	item_held.queue_free()
	item_held = null
	
func return_item():
	item_held.global_position = last_pos
	item_held.scale = get_container_scale(last_container, item_held)
	last_container.insert_item(item_held)
	item_held = null

func pickup_item(item_id):
	var item = item_base.instantiate()
	item.set_meta("id", item_id)
	item.texture = load(ItemDB.get_item(item_id)["icon"])
	add_child(item)
	if not grid.insert_item_at_first_available(item):
		item.queue_free()
		return false
	return true

func get_container_scale(container, item):
	
	var container_size
	if container == equipment_slots:
		container_size = 120
	elif container == quick_slots:
		container_size = 75
	else:
		container_size = 500
		
	var largest_dimension = max(item.size.x, item.size.y)
	
	if container_size > largest_dimension:
		return Vector2(1, 1)
	else:
		return Vector2.ONE * container_size / largest_dimension
