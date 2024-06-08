extends UIButton

@export var skill_name = ""
@export var hover_offset = -75.0
@export var select_offset = -100.0
@export var duration = 0.02
@export var select_sound: AudioStream
@export var unhover_sound: AudioStream

signal skill_scroll_selected(skill_tree_name, skill_tree_scroll)

var initial_pos
var selected = false


func _ready():
	super()
	initial_pos = get_position()
	mouse_exited.connect(_mouse_exited)
	

func _mouse_entered():
	if selected:
		return
	
	super()
	animate_offset(initial_pos.x + hover_offset, duration)
	

func _focus_entered():
	if selected:
		return
	
	super()
	

func _mouse_exited():
	if selected:
		return
	
	release_focus()
	
	if unhover_sound:
		# We use play_exlusive to avoid playing unhover_sound while
		# another scroll's hover_sound is playing. Must be deferred to allow
		# the other scroll's hover_sound to be registered in the audio_player.
		audio_player.call_deferred("play_only_if_no_one_playing", unhover_sound)
	
	animate_offset(initial_pos.x, duration)
	

func select():
	if selected:
		return
	
	selected = true
	var new_pos = initial_pos
	new_pos.x += select_offset
	set_position(new_pos)
	
	if select_sound:
		audio_player.play(select_sound)
	

func deselect():
	selected = false
	animate_offset(initial_pos.x, duration)
	

func _pressed():
	select()
	skill_scroll_selected.emit(skill_name, self)
	

func animate_offset(target_x, animation_duration):
	var start_time = Time.get_ticks_msec()
	var start_x = position.x
	animation_duration *= 1000
	while Time.get_ticks_msec() <= start_time + animation_duration:
		var t = (Time.get_ticks_msec() - start_time) / animation_duration
		position.x = lerp(start_x, target_x, t)
		await get_tree().process_frame
		
	position.x = target_x
	
