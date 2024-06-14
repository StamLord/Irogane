extends Node3D

var rotation_speed = 4.0

func _process(delta):
	var parent_rotation = owner.global_rotation
	rotation.y = lerp_angle(rotation.y, -parent_rotation.y, rotation_speed * delta)
	
