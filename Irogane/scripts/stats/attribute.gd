extends Value
class_name Attribute

@export_range(1, 10) var value = 1
@export var min_max : Vector2 = Vector2(1, 10)
@export var modified_min_max : Vector2 = Vector2(1, 12)

var modifier_dict : Dictionary

var modified_value : int
var dirty_value = true
	
func add_point(points):
	value = clamp(value + points, min_max.x, min_max.y)
	dirty_value = true

func remove_point(points):
	value = clamp(value - points, min_max.x, min_max.y)
	dirty_value = true
	
func get_value():
	if not dirty_value:
		return modified_value
	
	# Recalculate modified value
	modified_value = value
	
	for mod in get_children():
		if mod is Modifier:
			modified_value = mod.modify(modified_value)
	
	# Clamp
	modified_value = clamp(modified_value, modified_min_max.x, modified_min_max.y)
	
	dirty_value = false
	return modified_value
	
func get_unmodified():
	return value

func add_modifier(modifier):
	if not modifier is Modifier:
		return
	
	if modifier_dict.has(modifier.name):
		return
	
	add_child(modifier)
	modifier_dict[modifier.name] = modifier
	dirty_value = true # Flags that we need to recalculate mods
	
func remove_modifier(modifier):
	if not modifier_dict.has(modifier.name):
		return
	
	remove_child(modifier_dict[modifier.name])
	modifier_dict.erase(modifier.name)
	dirty_value = true # Flags that we need to recalculate mods
