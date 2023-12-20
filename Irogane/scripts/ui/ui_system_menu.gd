extends UIWindow
@onready var settings = $settings
@onready var save = $save
@onready var load_window = $load
@onready var resolution_button = $settings/Panel/MarginContainer/ScrollContainer/VBoxContainer/graphics_margin/HBoxContainer/resolution/resolution_button
@onready var scene_manager = get_node("/root/SceneManager")

func _ready():
	UIManager.open_system_menu.connect(open)
	
func open():
	visible = true
	UIManager.add_window(self)
	get_tree().paused = true
	

func close():
	settings.close()
	
	visible = false
	UIManager.remove_window(self)
	get_tree().paused = false
	

func _on_continue_pressed():
	save.close()
	load_window.close()
	settings.close()
	close()
	

func _on_save_pressed():
	save.open()
	load_window.close()
	settings.close()
	

func _on_load_pressed():
	load_window.open()
	save.close()
	settings.close()
	

func _on_settings_pressed():
	settings.open()
	save.close()
	load_window.close()
	

func _on_quit_pressed():
	close()
	scene_manager.goto_scene_no_load("res://scenes/main_menu.tscn")
	

