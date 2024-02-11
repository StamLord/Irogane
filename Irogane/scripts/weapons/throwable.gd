extends Node3D

@onready var projectile_scene = load("res://prefabs/weapons/projectiles/shuriken.tscn")

const ITEM_ID = "shuriken"

func fire_shuriken(position_offset, rotation_offset):
	var pickup =  projectile_scene.instantiate()
	get_tree().get_root().add_child(pickup)
	
	pickup.global_position = (CameraEntity.main_camera.global_basis * position_offset) + global_position
	pickup.global_rotation = CameraEntity.main_camera.global_rotation + rotation_offset
	pickup.item_id = ITEM_ID
	pickup.restart()
	

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var position_offset = Vector3(0, 0, -0.5)
		var rotation_offset = Vector3.ZERO
		fire_shuriken(position_offset, rotation_offset)
	elif Input.is_action_just_pressed("attack_secondary"):
		if get_parent().active_skill:
			print("activating skill ", get_parent().active_skill)
			if get_parent().active_skill == "triple_throw":
				triple_throw()
	

func triple_throw():
	const SPREAD_DISTANCE = 0.025
	const SPREAD_ANGLE = 0.08
	
	var position_offset = Vector3(0, 0, -0.5)
	var rotation_offset = Vector3.ZERO
	fire_shuriken(position_offset, rotation_offset)
	
	var position_offset2 = Vector3(-SPREAD_DISTANCE, 0, -0.5)
	var rotation_offset2 = Vector3(0, SPREAD_ANGLE, 0)
	fire_shuriken(position_offset2, rotation_offset2)
	
	var position_offset3 = Vector3(SPREAD_DISTANCE, 0, -0.5)
	var rotation_offset3 = Vector3(0, -SPREAD_ANGLE, 0)
	fire_shuriken(position_offset3, rotation_offset3)
	
