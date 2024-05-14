extends PlayerState
class_name Pushed

# Refs
@onready var head_check = $"../../head_check"
@onready var head = $"../../head"
@onready var rope_check = $"../../rope_check"
@onready var push_back_dust_l = $"../../vfx/push_back_dust_l"
@onready var push_back_dust_r = $"../../vfx/push_back_dust_r"

# Variables
@export var deceleration = 10
@export var exit_threshold = 0.2
@export var dash_head_height = 1.25;
@export var velocity_retention_on_exit = 0.5;

var speed = 0.0
var accumulated_gravity = 0.0

var direction = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func Enter(body):
	# Lower  head
	head.change_height(dash_head_height, 0.2)
	accumulated_gravity = 0.0
	

func Update(delta):
	pass
	

func PhysicsUpdate(body, delta):
	var velocity = body.velocity
	
	# Decelerate when sliding on ground
	if body.is_on_floor():
		speed -= deceleration * delta
	
	# VFX active only when on ground
	set_vfx_active(body.is_on_floor())
	
	# Stuck or too slowV
	if speed < exit_threshold:
		if not body.is_on_floor():
			Transitioned.emit(self, "air")
			return
		elif head_check.is_colliding():
			Transitioned.emit(self, "crouch")
			return
		else:
			Transitioned.emit(self, "walk")
			return
	
	# Apply gravity
	accumulated_gravity -= gravity * delta
	
	velocity = direction * speed
	velocity.y += accumulated_gravity
	
	body.velocity = velocity
	body.move_and_slide()
	

func Exit(body):
	body.last_direction = direction
	body.last_speed = speed
	
	# Slow down body velocity
	body.velocity *= velocity_retention_on_exit
	
	# Return head to original height
	head.reset_height(0.2)
	
	set_vfx_active(false)
	

func set_vfx_active(state):
	push_back_dust_l.active = state
	push_back_dust_r.active = state
	
