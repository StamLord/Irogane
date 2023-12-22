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

var create_prefab_script = load("res://addons/building_blocks/create_prefab.gd")
var create_prefab_instance

var open_files = []
var output_folder = null

var offset = Vector3.ZERO
var default_dimensions = Vector3(0.25, 0.25, 0.25)

func _ready():
	open_files.clear()
	create_prefab_instance = create_prefab_script.new()
	
	offset_input_x.text = str(offset.x)
	offset_input_y.text = str(offset.y)
	offset_input_z.text = str(offset.z)
	
	dimensions_input_x.text = str(default_dimensions.x)
	dimensions_input_y.text = str(default_dimensions.y)
	dimensions_input_z.text = str(default_dimensions.z)
	

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
	

func save_current_scene(file_path):
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())
	ResourceSaver.save(file_path, packed_scene)
	

func _on_update_prefab_pressed():
	for file_path in open_files:
		# Load scene resource (PackedScene)
		var packed_scene = load(file_path)
		
		# Instantiate and update scene
		var root = packed_scene.instantiate()
		root = create_prefab_instance.update_prefab(root, default_dimensions, offset)
		
		# Pack and save scene to same file
		var new_packed_scene = PackedScene.new()
		new_packed_scene.pack(root)
		ResourceSaver.save(new_packed_scene, file_path)
	


func _on_offset_x_text_changed():
	var parsed = offset_input_x.text.to_float()
	offset.x = parsed
#	offset_input_x.text = str(parsed)
	

func _on_offset_y_text_changed():
	var parsed = offset_input_y.text.to_float()
	offset.y = parsed
#	offset_input_y.text = str(parsed)
	

func _on_offset_z_text_changed():
	var parsed = offset_input_z.text.to_float()
	offset.z = parsed
	

func _on_dimensions_x_text_changed():
	var parsed = dimensions_input_x.text.to_float()
	default_dimensions.x = parsed
	

func _on_dimensions_y_text_changed():
	var parsed = dimensions_input_y.text.to_float()
	default_dimensions.y = parsed
	

func _on_dimensions_z_text_changed():
	var parsed = dimensions_input_z.text.to_float()
	default_dimensions.z = parsed
	

func _on_clear_files_pressed():
	open_files = []
	update_open_files_label()
	
