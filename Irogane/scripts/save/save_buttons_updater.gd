extends VBoxContainer

enum button_type_enum {SAVE, LOAD}
@export var button_type : button_type_enum

@onready var prefab = $Button
@onready var thumbnail_rect = $"../../../info_panel/VBoxContainer/save_thumbnail"
@onready var load_window = $"../../../../../.."
@onready var date_label = $"../../../info_panel/VBoxContainer/Panel/VBoxContainer/date_label"
@onready var level_label = $"../../../info_panel/VBoxContainer/Panel/VBoxContainer/level_label"
@onready var name_label = $"../../../info_panel/VBoxContainer/Panel/VBoxContainer/name_label"
@onready var version_label = $"../../../info_panel/VBoxContainer/Panel/VBoxContainer/version_label"

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	SaveSystem.on_game_save.connect(_on_visibility_changed)
	

func _on_visibility_changed():
	# Delete all children except prefab
	for child in get_children():
		if child != prefab:
			child.queue_free()
	
	# If save, create a new save button first
	if button_type == button_type_enum.SAVE:
		var button = prefab.duplicate()
		button.text = "NEW SAVE"
		button.pressed.connect(SaveSystem.save)
		button.visible = true
		add_child(button)
		
	# Create a button per save file
	var files = SaveSystem.get_save_files()
	for file in files:
		var button = prefab.duplicate()
		
		# Index is between _ and extension: savefile_X.save
		var index = file.split(".")[0].split("_")[1]
		button.text = "SAVE " + index
		
		if button_type == button_type_enum.SAVE:
			button.pressed.connect(SaveSystem.save.bind(index))
		elif button_type == button_type_enum.LOAD:
			button.pressed.connect(SaveSystem.load_save.bind(index))
		
		button.mouse_entered.connect(display_save_info.bind(file))
		
		button.visible = true
		add_child(button)
	

func display_save_info(filename):
	var info = SaveSystem.get_save_file_info(filename)
	
	# Date
	var date = Time.get_datetime_string_from_unix_time(info["date"]) # YYYY-MM-DDTHH:MM:SS
	date = date.replace("T", " ")
	date_label.text = date
	version_label.text = "Version %s" % info["version"]
	name_label.text = info["name"]
	level_label.text = "Level %s" % info["level"]
	
	# Thumbnail
	thumbnail_rect.texture = info["thumbnail"] if info.has("thumbnail") else null
	
