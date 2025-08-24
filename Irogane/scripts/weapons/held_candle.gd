extends Node3D

@onready var candle_object = $candle_object
@onready var candle_target = $candle_target
@onready var ignitable_area = $candle_object/MeshInstance3D/ignitable_area

const candle_speed = 10.0
var candle_origin: Vector3
var candle_direction: Vector3

func _ready():
	if candle_object:
		candle_origin = candle_object.position
		candle_direction = (candle_target.position - candle_origin).normalized()
	
	visibility_changed.connect(on_visibility_changed)
	

func _process(delta):
	if not visible or not candle_object or not candle_target:
		return
	
	var is_pressed = Input.is_action_pressed("attack_primary")
	var target_position = candle_target.position if is_pressed else candle_origin
	
	# Prevent clipping
	if is_pressed:
		var raycast_result = perform_raycast()
		if raycast_result:
			target_position = to_local(raycast_result.position) - candle_direction * 0.25
	
	candle_object.position = lerp(candle_object.position, target_position, candle_speed * delta)
	

func on_visibility_changed():
	if not visible and ignitable_area:
		ignitable_area.extinguish()
	

func perform_raycast():
	var origin = to_global(candle_origin - candle_direction * 0.5)
	var target = to_global(candle_target.position + candle_direction * 0.25)
	var query = PhysicsRayQueryParameters3D.create(origin, target, 1, [owner.get_rid()])
	var space_state = get_world_3d().direct_space_state
	return space_state.intersect_ray(query)
	
