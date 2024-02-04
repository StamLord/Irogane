extends Node3D


@export_flags_3d_physics var collision_mask

var start_time
var start_pos
var last_pos
var start_speed
var speed = 20
var stopped = false

func _ready():
	restart()
	

func restart():
	start_time = Time.get_ticks_msec()
	start_pos = global_position
	last_pos = start_pos
	start_speed = -basis.z * speed
	stopped = false
	

func _process(delta):
	if stopped:
		return
	
	# Calculate position
	var time_passed = (Time.get_ticks_msec() - start_time) / 1000.0;
	var new_pos = start_pos + start_speed * time_passed;
	
	# Add gravity
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	new_pos.y = start_pos.y + start_speed.y * time_passed - gravity * time_passed  * time_passed * 0.5
	
	# Set new position
	global_position = new_pos;
	
	# Rotate in direction of flight
	#transform.forward = transform.position - lastPosition;
	
	# Rotate visual object
	#if(visual) 
	#{
	#	//visual.transform.Rotate(visualRotationPerSecond.x * Time.deltaTime, 0, 0, Space.Self);
	#	visual.transform.RotateAround(visual.transform.right, visualRotationPerSecond.x * Time.deltaTime);
	#	visual.transform.RotateAround(transform.forward, visualRotationPerSecond.z * Time.deltaTime);
	#}
	
	collision_check(delta)
	last_pos = new_pos;
	

func collision_check(delta):
	var ray_origin = global_position
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(last_pos, ray_origin, collision_mask)
	var result = space_state.intersect_ray(query)
	
	if result:
		stopped = true
		get_tree().get_root().remove_child(self)
		result.collider.add_child(self)
		global_position = result.position
	
