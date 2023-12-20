extends Camera3D

func _ready():
	CameraShaker.set_main_camera(self)
	DebugCommandsManager.set_main_camera(self)
	
