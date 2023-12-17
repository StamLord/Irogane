extends PanelContainer

@onready var scene_manager = get_node("/root/SceneManager")
@onready var progress_bar = %TextureProgressBar
@onready var bg_image = %bg_image
@onready var bg_images = [preload("res://assets/images/golden_castle.jpg"), preload("res://assets/images/red_cliff.jpg")]

var progress = []
var scene_load_status = 0

func _ready():
	randomize_image()
	

func randomize_image():
	var rng = RandomNumberGenerator.new()
	var image_index = rng.randi_range(0, bg_images.size() - 1)
	bg_image.texture = bg_images[image_index]
	

func _exit_tree():
	randomize_image()
	

func _process(delta):
	var scene_name = scene_manager.loading_scene_name
	
	if scene_name:
		scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
		var new_value = floor(progress[0] * 100)
		if new_value > progress_bar.value:
			progress_bar.value = new_value
	
