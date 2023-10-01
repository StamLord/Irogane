extends Control
class_name quick_slots

@onready var slots_container = $HBoxContainer
@onready var slots = slots_container.get_children()
@export var valid_slot_types = ["WEAPON", "CONSUMABLE"]

var items = {} # Key: Slot Value: Item

signal slot_changed(slot_index)

func _ready():
	for slot in slots:
		items[slot] = null

func insert_item(item):
	# Get slot under the item
	var item_pos = item.global_position + item.size * item.scale / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	
	# Get item slot data
	var item_slot = ItemDB.get_item(item.get_meta("id"))["slot"]
	
	# Wrong slot
	if item_slot not in valid_slot_types:
		return false
	
	# Slot not empty
	if items[slot] != null:
		return false
	
	# Set item in slot
	items[slot] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size * item.scale / 2
	
	slot_changed.emit(slots.find(slot))
	
	return true

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	var slot = get_slot_under_pos(pos)
	if slot == null:
		return null
	
	items[slot] = null
	
	slot_changed.emit(slots.find(slot))
	
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

func get_item_in_slot(index):
	if index >= slots.size():
		return null
	elif index < 0:
		return null
		
	return items[slots[index]]
