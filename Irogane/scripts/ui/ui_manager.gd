extends Node

var windows : Array[UIWindow]
var ui_node = null

signal open_system_menu()

const UI_SCENE_PATH = "res://prefabs/ui/game_ui.tscn"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveSystem.on_game_load.connect(on_game_load)
	update_context()
	

func create_ui_node_if_needed():
	if ui_node == null:
		var game_ui_scene = ResourceLoader.load(UI_SCENE_PATH)
		ui_node = game_ui_scene.instantiate()
		get_tree().root.add_child(ui_node)
	

func delete_ui_node():
	if ui_node:
		ui_node.queue_free()
	

func close_all_windows():
	var windows_to_close = []
	
	for window in windows:
		if window != null: # After load from main_menu, scene is changed and the windows are freed (null)
			windows_to_close.push_back(window) # can't remove mid iteration so use array to store
	
	for window in windows_to_close:
		window.close()
	
	windows = []
	
	update_context()
	

func on_game_load():
	close_all_windows()
	

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		close_last_window()
	elif Input.is_action_just_pressed("attack_secondary"):
		call_deferred("close_last_window", false) # Deferred to avoid attacking in same frame
	

func add_window(window):
	if window is UIWindow:
		windows.push_front(window)
	
	update_context()
	

func remove_window(window):
	if window is UIWindow:
		windows.erase(window)
	
	update_context()
	

func close_last_window(can_open_menu = true):
	# If no windows to close, open system menu
	if windows.size() < 1:
		if can_open_menu:
			open_system_menu.emit()
		return
	
	if windows[0].close_on_back:
		windows[0].close()
	

func update_cursor():
	if windows.size() > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func window_count():
	return windows.size()
	

func hide_ui():
	for window in windows:
		window.visible = false
	

func unhide_ui():
	for window in windows:
		window.visible = true
	

func get_inventory():
	if ui_node == null:
		return null
	
	return ui_node.get_node("inventory_window/inventory")
	

func update_context():
	if window_count() > 0:
		InputContextManager.switch_context(InputContextType.UI)
	else:
		InputContextManager.switch_context(InputContextType.GAME)
		
	# Cursor must be updated after context switched, 
	# to avoid mouse mode being overriden by context manager listeners
	update_cursor()
	
