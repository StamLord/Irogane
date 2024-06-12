@tool
extends Interactive
class_name Switch

@export var state : bool : 
	set(value): 
		state = value
		
		if Engine.is_editor_hint():
			if state:
				get_parent().position = on_position
				get_parent().rotation_degrees = on_rotation
			else:
				get_parent().position = off_position
				get_parent().rotation_degrees = off_rotation
	

@export var on_text : String
@export var off_position : Vector3
@export var on_position : Vector3
@export var off_rotation : Vector3
@export var on_rotation : Vector3
@export var animation_time : float
@export var sub_switches : Array[Switch]
@export var required_switches : Array[Switch]
@export var required_keys : Array[Key]

@onready var is_locked = required_keys.size() > 0
var is_animating_position : bool
var is_animating_rotation : bool

signal on_state_changed(state)
signal on_animation_done(state)
signal on_failed_unlocked()
signal on_unlocked()

func use(interactor):
	if is_locked:
		for key in required_keys:
			var use_key = interactor.use_key(key.tower_id, key.color)
			if use_key == false:
				on_failed_unlocked.emit()
				return
			
		is_locked = false # Once unlocked, keys are no longer needed
		on_unlocked.emit()
	
	for switch in required_switches:
		if switch.state == false:
			return
	
	state = !state
	
	perform_animations()
	
	for sub_switch in sub_switches:
		sub_switch.chain_use()
	

func chain_use():
	state = !state
	perform_animations()
	

func perform_animations():
	if state:
		animate_position(off_position, on_position)
		animate_rotation(off_rotation, on_rotation)
	else:
		animate_position(on_position, off_position)
		animate_rotation(on_rotation, off_rotation)
	
	on_state_changed.emit(state)
	
	await get_tree().create_timer(animation_time).timeout
	on_animation_done.emit(state)
	

func get_text():
	return on_text if state else interaction_text

func animate_position(from, to):
	is_animating_position = true
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		get_parent().position = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	get_parent().position = to
	is_animating_position = false
	

func animate_rotation(from, to):
	is_animating_rotation = true
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		get_parent().rotation_degrees = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	get_parent().rotation_degrees = to
	is_animating_rotation = false
	
