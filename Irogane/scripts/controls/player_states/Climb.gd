extends PlayerState
class_name Climb

# References
@onready var ledge_check = %ledge_check
@onready var head = $"../../head"
@onready var head_check = %head_check
@onready var head_check_2 = %head_check_2
@onready var wall_check = %wall_check
@onready var stats = %stats
@onready var climb_check = %climb_check

# Variables
@export var speed = 1.5;
@export var acceleration = 10
@export var push_force = 2
@export var wall_distance = 0.5
@export_flags_3d_physics var ledge_mask

var direction = Vector3.ZERO
var current_wall = null
var wall_normal = Vector3.ZERO
var wall_right = Vector3.ZERO

var is_animating_position = false

var last_deplete = 0

var debug = false

signal climb_rope_started()
signal climb_rope_ended()

func Enter(body):
	direction = Vector3.ZERO
	
	# Reset body velocity
	body.velocity = Vector3.ZERO
	climb_rope_started.emit()
	
	current_wall = climb_check.get_collider()
	wall_normal = climb_check.get_collision_normal()
	
	adjust_to_wall(body, climb_check.get_collision_point())
	

func adjust_to_wall(body, point):
	point.y = body.global_position.y # Treat as same height
	var dir = (body.global_position - point).normalized()
	body.global_position = point + dir * wall_distance
	head.set_temp_horizontal_limits(Vector2(-50, 50), get_wall_normal_angle())
	

func rotate_around_wall(body, point, normal):
	point.y = body.global_position.y # Treat as same height
	var target_position = point + normal * wall_distance * 0.4
	head.disable_rotation()
	await start_animating_position(body, target_position, point - normal)
	head.enable_rotation()
	head.set_temp_horizontal_limits(Vector2(-50, 50), get_wall_normal_angle())
	

func get_wall_normal_angle():
	return rad_to_deg(-wall_normal.signed_angle_to(-Vector3.FORWARD, Vector3.UP))
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, delta):
	if is_animating_position:
		return
		
	var front_wall_result = wall_front_query(body)
	if not front_wall_result:
		Transitioned.emit(self, "air")
		return
		
	update_wall_data(front_wall_result)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var left_wall_result = wall_left_query(body)
	var right_wall_result = wall_right_query(body)
	var top_wall_result = wall_top_query(body)
	var bottom_wall_result = wall_bottom_query(body)
	
	if debug:
		if left_wall_result:
			DebugCanvas.debug_point(left_wall_result.position, Color.RED)
		if front_wall_result:
			DebugCanvas.debug_point(front_wall_result.position, Color.GREEN)
		if right_wall_result:
			DebugCanvas.debug_point(right_wall_result.position, Color.BLUE)
		if top_wall_result:
			DebugCanvas.debug_point(top_wall_result.position, Color.RED)
		if bottom_wall_result:
			DebugCanvas.debug_point(bottom_wall_result.position, Color.BLUE)
	
	var new_direction = Vector3.ZERO
	
	# Left/Right
	if left_wall_result and input_dir.x < 0 or right_wall_result and input_dir.x > 0:
		new_direction += wall_right * input_dir.x
	# Up/Down
	if top_wall_result and input_dir.y < 0 and not head_check.is_colliding() or bottom_wall_result and input_dir.y > 0:
		new_direction += Vector3.UP * -input_dir.y
	
	direction = lerp(direction, new_direction.normalized(), delta * acceleration)
		
	if debug:
		DebugCanvas.debug_line(front_wall_result.position, front_wall_result.position + direction, Color.GREEN)
	
	body.velocity = direction * speed
	body.move_and_slide()
	
	# Stamina deplete
	var enough_stamina = true
	var deplete_interval = 250 if input_dir.length() > 0 else 750
	if Time.get_ticks_msec() - last_deplete >= deplete_interval:
		last_deplete = Time.get_ticks_msec()
		enough_stamina = stats.deplete_stamina(1)
	
	var left_corner_result = wall_left_corner_query(body)
	var right_corner_result = wall_right_corner_query(body)
	
	if left_corner_result and not left_wall_result and input_dir.x < 0:
		update_wall_data(left_corner_result)
		rotate_around_wall(body, left_corner_result.position, left_corner_result.normal)
	elif right_corner_result and not right_wall_result and input_dir.x > 0:
		update_wall_data(right_corner_result)
		rotate_around_wall(body, right_corner_result.position, right_corner_result.normal)
		
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Jump State
	if Input.is_action_just_pressed("jump"):
		body.jump_direction = wall_normal
		Transitioned.emit(self, "jump")
		return
	
	# Fall off
	if Input.is_action_just_pressed("crouch") or not enough_stamina:
		if not enough_stamina:
			CameraShaker.shake(1.0, 0.25)
		
		Transitioned.emit(self, "air")
		return
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding() and not top_wall_result and not head_check_2.is_colliding():
		# Verify we have enough head room
		var ledge_position = ledge_check.get_collision_point()
		var query = PhysicsRayQueryParameters3D.create(ledge_position + Vector3.UP * 0.01, ledge_position + Vector3.UP * 1.9, ledge_mask)
		var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
		
		if not collision:
			Transitioned.emit(self, "vault")
			return
	
	# Ground State
	if body.is_on_floor() and input_dir.y > 0:
		Transitioned.emit(self, "walk")
		return
	

func Exit(body):
	body.last_direction = Vector3.ZERO
	body.last_speed = speed
	head.reset_temp_horizontal_limits()
	climb_rope_ended.emit()
	

func update_wall_data(query_result):
	current_wall = query_result.collider
	wall_normal = query_result.normal
	wall_right = Vector3.UP.cross(wall_normal) # Use world up for now
	

func wall_query(body : Node3D, position : Vector3, ray_direction : Vector3):
	var query = PhysicsRayQueryParameters3D.create(position, ray_direction, climb_check.collision_mask)
	var space_state = body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	return result

func wall_front_query(body : Node3D):
	var origin =  body.global_position + Vector3.UP * 1.5
	return wall_query(body, origin, origin - wall_normal)
	

func wall_left_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.5 - wall_right * 0.15
	return wall_query(body, origin, origin - wall_normal)
	

func wall_right_query(body : Node3D):
	var origin =  body.global_position + body.global_basis * Vector3.UP * 1.5 + wall_right * 0.15
	return wall_query(body, origin, origin - wall_normal)
	

func wall_top_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.75
	return wall_query(body, origin, origin - wall_normal)
	

func wall_bottom_query(body : Node3D):
	var origin =  body.global_position + body.global_basis * Vector3.UP * 1.0
	return wall_query(body, origin, origin - wall_normal)
	

func wall_left_corner_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.5 
	origin -= wall_normal * 0.5 # Move forward into wall
	origin -= wall_right * 0.5  # Move left
	
	if debug:
		DebugCanvas.debug_line(origin, origin + wall_right * 0.5)
	
	return wall_query(body, origin, origin + wall_right * 0.5)
	

func wall_right_corner_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.5 
	origin -= wall_normal * 0.5 # Move forward into wall
	origin += wall_right * 0.5  # Move right
	
	if debug:
		DebugCanvas.debug_line(origin, origin - wall_right * 0.5)
	
	return wall_query(body, origin, origin - wall_right * 0.5)
	

func start_animating_position(body : Node3D, target_position : Vector3, target_look : Vector3):
	is_animating_position = true
	var duration = 0.5 * 1000
	var start_time = Time.get_ticks_msec()
	var start_position = body.global_position
	var start_target = body.global_position + body.global_basis * Vector3.FORWARD
	
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		body.global_position = lerp(start_position, target_position, t)
		var lerp_look_target = lerp(start_target, target_look, t)
		body.look_at(lerp_look_target)
		await get_tree().process_frame
	
	body.global_position = target_position
	is_animating_position = false
	
