extends Node

var mouse_sensitivity = Vector2()
var mouse_sesitivity_multiplier_variable = 1.0
const MOUSE_SENSITIVITY_MULTIPLIER = 0.3

var camera_fov = 75
signal camera_fov_changed(fov)

func _ready():
	add_debug_commands()
	

func set_mouse_sensitivity_x(value: float):
	mouse_sensitivity.x = value * MOUSE_SENSITIVITY_MULTIPLIER * mouse_sesitivity_multiplier_variable
	

func set_mouse_sensitivity_y(value: float):
	mouse_sensitivity.y = value * MOUSE_SENSITIVITY_MULTIPLIER * mouse_sesitivity_multiplier_variable
	

func set_camera_fov(fov: float):
	camera_fov = fov
	camera_fov_changed.emit(fov)
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"set_fov",
		debug_set_original_fov,
		 [{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New fov value"
			}],
		"Sets the player camera fov to the new value"
		)
	
	DebugCommandsManager.add_command(
		"set_mouse_sensitivity",
		debug_set_sensitivity,
		 [{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New sensitivity value"
			}, {
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New sensitivity value"
			}],
		"Sets the player camera mouse sensitivity to the new value"
		)
	

func debug_set_original_fov(args: Array):
	set_camera_fov(args[0])
	

func debug_set_sensitivity(args: Array):
	set_mouse_sensitivity_x(args[0])
	set_mouse_sensitivity_y(args[1])
	
