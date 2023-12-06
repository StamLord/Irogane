extends UIWindow
@onready var settings = $settings
@onready var resolution_button = $settings/Panel/MarginContainer/ScrollContainer/VBoxContainer/graphics_margin/HBoxContainer/resolution/resolution_button


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
	close()
	

func _on_settings_pressed():
	settings.open()
	

func _on_quit_pressed():
	get_tree().quit()
	

func _on_anti_aliasing_button_item_selected(index):
	var settings = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X, Viewport.MSAA_8X]
	RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), settings[index])
	

func _on_vsync_button_item_selected(index):
	var settings = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ENABLED]
	DisplayServer.window_set_vsync_mode(settings[index])
	

func _on_limit_fps_button_item_selected(index):
	var settings = [0, 30, 60, 144]
	Engine.max_fps = settings[index]
	

func _on_draw_distance_button_item_selected(index):
	var settings = [500, 1000, 2000, 4000]
	CameraShaker.main_camera.far = settings[index]

func _on_full_screen_button_toggled(button_pressed):
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	# Update resolution windowed
	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		_on_resolution_button_item_selected(resolution_button.selected)
	

func _on_resolution_button_item_selected(index):
	var settings = [Vector2i(800,600), Vector2i(1280,720), Vector2i(1920,1080)]
	DisplayServer.window_set_size(settings[index])
