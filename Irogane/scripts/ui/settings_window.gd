extends UIWindow


@onready var anti_aliasing_button = %anti_aliasing_button
@onready var resolution_button = %resolution_button
@onready var vsync_button = %vsync_button
@onready var fps_button = %limit_fps_button
@onready var draw_distance_button = %draw_distance_button
@onready var full_screen_button = %full_screen_button

@onready var master_slider = %master_slider
@onready var sound_slider = %sound_slider
@onready var music_slider =  %music_slider

@onready var horizontal_slider = %horizontal_slider
@onready var vertical_slider = %vertical_slider

@onready var fov_slider = %fov_slider


const RESOLUTION_SETTINGS = [Vector2i(800,600), Vector2i(1280,720), Vector2i(1920,1080)]
const ANTI_ALIASING_SETTINGS = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X, Viewport.MSAA_8X]
const VSYNC_SETTINGS = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ENABLED]
const FPS_SETTINGS = [0, 30, 60, 144]
const DRAW_DISTANCE_SETTINGS = [500, 1000, 2000, 4000]

var anti_aliasing = Viewport.MSAA_DISABLED
var draw_distance = 500


func _ready():
	load_system_settings()
	

func _on_anti_aliasing_button_item_selected(index):
	anti_aliasing = ANTI_ALIASING_SETTINGS[index] 
	RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), anti_aliasing)
	save_system_settings()
	

func _on_vsync_button_item_selected(index):
	DisplayServer.window_set_vsync_mode(VSYNC_SETTINGS[index])
	save_system_settings()
	

func _on_limit_fps_button_item_selected(index):
	Engine.max_fps = FPS_SETTINGS[index]
	save_system_settings()
	

func _on_draw_distance_button_item_selected(index):
	draw_distance = DRAW_DISTANCE_SETTINGS[index]
	if CameraEntity.main_camera != null:
		CameraEntity.main_camera.far = draw_distance
		
	save_system_settings()
	

func _on_resolution_button_item_selected(index):
	DisplayServer.window_set_size(RESOLUTION_SETTINGS[index])
	save_system_settings()
	

func _on_full_screen_button_toggled(button_pressed):
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	
	# Update resolution windowed
	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		_on_resolution_button_item_selected(resolution_button.selected)
	save_system_settings()
	

func save_system_settings():
	SaveSystem.save_system_settings(get_system_settings())
	

func get_system_settings():
	var resolution = DisplayServer.window_get_size()
	
	return {
		"anti_aliasing": anti_aliasing,
		"vsync": DisplayServer.window_get_vsync_mode(),
		"max_fps": Engine.max_fps,
		"draw_distance": draw_distance,
		"resolution": [resolution.x, resolution.y],
		"full_screen": DisplayServer.window_get_mode(),
		"master_level": master_slider.value,
		"sound_level": sound_slider.value,
		"music_level": music_slider.value,
		"mouse_sensitivity_horizontal": horizontal_slider.value,
		"mouse_sensitivity_vertical": vertical_slider.value,
		"camera_fov": fov_slider.value
	}
	

func apply_system_settings(data):
	if "anti_aliasing" in data:
		var _anti_aliasing = data["anti_aliasing"]
		var anti_aliasing_index = ANTI_ALIASING_SETTINGS.find(int(_anti_aliasing))
		
		if anti_aliasing_index != -1:
			anti_aliasing_button.select(anti_aliasing_index)
			RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), _anti_aliasing)
		
	if "vsync" in data:
		var vsync = data["vsync"]
		var vsync_index = VSYNC_SETTINGS.find(int(vsync))

		if vsync_index != -1:
			vsync_button.select(vsync_index)
			DisplayServer.window_set_vsync_mode(vsync)
		
	if "max_fps" in data:
		var max_fps = data["max_fps"]
		var fps_index = FPS_SETTINGS.find(int(max_fps))
	
		if fps_index != -1:
			fps_button.select(fps_index)
			Engine.max_fps = max_fps
		
	if "draw_distance" in data:
		var _draw_distance = data["draw_distance"]
		var draw_distance_index = DRAW_DISTANCE_SETTINGS.find(int(_draw_distance))
		
		if draw_distance_index != -1:
			draw_distance_button.select(draw_distance_index)
			if CameraEntity.active_camera != null:
				CameraEntity.active_camera.far = _draw_distance
	
	if "resolution" in data:
		var resolution = data["resolution"]
		var res_vector = Vector2i(resolution[0], resolution[1])
		var res_index = RESOLUTION_SETTINGS.find(res_vector)
	
		if res_index != -1:
			resolution_button.select(res_index)
			DisplayServer.window_set_size(res_vector)
	
	if "full_screen" in data:
		full_screen_button.button_pressed = data["full_screen"] == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(data["full_screen"])
	
	if "master_level" in data:
		master_slider.value = data["master_level"]
	
	if "sound_level" in data:
		sound_slider.value = data["sound_level"]
	
	if "music_level" in data:
		music_slider.value = data["music_level"]
	
	if "mouse_sensitivity_horizontal" in data:
		horizontal_slider.value = data["mouse_sensitivity_horizontal"]
	
	if "mouse_sensitivity_vertical" in data:
		vertical_slider.value = data["mouse_sensitivity_vertical"]
	
	if "camera_fov" in data:
		fov_slider.value = data["camera_fov"]
	

func load_system_settings():
	var save_data = SaveSystem.load_system_settings()
	
	if save_data:
		apply_system_settings(save_data)
	

func _on_horizontal_slider_value_changed(value):
	ControlSettings.set_mouse_sensitivity_x(value)
	save_system_settings()
	

func _on_vertical_slider_value_changed(value):
	ControlSettings.set_mouse_sensitivity_y(value)
	save_system_settings()
	

func _on_fov_slider_value_changed(value):
	ControlSettings.set_camera_fov(value)
	save_system_settings()
