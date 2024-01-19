extends Node3D

# Male materials
var male_skin_material: StandardMaterial3D = load("res://assets/models/male/materials/male_skin.tres").duplicate()
var male_face_material: ShaderMaterial = load("res://assets/models/male/materials/male_face.tres").duplicate()

# Female materials
var female_skin_material: StandardMaterial3D = load("res://assets/models/female/materials/female_skin.tres").duplicate()
var female_face_material: ShaderMaterial = load("res://assets/models/female/materials/female_face.tres").duplicate()

# Shared hair material
const HAIR_MATERIAL_0_PATH = "res://assets/materials/hair/hair_0.tres"
const HAIR_MATERIAL_1_PATH = "res://assets/materials/hair/hair_1.tres"

var hair_material_0: StandardMaterial3D = load(HAIR_MATERIAL_0_PATH).duplicate()
var hair_material_1: StandardMaterial3D = load(HAIR_MATERIAL_1_PATH).duplicate()

@onready var male_model = $male_model
@onready var female_model = $female_model

enum GENDER {MALE, FEMALE}
var current_gender = GENDER.MALE

# Defines part names and default values
var default_selections = {
	"hair": -1,
	"bangs": -1,
	"facial": -1,
	"mask": -1,
	"top": -1,
	"bottom": -1,
	"shoes": -1
	}

# part_name : [part_node,...]
var male_parts = { }
var female_parts = { }

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
		male_parts[key] = []
		female_parts[key] = []
		current_selections[key] = default_selections[key]
	
	# Get parts on both models and set duplicate materials
	init_parts_on_model(male_model, male_parts, male_skin_material, male_face_material)
	init_parts_on_model(female_model, female_parts, female_skin_material, female_face_material)
	

func init_parts_on_model(model_node, parts_dict, skin_material, face_material):
	for child in model_node.get_node("Armature/Skeleton3D").get_children():
		# Check first part of name eg "bangs" from "bangs_01"
		var part_name = child.name.split("_")[0]
		if parts_dict.has(part_name):
			parts_dict[part_name].append(child)
		
		# Set duplicate materials
		if part_name in ["hair", "bangs", "facial"]:
			if child is MeshInstance3D and child.mesh != null:
				var material_0 = child.mesh.surface_get_material(0)
				var material_1 = child.mesh.surface_get_material(1)
				if material_0 != null:
					child.set_surface_override_material(0, get_duplicate_material(material_0))
				if material_1 != null:
					child.set_surface_override_material(1, get_duplicate_material(material_1))
		elif part_name in ["body"]:
			child.set_surface_override_material(0, skin_material)
			child.set_surface_override_material(1, face_material)
	

func get_duplicate_material(material : Material):
	var path = material.get_path()
	if path == HAIR_MATERIAL_0_PATH:
		return hair_material_0
	elif path == HAIR_MATERIAL_1_PATH:
		return hair_material_1
	
	# Default
	return hair_material_0
	

func mask_parts(parts_to_mask, mask: bool):
	for part in parts_to_mask:
		# Hide / Show part
		var index = current_selections[part]
		if index >= 0:
			get_parts()[part][index].visible = !mask
	

func set_part(args):
	show_part_at_index(args[0], args[1])
	

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
	var parts = get_parts()
	
	if not parts.has(part):
		print("Error! No part named %s ", part)
		return
	
	# Clamp for safety
	index = clamp(index, -1, parts[part].size() - 1) 
	
	# Hide current selection
	if current_selections[part] > -1 and current_selections[part] < parts[part].size():
		parts[part][current_selections[part]].visible = false
	
	# Show new selection if not -1
	if index >= 0:
		parts[part][index].visible = true
		
		# If this part masks other parts, mask them
		if masks.has(part):
			mask_parts(masks[part], true)
	# If this part is disabled and masks other parts, unmask them
	elif masks.has(part):
		mask_parts(masks[part], false)
	
	# Update selection
	current_selections[part] = index
	

func cycle_part_variation(part: String, increment = 1, allow_no_selection = true):
	var parts = get_parts()
	
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
	var parts = get_parts()
	
	if not parts[part_name]:
		print("Error! No part named %s", part_name)
		return
	
	var max_index = parts[part_name].size() - 1
	var min_index = -1 if allow_no_selection else 0
	
	var new_selection = rng.randi_range(min_index, max_index)
	
	show_part_at_index(part_name, new_selection)
	
	return new_selection
	

func set_face_index(index: int):
	get_face_material().set_shader_parameter("face", index)
	current_face = index
	

func cycle_face_variation(forward = true):
	var num_options = get_face_material().get_shader_parameter("max_cells")
	var curr_selection = get_face_material().get_shader_parameter("face")
	
	var next_selection = curr_selection + 1 if forward else curr_selection - 1
	
	if next_selection == num_options:
		next_selection = 0
		
	if next_selection == -1:
		next_selection = num_options -1
	
	set_face_index(next_selection)
		
	return next_selection
	

func get_face_selection():
	return get_face_material().get_shader_parameter("face")
	

func randomize_face_variation():
	var rng = RandomNumberGenerator.new()
	var num_options = get_face_material().get_shader_parameter("max_cells")
	
	var new_selection = rng.randi_range(0, num_options - 1)
	
	get_face_material().set_shader_parameter("face", new_selection)
	
	return new_selection
	

func get_visible_part_index(part: String):
	if not current_selections.has(part):
		print("Error! No part named %s", part)
		return -1
	
	return current_selections[part]
	

func set_skin_color(color: Color):
	get_skin_material().albedo_color = color
	get_face_material().set_shader_parameter("ColorParameter", color)
	current_colors["skin"] = color
	

func set_hair_color(color: Color):
	hair_material_0.albedo_color = color
	hair_material_1.albedo_color = color
	current_colors["hair"] = color
	

func set_male_gender():
	set_gender(GENDER.MALE)
	hide_all_parts() # Reset appearance first to avoid last selection being visible
	load_appearance(save_appearance())
	

func set_female_gender():
	set_gender(GENDER.FEMALE)
	hide_all_parts() # Reset appearance first to avoid last selection being visible
	load_appearance(save_appearance())
	

func set_gender(gender : GENDER):
	current_gender = gender
	var is_male = (gender == GENDER.MALE)
	
	# Display relevant model
	male_model.visible = is_male
	female_model.visible = not is_male
	

func save_appearance():
	var data = {
		"gender" : str(current_gender),
		"face" : current_face,
		"skin_color" : [current_colors["skin"].r, current_colors["skin"].g, current_colors["skin"].b],
		"hair_color" : [current_colors["hair"].r, current_colors["hair"].g, current_colors["hair"].b],
		"parts" : current_selections
	}
	
	return data
	

func load_appearance(data):
	if data["gender"] == str(GENDER.FEMALE):
		set_gender(GENDER.FEMALE)
	else: # Default to male
		set_gender(GENDER.MALE)
	
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
	

func get_parts():
	return male_parts if current_gender == GENDER.MALE else female_parts
	

func get_face_material():
	return male_face_material if current_gender == GENDER.MALE else female_face_material
	

func get_skin_material():
	return male_skin_material if current_gender == GENDER.MALE else female_skin_material
	

func hide_all_parts():
	var parts = get_parts()
	for part_name in parts:
		for part in parts[part_name]:
			part.visible = false
	
