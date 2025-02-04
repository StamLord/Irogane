extends Interactive
class_name Readable

@onready var origin_position = global_position
@onready var origin_rotation = global_rotation

const CAMERA_DISTANCE = 0.5
const STOP_READING_DISTANCE = 0.5
const ANIMATE_SPEED = 4.0

var is_reading = false
var target_position = null
var interactor = null
var interactor_origin_position = null

func use(_interactor):
	if is_reading:
		stop_reading()
	else: 
		is_reading = true
		var interactor_forward = -_interactor.global_basis.z
		target_position = _interactor.global_position + interactor_forward * CAMERA_DISTANCE
		interactor = _interactor
		interactor_origin_position = _interactor.global_position
	

func get_text():
	if is_reading:
		return ""
	
	return interaction_text
	

func _process(delta):
	if is_reading:
		global_position = lerp(global_position, target_position, ANIMATE_SPEED * delta)
		look_at(interactor.global_position, Vector3.UP, true)
		
		if interactor.global_position.distance_to(interactor_origin_position) >= STOP_READING_DISTANCE:
			stop_reading()
	else:
		global_position = lerp(global_position, origin_position, ANIMATE_SPEED * delta)
		
		global_rotation.x = lerp_angle(global_rotation.x, origin_rotation.x, ANIMATE_SPEED * delta)
		global_rotation.y = lerp_angle(global_rotation.y, origin_rotation.y, ANIMATE_SPEED * delta)
		global_rotation.z = lerp_angle(global_rotation.z, origin_rotation.z, ANIMATE_SPEED * delta)
	

func stop_reading():
	is_reading = false
	target_position = null
	interactor = null
	interactor_origin_position = null
	
