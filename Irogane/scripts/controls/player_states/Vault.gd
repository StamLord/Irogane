extends PlayerState
class_name Vault

# References
@onready var ledge_check = $"%ledge_check"
@onready var head = $"../../head"
@onready var head_check = $"%head_check"
@onready var stand_collider = $"../../stand_collider"
@onready var crouch_collider = $"../../crouch_collider"

# Variables
@export var climb_time = 0.4;
@export var crouch_head_height = 0.8

var target_collider
var target_position
var direction = Vector3.ZERO

var start_time
var start_position
var duration
var is_crouch

signal vault_started(ledge_position)
signal vault_ended()

func Enter(body):
	# Reset direction so we don't continue moving in next state
	body.last_direction = Vector3.ZERO
	
	# Disable colliders while we can move it ourselves
	stand_collider.disabled = true
	crouch_collider.disabled = true
	
	# Get our collider and end position
	target_collider = ledge_check.get_collider()
	# Target position should have a forward offset of 0.25 units 
	target_position = ledge_check.get_collision_point() + body.global_transform.basis * Vector3.FORWARD * 0.25
	
	# Freeze rigidbody so we don't push it away
	if target_collider is RigidBody3D:
		target_collider.freeze = true
	
	start_time = Time.get_ticks_msec()
	start_position = body.position
	duration = climb_time * 1000 # Convert to milliseconds
	
	head.change_tilt(20.0, 0.1)
	
	# Check if we are in a crouch space
	var query = PhysicsRayQueryParameters3D.create(target_position, target_position + Vector3.UP * 1.9)
	var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
	is_crouch = collision
	
	if is_crouch:
		head.change_height(crouch_head_height, 0.2)
		
	vault_started.emit(target_position)

func Update(_delta):
	pass

func PhysicsUpdate(body, _delta):
	var t = (Time.get_ticks_msec() - start_time) / duration
	body.position = lerp(start_position, target_position, t)
	
	if(Time.get_ticks_msec() - start_time > duration):
		body.position = target_position
		if head_check.is_colliding():
			Transitioned.emit(self, "crouch")
		else:
			Transitioned.emit(self, "walk")

func Exit(body):
	# Unfreeze rigidbody
	if target_collider is RigidBody3D:
		target_collider.freeze = false
	
	body.move_and_slide() 	# Update body to acknowledge new state, 
							# otherwise next state will think it's not on floor
	
	head.reset_tilt(0.2)
	
	if is_crouch:
		head.reset_height(0.2)
		crouch_collider.disabled = false
	else:
		stand_collider.disabled = false
		
	vault_ended.emit(target_position)
	

func get_time_since_last_vault():
	if start_time == null:
		return INF
	
	return Time.get_ticks_msec() - start_time
	
