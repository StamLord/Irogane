extends CharacterBody3D

# References
@onready var head = $head
@onready var stand_collider = $stand_collider
@onready var crouch_collider = $crouch_collider
@onready var head_check = $head_check
@onready var ledge_check = $ledge_check

# Speed
@export var walk_speed = 5.0;
@export var run_speed = 8.0;
@export var crouch_speed = 2.0;

# Acceleration
@export var ground_acceleration = 10
@export var air_acceleration = 0.1
@export var air_move_acceleration = 10

# Crouch
@export var crouch_depth = -0.5;
@export var crouch_depth_speed = 10;

# Mouse
@export var mouse_sensitivity = 0.4;
@export var look_min = -90;
@export var look_max = 90;

# Jump
@export var jump_velocity = 4.5
@export var max_air_jumps = 1;

var target_speed = 5.0
var acceleration = 10

var direction = Vector3.ZERO

var current_air_jump = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(look_min), deg_to_rad(look_max))

func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if Input.is_action_pressed("crouch"):
		stand_collider.disabled = true
		crouch_collider.disabled = false
		head.position.y = lerp(head.position.y, 1.8 + crouch_depth, delta * crouch_depth_speed)
		target_speed = crouch_speed
	elif not head_check.is_colliding():
		crouch_collider.disabled = true
		stand_collider.disabled = false
		head.position.y = lerp(head.position.y, 1.8, delta * crouch_depth_speed)
		if Input.is_action_pressed("sprint"):
			target_speed = run_speed
		else:
			target_speed = walk_speed
	
	# Ground
	if is_on_floor():
		current_air_jump = 0
		acceleration = ground_acceleration
	# Air
	else:
		# Apply gravity
		velocity.y -= gravity * delta
		
		# Decide which acceleration to use
		if input_dir != Vector2.ZERO:
			acceleration = air_move_acceleration
		else:
			acceleration = air_acceleration
		
		if ledge_check.is_colliding() and input_dir.y < 0:
			position = lerp(position, position + transform.basis.z, delta * crouch_depth_speed)
			return

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif current_air_jump < max_air_jumps:
			velocity.y = jump_velocity
			current_air_jump += 1
	
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	
	if direction:
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)

	move_and_slide()
