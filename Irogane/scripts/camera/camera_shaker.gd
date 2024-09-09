extends Camera3D

var origin = null

func _ready():
	
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	
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
	

func subscribe_to_player(player_node):
	var stats = player_node.get_node("stats")
	if stats:
		stats.on_hit.connect(hit_vfx)
	

func get_camera_origin():
	if origin == null:
		if CameraEntity.active_camera == null:
			Utils.warning(self, "No active_camera in CameraEntity. This shouldn't happen!")
			origin = Vector3.UP * 2
		else:
			origin = CameraEntity.active_camera.position
	return origin
	

func hit_vfx(attack_info):
	shake(lerp(0.5, 2.0, attack_info.soft_damage / 45), 0.2)
	

func _process(_delta):
	if Input.is_key_pressed(KEY_HOME):
		shake(0.25, 0.2)
	

func shake(amount: float, duration: float):
	var start = Time.get_ticks_msec()
	
	while(Time.get_ticks_msec() - start <= duration * 1000.0):
		var t = (Time.get_ticks_msec() - start) / (duration * 1000.0)
		var _shake = lerp(amount, 0.0, t)
		
		var offset = Vector3.ZERO
		randomize()
		offset.x = (randf() - 0.5) * 2 * _shake
		randomize()
		offset.y = (randf() - 0.5) * 2 * _shake
		
		if CameraEntity.active_camera != null:
			CameraEntity.active_camera.position = lerp(CameraEntity.active_camera.position, get_camera_origin() + offset, 0.1)
		
		await get_tree().process_frame
	
	if CameraEntity.active_camera != null:
		CameraEntity.active_camera.position = get_camera_origin()
	

func shake2(amount, duration):
	var origin = CameraEntity.active_camera.position
	
	var start = Time.get_ticks_msec()
	var prev_offset = random_point_on_circle()
	
	while(Time.get_ticks_msec() - start <= duration * 1000.0):
		var t = (Time.get_ticks_msec() - start) / (duration * 1000.0)
		var _shake = lerp(amount, 0.0, t)
		
		# Flip point on circle to ensure we have a distinct new rotation
		var offset = prev_offset.rotated(180)
		
		# Rotate a small random amount to ensure a random shake
		offset = offset.rotated(randf_range(-30, 30))
		
		# Add shake amount
		offset *= _shake
		
		# Move camera
		CameraEntity.active_camera.position = lerp(CameraEntity.active_camera.position, origin + Vector3(offset.x, offset.y, 0), 0.1)
		
		# Save for next iteration
		prev_offset = offset
		
		await get_tree().process_frame
		
	CameraEntity.active_camera.position = origin
	

func random_point_on_circle():
	randomize()
	var point = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	point = point.normalized()
	
	return point
	

func shake_debug(args : Array):
	shake(args[0], args[1])
	
