extends Node

const statuses_folder = "res://data/statuses/"

# Dictionaries <status_name : Status>
var statuses = {}

func _ready():
	print("Loading resources...")
	var start_time = Time.get_ticks_msec()
	
	var status_files = Utils.get_all_files_in_folder(statuses_folder)
	
	for file in status_files:
		var resource = load(file)
		statuses[Utils.get_resource_file_name(resource)] = resource
	
	print("Loading resources finished. Took %s ms" % str(Time.get_ticks_msec() - start_time))
	

func get_status(status_name):
	if statuses.has(status_name):
		return statuses[status_name]
	
	return null
	
