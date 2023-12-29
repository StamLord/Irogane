@tool
extends Control

@onready var file_dialog = $FileDialog
@onready var folder_dialog = $FolderDialog

@onready var open_files_label = %open_files_label

@onready var offset_input_x = %offset_x
@onready var offset_input_y = %offset_y
@onready var offset_input_z = %offset_z

@onready var dimensions_input_x = %dimensions_x
@onready var dimensions_input_y = %dimensions_y
@onready var dimensions_input_z = %dimensions_z

@onready var rotation_input_x = %rotations_x
@onready var rotation_input_y = %rotations_y
@onready var rotation_input_z = %rotations_z

var create_prefab_script = load("res://addons/building_blocks/create_prefab.gd")
var create_prefab_instance

var open_files = []
var output_folder = null

var collider_offset = Vector3.ZERO
var default_dimensions = Vector3(0.25, 0.25, 0.25)
var collider_rotation = Vector3(0.0, 0.0, 0.0)

func _ready():
	open_files.clear()
	create_prefab_instance = create_prefab_script.new()
	
	offset_input_x.text = str(collider_offset.x)
	offset_input_y.text = str(collider_offset.y)
	offset_input_z.text = str(collider_offset.z)
	
	dimensions_input_x.text = str(default_dimensions.x)
	dimensions_input_y.text = str(default_dimensions.y)
	dimensions_input_z.text = str(default_dimensions.z)
	
	rotation_input_x.text = str(collider_rotation.x)
	rotation_input_y.text = str(collider_rotation.y)
	rotation_input_z.text = str(collider_rotation.z)
	

func _on_open_model_pressed():
	file_dialog.popup_centered()
	

func _on_create_prefab_pressed():
	folder_dialog.popup_centered()
	

func _on_file_dialog_files_selected(paths):
	open_files = paths
	update_open_files_label(paths)
	

func update_open_files_label(paths = []):
	open_files_label.text = ""
	
	for file_path in paths:
		var file_name = file_path.split("/")[-1]
		open_files_label.text += file_name
		open_files_label.text += "\n"
	

func _on_folder_dialog_dir_selected(dir):
	output_folder = dir
	print(dir)
	

func _on_update_prefab_pressed():
	for file_path in open_files:
		# Load scene resource (PackedScene)
		var packed_scene = load(file_path)
		
		# Instantiate and update scene
		var root = packed_scene.instantiate()
		root = create_prefab_instance.update_prefab(root, default_dimensions, collider_offset, collider_rotation)
		
		# Pack and save scene to same file
		var new_packed_scene = PackedScene.new()
		new_packed_scene.pack(root)
		var error = ResourceSaver.save(new_packed_scene, file_path)
		
		print("Saved to: ", file_path, " Error [{e}]".format({"e" : error}))
	

func _on_offset_x_text_changed():
	var parsed = offset_input_x.text.to_float()
	collider_offset.x = parsed
#	offset_input_x.text = str(parsed)
	

func _on_offset_y_text_changed():
	var parsed = offset_input_y.text.to_float()
	collider_offset.y = parsed
#	offset_input_y.text = str(parsed)
	

func _on_offset_z_text_changed():
	var parsed = offset_input_z.text.to_float()
	collider_offset.z = parsed
	

func _on_dimensions_x_text_changed():
	var parsed = dimensions_input_x.text.to_float()
	default_dimensions.x = parsed
	

func _on_dimensions_y_text_changed():
	var parsed = dimensions_input_y.text.to_float()
	default_dimensions.y = parsed
	

func _on_dimensions_z_text_changed():
	var parsed = dimensions_input_z.text.to_float()
	default_dimensions.z = parsed
	

func _on_rotations_x_text_changed():
	var parsed = rotation_input_x.text.to_float()
	collider_rotation.x = parsed
	

func _on_rotations_y_text_changed():
	var parsed = rotation_input_y.text.to_float()
	collider_rotation.y = parsed
	

func _on_rotations_z_text_changed():
	var parsed = rotation_input_z.text.to_float()
	collider_rotation.z = parsed
	

func _on_clear_files_pressed():
	open_files = []
	update_open_files_label()
	


