extends Node3D

@export var chunk : Node3D
@export var range = 50
func _process(delta):
	if chunk == null:
		return
	
	var camera = CameraEntity.main_camera
	if camera == null:
		return
	
	var resolution = 16
	var angle = 360.0 / resolution
	var prev_point = null
	for i in range(resolution):
		var offset = Vector3(0, 0, range).rotated(Vector3.UP, deg_to_rad(angle * i))
		var point = chunk.global_position + offset
		
		if prev_point != null:
			DebugCanvas.debug_line(prev_point, point, Color.PURPLE)
		
		prev_point = point
		
	
	if global_position.distance_to(camera.global_position) >= range:
		chunk.process_mode = Node.PROCESS_MODE_DISABLED
		#print(chunk, " set to disabled")
	else:
		chunk.process_mode = Node.PROCESS_MODE_INHERIT
	
	
