extends OmniLight3D

@export var base_energy = 1.0
@export var flicker_amount = 2.0
@export var flicker_speed = 4.0

func _process(delta):
	light_energy = base_energy + flicker_amount * (randf() - 0.5) * delta * flicker_speed
	
