extends SoundEmitter

@onready var camera = %camera

func _process(delta):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var mouse_pos = event.position
		var space_state = get_world_3d().direct_space_state
		
		# Get the ray start and end from the camera
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0   # 1000 units forward
		
		# Perform raycast
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		
		if result:
			var collision_point = result.position
			emit_sound(collision_point, 10)
			print("Hit at: ", collision_point)
		else:
			print("No hit")
