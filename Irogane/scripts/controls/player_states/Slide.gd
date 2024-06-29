extends PlayerState
class_name Slide

# Refs
@onready var stand_collider = $"../../stand_collider"
@onready var crouch_collider = $"../../crouch_collider"
@onready var head_check = $"../../head_check"
@onready var head = $"../../head"
@onready var slide_dust = $"../../vfx/slide_dust"

# Variables
@export var speed_multiplier = 1.5;
@export var deceleration = 1.5;
@export var exit_threshold = 3
@export var slide_head_height = 0.7;

var speed
var direction = Vector3.ZERO
var original_head_height = 1.8

func Enter(body):
	# Flatten direction on floor
	direction = flatten_vector(body.last_direction, body.get_floor_normal())
	
	speed = body.last_speed * speed_multiplier
	
	# Switch to crouch collider
	stand_collider.disabled = true
	crouch_collider.disabled = false
	
	# Lower  head
	original_head_height = head.position.y
	head.change_height(slide_head_height, 0.2)
	head.change_tilt(-10.0, 0.2)
	
	# Start vfx
	slide_dust.active = true
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, delta):
	# Flatten direction on floor
	direction = flatten_vector(direction, body.get_floor_normal())
	
	# Slow down over time
	if direction.y >= 0:
		direction = lerp(direction, Vector3.ZERO, delta * deceleration)
	else:
		direction = lerp(direction, Vector3.ZERO, delta * deceleration * 0.5)
	
	var velocity = direction * speed
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Walk State
	if body.velocity.length() < exit_threshold:
		if head_check.is_colliding():
			Transitioned.emit(self, "crouch")
		else:
			Transitioned.emit(self, "walk")
		return
	
	# Air State
	if not body.is_on_floor():
		Transitioned.emit(self, "air")
		return
	
	# Jump State
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		Transitioned.emit(self, "jump")
		return
	

func Exit(body):
	body.last_direction = direction
	body.last_speed = speed / speed_multiplier # Fix the speed back to what it was before slide
	
	# Switch to stand collider
	stand_collider.disabled = false
	crouch_collider.disabled = true
	
	# Return head to original height
	head.reset_height(0.2)
	head.reset_tilt(0.2)
	
	# Stop vfx
	slide_dust.active = false
	

func flatten_vector(vector, normal):
	var plane = Plane(normal)
	var flat_vector = plane.project(vector)
	
	# If going up a slope, to prevent body moving up 
	# and losing contact with the floor, we return vector as is
	if flat_vector.y > 0 :
		return vector
	# Otherwise, use flat vector while keeping same length
	else:
		return flat_vector.normalized() * vector.length()
	
