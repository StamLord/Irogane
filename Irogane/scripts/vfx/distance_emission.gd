extends GPUParticles3D

@export var active = false
@export var emission_per_unit = 0

var last_position

func _process(delta):
	if not active or emission_per_unit == 0:
		return
	
	if last_position == null:
		last_position = global_position
	
	var distance = global_position.distance_to(last_position)
	var particles = floor(distance * emission_per_unit)
	
	if particles > 0:
		for p in range(particles):
			emit_particle(global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
		last_position = global_position
	

