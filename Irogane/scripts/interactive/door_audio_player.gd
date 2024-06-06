extends Node3D

@export var switch : Switch
@onready var audio_player = $audio_player

var unlocked_clip = preload("res://assets/audio/lock/door_lock_0.ogg")
var opened_clip = preload("res://assets/audio/lock/wood_door_open.ogg")
var closed_clip = preload("res://assets/audio/lock/wood_door_close.ogg")

func _ready():
	if switch != null:
		switch.on_state_changed.connect(play_opened)
		switch.on_animation_done.connect(play_closed)
		switch.on_failed_unlocked.connect(play_unlocked)
		switch.on_unlocked.connect(play_unlocked)
	

func play_clip(clip):
	if audio_player == null:
		return
	
	if audio_player.stream is AudioStreamPolyphonic:
		if not audio_player.playing:
			audio_player.play()
		audio_player.get_stream_playback().play_stream(clip)
	else:
		audio_player.stream = clip
		audio_player.play()
	

func play_opened(state):
	if state:
		play_clip(opened_clip)
	

func play_unlocked():
	play_clip(unlocked_clip)
	

func play_closed(state):
	if not state:
		play_clip(closed_clip)
	
