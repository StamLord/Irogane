extends PanelContainer

@onready var scene_manager = get_node("/root/SceneManager")
@onready var progress_bar = %ProgressBar

var progress = []
var scene_load_status = 0

func _process(delta):
	var scene_name = scene_manager.loading_scene_name
	if scene_name:
		scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
		var new_value = floor(progress[0] * 100)
		if new_value > progress_bar.value:
			progress_bar.value = new_value
	
