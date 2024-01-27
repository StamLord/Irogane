extends UIButton

var initial_pos
var selected = false
@export var skill_name = ""
@export var hover_offset = -75.0
@export var select_offset = -100.0
@export var duration = 0.02
@export var hover_sound: AudioStream
@export var unhover_sound: AudioStream

signal skill_selected(skill_name)
signal skill_hovered(skill_name)

func _ready():
	super()
	initial_pos = get_position()
	mouse_exited.connect(_mouse_exited)
	

func _mouse_entered():
	super()
	skill_hovered.emit(skill_name)
	
	if selected:
		return
	
	if hover_sound:
		audio_player.play(hover_sound)
	
	animate_offset(initial_pos.x + hover_offset, duration)
	

func _mouse_exited():
	if selected:
		return
	
	if unhover_sound:
		audio_player.play(unhover_sound)
	animate_offset(initial_pos.x, duration)
	

func select():
	if selected:
		return
	
	selected = true
	var new_pos = initial_pos
	new_pos.x += select_offset
	set_position(new_pos)
	

func deselect():
	selected = false
	animate_offset(initial_pos.x, duration)
	

func _pressed():
	select()
	skill_selected.emit(skill_name)
	

func animate_offset(target_x, duration):
	var start_time = Time.get_ticks_msec()
	var start_x = position.x
	duration *= 1000
	while Time.get_ticks_msec() <= start_time + duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		position.x = lerp(start_x, target_x, t)
		await get_tree().process_frame
		
	position.x = target_x
	
