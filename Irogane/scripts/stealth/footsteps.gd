extends Node3D

@onready var audio_player = $audio

@export var sound_emitter : SoundEmitter
@export var state_machine : PlayerStateMachine
@export var steps_per_unit = 0.5
@export var steps_sound_range = 8
@export var playing_in_states = ["walk", "run"]
@export var play_once_from_state = ["air"]

var footstep_sounds = [
	preload("res://assets/audio/footsteps/StepSamurai01.mp3"), 
	preload("res://assets/audio/footsteps/StepSamurai02.mp3"), 
	preload("res://assets/audio/footsteps/StepSamurai03.mp3"), 
	preload("res://assets/audio/footsteps/StepSamurai04.mp3"), 
	preload("res://assets/audio/footsteps/StepSamurai05.mp3")]

var last_position = Vector3.ZERO
var distance_traveled = 0.0

var is_playing = false
var play_once = false

func _ready():
	last_position = global_position
	
	if state_machine:
		state_machine.on_state_enter.connect(on_state_enter)
		state_machine.on_state_exit.connect(on_state_exit)
	

func _process(_delta):
	if not is_playing:
		return
	
	distance_traveled += global_position.distance_to(last_position)
	var step_distance = 1.0 / steps_per_unit
	
	if distance_traveled >= step_distance:
		emit_stealth_sound()
		play_footstep_sfx()
		distance_traveled -= step_distance
		
	last_position = global_position
	

func emit_stealth_sound():
	if sound_emitter:
		sound_emitter.emit_sound(global_position, steps_sound_range)
	

func play_footstep_sfx():
	audio_player.play(footstep_sounds.pick_random())
	

func on_state_enter(state_name):
	var was_playing = is_playing
	is_playing = state_name in playing_in_states
	
	# If only started playing reset distance and last position
	if is_playing and not was_playing:
		distance_traveled = 0.0
		last_position = global_position
	
	# Play sound once if exited a valid state
	if is_playing and play_once:
		emit_stealth_sound()
		play_footstep_sfx()
	play_once = false
	

func on_state_exit(state_name):
	# Check if should play once when entering next valid state
	play_once = state_name in play_once_from_state
	
