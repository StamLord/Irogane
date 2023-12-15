extends Node
class_name Utils

static func str_to_vector3(string : String):
	string = string.replace("(", "")
	string = string.replace(")", "")
	var values = string.split(",")
	
	return Vector3(values[0].to_float(), values[1].to_float(), values[2].to_float())
	
