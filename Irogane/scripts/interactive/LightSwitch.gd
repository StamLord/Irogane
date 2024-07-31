extends Switch
class_name LightSwitch

@export var light: Light3D

func perform_animations():
	light.visible = state
	
