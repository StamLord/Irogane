extends Node


func play_audio(sound: AudioStream):
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	get_tree().root.add_child.call_deferred(player)
	player.set_bus(&"Sound")
	player.set_stream(sound)
	
	player.play()
	player.finished.connect(delete_player.bind(player))
	

func delete_player(audio_player):
	audio_player.queue_free()
	
