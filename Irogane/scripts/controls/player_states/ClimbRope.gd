extends PlayerState
class_name ClimbRope

# References
@onready var rope_check = $"../../rope_check"
@onready var wall_check = $"../../wall_check"
@onready var ledge_check = $"../../ledge_check"

# Variables
@export var speed = 5.0;
@export var acceleration = 10
@export var push_force = 2
@export_flags_3d_physics var ledge_mask

var direction = Vector3.ZERO
var vertical_direction : float
var rope : Rope
var rope_segment_index : int
var rope_segment
var percentage : float

signal climb_rope_started()
signal climb_rope_ended()

func Enter(body):
	direction = body.last_direction
	
	rope = find_closest_rope(rope_check.global_position)
	if rope != null:
		rope_segment_index = rope.get_closest_segment_index(rope_check.global_position)
		parent_to_segment(body, rope.rope[rope_segment_index])
		rope_segment.apply_force(body.velocity * 100)
	
	# Reset body velocity
	body.velocity = Vector3.ZERO
	climb_rope_started.emit()

func Update(delta):
	pass

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	vertical_direction = input_dir.y
	
	percentage += vertical_direction * speed * delta
	percentage = clampf(percentage, 0.0, 1.0)
	
	# Switch segment
	if percentage == 0 and rope.is_valid_segment_index(rope_segment_index - 1):
		rope_segment_index -= 1
		percentage = 1
		parent_to_segment(body, rope.rope[rope_segment_index])
	elif percentage == 1 and rope.is_valid_segment_index(rope_segment_index + 1):
		rope_segment_index += 1
		percentage = 0
		parent_to_segment(body, rope.rope[rope_segment_index])
	
	# Update position
	#var rope_check_offset = body.global_position - rope_check.global_position
	body.global_position = lerp(body.global_position, rope.get_position_on_segment(rope_segment_index, percentage) + body.basis * Vector3.BACK * 0.5, delta * 20)
	
	# Apply forces to rope horizontally
	if Input.is_action_pressed("left"):
		rope_segment.apply_force(body.basis * Vector3.RIGHT * input_dir.x * speed * 10)
		
	if Input.is_action_pressed("right"):
		rope_segment.apply_force(body.basis * Vector3.RIGHT * input_dir.x * speed * 10)
	
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Jump State
	if Input.is_action_just_pressed("jump"):
		disable_rope_check(0.5)
		Transitioned.emit(self, "jump")
		return
	
	# Fall off
	if Input.is_action_just_pressed("crouch"):
		disable_rope_check(0.5)
		Transitioned.emit(self, "air")
		return
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding():
		# Verify we have enough head room
		var ledge_position = ledge_check.get_collision_point()
		var query = PhysicsRayQueryParameters3D.create(ledge_position, ledge_position + Vector3.UP * 1.9, ledge_mask)
		var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
		
		if not collision:
			Transitioned.emit(self, "vault")
			return
	
	# Ground State
	if body.is_on_floor():
		Transitioned.emit(self, "walk")
		return

func Exit(body):
	body.last_direction = Vector3.ZERO
	body.last_speed = speed
	climb_rope_ended.emit()

func find_closest_rope(position):
	# Find all ropes
	var found_segments: Array
	if rope_check.is_colliding():
		for i in range(rope_check.get_collision_count()):
			if rope_check.get_collider(i).get_parent() is Rope:
				found_segments.push_back(rope_check.get_collider(i))
	
	# Find the closest rope
	var closest_segment = null
	var closest_distance = INF
	for i in range(found_segments.size()):
		var distance = found_segments[i].global_position.distance_to(position)
		if  distance < closest_distance:
			closest_distance = distance
			closest_segment = found_segments[i]
			
	if closest_segment != null:
		return closest_segment.get_parent()
	
	return null
				
func FindClosestRopeSegment(position):
	
	# Find all rope segments we are touching
	var found_segments: Array
	if rope_check.is_colliding():
		for i in range(rope_check.get_collision_count()):
			if rope_check.get_collider(i).get_parent() is Rope:
				found_segments.push_back(rope_check.get_collider(i))
	
	# Find the closest one
	var closest_segment = null
	var closest_distance = INF
	for i in range(found_segments.size()):
		var distance = found_segments[i].global_position.distance_to(position)
		if  distance < closest_distance:
			closest_distance = distance
			closest_segment = found_segments[i]
			
	return closest_segment
			
func parent_to_segment(body, segment):
	rope_segment = segment
	print(rope_segment)

func disable_rope_check(duration):
	rope_check.enabled = false
	await get_tree().create_timer(duration).timeout
	rope_check.enabled = true
