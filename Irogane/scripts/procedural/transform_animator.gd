extends Node3D

@export var position_curve : CurveXYZTexture
@export var rotation_curve : CurveXYZTexture
@export var duration = 1.0
@export var animate = true

var timer = 0
var start_position = Vector3.ZERO

func _ready():
	start_position = position
	

func _process(delta):
	
	timer += delta
	if timer >= duration:
		timer -= duration
	
	var t = timer / duration
	
	if position_curve and position_curve.curve_x and position_curve.curve_y and position_curve.curve_z:
		position = start_position + Vector3(
			position_curve.curve_x.sample(t),
			position_curve.curve_y.sample(t),
			position_curve.curve_z.sample(t))
	
	if rotation_curve and rotation_curve.curve_x and rotation_curve.curve_y and rotation_curve.curve_z:
		rotation_degrees = Vector3(
			rotation_curve.curve_x.sample(t),
			rotation_curve.curve_y.sample(t),
			rotation_curve.curve_z.sample(t))
