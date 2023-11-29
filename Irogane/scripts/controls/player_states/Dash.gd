extends PlayerState
class_name Dash

# Refs
@onready var head_check = $"../../head_check"
@onready var head = $"../../head"
@onready var rope_check = $"../../rope_check"

# Variables
@export var dash_distance = 4;
@export var dash_duration = .25;
@export var exit_threshold = 0.2
@export var dash_head_height = 1.5;
@export var velocity_retention_on_exit = 0.5;

var speed
var direction = Vector3.ZERO
var end_time = 0

func Enter(body):
	direction = body.last_direction
	speed = dash_distance / dash_duration
	end_time = Time.get_ticks_msec() + dash_duration * 1000
	
	# Lower  head
	head.ChangeHeight(dash_head_height, 0.2)
	
	# Reset vertical velocity
	body.velocity.y = 0

func Update(delta):
	pass

func PhysicsUpdate(body, delta):
	var velocity = body.velocity
	
	# Jump State
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "jump")
		return
	
	# Climb Rope
	if rope_check.is_colliding():
		for i in range(rope_check.get_collision_count()):
			if rope_check.get_collider(i).get_parent() is Rope:
				Transitioned.emit(self, "climb_rope")
				return
	
	# Time to exit or stuck
	if Time.get_ticks_msec() >= end_time or velocity.length() < exit_threshold:
		if not body.is_on_floor():
			Transitioned.emit(self, "air")
			return
		elif head_check.is_colliding():
			Transitioned.emit(self, "crouch")
			return
		else:
			Transitioned.emit(self, "walk")
			return
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	body.velocity = velocity
	body.move_and_slide()
	

func Exit(body):
	body.last_direction = direction
	
	# Slow down body velocity
	body.velocity *= velocity_retention_on_exit
	
	# Return head to original height
	head.ResetHeight(0.2)
