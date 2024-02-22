extends Node3D

@onready var projectile_scene = load("res://prefabs/weapons/projectiles/shuriken.tscn")

const ITEM_ID = "shuriken"
const INITIAL_POS_OFFSET = Vector3(0, 0, -0.5)

func fire_shuriken(position_offset, rotation_offset):
	var projectile =  projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = (CameraEntity.main_camera.global_basis * position_offset) + global_position
	projectile.global_rotation = CameraEntity.main_camera.global_rotation + rotation_offset
	projectile.item_id = ITEM_ID
	projectile.restart()
	

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var position_offset = INITIAL_POS_OFFSET
		var rotation_offset = Vector3.ZERO
		fire_shuriken(position_offset, rotation_offset)
	elif Input.is_action_just_pressed("attack_secondary"):
		if get_parent().active_skill:
			print("activating skill ", get_parent().active_skill)
			if get_parent().active_skill == "triple_throw":
				triple_throw()
			elif get_parent().active_skill == "octo_throw":
				octo_throw()

func throw_many_shuriken(pos_offset_array: Array, rotation_offset_array: Array):
	if pos_offset_array.size() != rotation_offset_array.size():
		print("Different position and rotation arrays size")
		return
	
	for i in pos_offset_array.size():
		fire_shuriken(pos_offset_array[i], rotation_offset_array[i])
	
func throw_many_static_shuriken(pos_offset_array: Array, rotation_offset_array: Array):
	if pos_offset_array.size() != rotation_offset_array.size():
		print("Different position and rotation arrays size")
		return
	
	for i in pos_offset_array.size():
		fire_static_shuriken(pos_offset_array[i], rotation_offset_array[i])
	

func triple_throw():
	const SPREAD_DISTANCE = 0.025
	const SPREAD_ANGLE = 0.08
	
	var position_offset2 = INITIAL_POS_OFFSET + Vector3(-SPREAD_DISTANCE, 0, 0)
	var position_offset3 = INITIAL_POS_OFFSET + Vector3(SPREAD_DISTANCE, 0, 0)
	
	var rotation_offset1 = Vector3(0, 0, deg_to_rad(90))
	var rotation_offset2 = Vector3(0, SPREAD_ANGLE, deg_to_rad(90))
	var rotation_offset3 = Vector3(0, -SPREAD_ANGLE, deg_to_rad(90))
	
	var position_offsets = [INITIAL_POS_OFFSET, position_offset2, position_offset3]
	var rotation_offsets = [rotation_offset1, rotation_offset2, rotation_offset3]
	
	throw_many_shuriken(position_offsets, rotation_offsets)
	

func fire_static_shuriken(position_offset, rotation_offset):
	var projectile =  projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = position_offset + global_position
	projectile.global_rotation_degrees = rotation_offset
	
	projectile.item_id = ITEM_ID
	projectile.restart()
	

func octo_throw():
	var position_offsets = []
	var rotation_offsets = []
	var count = 8
	var part = 360 / count
	var camera_y = CameraEntity.main_camera.global_rotation_degrees.y
	print("camera_y ", camera_y)
	for i in range(count):
		var degrees = part * i
		var position_offset = INITIAL_POS_OFFSET.rotated(Vector3(0, 1, 0), deg_to_rad(degrees + camera_y))
		var rotation_offset = Vector3(0, degrees + camera_y, 90)
		
		position_offsets.append(position_offset)
		rotation_offsets.append(rotation_offset)
	
	throw_many_static_shuriken(position_offsets, rotation_offsets)
	
