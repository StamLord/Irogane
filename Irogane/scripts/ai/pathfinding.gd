extends CharacterBody3D

@onready var step_check = $step_check
@onready var door_check = $door_check
@onready var step_separation = %step_separation
@onready var stats = %stats
@onready var push_back_dust_l = $vfx/push_back_dust_l
@onready var push_back_dust_r = $vfx/push_back_dust_r

@export var movement_speed = 2
@export var acceleration = 10
@export var rotation_speed = 5
@export var gravity = 9
@export var push_force = 15

@onready var nav = $NavigationAgent3D

@export var max_step_height = .3
@export var step_check_distance = 0.5

@export var door_check_distance = 1.5

var prev_current_angle : float
var prev_target_angle : float

var next_position = Vector3.ZERO
var direction = Vector3.ZERO

var look_at_target_while_moving = false
var target_rotation = null

var is_traveling_link = false
var link_details = null

var was_on_floor_last_frame = false
var snapped_to_stairs_last_frame = false

var override_rotation_speed = null
var override_movement_speed = null

var is_pushed_back = false
var push_back_force = Vector3.ZERO
var push_back_speed = 0.0
var push_back_accumulated_gravity = 0.0
var push_back_deceleration = 10
var push_back_exit_threshold = 0.2
var push_back_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	nav.link_reached.connect(link_reached)
	
	# Block physics process until NavigationServer synchronizes once
	set_physics_process(false)
	NavigationServer3D.map_changed.connect(start_physics)
	

func start_physics(map):
	set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(start_physics)
	

func link_reached(details):
	move_in_link(details)
	

func move_in_link(link_details):
	is_traveling_link = true
	
	var from = link_details["link_entry_position"]
	var offset = global_position - from
	
	var to = link_details["link_exit_position"] + offset
	var distance = from.distance_to(to)
	var duration = (distance / get_movement_speed()) * 1000
	var start_time = Time.get_ticks_msec()
	
	while(Time.get_ticks_msec() - start_time < duration):
		var t = (Time.get_ticks_msec() - start_time) / duration
		global_position = lerp(from, to, t)
		await get_tree().process_frame
	
	global_position = to
	is_traveling_link = false
	

func _process(delta):
	if is_pushed_back:
		process_push_back(delta)
		return
	
	if not is_traveling_link:
		if nav.is_navigation_finished():
			if target_rotation: # Face an overriding rotation target
				rotate_to_target_rotation(delta)
			else: # Face the path target position
				rotate_to_target(delta)
		elif look_at_target_while_moving and target_rotation:
			rotate_to_target_rotation(delta)
		else: # Face next position on path
			rotate_to_next_position(delta) 
	
	# Open doors when moving into them
	if door_check != null and velocity.length() > 0 and door_check.is_colliding():
		var collider = door_check.get_collider()
		if collider is Switch and collider.state == false:
			collider.use(null)
	

func set_target_position(target_position : Vector3):
	nav.target_position = target_position
	

func reset_target_position():
	nav.target_position = global_position
	

func set_target_rotation(_target_rotation : Vector3):
	target_rotation = _target_rotation
	

func reset_target_rotation():
	target_rotation = null
	

func _physics_process(delta):
	if is_traveling_link:
		return
	
	if stats and stats.is_staggered:
		return
	
	next_position = nav.get_next_path_position()
	direction = (next_position - global_position).normalized()
	
	# Get dot product between our facing direction and the direction
	var facing_direction = basis * Vector3.FORWARD # Our facing direction
	var dot_product = facing_direction.dot(direction)
	dot_product = max(0, dot_product) # Make sure it's not below 0
	
	# Multiply by dot to slow down movement when facing the wrong direction
	var speed_mult = lerp(0.5, 1.0, dot_product) # Moving forward at full speed, backwards and sideways at half
	nav.set_velocity(direction * get_movement_speed() * speed_mult)
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	# The next position in local space is the direction we travel in
	var local_direction = to_local(next_position)
	local_direction.y = 0
	local_direction = local_direction.normalized()
	
	# Move step separations to go up stairs regardless of movement direction
	StairUtils.update_step_separation(step_separation, local_direction, step_check_distance)
	
	move_and_slide()
	
	# Snap down to stairs when moving down
	var snap_down_result = StairUtils.snap_down_to_stairs_check(
		self, local_direction, step_check, 
		step_check_distance, max_step_height, 
		was_on_floor_last_frame, snapped_to_stairs_last_frame)
	
	was_on_floor_last_frame = snap_down_result["on_floor"]
	snapped_to_stairs_last_frame = snap_down_result["snapped_down"]
	
	# Collisions
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal() * push_force * delta)
			collider.apply_impulse(-collision.get_normal() * 0.01, collision.get_position())
		elif collider is CharacterBody3D:
			collider.velocity += -collision.get_normal() * push_force * delta
	

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	var flat_vector = velocity.move_toward(safe_velocity, .25)
	velocity.x = flat_vector.x
	velocity.z = flat_vector.z
	

func rotate_to_next_position(delta):
	rotate_to_position(next_position, delta)
	

func rotate_to_target(delta):
	rotate_to_position(nav.target_position, delta)
	

func rotate_to_target_rotation(delta):
	rotate_to_position(target_rotation, delta)
	

func rotate_to_position(target_position, delta):
	if target_position == null:
		return
	
	var forward = global_basis * Vector3.FORWARD
	var flat_dir = Vector3(target_position.x - global_position.x, 0, target_position.z - global_position.z).normalized()
	var new_forward = lerp(forward, flat_dir, delta * get_rotation_speed())
	
	look_at(global_position + new_forward)
	

func rotate_angle(delta):
	var current_angle = rad_to_deg(basis.z.signed_angle_to(-Vector3.FORWARD, Vector3.UP))
	var target_angle = rad_to_deg(direction.signed_angle_to(Vector3.FORWARD, Vector3.UP))
	
	# Fix signed angle flipping from 360 to -360
	if abs(current_angle - prev_current_angle) > 180.0:
		if current_angle > 0.0:
			current_angle -= 360.0
		else:
			current_angle += 360.0
			
	if abs(target_angle - prev_target_angle) > 180.0:
		if target_angle > 0.0:
			target_angle -= 360.0
		else:
			target_angle += 360.0
	
	prev_current_angle = current_angle
	prev_target_angle = target_angle
	
	# Calculate new angle
	var angle = lerp(current_angle, target_angle, delta * get_rotation_speed())
	
	# Set rotation
	rotation_degrees.y = -angle
	

func set_override_rotation_speed(new_override_rotation_speed):
	override_rotation_speed = new_override_rotation_speed
	

func set_override_movement_speed(new_override_movement_speed):
	override_movement_speed = new_override_movement_speed
	

func clear_override_rotation_speed():
	override_rotation_speed = null
	

func clear_override_movement_speed():
	override_movement_speed = null
	

func get_movement_speed():
	return override_movement_speed if override_movement_speed != null else movement_speed
	

func get_rotation_speed():
	return override_rotation_speed if override_rotation_speed != null else rotation_speed
	

func start_push_back(force : Vector3):
	is_pushed_back = true
	push_back_force = force
	push_back_speed = force.length()
	push_back_accumulated_gravity = 0.0
	set_vfx_active(true)
	

func process_push_back(delta):
	var direction = push_back_force.normalized()
	
	# Decelerate when sliding on ground
	if is_on_floor():
		push_back_speed -= push_back_deceleration * delta
	
	# Apply gravity
	push_back_accumulated_gravity -= push_back_gravity * delta
	
	velocity = direction * push_back_speed
	velocity.y += push_back_accumulated_gravity
	
	move_and_slide()
	
	# Vfx
	set_vfx_active(is_on_floor())
	
	if push_back_speed < push_back_exit_threshold:
		is_pushed_back = false
		set_vfx_active(false)
	

func set_vfx_active(state):
	push_back_dust_l.active = state
	push_back_dust_r.active = state
	
