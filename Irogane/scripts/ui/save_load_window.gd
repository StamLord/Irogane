extends UIWindow

enum window_type_enum {SAVE, LOAD}
@export var window_type : window_type_enum

@onready var window_title = $Panel/title
@onready var prefab = $Panel/MarginContainer/HBoxContainer/Panel/ScrollContainer/VBoxContainer/save_load_button
@onready var buttons_container = $Panel/MarginContainer/HBoxContainer/Panel/ScrollContainer/VBoxContainer
@onready var thumbnail_rect = $Panel/MarginContainer/HBoxContainer/info_panel/VBoxContainer/save_thumbnail
@onready var date_label = $Panel/MarginContainer/HBoxContainer/info_panel/VBoxContainer/Panel/VBoxContainer/date_label
@onready var level_label = $Panel/MarginContainer/HBoxContainer/info_panel/VBoxContainer/Panel/VBoxContainer/level_label
@onready var name_label = $Panel/MarginContainer/HBoxContainer/info_panel/VBoxContainer/Panel/VBoxContainer/name_label
@onready var version_label = $Panel/MarginContainer/HBoxContainer/info_panel/VBoxContainer/Panel/VBoxContainer/version_label


func _ready():
	window_title.text = "Load Game" if window_type == window_type_enum.LOAD else "Save Game"
	visibility_changed.connect(_on_visibility_changed)
	SaveSystem.on_game_save.connect(_on_visibility_changed)
	

func _on_visibility_changed():
	# Delete all children except prefab
	for child in buttons_container.get_children():
		if child != prefab:
			child.queue_free()
	
	# If save, create a new save button first
	if window_type == window_type_enum.SAVE:
		var new_button = prefab.duplicate()
		new_button.text = "New Save"
		new_button.pressed.connect(SaveSystem.save_game)
		new_button.visible = true
		buttons_container.add_child(new_button)
		
	# Create a button per save file
	var files = SaveSystem.get_save_files()
	for file in files:
		var new_button = prefab.duplicate()
		
		# Index is between _ and extension: savefile_X.save
		var index = file.split(".")[0].split("_")[1]
		new_button.text = "Save " + index
		
		if window_type == window_type_enum.SAVE:
			new_button.pressed.connect(SaveSystem.save_game.bind(index))
		elif window_type == window_type_enum.LOAD:
			new_button.pressed.connect(SaveSystem.load_game.bind(index))
		
		new_button.mouse_entered.connect(display_save_info.bind(file))
		
		new_button.visible = true
		buttons_container.add_child(new_button)
	

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
