extends PlayerState
class_name Climb

# References
@onready var ledge_check = %ledge_check
@onready var head_check = %head_check
@onready var head_check_2 = %head_check_2
@onready var wall_check = %wall_check

# Variables
@export var speed = 1.0;
@export var acceleration = 10
@export var push_force = 2
@export_flags_3d_physics var ledge_mask

var direction = Vector3.ZERO
var current_wall = null
var wall_normal = Vector3.ZERO
var wall_right = Vector3.ZERO

signal climb_rope_started()
signal climb_rope_ended()

func Enter(body):
	direction = Vector3.ZERO
	
	# Reset body velocity
	body.velocity = Vector3.ZERO
	climb_rope_started.emit()
	
	current_wall = wall_check.get_collider()
	wall_normal = wall_check.get_collision_normal()
	

func Update(delta):
	pass
	

func PhysicsUpdate(body, delta):
	var front_wall_result = wall_front_query(body)
	
	if not front_wall_result:
		Transitioned.emit(self, "air")
		return
	
	current_wall = front_wall_result.collider
	wall_normal = front_wall_result.normal
	var wall_point = front_wall_result.position
	var climb_up = Vector3.UP # World up
	wall_right = climb_up.cross(wall_normal)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var left_wall_result = wall_left_query(body)
	var right_wall_result = wall_right_query(body)
	var top_wall_result = wall_top_query(body)
	var bottom_wall_result = wall_bottom_query(body)
	
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
		new_direction += climb_up * -input_dir.y
	
	direction = lerp(direction, new_direction.normalized(), delta * acceleration)
		
	DebugCanvas.debug_line(wall_point, wall_point + direction, Color.GREEN)
	
	body.velocity = direction * speed
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Jump State
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return
	
	# Fall off
	if Input.is_action_just_pressed("crouch"):
		Transitioned.emit(self, "air")
		return
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding() and not top_wall_result and not head_check_2.is_colliding():
		# Verify we have enough head room
		var ledge_position = ledge_check.get_collision_point()
		var query = PhysicsRayQueryParameters3D.create(ledge_position, ledge_position + Vector3.UP * 1.9, ledge_mask)
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
	climb_rope_ended.emit()
	

func wall_query(body : Node3D, position : Vector3, direction : Vector3):
	var query = PhysicsRayQueryParameters3D.create(position, direction)
	var camera3d = CameraEntity.main_camera
	var space_state = body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	return result

func wall_front_query(body : Node3D):
	var origin =  body.global_position + Vector3.UP * 1.5
	return wall_query(body, origin, origin - wall_normal)
	

func wall_left_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.5 - wall_right * 0.5
	return wall_query(body, origin, origin - wall_normal)
	

func wall_right_query(body : Node3D):
	var origin =  body.global_position + body.global_basis * Vector3.UP * 1.5 + wall_right * 0.5
	return wall_query(body, origin, origin - wall_normal)
	

func wall_top_query(body : Node3D):
	var origin = body.global_position + body.global_basis * Vector3.UP * 1.75
	return wall_query(body, origin, origin - wall_normal)
	

func wall_bottom_query(body : Node3D):
	var origin =  body.global_position + body.global_basis * Vector3.UP * 1.0
	return wall_query(body, origin, origin - wall_normal)
	
