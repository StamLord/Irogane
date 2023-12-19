extends Camera3D

func _ready():
	CameraEntity.set_main_camera(self)
	CameraShaker.set_main_camera(self)
