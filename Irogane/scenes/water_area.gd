extends Area3D

@onready var water_splash = $vfx/water_splash
@onready var water_splash_2 = $vfx/water_splash2
@onready var water_splash_3 = $vfx/water_splash3
@onready var water_splash_4 = $vfx/water_splash4
@onready var water_spray = $vfx/water_spray

@export var spray_amount = 8

var bodies = []
var bodies_exited = {}

func _process(delta):
	# Clean list of bodies that exited after a .1 delay
	for b in bodies_exited:
		if Time.get_ticks_msec() - bodies_exited[b] >= .1:
			bodies_exited.erase(b)
	

func _on_body_entered(body):
	if bodies.has(body) or bodies_exited.has(body):
		return
	
	bodies.append(body)
	
	var pos = body.global_position + Vector3.UP * 0.1
	
	water_splash.global_position = pos
	water_splash_2.global_position = pos
	water_splash_3.global_position = pos
	water_splash_4.global_position = pos
	water_spray.global_position = pos
	
	water_splash.emit_particle(water_splash.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	water_splash_2.emit_particle(water_splash_2.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	water_splash_3.emit_particle(water_splash_3.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	water_splash_4.emit_particle(water_splash_4.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	
	for i in range(spray_amount):
		water_spray.emit_particle(water_spray.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)

func _on_body_exited(body):
	bodies.erase(body)
	bodies_exited[body] = Time.get_ticks_msec()
	
