extends Decal

@export var fade_after_duration = 10.0
@export var fade_duration = 2.0

signal fade_over()

var start_time = 0.0
var fade_done = true

func _enter_tree():
	start_time = Time.get_ticks_msec()
	fade_done = false
	modulate.a = 1
	

func _process(delta):
	if fade_done:
		return
	
	if Time.get_ticks_msec() - start_time >= fade_after_duration * 1000:
		var fade_time = Time.get_ticks_msec() - start_time - (fade_after_duration * 1000 )
		var t = fade_time / (fade_duration * 1000)
		modulate.a = lerp(1, 0, t)
		
		if t >= 1:
			fade_done = true
			fade_over.emit()
	
