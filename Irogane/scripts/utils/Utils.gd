extends Node
class_name Utils

static func str_to_vector3(string : String):
	string = string.replace("(", "")
	string = string.replace(")", "")
	var values = string.split(",")
	
	return Vector3(values[0].to_float(), values[1].to_float(), values[2].to_float())
	

static func random_inside_circle():
	return random_on_circle() * randf()
	

static func random_on_circle():
	randomize()
	return Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	
