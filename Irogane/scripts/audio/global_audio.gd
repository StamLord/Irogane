extends Node

var audio_player = null

func _ready():
	create_audio_player_if_needed()
	

func create_audio_player_if_needed():
	if not audio_player:
		audio_player = AudioStreamPlayer2D.new()
		get_tree().root.add_child.call_deferred(audio_player)
	

func play_audio(sound: AudioStream):
	if audio_player:
		audio_player.stream = sound
		audio_player.play()
	
