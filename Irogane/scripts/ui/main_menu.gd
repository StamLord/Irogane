extends UIWindow

@onready var scene_manager = get_node("/root/SceneManager")
@onready var load_window = $game_load_window
@onready var settings_window = $settings_window
@onready var start_button = %start_button

@onready var start_sound = load("res://assets/audio/ui/taiko_hit_1.ogg")

func _ready():
	visible = true
	UIManager.add_window(self)
	start_button.grab_focus()
	

func _on_start_button_pressed():
	GlobalAudio.play_audio(start_sound)
	close()
	scene_manager.goto_scene("res://prefabs/ui/character_creator.tscn")
	

func _on_load_button_pressed():
	load_window.open()
	

func _on_quit_button_pressed():
	get_tree().quit()
	

func _on_settings_button_pressed():
	settings_window.open()
