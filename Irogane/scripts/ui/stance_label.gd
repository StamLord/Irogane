extends Control

@export var fade_duration = .5
@export var display_duration = 2
@export var in_scale = Vector2(2, 1)
@export var out_scale = Vector2(2, 1)

@onready var stance_label = $stance_label

func show_text(_text : String):
	stance_label.text = _text
	start_animation()
	

func start_animation():
	visible = true
	var fade_duration_msec = float(fade_duration * 1000)
	
	# Fade / Scale in
	var time_started = Time.get_ticks_msec()
	while Time.get_ticks_msec() - time_started <= fade_duration_msec:
		var t = (Time.get_ticks_msec() - time_started) / fade_duration_msec
		modulate.a = t
		scale = lerp(in_scale, Vector2.ONE, t)
		await get_tree().process_frame
	
	# Display
	await get_tree().create_timer(display_duration).timeout
	
	# Fade / Scale out
	time_started = Time.get_ticks_msec()
	while Time.get_ticks_msec() - time_started <= fade_duration_msec:
		var t = (Time.get_ticks_msec() - time_started) / fade_duration_msec
		modulate.a = 1 - t
		scale = lerp(Vector2.ONE, out_scale, t)
		await get_tree().process_frame
	
	visible = false
	
