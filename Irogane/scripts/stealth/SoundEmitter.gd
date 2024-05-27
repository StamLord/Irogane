extends Node3D
class_name SoundEmitter

@onready var sound_cast = $sound_cast
@onready var ripple_vfx = $sound_ripple_vfx
@export_flags_3d_physics var sound_collision_mask = 16

static var debug = false

func _ready():
	DebugCommandsManager.add_command(
		"display_sound_bubble",
		set_debug,
		 [{
				"arg_name" : "1/0",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : "1: True, 0: False"
			}],
		"Displays/Hides sound bubble comming from SoundEmitter(s)"
		)
	

func emit_sound(sound_position, sound_range):
	# Set and cast a sphere around us
	sound_cast.global_position = sound_position
	sound_cast.shape.radius = sound_range
	sound_cast.collision_mask = sound_collision_mask
	
	sound_cast.force_shapecast_update()
	
	# Get AwarnessAgents from colliders
	for i in range(sound_cast.get_collision_count()):
		if sound_cast.get_collider(i) is AwarenessAgent:
			sound_cast.get_collider(i).hear_sound(sound_position)
	
	# Play vfx
	if debug and ripple_vfx:
		ripple_vfx.global_position = sound_position
		ripple_vfx.process_material.scale_min = sound_range * 2
		ripple_vfx.process_material.scale_max = sound_range * 2
		ripple_vfx.emit_particle(ripple_vfx.get_global_transform(), Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	

func set_debug(args):
	debug = bool(args[0])
	
