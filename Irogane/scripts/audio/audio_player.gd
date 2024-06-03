extends Node3D
class_name AudioPlayer

@export var bus: StringName = &"Master"
@export var default_volume: float = 0.0
var audio_players_by_id = {}
var can_play = true

func set_can_play(value: bool):
	can_play = value
	

func get_can_play():
	return can_play
	

func play_only_if_no_one_playing(sound: AudioStream, pitch: float = 1.0, volume: float = 0.0):
	if audio_players_by_id.size() > 0:
		return
	
	play(sound, pitch, volume)
	

func play_exclusive(sound: AudioStream, pitch: float = 1.0, volume: float = 0.0):
	# TODO: FIX this
	for id in audio_players_by_id:
		var player = audio_players_by_id[id]
		player.stop()
		delete_player(player)
	play(sound, pitch, volume)
	

func play(sound: AudioStream, pitch = null, volume: float = 0.0):
	if not can_play:
		return
	
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	activate_player(player, sound, pitch, volume)
	

func activate_player(player, sound: AudioStream, pitch = 1.0, volume: float = 0.0):
	audio_players_by_id[player.get_instance_id()] = player
	add_child(player)
	
	
	if pitch:
		player.set_pitch_scale(pitch)
	
	player.set_volume_db(default_volume)
	
	if volume:
		player.set_volume_db(volume)
	
	player.set_bus(bus)
	player.set_stream(sound)
	
	player.play()
	player.finished.connect(delete_player.bind(player))
	

func play_positional_sound(sound: AudioStream, sound_position = null, pitch = null, volume: float = 0.0):
	if not can_play:
		return
	
	var player: AudioStreamPlayer3D  = AudioStreamPlayer3D.new()
	
	if sound_position:
		player.set_global_position(sound_position)
	else:
		player.set_global_position(global_position)
	
	activate_player(player, sound, pitch, volume)
	

func delete_player(audio_player: AudioStreamPlayer3D):
	audio_players_by_id.erase(audio_player.get_instance_id())
	audio_player.queue_free()
	
