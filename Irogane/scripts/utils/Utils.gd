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
	

static func get_all_files_in_folder(path):
	var file_paths = []
	
	var dir = DirAccess.open(path)
	if dir == null:
		return file_paths
	
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":  
		var file_path = path + "/" + file_name  
		file_paths.append(file_path)  
		file_name = dir.get_next()  
	
	return file_paths
	

static func get_resource_file_name(resource : Resource):
	return resource.resource_path.get_basename().split("/")[-1]
	

static func angle_between_vector3(v1: Vector3, v2: Vector3) -> float:
	v1 = v1.normalized()
	v2 = v2.normalized()
	
	# Calculate the angle between the vectors using the arccosine function (in radians)
	var dot_product = v1.dot(v2)
	var angle = acos(dot_product)
	return angle
	

static func rotate_y_to_target(body: Node3D, target_point: Vector3):
	var direction_to_target = target_point - body.global_position
	var angle = Vector2(-body.global_basis.z.x, -body.global_basis.z.z).angle_to(Vector2(direction_to_target.x, direction_to_target.z))
	body.rotate_y(-angle)
	

static func remap_value(value, start1, end1, start2, end2):
	return start2 + (value - start1) * (end2 - start2) / (end1 - start1)
	

static func random_color(seed : int = 0) -> Color:
	var rand = RandomNumberGenerator.new()
	rand.seed = seed
	var color = Color(rand.randf(), rand.randf(), rand.randf())
	print(color)
	return color
	

static func warning(node : Node, message : String):
	print(node.name, ": ", message)
	
