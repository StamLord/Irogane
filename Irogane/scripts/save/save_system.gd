extends Node

@onready var scene_manager = get_node("/root/SceneManager")

const game_dir_path = "user://"
const save_dir_name = "saves"
const settings_dir_name = "settings"
const save_filename = "savegame_{i}.save"
const thumbnail_filename = "savegame_{i}.png"
const system_settings_file_name = "system.config"
var save_path = null
var settings_path = null

signal on_game_save()
signal on_game_load()

var pending_save_file = null

func _ready():
	scene_manager.on_scene_loaded.connect(scene_loaded)
	var directory = DirAccess.open(game_dir_path)
	var dirs = directory.get_directories()
	
	if not directory.dir_exists(save_dir_name):
		directory.make_dir(save_dir_name)
		
	if not directory.dir_exists(settings_dir_name):
		directory.make_dir(settings_dir_name)
	
	save_path = game_dir_path.path_join(save_dir_name)
	settings_path = game_dir_path.path_join(settings_dir_name)

func get_save_files():
	var directory = DirAccess.open(save_path)
	var files = directory.get_files()
	
	# Filter items according to filename convention
	var saves = []
	for file in files:
		if file.split("_")[0] != save_filename.split("_")[0]:
			continue
		if file.split(".")[1] != save_filename.split(".")[1]:
			continue
		saves.append(file)
	
	return saves

func get_save_file_info(filename):
	var save_file = save_path.path_join(filename)
	var info = {}
	
	if not FileAccess.file_exists(save_file):
		return info
	
	var save_game = FileAccess.open(save_file, FileAccess.READ)
	
	var json = JSON.new()
	
	# Get version
	json.parse(save_game.get_line())
	var data = json.get_data()
	info["version"] = data
	
	# Get Date
	info["date"] = FileAccess.get_modified_time(save_file)
	
	# Get thumbnail as ImageTexture
	var new_thumbnail_filename = save_path.path_join(filename.replace(".save", ".png"))
	
	if FileAccess.file_exists(new_thumbnail_filename):
		var image = Image.new()
		image.load(new_thumbnail_filename)
		info["thumbnail"] = ImageTexture.create_from_image(image)
	
	# Get player level
#	json.parse(save_game.get_line())
#	data = json.get_data()
#	info["level"] = data["level"]
	
	return info

func get_highest_save_index():
	var files = get_save_files()
	var biggest_index = -1
	
	for file in files:
		var index_str = file.split("_")[1].split(".")[0]
		var index_int = index_str.to_int()
		if index_int > biggest_index:
			biggest_index = index_int
		
	return biggest_index
	

func save(index = null):
	# Generate next index if not provided
	if index == null:
		index = str(get_highest_save_index() + 1)
	
	var save_file = save_path.path_join(save_filename)
	save_file = save_file.format({"i" : index})
	
	var save_game = FileAccess.open(save_file, FileAccess.WRITE)
	
	save_game.store_line(JSON.stringify("{version : 0.1}"))
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
			
		# Check the node has a save function.
		if !node.has_method("save_data"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		# Call the node's save function.
		var node_data = node.call("save_data")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(json_string)
	
	# Generate thumbnail
	create_thumbnail(index)
	
	on_game_save.emit()
	

func _parse_json_string(json_string):
	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null

	# Get the data from the JSON object
	var data = json.get_data()
	return data
	

func load_save_file(save_file):
	# Get all objects in current scene that should be saveable
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	# Iterate over save file
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		var data = _parse_json_string(json_string)
		
		if data == null:
			continue
	
		# Find if node exits
		var node = get_node(data["parent"]).get_node(data["node_name"])
		
		# If node doesn't exist, we create it
		if node == null:
			print("Creating new node: ", data["filename"])
			node = load(data["filename"]).instantiate()
			get_node(data["parent"]).add_child(node)
		
		print("Updating node: ", data["parent"], data["filename"])
		
		# If node handles it own load
		if node.has_method("load_data"):
			node.load_data(data)
		else:
			node.position = Vector3(data["gpos_x"], data["gpos_y"], data["gpos_z"])
			node.rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])
			node.velocity = Vector3(data["velocity_x"], data["velocity_y"], data["velocity_z"])
		
			# Now we set the remaining variables.
			for i in data.keys():
				if i in ["filename", "parent", "gpos_x", "gpos_y", "gpos_z", "rot_x", "rot_y", "rot_z"]:
					continue
				node.set(i, data[i])
		
		# Erase from our list of persists so we don't delete them later
		save_nodes.erase(node)
	
	# Delete all persistant nodes that are left in scene
	for i in save_nodes:
		print("Erasing node: ", i)
		i.queue_free()
		
	on_game_load.emit()
	

func load_save(from_main_menu, index = 0):
	var save_file_path = save_path.path_join(save_filename)
	save_file_path = save_file_path.format({"i" : index})
	
	if not FileAccess.file_exists(save_file_path):
		return # Error! We don't have a save to load.
	
	# Load the file line by line and process that dictionary to restore
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	
	# First line should be the save version for future compatibility checks
	var version = save_file.get_line()
	print("Loading save file, version: ", version)
	
	# Second line is scene name
	#var saved_scene_name = save_file.get_line()
	#print("Save file scene name: ", saved_scene_name)
	
	var scene_name = "res://scenes/main.tscn"
	
	if from_main_menu:
		pending_save_file = save_file
		scene_manager.goto_scene(scene_name)
	else:
		load_save_file(save_file)
	

func scene_loaded(scene_name):
	if pending_save_file:
		load_save_file(pending_save_file)
		pending_save_file = null
	

func create_thumbnail(index):
	# Hide ui to take a screenshot
	UIManager.hide_ui()
	await get_tree().create_timer(0.15).timeout
	
	var image = get_viewport().get_texture().get_image()
	UIManager.unhide_ui()
	
	var filename = save_path.path_join(thumbnail_filename).format({"i" : index})
	image.save_png(filename)
	

func save_system_settings(settings):
	var settings_file_path = settings_path.path_join(system_settings_file_name)
	
	var settings_file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	
	settings_file.store_line(JSON.stringify(settings))
	

func load_system_settings():
	var settings_file_path = settings_path.path_join(system_settings_file_name)
	
	if not FileAccess.file_exists(settings_file_path):
		return # Error! We don't have a settings file
	
	var settings_file = FileAccess.open(settings_file_path, FileAccess.READ)
	var settings_data_json_string = settings_file.get_line()
	var settings_data = _parse_json_string(settings_data_json_string)
	return settings_data
