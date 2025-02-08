extends Interactive
class_name Door

@export var open_position_offset : Vector3
@export var open_rotation_offset : Vector3
@export var dual_side = true
@export var start_open = false
@export_range(-1.0, 1.0) var start_open_percentage = 1.0
@export var animation_time = 0.5

@export var switches : Array[Switch]
@export var auto_open = false

enum DoorState {OPEN, OPENING, CLOSING ,CLOSED, AJAR}
var door_state = DoorState.CLOSED

var origin_position: Vector3
var origin_rotation: Vector3 # Degrees

# Run-time animation data
var animation_start_time = -1
var is_animation_reversed = false
var from_position = null
var from_rotation = null
var to_position = null
var to_rotation = null
var target_state = DoorState.CLOSED

func _ready():
	origin_position = position
	origin_rotation = rotation_degrees
	
	animation_time *= 1000
	
	if start_open:
		instant_open()
	
	for switch in switches:
		switch.on_state_changed.connect(switch_state_changed)
		if start_open:
			switch.state = true
	
	# Prevent direct interaction if should be opened by switches
	if auto_open and switches.size() > 0:
		set_disabled(true)
	

func _process(delta):
	if not door_state in [DoorState.OPENING, DoorState.CLOSING]:
		return
	
	var t = (Time.get_ticks_msec() - animation_start_time) / animation_time
	
	if t >= 1.0:
		position = to_position
		rotation_degrees = to_rotation
		door_state = target_state
	else:
		position = lerp(from_position, to_position, t)
		rotation_degrees = lerp(from_rotation, to_rotation, t)
	

func open():
	if door_state == DoorState.OPEN:
		return
	
	from_position = position
	from_rotation = rotation_degrees
	var reverse = -1 if is_animation_reversed else 1
	to_position = origin_position + open_position_offset * reverse
	to_rotation = origin_rotation + open_rotation_offset * reverse
	target_state = DoorState.OPEN
	
	door_state = DoorState.OPENING
	animation_start_time = Time.get_ticks_msec()
	

func close():
	if door_state == DoorState.CLOSED:
		return
	
	from_position = position
	from_rotation = rotation_degrees
	to_position = origin_position 
	to_rotation = origin_rotation 
	target_state = DoorState.CLOSED
	
	door_state = DoorState.CLOSING
	animation_start_time = Time.get_ticks_msec()
	

func instant_open():
	position = origin_position + open_position_offset
	rotation_degrees = origin_rotation + lerp(Vector3.ZERO, open_rotation_offset, start_open_percentage)
	
	if abs(start_open_percentage) >= 1.0:
		door_state = DoorState.OPEN
	else:
		door_state = DoorState.AJAR
	

func use(interactor):
	# Can't interact directly with Door if there are switches
	if is_disabled:
		return
	
	if dual_side:
		var plane = Plane(-global_basis.z, global_transform.origin) # Create a plane with door's forward as normal
		is_animation_reversed = plane.is_point_over(interactor.owner.global_position)
	
	if all_switches_on():
		if door_state in [DoorState.CLOSED, DoorState.CLOSING, DoorState.AJAR]:
			open()
		elif door_state in [DoorState.OPEN, DoorState.OPENING]:
			close()
	

func switch_state_changed(state : bool):
	if not state:
		close()
		return
	
	if not all_switches_on():
		close()
		return
	
	if auto_open:
		open()
	

func all_switches_on() -> bool:
	for switch in switches:
		if switch.state == false:
			return false
	
	return true
	
