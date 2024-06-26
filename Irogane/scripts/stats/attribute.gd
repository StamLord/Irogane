extends Value
class_name Attribute

@export_range(1, 10) var value = 1
@export var min_max : Vector2 = Vector2(1, 10)
@export var modified_min_max : Vector2 = Vector2(1, 12)

var modifier_dict : Dictionary

var modified_value : int
var dirty_value = true

func add_point(points):
	set_value(value + points)
	

func remove_point(points):
	set_value(value - points)
	

func set_value(_value):
	self.value = clamp(_value, min_max.x, min_max.y)
	dirty_value = true
	

func get_minimum_value():
	return min_max[0]
	

func get_maximum_value():
	return min_max[1]
	

func get_value():
	if not dirty_value:
		return modified_value
	
	# Recalculate modified value
	modified_value = value
	for mod in modifier_dict.values():
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
	
	if modifier_dict.has(modifier.modifier_name):
		return
	
	modifier_dict[modifier.modifier_name] = modifier
	dirty_value = true # Flags that we need to recalculate mods
	

func remove_modifier(modifier):
	if not modifier_dict.has(modifier.modifier_name):
		return
	
	modifier_dict.erase(modifier.modifier_name)
	dirty_value = true # Flags that we need to recalculate mods
	

func save_data():
	var data = {
		"value" : value,
		"modifier_dict" : modifier_dict
	}
	
	return data
	

func load_data(data):
	value = data["value"]
	modifier_dict = data["modifier_dict"]
	
	# Value needs to be calculated again with the modifiers
	dirty_value = true
	
