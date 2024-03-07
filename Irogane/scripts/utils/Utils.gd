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
	
