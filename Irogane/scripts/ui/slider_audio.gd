extends Node

@export var audio_player: AudioPlayer
@export var slider: Slider
@export var rate_limit: float = 0.03

@onready var slider_sound = load("res://assets/audio/ui/slider_click.ogg")

var last_sound_timestamp 

func _ready():
	if slider:
		slider.value_changed.connect(on_value_change)
	

func on_value_change(_value):
	if audio_player:
		if last_sound_timestamp:
			var time_now = Time.get_unix_time_from_system()
			var time_elapsed = time_now - last_sound_timestamp
			
			if time_elapsed < rate_limit:
				return
		
		var pitch_ratio = _value/255
		var ratio_multiplier = 0.1
		var pitch_base = 0.95
		var pitch = pitch_base + (ratio_multiplier * pitch_ratio)
		
		audio_player.play(slider_sound, null, pitch)
		last_sound_timestamp = Time.get_unix_time_from_system()
	
