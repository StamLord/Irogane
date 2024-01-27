extends Control

@onready var ui_screens = [$appearance_UI, $attributes_UI, $boons_UI]

var current_ui_screen_index = 0
var char_name = null
var char_sex = null
var appearance_data = null
var attributes_data = null
var boons = []
var flaws = []
var ambition = null

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
		start_new_game()
	
	var curr_ui_screen
	
	curr_ui_screen = ui_screens[current_ui_screen_index]
	
	curr_ui_screen.visible = false
	
	current_ui_screen_index += 1
	
	curr_ui_screen = ui_screens[current_ui_screen_index]
	curr_ui_screen.visible = true
	

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		prev_ui_screen()
	

func load_appearance(data):
	char_sex = data.sex
	appearance_data = data.appearance
	

func load_attributes(data):
	attributes_data = data
	

func load_boons(data):
	boons = data.boons
	flaws = data.flaws
	ambition = data.ambition
	

func start_new_game():
	var char_dict = {
		"name": char_name,
		"sex": char_sex,
		"appearance" : appearance_data,
		"attributes": attributes_data,
	}
	SceneManager.goto_scene("res://scenes/main.tscn")
	PlayerEntity.load_player_data(char_dict)
	
