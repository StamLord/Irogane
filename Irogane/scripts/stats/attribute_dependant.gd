extends Value
class_name AttributeDependant

@export var attribute : Attribute
@export var values : Array[int]

func get_value():
	if attribute == null:
		return values[0]
	
	var attr = clamp(attribute.get_value() - attribute.min_max.x, 0, values.size() - 1)
	return values[attr]
