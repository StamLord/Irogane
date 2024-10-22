extends Camera3D

@onready var stats = %stats
@onready var main_camera = %main_camera
@onready var rigidbody = $".."

var death_directions = [Vector3.UP, Vector3.DOWN, Vector3.RIGHT, Vector3.LEFT]

func _ready():
	if stats != null:
		stats.on_death.connect(activate_death_cam)
		stats.on_resurrect.connect(deactivate_death_cam)
	

func activate_death_cam():
	if main_camera != null:
		get_parent().global_position = main_camera.global_position
		get_parent().global_rotation = main_camera.global_rotation
		fov = main_camera.fov
		cull_mask = main_camera.cull_mask
		near = main_camera.near
		far = main_camera.far
	
	current = true
	
	if rigidbody != null:
		rigidbody.freeze = false
		await get_tree().process_frame
		rigidbody.apply_impulse(death_directions.pick_random() * 10)
	

func deactivate_death_cam():
	if main_camera != null:
		get_parent().global_position = main_camera.global_position
		get_parent().global_rotation = main_camera.global_rotation
		main_camera.current = true
	
	if rigidbody != null:
		rigidbody.freeze = true
	
