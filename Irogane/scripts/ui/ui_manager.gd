extends Node

@onready var save_manager = get_node("/root/SaveSystem")

var windows : Array[UIWindow]

signal cursor_lock()
signal cursor_unlock()

signal open_system_menu()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	save_manager.on_game_load.connect(on_game_load)
	update_cursor()

func close_all_windows():
	var windows_to_close = []
	
	for window in windows:
		if window != null: # After load from main_menu, scene is changed and the windows are freed (null)
			windows_to_close.push_back(window) # can't remove mid iteration so use array to store
	
	for window in windows_to_close:
		window.close()
	
	windows = []
	update_cursor()
	

func on_game_load():
	close_all_windows()
	

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		close_last_window()

func add_window(window):
	if window is UIWindow:
		windows.push_front(window)
	update_cursor()

func remove_window(window):
	if window is UIWindow:
		windows.erase(window)
	update_cursor()

func close_last_window():
		# If no windows to close, open system menu
	if windows.size() < 1:
		open_system_menu.emit()
		return
	
	if windows[0].close_on_back:
		windows[0].close()
	

func update_cursor():
	if windows.size() > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursor_unlock.emit()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cursor_lock.emit()
	

func window_count():
	return windows.size()
	

func hide_ui():
	for window in windows:
		window.visible = false
	

func unhide_ui():
	for window in windows:
		window.visible = true
	
