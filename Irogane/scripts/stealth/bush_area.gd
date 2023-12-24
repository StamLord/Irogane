extends Area3D

@onready var wiggle_bone = $"../dwarf_cedar_rig/Skeleton3D/WiggleBone"
@onready var audio_player = $"../audio_player"

@export var wiggle_force = 5.0

@onready var sound_clip = preload("res://assets/audio/bush/Foliage03.wav")

func _ready():
	body_entered.connect(bush_entered)
	body_exited.connect(bush_exited)
	

func bush_entered(body):
	if not wiggle_bone:
		return
	
	# StaticBodies don't move so we shouldn't interact with them
	if body is StaticBody3D:
		return
	
	var entry_direction = (global_position - body.global_position).normalized()
	wiggle_bone.apply_impulse(entry_direction * wiggle_force)
	
	if audio_player:
		audio_player.play(sound_clip)
	

func bush_exited(body):
	if not wiggle_bone:
		return
	
	var exit_direction = (body.global_position - global_position).normalized()
	wiggle_bone.apply_impulse(exit_direction * wiggle_force)
	
	if audio_player:
		audio_player.play(sound_clip)
	
