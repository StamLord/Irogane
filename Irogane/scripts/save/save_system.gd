extends Node

const save_path = "user://"
const save_filename = "savegame_{i}.save"
const thumbnail_filename = "savegame_{i}.png"

signal on_game_save()
signal on_game_load()

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
	var thumbnail_filename = save_path.path_join(filename.replace(".save", ".png"))
	
	if FileAccess.file_exists(thumbnail_filename):
		var image = Image.new()
		image.load(thumbnail_filename)
		info["thumbnail"] = ImageTexture.new().create_from_image(image)
	
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
		if !node.has_method("save"):
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
	

func load(index = 0):
	var save_file = save_path.path_join(save_filename)
	save_file = save_file.format({"i" : index})
	
	if not FileAccess.file_exists(save_file):
		return # Error! We don't have a save to load.
	
	# Get all objects in current scene that should be saveable
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	# Load the file line by line and process that dictionary to restore
	var save_game = FileAccess.open(save_file, FileAccess.READ)
	
	# First line should be the save version for future compatibility checks
	var version = save_game.get_line()
	print("Loading save file, version: ", version)
	
	# Iterate over save file
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var data = json.get_data()
		
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
	

func create_thumbnail(index):
	# Hide ui to take a screenshot
	UIManager.hide_ui()
	await get_tree().create_timer(0.15).timeout
	
	var image = get_viewport().get_texture().get_image()
	UIManager.unhide_ui()
	
	var filename = save_path.path_join(thumbnail_filename).format({"i" : index})
	image.save_png(filename)
	
