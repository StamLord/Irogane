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

var look_enabled = true
var is_tilting = false

func _ready():
	original_height = position.y
	UIManager.cursor_lock.connect(enable_look)
	UIManager.cursor_unlock.connect(disable_look)

func _input(event):
	if is_tilting:
		return
	
	if not look_enabled:
		return
	
	if event is InputEventMouseMotion:
		body.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(look_min), deg_to_rad(look_max))

func ChangeHeight(height, duration):
	new_height = height
	height_duration = duration
	
	HeightAnimate()

func ResetHeight(duration):
	ChangeHeight(original_height, duration)

func HeightAnimate():
	var startTime = Time.get_ticks_msec()
	var duration = height_duration * 1000
	var startHeight = position.y
	
	while Time.get_ticks_msec() - startTime <= duration:
		var t = (Time.get_ticks_msec() - startTime) / duration
		position.y = lerp(startHeight, new_height, t)
		
		# Wait for next frame
		await get_tree().create_timer(0).timeout

	position.y = new_height

func ChangeTilt(tilt, duration):
	new_tilt = tilt
	tilt_duration = duration
	
	TiltAnimate()
	
func ResetTilt(duration):
	ChangeTilt(0.0, duration)

func TiltAnimate():
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

func enable_look():
	look_enabled = true
	
func disable_look():
	look_enabled = false