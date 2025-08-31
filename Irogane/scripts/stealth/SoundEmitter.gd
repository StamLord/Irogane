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
	
	if sound_cast == null:
		create_sound_cast()
	

func create_sound_cast():
	var shape_cast = ShapeCast3D.new()
	shape_cast.shape = SphereShape3D.new()
	shape_cast.collision_mask = sound_collision_mask
	add_child(shape_cast)
	sound_cast = shape_cast
	

func emit_sound(sound_position, sound_range):
	# Set and cast a sphere around us
	if sound_cast.shape == null:
		sound_cast.shape = SphereShape3D.new()
	
	sound_cast.global_position = sound_position
	sound_cast.shape.radius = sound_range
	sound_cast.collision_mask = sound_collision_mask
	sound_cast.collide_with_areas = true
	
	sound_cast.force_shapecast_update()
	
	# Get AwarnessAgents from colliders
	for i in range(sound_cast.get_collision_count()):
		if sound_cast.get_collider(i) is AwarenessAgent:
			var path = get_nav_path(sound_position, sound_cast.get_collider(i).global_position)
			var distance = get_path_length(path)
			
			if distance > sound_range:
				if debug:
					DebugCanvas.debug_path(path, Color.RED)
				continue
			
			if debug:
				DebugCanvas.debug_path(path, Color.YELLOW)
			
			sound_cast.get_collider(i).hear_sound(sound_position)
	
	# Play vfx
	if debug and ripple_vfx:
		ripple_vfx.global_position = sound_position
		ripple_vfx.process_material.scale_min = sound_range * 2
		ripple_vfx.process_material.scale_max = sound_range * 2
		ripple_vfx.emit_particle(ripple_vfx.get_global_transform(), Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	

func get_nav_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var nav_map = get_world_3d().navigation_map 
	if nav_map == null:
		return PackedVector3Array()
	
	return NavigationServer3D.map_get_path(nav_map, from, to, true)
	

func get_path_length(path: PackedVector3Array):
	var length = 0.0
	for i in range(path.size() - 1):
		length += path[i].distance_to(path[i + 1])
		
	return length
	

func set_debug(args):
	debug = bool(args[0])
	
