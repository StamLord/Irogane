extends Node

const GAME_DIR_PATH = "user://"
const SAVE_DIR_NAME = "saves"
const SETTINGS_DIR_NAME = "settings"
const SAVE_FILE_NAME = "savegame_{i}.save"
const THUMBNAIL_FILE_NAME = "savegame_{i}.png"
const SYSTEM_SETTINGS_FILE_NAME = "system.config"

const SETTINGS_VERSION = 0.2

var save_path = GAME_DIR_PATH.path_join(SAVE_DIR_NAME)
var settings_path = GAME_DIR_PATH.path_join(SETTINGS_DIR_NAME)

# Creates the helper class to interact with JSON
var JSON_HELPER = JSON.new()

signal on_game_save()
signal on_game_load()


func create_dirs_if_needed():
	var directory = DirAccess.open(GAME_DIR_PATH)
	
	if not directory.dir_exists(SAVE_DIR_NAME):
		directory.make_dir(SAVE_DIR_NAME)
		
	if not directory.dir_exists(SETTINGS_DIR_NAME):
		directory.make_dir(SETTINGS_DIR_NAME)
	

func _ready():
	create_dirs_if_needed()
	

func get_save_files():
	var directory = DirAccess.open(save_path)
	var files = directory.get_files()
	
	# Filter items according to filename convention
	var saves = []
	for file in files:
		if file.split("_")[0] != SAVE_FILE_NAME.split("_")[0]:
			continue
		if file.split(".")[1] != SAVE_FILE_NAME.split(".")[1]:
			continue
		saves.append(file)
	
	return saves
	

func get_save_file_info(filename):
	var save_file_path = save_path.path_join(filename)
	var info = {}
	
	if not FileAccess.file_exists(save_file_path):
		return info
	
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	
	# First line should be the save version for future compatibility checks
	var version_dict = _parse_json_string(save_file.get_line())
	
	if version_dict == null:
		info["version"] = "ERROR"
		
	var version = version_dict["version"]
	
	# Second line is scene name
	var scene_dict = _parse_json_string(save_file.get_line())
	
	if scene_dict == null:
		info["scene_name"] = "ERROR"
	
	var scene_name = scene_dict["scene"]
	
	info["version"] = version
	info["scene_name"] = scene_name
	
	# Get Date
	info["date"] = FileAccess.get_modified_time(save_file_path)
	
	# Get thumbnail as ImageTexture
	var new_thumbnail_filename = save_path.path_join(filename.replace(".save", ".png"))
	
	if FileAccess.file_exists(new_thumbnail_filename):
		var image = Image.new()
		image.load(new_thumbnail_filename)
		info["thumbnail"] = ImageTexture.create_from_image(image)
	
	# Get player level
	var player_data = _parse_json_string(save_file.get_line())
	info["name"] = player_data["name"]
	info["level"] = player_data["stats"]["level"]
	
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
	

func save_game(index = null):
	# Generate next index if not provided
	if index == null:
		index = str(get_highest_save_index() + 1)
	
	var save_file_path = save_path.path_join(SAVE_FILE_NAME)
	save_file_path = save_file_path.format({"i" : index})
	
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	
	save_file.store_line(JSON.stringify({"version" : SETTINGS_VERSION}))
	save_file.store_line(JSON.stringify({"scene" : SceneManager.current_scene.scene_file_path}))
	
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
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(JSON.stringify(node_data))
	
	# Generate thumbnail
	create_thumbnail(index)
	
	on_game_save.emit()
	

func _parse_json_string(json_string):
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = JSON_HELPER.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", JSON_HELPER.get_error_message(), " in ", json_string, " at line ", JSON_HELPER.get_error_line())
		return null

	# Get the data from the JSON object
	var data = JSON_HELPER.get_data()
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
		
	

func load_game(index = 0):
	on_game_load.emit()
	var save_file_path = save_path.path_join(SAVE_FILE_NAME)
	save_file_path = save_file_path.format({"i" : index})
	
	if not FileAccess.file_exists(save_file_path):
		print("Error, Save file not found %s", save_file_path)
		return # Error! We don't have a save to load.
	
	# Load the file line by line and process that dictionary to restore
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	
	# First line should be the save version for future compatibility checks
	var version_dict = _parse_json_string(save_file.get_line())
	
	if version_dict == null:
		print("Error, could not find version in save file")
		return
		
	var version = version_dict["version"]
	print("Loading save file, version: ", version)
	
	if version_dict["version"] != SETTINGS_VERSION:
		print("Error, save version mismatch, current: %s, got: ", SETTINGS_VERSION, version)
		return
	
	# Second line is scene name
	var scene_dict = _parse_json_string(save_file.get_line())
	
	if scene_dict == null:
		print("Error, could not find scene name")
		return
	
	var scene_name = scene_dict["scene"]
	print("Loaded scene name: ", scene_name)

	PlayerEntity.create_player_node_if_needed()
	UIManager.create_ui_node_if_needed()
	
	SceneManager.goto_scene(scene_name)
	await SceneManager.on_scene_loaded

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
		
	

func create_thumbnail(index):
	# Hide ui to take a screenshot
	UIManager.hide_ui()
	await get_tree().create_timer(0.15).timeout
	
	var image = get_viewport().get_texture().get_image()
	UIManager.unhide_ui()
	
	var filename = save_path.path_join(THUMBNAIL_FILE_NAME).format({"i" : index})
	image.save_png(filename)
	

func save_system_settings(settings):
	var settings_file_path = settings_path.path_join(SYSTEM_SETTINGS_FILE_NAME)
	var settings_file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	settings_file.store_line(JSON.stringify(settings))
	

func load_system_settings():
	var settings_file_path = settings_path.path_join(SYSTEM_SETTINGS_FILE_NAME)
	
	if not FileAccess.file_exists(settings_file_path):
		return # Error! We don't have a settings file
	
	var settings_file = FileAccess.open(settings_file_path, FileAccess.READ)
	var settings_data_json_string = settings_file.get_line()
	var settings_data = _parse_json_string(settings_data_json_string)
	return settings_data
