extends Node

var windows : Array[UIWindow]

signal cursor_lock()
signal cursor_unlock()

func _ready():
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
	if windows.size() < 1:
		return
	
	windows[0].close()

func update_cursor():
	if windows.size() > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursor_unlock.emit()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cursor_lock.emit()
