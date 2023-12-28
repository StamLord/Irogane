extends PlayerState
class_name Crouch

# References
@onready var stand_collider = $"../../stand_collider"
@onready var crouch_collider = $"../../crouch_collider"
@onready var head_check = $"../../head_check"
@onready var head = $"../../head"
@onready var step_check = $"../../step_check"
@onready var step_separation = %step_separation

# Variables
@export var speed = 3.0;
@export var acceleration = 10
@export var crouch_head_height = 0.8

@export var max_step_height = .3
@export var step_check_distance = 0.5

var direction = Vector3.ZERO

var was_on_floor_last_frame = false
var snapped_to_stairs_last_frame = false

func Enter(body):
	direction = body.last_direction
	
	stand_collider.disabled = true
	crouch_collider.disabled = false
	step_separation.disabled = false
	
	# Lower head
	head.change_height(crouch_head_height, 0.2)
	

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
	
	var input_dir_3d = Vector3(input_dir.x, 0, input_dir.y)
	
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
	
	# Air State
	if not body.is_on_floor() and not snapped_to_stairs_last_frame:
		Transitioned.emit(self, "air")
		return
	
	# Crouch State
	if not Input.is_action_pressed("crouch") and not head_check.is_colliding(): 
		Transitioned.emit(self, "walk")
		return
	

func Exit(body):
	body.last_direction = direction
	body.last_speed = speed
	
	stand_collider.disabled = false
	crouch_collider.disabled = true
	step_separation.disabled = true
	
	# Return head to original height
	head.reset_height(0.2)
	
