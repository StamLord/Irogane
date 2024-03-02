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
	

func valid_item(item):
	# Get item slot data if not null
	var item_slot = null
	if item != null:
		item_slot = ItemDB.get_item(item.get_meta("id"))["slot"]
	
	return item_slot in valid_slot_types
	

func highlight_valid_slots(item):
	animate_highlight(slots_container, valid_item(item))
	

func animate_highlight(slot, state):
	var start = Time.get_ticks_msec()
	var duration = 0.1 * 1000
	var from_alpha = slot.modulate.a
	var to_alpha = 1.0 if state else 0.5
	
	while Time.get_ticks_msec() - start <= duration:
		var t = (Time.get_ticks_msec() - start) / duration
		slot.modulate.a = lerp(from_alpha, to_alpha, t)
		
		await get_tree().process_frame
	
	slot.modulate.a = to_alpha
	

func insert_item(item):
	# Get slot under the item
	var item_pos = item.global_position + item.size * item.scale / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	
	return insert_item_in_slot(item, slot)
	

func insert_item_at_index(item, index : int):
	return insert_item_in_slot(item, slots[index])
	

func insert_item_in_slot(item, slot):
	# Wrong slot
	if not valid_item(item):
		return false
	
	# Slot not empty
	if items[slot] != null:
		return false
	
	# Set item in slot
	items[slot] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size * item.scale / 2
	
	slot_changed.emit(slots.find(slot))
	
	return true
	

func remove_item_at_index(index : int):
	var slot = slots[index]
	items[slot].queue_free()
	items[slot] = null
	
	slot_changed.emit(index)
	

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
	
