extends Node3D

var skin_material: StandardMaterial3D = load("res://assets/materials/human_male/human_skin.tres").duplicate()
var face_material: ShaderMaterial = load("res://assets/materials/human_male/male_faces.tres").duplicate()
var hair_material: StandardMaterial3D = load("res://assets/materials/human_male/hair.tres").duplicate()

# Defines part names and default values
var default_selections = {
	"head" : 0,
	"hair": -1,
	"bangs": -1,
	"facial": -1,
	"mask": -1,
	"top": -1,
	"pants": -1,
	"shoes": -1
	}

# part_name : [part_node,...]
var parts = { }

# part_name : int
var current_selections = { }

var current_colors = {
	"skin" : Color.WHITE,
	"hair" : Color.WHITE,
}

# Parts that mask other parts
var masks = {
	"mask" : ["hair", "bangs", "facial"]
}

var default_face = 0
var current_face = 0

func _ready():
	add_show_part_command()
	add_get_part_options_command()
	
	# Initialize parts
	for key in default_selections:
		parts[key] = []
		current_selections[key] = default_selections[key]
	
	# Get parts on model
	for child in get_node("Armature/Skeleton3D").get_children():
		# Check first part of name eg "bangs" from "bangs_01"
		var part_name = child.name.split("_")[0]
		if parts.has(part_name):
			parts[part_name].append(child)
	
		# Set local duplicate of materials
		if part_name == "head":
			child.set_surface_override_material(0, skin_material)
			child.set_surface_override_material(1, face_material)
		elif part_name in ["hair", "bangs", "facial"]:
			child.set_surface_override_material(0, hair_material)
		elif part_name in ["body"]:
			child.set_surface_override_material(0, skin_material)
			child.set_surface_override_material(1, face_material)
	

func mask_parts(parts_to_mask, mask: bool):
	for part in parts_to_mask:
		if not parts_to_mask.has(part):
			continue
		
		# Hide / Show part
		var index = current_selections[part]
		if index >= 0:
			parts[part][index].visible = !mask
	

func set_part(args):
	self.show_part_at_index(args[0], args[1])
	

func add_show_part_command():
	var args = [
		{
			"arg_name": "part_name",
			"arg_type": DebugCommandsManager.ArgumentType.STRING,
			"arg_description": "part name of the model, as configured in appearance script",
		},
		{
			"arg_name": "index",
			"arg_type": DebugCommandsManager.ArgumentType.INT,
			"arg_description": "index of part variation]",
		}
	]
	
	DebugCommandsManager.add_command("set_part", set_part, args, "Set model part variation by index")
	
func get_part_options(args):
	return str(self.parts[args[0]].size())
	

func add_get_part_options_command():
	var args = [
		{
			"arg_name": "part_name",
			"arg_type": DebugCommandsManager.ArgumentType.STRING,
			"arg_description": "part name of the model, as configured in appearance script",
		},
	]
	
	DebugCommandsManager.add_command("get_part_options", get_part_options, args, "Get number of available options for a model part")
	

func show_part_at_index(part: String, index: int):
	if not parts.has(part):
		print("Error! No part named %s ", part)
		return
	
	# Clamp for safety
	index = clamp(index, -1, parts[part].size()) 
	
	# Hide current selection
	parts[part][current_selections[part]].visible = false
	
	# Show new selection if not -1
	if index >= 0:
		if index > parts[part].size():
			print("Error, invalid index %s" % parts[part].size())
			return
	
		parts[part][index].visible = true
		
		# If this part masks other parts, mask them
		if masks.has(part):
			mask_parts(masks[part], true)
	# If this part is disabled and masks other parts, unmask them
	elif masks.has(part):
		mask_parts(masks[part], false)
	
	# Update selection
	current_selections[part] = index
	#print(current_selections)
	

func cycle_part_variation(part: String, increment = 1, allow_no_selection = true):
	if not parts.has(part):
		print("Error! No part named %s", part)
		return
	
	var index_to_show = current_selections[part] + increment
	var max_size = parts[part].size()
	var min_size = -1 if allow_no_selection else 0
	
	if index_to_show >= max_size:
		index_to_show = min_size
	elif index_to_show < min_size:
		index_to_show = max_size - 1
		
	show_part_at_index(part, index_to_show)
	
	return index_to_show
	

func randomize_part(part_name: String, allow_no_selection = true):
	var rng = RandomNumberGenerator.new()
	
	if not parts[part_name]:
		print("Error! No part named %s", part_name)
		return
	
	var max_index = parts[part_name].size() - 1
	var min_index = -1 if allow_no_selection else 0

	var new_selection = rng.randi_range(min_index, max_index)
	
	show_part_at_index(part_name, new_selection)
	
	return new_selection
	

func set_face_index(index: int):
	face_material.set_shader_parameter("face", index)
	current_face = index
	

func cycle_face_variation(forward = true):
	var num_options = face_material.get_shader_parameter("max_cells")
	var curr_selection = face_material.get_shader_parameter("face")
	
	var next_selection = curr_selection + 1 if forward else curr_selection - 1
	
	if next_selection == num_options:
		next_selection = 0
		
	if next_selection == -1:
		next_selection = num_options -1
	
	face_material.set_shader_parameter("face", next_selection)
		
	return next_selection

func get_face_selection():
	return face_material.get_shader_parameter("face")
	

func randomize_face_variation():
	var rng = RandomNumberGenerator.new()
	var num_options = face_material.get_shader_parameter("max_cells")
	
	var new_selection = rng.randi_range(0, num_options - 1)
	
	face_material.set_shader_parameter("face", new_selection)
	
	return new_selection
	

func get_visible_part_index(part: String):
	if not current_selections.has(part):
		print("Error! No part named %s", part)
		return -1
	
	return current_selections[part]
	

func set_skin_color(color: Color):
	skin_material.albedo_color = color
	face_material.set_shader_parameter("ColorParameter", color)
	current_colors["skin"] = color

func set_hair_color(color: Color):
	hair_material.albedo_color = color
	current_colors["hair"] = color
	

func save_appearance():
	var data = {
		"face" : current_face,
		"skin_color" : [current_colors["skin"].r, current_colors["skin"].g, current_colors["skin"].b],
		"hair_color" : [current_colors["hair"].r, current_colors["hair"].g, current_colors["hair"].b],
		"parts" : current_selections
	}
	
	return data
	

func load_appearance(data):
	set_face_index(data["face"])
	var skin_color = Color(data["skin_color"][0], data["skin_color"][1], data["skin_color"][2])
	var hair_color = Color(data["hair_color"][0], data["hair_color"][1], data["hair_color"][2])
	set_skin_color(skin_color)
	set_hair_color(hair_color)
	
	for part in data["parts"]:
		show_part_at_index(part, data["parts"][part])
	

func load_defaults():
	# Reset face
	set_face_index(default_face)
	
	# Reset parts
	for part in default_selections:
		show_part_at_index(part, default_selections[part])
	

func str_to_color(string):
	var color = string.replace("(","").replace(")","").split(",")
	return Color(color[0].to_float(), color[1].to_float(), color[2].to_float(), color[3].to_float())
	
