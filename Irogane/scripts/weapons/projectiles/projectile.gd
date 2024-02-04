extends Node3D


var start_time
var start_pos
var start_speed
var speed = 0.005

func _ready():
	restart()
	

func restart():
	start_time = Time.get_ticks_msec()
	start_pos = global_position
	start_speed = basis.z * speed
	

func _process(delta):
	# Calculate position
	var time_passed = Time.get_ticks_msec() - start_time;
	var new_pos = start_pos + start_speed * time_passed;

	# Gravity
	#if(gravity)
	#	if(useGlobalGravity)
	#		newPos.y = startPos.y + startSpeed.y * timePassed + Physics.gravity.y *.5f * timePassed * timePassed;
	#	else
	#		newPos.y = startPos.y + startSpeed.y * timePassed + customGravity.y *.5f * timePassed * timePassed;
	
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
	
