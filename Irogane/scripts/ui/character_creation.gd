extends Control

var current_ui_screen_index = 0
@onready var ui_screens = [$appearance_UI, $attributes_UI]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func prev_ui_screen():
	if current_ui_screen_index == 0:
		SceneManager.goto_scene_no_load("res://scenes/main_menu.tscn")
		return
	
	var curr_ui_screen = ui_screens[current_ui_screen_index]
	curr_ui_screen.visible = false
	current_ui_screen_index -= 1
	
	curr_ui_screen = ui_screens[current_ui_screen_index]
	curr_ui_screen.visible = true
	

func next_ui_screen():
	if current_ui_screen_index == ui_screens.size() - 1:
		pass #max screen
	
	var curr_ui_screen
	

	curr_ui_screen = ui_screens[current_ui_screen_index]
	
	curr_ui_screen.visible = false
	
	current_ui_screen_index += 1
	
	curr_ui_screen = ui_screens[current_ui_screen_index]
	curr_ui_screen.visible = true
	

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		prev_ui_screen()
	
