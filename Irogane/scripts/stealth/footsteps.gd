extends Node3D

@onready var audio_player = $audio

@export var sound_emitter : SoundEmitter
@export var state_machine : PlayerStateMachine
@onready var carpet_check = %carpet_check

@export var playing_in_states = ["walk", "run"]
@export var steps_per_unit = 2.0

@export var steps_sound_range = 4
@export var stone_volume = -20

@export var carpet_sound_range = 2
@export var carpet_volume = -25

var footstep_sounds = [
	preload("res://assets/audio/footsteps/stone/footstep_stone_07.ogg"), 
	preload("res://assets/audio/footsteps/stone/footstep_stone_08.ogg"),
	preload("res://assets/audio/footsteps/stone/footstep_stone_12.ogg"),
	preload("res://assets/audio/footsteps/stone/footstep_stone_13.ogg"),
	]
	

var carpet_footstep_sounds = [
	preload("res://assets/audio/footsteps/stone/footstep_carpet_03.ogg"), 
	preload("res://assets/audio/footsteps/stone/footstep_carpet_04.ogg"),
	preload("res://assets/audio/footsteps/stone/footstep_carpet_05.ogg"),
	preload("res://assets/audio/footsteps/stone/footstep_carpet_06.ogg"),
	]
	

var last_position = Vector3.ZERO
var distance_traveled = 0.0

var is_playing = false

func _ready():
	last_position = global_position
	
	if state_machine:
		state_machine.on_state_enter.connect(on_state_enter)
	

func make_a_step():
	var range
	if carpet_check.is_colliding():
		range = carpet_sound_range
	else:
		range = steps_sound_range
	
	emit_stealth_sound(range)
	play_footstep_sfx()
	

func _process(_delta):
	if not is_playing:
		return
	
	distance_traveled += global_position.distance_to(last_position)
	
	if distance_traveled >= steps_per_unit:
		make_a_step()
		distance_traveled -= steps_per_unit
	
	last_position = global_position
	

func emit_stealth_sound(range):
	if sound_emitter:
		sound_emitter.emit_sound(global_position, range)
	

func play_footstep_sfx():
	var sound
	var volume
	
	if carpet_check.is_colliding():
		sound = carpet_footstep_sounds.pick_random()
		volume = carpet_volume
	else:
		sound = footstep_sounds.pick_random()
		volume = stone_volume
	
	var sound_pitch = randf_range(0.8, 1.2)
	audio_player.play(sound, sound_pitch, volume)
	

func on_state_enter(state_name):
	var was_playing = is_playing
	is_playing = state_name in playing_in_states
	
	# If only started playing reset distance and last position
	if is_playing and not was_playing:
		distance_traveled = 0.0
		last_position = global_position
		make_a_step()
	
