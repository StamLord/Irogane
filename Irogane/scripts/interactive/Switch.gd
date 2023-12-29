@tool
extends Interactive
class_name Switch

@export var state : bool : 
	set(value): 
		state = value
		
		if Engine.is_editor_hint():
			if state:
				get_parent().position = origin_position + get_parent().basis * on_position
				get_parent().rotation_degrees = origin_rotation + on_rotation
			else:
				get_parent().position = origin_position
				get_parent().rotation_degrees = origin_rotation
	

@export var on_text : String
@export var on_position : Vector3
@export var on_rotation : Vector3
@export var animation_time : float
@export var sub_switches : Array[Switch]

@onready var origin_position =  get_parent().position
@onready var origin_rotation = get_parent().rotation_degrees

var is_animating_position : bool
var is_animating_rotation : bool

signal on_state_changed(state)

func use(interactor):
	state = !state
	
	perform_animations()
	
	for sub_switch in sub_switches:
		sub_switch.chain_use()
	

func chain_use():
	state = !state
	perform_animations()
	

func perform_animations():
	if state:
		animate_position(origin_position, origin_position + get_parent().basis * on_position)
		animate_rotation(origin_rotation, origin_rotation + on_rotation)
	else:
		animate_position(origin_position + get_parent().basis * on_position, origin_position)
		animate_rotation(origin_rotation + on_rotation, origin_rotation)
	
	on_state_changed.emit(state)
	

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
