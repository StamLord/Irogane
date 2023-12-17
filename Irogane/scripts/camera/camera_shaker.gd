extends Camera3D

var main_camera = null
var origin = null

func _ready():
	DebugCommandsManager.add_command(
		"shake_camera",
		shake_debug,
		 [{
				"arg_name" : "amount",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "Shake amount"
			},
			{
				"arg_name" : "duration",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "Shake duration"
		}],
		"Shakes the main camera"
		)
	

func _process(delta):
	if Input.is_key_pressed(KEY_HOME):
		shake(0.25, 0.2)
	

func set_main_camera(camera):
	main_camera = camera
	origin = main_camera.position
	

func shake(amount, duration):
	if main_camera == null:
		return
		
	var start = Time.get_ticks_msec()
	
	while(Time.get_ticks_msec() - start <= duration * 1000.0):
		var t = (Time.get_ticks_msec() - start) / (duration * 1000.0)
		var shake = lerp(amount, 0.0, t)
		
		var offset = Vector3.ZERO
		randomize()
		offset.x = (randf() - 0.5) * 2 * shake
		randomize()
		offset.y = (randf() - 0.5) * 2 * shake
		
		main_camera.position = lerp(main_camera.position, origin + offset, 0.1)
		
		await get_tree().process_frame
	
	main_camera.position = origin
	

func shake2(amount, duration):
	if main_camera == null:
			return
	
	var start = Time.get_ticks_msec()
	var prev_offset = random_point_on_circle()
	
	while(Time.get_ticks_msec() - start <= duration * 1000.0):
		var t = (Time.get_ticks_msec() - start) / (duration * 1000.0)
		var shake = lerp(amount, 0.0, t)
		
		# Flip point on circle to ensure we have a distinct new rotation
		var offset = prev_offset.rotated(180)
		
		# Rotate a small random amount to ensure a random shake
		offset = offset.rotated(randf_range(-30, 30))
		
		# Add shake amount
		offset *= shake
		
		# Move camera
		main_camera.position = lerp(main_camera.position, origin + Vector3(offset.x, offset.y, 0), 0.1)
		
		# Save for next iteration
		prev_offset = offset
		
		await get_tree().process_frame
		
	main_camera.position = origin
	

func random_point_on_circle():
	randomize()
	var point = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	point = point.normalized()
	
	return point
	

func shake_debug(args : Array):
	shake(args[0], args[1])
	
