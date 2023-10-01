extends PlayerState
class_name Crouch

# References
@onready var stand_collider = $"../../stand_collider"
@onready var crouch_collider = $"../../crouch_collider"
@onready var head_check = $"../../head_check"
@onready var head = $"../../head"
@onready var step_check = $"../../step_check"

# Variables
@export var speed = 3.0;
@export var acceleration = 10
@export var crouch_head_height = 0.8

@export var max_step_height = .3
@export var max_step_angle = 10
@export var step_check_distance = 0.55

var direction = Vector3.ZERO

func Enter(body):
	direction = body.last_direction
	
	# Switch to crouch collider
	stand_collider.disabled = true
	crouch_collider.disabled = false
	
	# Lower head
	head.ChangeHeight(crouch_head_height, 0.2)

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	
	var velocity = body.velocity
	
	velocity.y = -1
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	body.velocity = velocity
	body.move_and_slide()
	
	var climb_step = is_step(body, Vector3(input_dir.x, 0, input_dir.y))
	
	# Air State
	if not body.is_on_floor() and not climb_step:
		Transitioned.emit(self, "air")
		return
	
	# Crouch State
	if not Input.is_action_pressed("crouch") and not head_check.is_colliding(): 
		Transitioned.emit(self, "walk")
		return

func Exit(body):
	body.last_speed = speed
	
	# Switch to stand collider
	stand_collider.disabled = false
	crouch_collider.disabled = true
	
	# Return head to original height
	head.ResetHeight(0.2)

func is_step(body, input_dir):
	
	# Move raycast position according to direction
	step_check.position.x = input_dir.x * step_check_distance
	step_check.position.z = input_dir.z * step_check_distance

	if not step_check.is_colliding():
		return false
	
	# Surface must be flat enough to be considered a step
	var angle = rad_to_deg(step_check.get_collision_normal().angle_to(Vector3.UP))
	if angle > max_step_angle:
		return false
	
	var step_pos = step_check.get_collision_point()
	var height_diff = step_pos.y - body.global_position.y
	
	# Verify we can stand on the step
	var shape_cast = ShapeCast3D.new()
	shape_cast.collide_with_areas = true
	shape_cast.collide_with_bodies = true
	shape_cast.shape = stand_collider.shape
	shape_cast.target_position = step_pos
	
	if shape_cast.get_collision_count() > 0:
		return false
	
	# Not a step if we are same height
	if height_diff == 0:
		return false
	elif height_diff < -max_step_height:
		return false
	elif height_diff > max_step_height:
		return false
	
	# If we are moving, change height
	if input_dir.length() > 0.1:
		body.global_position.y += height_diff - 0.01
	
	return true
