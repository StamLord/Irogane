@tool
extends Interactive
class_name Switch

@export var state : bool : 
	set(value): 
		state = value
		
		if Engine.is_editor_hint():
			origin_position = get_parent().position
			origin_rotation_degrees = get_parent().rotation_degrees
			
			if state:
				get_parent().position = origin_position + on_position
				get_parent().rotation_degrees = origin_rotation_degrees + on_rotation
			else:
				get_parent().position = origin_position + off_position
				get_parent().rotation_degrees = origin_rotation_degrees + off_rotation
	

@export var on_text : String
@export var _animate_position : bool = true
@export var off_position : Vector3
@export var on_position : Vector3
@export var _animate_rotation : bool = true
@export var off_rotation : Vector3
@export var on_rotation : Vector3
@export var animation_time : float
@export var sub_switches : Array[Switch]
@export var required_switches : Array[Switch]
@export var required_keys : Array[Key]

@onready var is_locked = required_keys.size() > 0
var is_animating_position : bool
var is_animating_rotation : bool

var origin_position: Vector3
var origin_rotation_degrees: Vector3

signal on_state_changed(state)
signal on_animation_done(state)
signal on_failed_unlocked()
signal on_unlocked()

func _ready():
	if Engine.is_editor_hint():
		return
	
	origin_position = get_parent().position
	origin_rotation_degrees = get_parent().rotation_degrees
	

func use(interactor):
	if is_locked:
		for key in required_keys:
			if interactor == null:
				return
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
	if _animate_position:
		var from_pos = off_position if state else on_position
		var to_pos = on_position if state else off_position
		animate_position(origin_position + from_pos, origin_position + to_pos)
	
	if _animate_rotation:
		var from_rot = off_rotation if state else on_rotation
		var to_rot = on_rotation if state else off_rotation
		animate_rotation(origin_rotation_degrees + from_rot, origin_rotation_degrees + to_rot)
	
	on_state_changed.emit(state)
	
	if _animate_position or _animate_rotation:
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
		await get_tree().process_frame
	
	get_parent().position = to
	is_animating_position = false
	

func animate_rotation(from, to):
	is_animating_rotation = true
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		get_parent().rotation_degrees = lerp(from, to, t)
		await get_tree().process_frame
	
	get_parent().rotation_degrees = to
	is_animating_rotation = false
	
