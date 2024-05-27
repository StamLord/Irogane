extends PlayerState
class_name Walk

# References
@onready var stand_collider = $"../../stand_collider"
@onready var step_check = $"../../step_check"
@onready var wall_check = %wall_check
@onready var step_separation = %step_separation
@onready var stamina = $"../../stats/stamina"

# Variables
@export var speed = 5.0;
@export var acceleration = 10
@export var push_force = 2

@export var max_step_height = .3
@export var step_check_distance = 0.5

var direction = Vector3.ZERO
var last_step = 0

var was_on_floor_last_frame = false
var snapped_to_stairs_last_frame = false

func Enter(body):
	stand_collider.disabled = false
	direction = body.last_direction
	step_separation.disabled = false
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	
	var velocity = body.velocity
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	body.velocity = velocity
	
	var input_dir_3d = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Move step separations to go up stairs regardless of movement direction
	StairUtils.update_step_separation(step_separation, input_dir_3d, step_check_distance)
	
	body.move_and_slide()
	
	# Snap down to stairs when moving down
	var snap_down_result = StairUtils.snap_down_to_stairs_check(
		body, input_dir_3d, step_check, 
		step_check_distance, max_step_height, 
		was_on_floor_last_frame, snapped_to_stairs_last_frame)
	
	was_on_floor_last_frame = snap_down_result["on_floor"]
	snapped_to_stairs_last_frame = snap_down_result["snapped_down"]
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Jump State
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		Transitioned.emit(self, "jump")
		return
	
	# Dash State
	if InputUtils.is_action_just_double_pressed("forward"):
		direction = body.basis * Vector3(0, 0, -1)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("backward"):
		direction = body.basis * Vector3(0, 0, 1)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("left"):
		direction = body.basis * Vector3(-1, 0, 0)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("right"):
		direction = body.basis * Vector3(1, 0, 0)
		Transitioned.emit(self, "dash")
		return
		
	# Air State
	if not body.is_on_floor() and not snapped_to_stairs_last_frame:
		Transitioned.emit(self, "air")
		return
	
	# Run State
	if Input.is_action_pressed("sprint") and stamina.get_value() > 2:
		Transitioned.emit(self, "run")
		return
	
	# Crouch State
	if Input.is_action_pressed("crouch"):
		Transitioned.emit(self, "crouch")
		return
	
	# Climb State
	if wall_check.is_colliding() and input_dir.y < 0:
		Transitioned.emit(self, "climb")
		return

func Exit(body):
	body.last_direction = direction
	body.last_speed = speed
	step_separation.disabled = true
	
