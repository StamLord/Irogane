extends AudioStreamPlayer3D
class_name SpatialAudioStreamPlayer3D

const raycast_max_distance = 10.0
const recalculate_threshold = 1.0
const max_occulsion_check = 20.0

var last_position = null

var room_i = 0
var wet_i = 0
var occulsion_i = 0

var debug = true

var audio_buses = [
	[["s1", "s1o"], ["s2", "s2o"]],
	[["m1", "m1o"], ["m2", "m2o"]],
	[["b1", "b1o"], ["b2", "b2o"]]]

func _process(_delta):
	# Check room size & wetness only after moving
	if last_position == null or global_position.distance_to(last_position) >= recalculate_threshold:
		room_check()
		last_position = global_position
	
	# Check occulsion every frame
	occulsion_check()
	
	# Get proper bus
	bus = audio_buses[room_i][wet_i][occulsion_i]
	
	if debug:
		DebugCanvas.debug_text(bus, global_position + Vector3.UP * 2, Color.GOLD)
	

func room_check():
	var raycast_results = [
		raycast_query(Vector3.FORWARD), 
		raycast_query(Vector3.BACK), 
		raycast_query(Vector3.LEFT),
		raycast_query(Vector3.RIGHT),
		raycast_query(Vector3.FORWARD + Vector3.RIGHT), 
		raycast_query(Vector3.FORWARD + Vector3.LEFT),
		raycast_query(Vector3.BACK + Vector3.RIGHT),
		raycast_query(Vector3.BACK + Vector3.LEFT),
		raycast_query(Vector3.UP),
		raycast_query(Vector3.UP + Vector3.FORWARD),
		raycast_query(Vector3.UP + Vector3.BACK),
		raycast_query(Vector3.UP + Vector3.LEFT),
		raycast_query(Vector3.UP + Vector3.RIGHT)]
	
	var room_size = 0.0
	var wetness = 1.0
	
	for result in raycast_results:
		if result:
			var dist = global_position.distance_to(result.position)
			room_size += (dist / raycast_max_distance) / float(raycast_results.size())
			room_size = min(room_size, 1.0)
		else:
			wetness -= 1.0 / float(raycast_results.size())
			wetness = max(wetness, 0.0)
	
	room_i = min(roundi(room_size * 3), 2)
	wet_i = min(roundi(wetness * 2), 1)
	

func occulsion_check():
	occulsion_i = 1
	
	var player_node = PlayerEntity.player_node
	if player_node == null:
		return
	
	var origin = global_position + Vector3.UP * 1.6
	var target = player_node.global_position + Vector3.UP * 1.6
	
	# Too far
	if (target - origin).length() >= max_occulsion_check:
		return
	
	var result = raycast_query(target - origin)
	if result and result.collider == player_node:
		occulsion_i = 0
	

func raycast_query(direction : Vector3):
	var origin = global_position + Vector3.UP * 1.6
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * raycast_max_distance)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if debug:
		DebugCanvas.debug_line(origin, origin + direction.normalized() * raycast_max_distance, Color.GOLD)
	
	return result
	
