extends PlayerState
class_name Run

# References
@onready var stand_collider = $"../../stand_collider"
@onready var step_check = $"../../step_check"
@onready var stamina = $"../../stats/stamina"

# Variables
@export var speed = 8;
@export var acceleration = 10
@export var push_force = 2

@export var max_step_height = .3
@export var max_step_angle = 10
@export var step_check_distance = 0.55

@export var deplete_stamina_every = 0.20

var direction = Vector3.ZERO
var last_deplete = 0

func Enter(body):
	stand_collider.disabled = false
	direction = body.last_direction

func Update(delta):
	pass

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	
	var took_step = is_step(body, Vector3(input_dir.x, 0, input_dir.y))
	
	var velocity = body.velocity
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Deplete Stamina
	var enough_stamina = true
	if Time.get_ticks_msec() - last_deplete >= deplete_stamina_every * 1000:
		enough_stamina = stamina.try_deplete(1)
		last_deplete = Time.get_ticks_msec()
		
	# Jump State
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		Transitioned.emit(self, "jump")
		return Vector3.ZERO
	
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
	if not body.is_on_floor() and not took_step:
		Transitioned.emit(self, "air")
		return Vector3.ZERO
	
	# Walk State
	if not Input.is_action_pressed("sprint") or not enough_stamina:
		Transitioned.emit(self, "walk")
		return Vector3.ZERO
	
	# Crouch State
	if Input.is_action_just_pressed("crouch"):
		Transitioned.emit(self, "slide")
		return Vector3.ZERO

func Exit(body):
	body.last_direction = direction
	body.last_speed = speed

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
