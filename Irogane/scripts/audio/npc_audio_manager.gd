extends Node3D

@export var awarness_agent : AwarenessAgent
@export var same_signal_wait = 2.0

@onready var audio_player = $audio_player

@onready var hear_sound_clips = [
	preload("res://assets/audio/guard_detection/hmm.ogg"), 
	preload("res://assets/audio/guard_detection/huh.ogg"), 
	preload("res://assets/audio/guard_detection/is_anyone_there.ogg"), 
	preload("res://assets/audio/guard_detection/i_heard_you.ogg"), 
	preload("res://assets/audio/guard_detection/what_was_that.ogg"), 
	preload("res://assets/audio/guard_detection/whos_there.ogg"), 
	preload("res://assets/audio/guard_detection/who_goes_there.ogg")]
@onready var see_sound_clips = [
	preload("res://assets/audio/guard_detection/hey.ogg"), 
	preload("res://assets/audio/guard_detection/i_can_see_you.ogg"), 
	preload("res://assets/audio/guard_detection/there_is_somebody_here.ogg"), 
	preload("res://assets/audio/guard_detection/you_know_i_can_see_you.ogg")]

var last_hear = 0.0
var last_see = 0.0

func _ready():
	if awarness_agent:
		awarness_agent.on_sound_heard.connect(play_sound_heard)
		awarness_agent.on_enemy_seen.connect(play_enemy_seen)
	

func play_sound_heard(_sound_position):
	if Time.get_ticks_msec() - last_hear <= same_signal_wait * 1000:
		return
	
	play(hear_sound_clips.pick_random())
	
	last_hear = Time.get_ticks_msec()
	

func play_enemy_seen(_sound_position):
	if Time.get_ticks_msec() - last_see <= same_signal_wait * 1000:
		return
	
	play(see_sound_clips.pick_random())
	
	last_see = Time.get_ticks_msec()
	

func play(clip):
	if audio_player == null:
		return
	
	audio_player.stream = clip
	audio_player.play()
