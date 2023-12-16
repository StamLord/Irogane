extends Camera3D

@onready var command_manager = get_node("/root/DebugCommandsManager")

func _ready():
	CameraShaker.set_main_camera(self)
	command_manager.set_main_camera(self)
	
