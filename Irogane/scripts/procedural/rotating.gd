extends Node3D

enum axis_enum {X, Y, Z}
enum rotation_type_enum {full, ping_pong}
@export var axis: axis_enum
@export var rotation_type: rotation_type_enum
@export var range = Vector2(0.0, 0.0)
@export var speed = 1.0

var inverted = false

func _process(delta):
	if axis == axis_enum.X:
		rotation_degrees.x = rotate_angle(rotation_degrees.x, delta)
	elif axis == axis_enum.Y:
		rotation_degrees.y = rotate_angle(rotation_degrees.y, delta)
	elif axis == axis_enum.Z:
		rotation_degrees.z = rotate_angle(rotation_degrees.z, delta)
	

func rotate_angle(angle, delta):
	if rotation_type == rotation_type_enum.ping_pong:
		var change = speed * delta
		
		if inverted:
			change *= -1
		
		angle = lerp(angle, angle + change, delta * speed)
		
		# Invert at range min/max
		if angle <= range.x or angle >= range.y:
			inverted = !inverted
		
		angle = clamp(angle, range.x, range.y)
	else:
		angle += speed * delta
		# Clamp to 360
		if angle > 360:
			angle -= 360
		elif angle < -360:
			angle += 360
	
	return angle
