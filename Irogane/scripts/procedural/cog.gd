extends Node3D

@export var distance_step = 0.8
@export var movement_axis = AXIS.X
@export var rotation_step = 45.0
@export var rotation_axis = Vector3.UP

enum AXIS {X, Y, Z}

var prev = 0.0

func _ready():
	prev = get_current_position()
	

func _process(delta):
	var current = get_current_position()
	var position_delta = current - prev
	
	if position_delta != 0.0:
		var rotate_amount = rotation_step * (position_delta / distance_step)
		rotation_degrees += rotate_amount * rotation_axis * delta * 100
	
	prev = current
	

func get_current_position() -> float:
	match movement_axis:
		AXIS.X: return global_position.x
		AXIS.Y: return global_position.y
		AXIS.Z: return global_position.z
	return global_position.x
	
