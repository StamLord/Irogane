extends Node3D

var current_index = 0
var is_animating = false

func _ready():
	animate_rotation(current_index)
	

func _process(_delta):
	if is_animating:
		return
	
	if Input.is_action_just_pressed("scroll_down"):
		set_index(current_index - 1)
	elif Input.is_action_just_pressed("scroll_up"):
		set_index(current_index + 1)
	

func set_index(new_index):
	current_index = new_index % 4
	animate_rotation(current_index)
	

func animate_rotation(index : int):
	is_animating = true
	
	var start_rotation_y = rotation.y
	var target_rotation_y = deg_to_rad(360.0 / get_child_count() * index)
	
	var start_time = Time.get_ticks_msec()
	var duration = 400
	
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / float(duration)
		rotation.y = lerp_angle(start_rotation_y, target_rotation_y, t)
		await get_tree().process_frame
	
	rotation.y = target_rotation_y
	is_animating = false
	
