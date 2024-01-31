extends Panel

@onready var camera = %Camera3D
@onready var reset_camera_button = %ResetCamera
@onready var node_to_rotate = %human_model #%rotate_around
@onready var face_camera = %face_camera

# Camera and character movement logic
var default_camera_position = Vector3(0, 1.8, 2)
var default_node_rotation = Vector3(0, 22, 0) 

const SCROLL_SPEED = 0.1

const MAX_SCROLL = 0.0
const MIN_SCROLL = -2.0
const MAX_VERTICAL_MOVE = 0.5
const MIN_VERTICAL_MOVE = -0.5
const MAX_HORIZONTAL_MOVE = 0.5

var camera_zoom_position = Vector3.ZERO
var camera_pan_position = Vector3.ZERO
var camera_pan_position_zoom_corrected = Vector3.ZERO

var camera_pan_horizontal_percentage = 0.5
var camera_pan_vertical_percentage = 0.5
var camera_zoom_percentage = 1.0

var rotating = false
var moving = false
var animating_camera = false
var in_control_panel = false
var prev_mouse_position
var next_mouse_position


func _ready():
	default_camera_position = camera.position
	default_node_rotation = node_to_rotate.rotation_degrees
	

func _process(delta):
	if Input.is_action_just_pressed("Rotate"):
		# Only control characer and camera in central panel
		if in_control_panel:
			rotating = true
			prev_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("Rotate"):
		rotating = false
	
	if Input.is_action_just_pressed("Move"):
		# Only control characer and camera in central panel
		if in_control_panel:
			moving = true
			prev_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("Move"):
		moving = false
	
	if rotating:
		reset_camera_button.show()
		next_mouse_position = get_viewport().get_mouse_position()
		node_to_rotate.rotate_y((next_mouse_position.x - prev_mouse_position.x) * .4 * delta)
		prev_mouse_position = next_mouse_position
	
	if moving:
		reset_camera_button.show()
		next_mouse_position = get_viewport().get_mouse_position()
	
		var mouse_delta = next_mouse_position - prev_mouse_position
	
		# Horizontal panning
		camera_pan_horizontal_percentage -= mouse_delta.x * .2 * delta
		camera_pan_horizontal_percentage = clampf(camera_pan_horizontal_percentage, 0.0, 1.0)
	
		# Vertical panning
		camera_pan_vertical_percentage += mouse_delta.y * .3 * delta
		camera_pan_vertical_percentage = clampf(camera_pan_vertical_percentage, 0.0, 1.0)
		
		camera_pan_position.x = lerp(-MAX_HORIZONTAL_MOVE, MAX_HORIZONTAL_MOVE, camera_pan_horizontal_percentage)
		camera_pan_position.y = lerp(MIN_VERTICAL_MOVE, MAX_VERTICAL_MOVE, camera_pan_vertical_percentage)
		
		prev_mouse_position = next_mouse_position
	
	# Zoom in
	if Input.is_action_just_pressed("ScrollUp"):
		if in_control_panel:
			reset_camera_button.show()
			camera_zoom_percentage -= SCROLL_SPEED
			camera_zoom_percentage = max(camera_zoom_percentage, 0.0)
	
	# Zoom out
	if Input.is_action_just_pressed("ScrollDown"):
		if in_control_panel:
			reset_camera_button.show()
			camera_zoom_percentage += SCROLL_SPEED
			camera_zoom_percentage = min(camera_zoom_percentage, 1.0)
	
	# The more zoomed we are, the less panning we want
	camera_pan_position_zoom_corrected = lerp(camera_pan_position * 0.1, camera_pan_position, camera_zoom_percentage)
	
	# Get zoom position that is added to default position
	camera_zoom_position = lerp(face_camera.position, default_camera_position, camera_zoom_percentage)
	
	# Get final camera position
	if not animating_camera:
		var new_position = camera_zoom_position + (camera.basis * camera_pan_position_zoom_corrected)
		camera.position = lerp(camera.position, new_position, 30 * delta)
	

func _on_mouse_entered():
	in_control_panel = true


func _on_mouse_exited():
	in_control_panel = false


# Duration in seconds
func move_camera(target_position: Vector3, duration: float):
	animating_camera = true
	
	# Reset extra camera values
	camera_pan_horizontal_percentage = 0.5
	camera_pan_vertical_percentage = 0.5
	camera_zoom_percentage = 1.0
	
	camera_pan_position = Vector3.ZERO
	camera_zoom_position = Vector3.ZERO
	
	var start_time = Time.get_ticks_msec()
	var start_position = camera.position
	
	duration *= 1000.0
	
	while (Time.get_ticks_msec() - start_time <= duration):
		var step = (Time.get_ticks_msec() - start_time) / duration
		camera.position = lerp(start_position, target_position, step)
		await get_tree().process_frame
		
	camera.position = target_position
	animating_camera = false
	

# Duration in seconds
func rotate_character(target_vector: Vector3, duration: float):
	var start_time = Time.get_ticks_msec()
	var start_rotation = node_to_rotate.rotation_degrees
	
	duration *= 1000.0
	
	while (Time.get_ticks_msec() - start_time <= duration):
		var step = (Time.get_ticks_msec() - start_time) / duration
		node_to_rotate.rotation_degrees = lerp(start_rotation, target_vector, step)
		await get_tree().process_frame
		
	node_to_rotate.rotation_degrees = target_vector
	

func _on_reset_camera_pressed():
	move_camera(default_camera_position, 0.2)
	rotate_character(default_node_rotation, 0.2)
	reset_camera_button.hide()
	
