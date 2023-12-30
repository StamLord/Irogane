extends UIWindow
@onready var settings_window = $settings_window
@onready var save_window = $game_save_window
@onready var load_window = $game_load_window


func _ready():
	UIManager.open_system_menu.connect(open)
	

func open():
	visible = true
	UIManager.add_window(self)
	get_tree().paused = true
	

func close():
	settings_window.close()
	
	visible = false
	UIManager.remove_window(self)
	get_tree().paused = false


func _on_continue_pressed():
	save_window.close()
	load_window.close()
	settings_window.close()
	close()
	

func _on_save_pressed():
	save_window.open()
	load_window.close()
	settings_window.close()
	

func _on_load_pressed():
	load_window.open()
	save_window.close()
	settings_window.close()
	

func _on_settings_pressed():
	settings_window.open()
	save_window.close()
	load_window.close()
	

func _on_quit_pressed():
	close()
	SceneManager.goto_scene_no_load("res://scenes/main_menu.tscn")
	

