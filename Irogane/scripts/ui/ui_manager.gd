extends Node

var windows : Array[UIWindow]

signal cursor_lock()
signal cursor_unlock()

signal open_system_menu()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_cursor()
	

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
	
