extends Node3D

@export var position_curve : CurveXYZTexture
@export var rotation_curve : CurveXYZTexture
@export var duration = 1.0
@export var animate = true

var timer = 0
func _process(delta):
	
	timer += delta
	if timer >= duration:
		timer -= duration
	
	var t = timer / duration
	
	position = Vector3(
		position_curve.curve_x.sample(t),
		position_curve.curve_y.sample(t),
		position_curve.curve_z.sample(t))
	
	rotation_degrees = Vector3(
		rotation_curve.curve_x.sample(t),
		rotation_curve.curve_y.sample(t),
		rotation_curve.curve_z.sample(t))
