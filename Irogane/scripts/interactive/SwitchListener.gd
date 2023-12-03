extends Node3D

@export var switch : Switch

@export var on_position : Vector3
@export var on_rotation : Vector3
@export var animation_time : float

var origin_position : Vector3
var origin_rotation : Vector3

func _ready():
	origin_position = position
	origin_rotation = rotation_degrees
	switch.on_state_changed.connect(update_state)
	

func update_state(state):
	if state:
		animate_position(origin_position, origin_position + on_position)
		animate_rotation(origin_rotation, origin_rotation + on_rotation)
	else:
		animate_position(origin_position + on_position, origin_position)
		animate_rotation(origin_rotation + on_rotation, origin_rotation)
	

func animate_position(from, to):
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		position = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	position = to
	
func animate_rotation(from, to):
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		rotation_degrees = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	rotation_degrees = to
