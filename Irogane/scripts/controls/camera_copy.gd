extends Camera3D

@onready var main_camera = $"../../.."

func _process(delta):
	global_transform = main_camera.global_transform
