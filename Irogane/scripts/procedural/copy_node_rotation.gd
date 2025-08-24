extends Node3D

func _process(delta):
	if not CameraEntity.main_camera:
		return
	
	global_rotation = CameraEntity.main_camera.global_rotation
	print(global_rotation)
