extends Node3D

# Ref
@onready var body = $".."
@onready var camera = $main_camera

# Mouse
@export var mouse_sensitivity = 0.4;
@export var look_min = -90;
@export var look_max = 90;

# Height
var original_height = 1.8
var new_height = 1.8
var height_duration = 4

# Tilt
var new_tilt = 20
var tilt_duration = 4

var is_tilting = false

# Fov
var original_fov = 75

var can_rotate = true

func _ready():
	original_height = position.y
	original_fov = camera.fov
	
	add_debug_commands()
	

func _input(event):
	if not can_rotate:
		return
	
	if is_tilting:
		return
	
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if event is InputEventMouseMotion:
		body.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(look_min), deg_to_rad(look_max))
	

func change_height(height, duration):
	new_height = height
	height_duration = duration
	
	height_animate()
	

func reset_height(duration):
	change_height(original_height, duration)
	

func height_animate():
	var startTime = Time.get_ticks_msec()
	var duration = height_duration * 1000
	var startHeight = position.y
	
	while Time.get_ticks_msec() - startTime <= duration:
		var t = (Time.get_ticks_msec() - startTime) / duration
		position.y = lerp(startHeight, new_height, t)
		
		# Wait for next frame
		await get_tree().create_timer(0).timeout
	
	position.y = new_height
	

func change_tilt(tilt, duration):
	new_tilt = tilt
	tilt_duration = duration
	
	tilt_animate()
	

func reset_tilt(duration):
	change_tilt(0.0, duration)
	

func tilt_animate():
	var startTime = Time.get_ticks_msec()
	var duration = tilt_duration * 1000
	var startRotation = camera.rotation_degrees.z
	
	is_tilting = true
	
	while Time.get_ticks_msec() - startTime <= duration:
		var t = (Time.get_ticks_msec() - startTime) / duration
		camera.rotation_degrees.z = lerp(startRotation, new_tilt, t)
		
		# Wait for next frame
		await get_tree().create_timer(0).timeout
	
	camera.rotation_degrees.z = new_tilt
	is_tilting = false
	

func fov_animate(new_fov, duration):
	var startTime = Time.get_ticks_msec()
	var startFov = camera.fov
	duration *= 1000
	
	while Time.get_ticks_msec() - startTime <= duration:
		var t = (Time.get_ticks_msec() - startTime) / duration
		camera.fov = lerp(startFov, new_fov, t)
		
		# Wait for next frame
		await get_tree().process_frame
	
	camera.fov = new_fov
	

func set_tilt(tilt):
	camera.rotation_degrees.z = tilt
	

func get_tilt():
	return camera.rotation_degrees.z
	

func set_fov(fov):
	camera.fov = fov
	

func get_fov():
	return camera.fov
	

func reset_fov(duration):
	fov_animate(original_fov, duration)
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"set_fov",
		set_original_fov,
		 [{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New fov value"
			}],
		"Sets the player camera fov to the new value"
		)
	

func set_original_fov(args: Array):
	original_fov = args[0]
	camera.fov = args[0]
	

func look_at_lerp(target : Vector3):
	look_at(target, Vector3.UP)
	

func enable_rotation():
	can_rotate = true
	

func disable_rotation():
	can_rotate = false
	
