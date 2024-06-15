extends Node3D

@export var distance_step = 0.8
@export var rotation_step = 45.0
@export var axis = Vector3.UP

var prev_position = Vector3.ZERO

func _ready():
	prev_position = global_position
	

func _process(delta):
	var position_delta = (global_position - prev_position).length()
	var rotate_amount = rotation_step * (position_delta / distance_step)
	rotation_degrees.x += rotate_amount * axis.x
	rotation_degrees.y += rotate_amount * axis.y
	rotation_degrees.z += rotate_amount * axis.z
	
	prev_position = global_position
	
