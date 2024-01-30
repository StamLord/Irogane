extends Node

const boons_folder = "res://data/boons/"
const flaws_folder = "res://data/flaws/"

# Dictionaries <quality_name : quality>
var boons = {}
var flaws = {}

func _ready():
	print("Loading resources...")
	var start_time = Time.get_ticks_msec()
	
	var boon_files = get_all_files_in_folder(boons_folder)
	var flaw_files = get_all_files_in_folder(flaws_folder)
	
	for file in boon_files:
		var resource = load(file)
		boons[get_resource_file_name(resource)] = resource
	
	for file in flaw_files:
		var resource = load(file)
		flaws[get_resource_file_name(resource)] = resource
	
	print("Loading resources finished. Took %s ms" % str(Time.get_ticks_msec() - start_time))
	

func get_all_files_in_folder(path):
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
	

func get_quality(quality_name):
	if boons.has(quality_name):
		return boons[quality_name]
	
	if flaws.has(quality_name):
		return flaws[quality_name]
	
	return null
	

func get_resource_file_name(resource : Resource):
	return resource.resource_path.get_basename().split("/")[-1]
	
