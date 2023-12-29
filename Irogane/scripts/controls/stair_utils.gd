extends Node
class_name StairUtils

static func snap_down_to_stairs_check(body, input_dir, step_check, step_check_distance, max_step_height, was_on_floor_last_frame, snapped_to_stairs_last_frame):
	var snapped_down = false
	
	# Move raycast position according to direction
	step_check.position.x = input_dir.x * step_check_distance
	step_check.position.z = input_dir.z * step_check_distance
	
	if not body.is_on_floor() and body.velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame) and step_check.is_colliding():
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -max_step_height
		params.from = body.global_transform
		params.motion = Vector3(0, max_step_down, 0)
		
		if PhysicsServer3D.body_test_motion(body.get_rid(), params, body_test_result):
			var translate_y = body_test_result.get_travel().y
			body.global_position.y += translate_y
			body.apply_floor_snap()
			snapped_down = true
	
	was_on_floor_last_frame = body.is_on_floor()
	snapped_to_stairs_last_frame = snapped_down
	
	return {"on_floor" : was_on_floor_last_frame, 
			"snapped_down" : snapped_to_stairs_last_frame}
	

static func update_step_separation(step_separation, input_dir, step_check_distance):
	step_separation.position.x = input_dir.x * step_check_distance
	step_separation.position.z = input_dir.z * step_check_distance
	
