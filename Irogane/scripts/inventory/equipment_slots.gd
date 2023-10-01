extends Panel

@onready var slots = get_children()
var items = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in slots:
		items[slot.name] = null

func insert_item(item):
	# Get slot under the item
	var item_pos = item.global_position + item.size * item.scale / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	
	# Get item slot data
	var item_slot = ItemDB.get_item(item.get_meta("id"))["slot"].to_lower()
	
	# Wrong slot
	if item_slot != slot.name:
		return false
	
	# Slot not empty
	if items[item_slot] != null:
		print("Not Empty")
		return false
	
	# Set item in slot
	items[item_slot] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size * item.scale / 2
	return true

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	var item_slot = ItemDB.get_item(item.get_meta("id"))["slot"].to_lower()
	items[item_slot] = null
	return item

func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)

func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)
	
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null
