extends Node3D
class_name Throwable

# Prefab
@onready var projectile_scene = load("res://prefabs/weapons/projectiles/shuriken.tscn")

# Skill Menu
@onready var ring_menu = $shuriken_ring_menu

const ITEM_ID = "shuriken"
const INITIAL_POS_OFFSET = Vector3(0, 0, -0.5)

var current_skill = ""
var shurikens_map = {}

func _ready():
	ring_menu.item_selected.connect(skill_selected)
	InputContextManager.context_changed.connect(context_changed)
	

func save_shuriken(type, shuriken):
	if type not in shurikens_map:
		shurikens_map[type] = []
	
	shurikens_map[type].append(shuriken)
	

func fire_shuriken(position_offset, rotation_offset, type = null):
	var projectile =  projectile_scene.instantiate()
	
	if type:
		save_shuriken(type, projectile)
	
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = (CameraEntity.main_camera.global_basis * position_offset) + global_position
	projectile.global_rotation = CameraEntity.main_camera.global_rotation + rotation_offset
	projectile.item_id = ITEM_ID
	projectile.restart()
	

func _process(delta):
	if not visible:
		return
	
	# Close ring menu if open
	if InputContextManager.is_current_context(InputContextType.RING_MENU):
		if not Input.is_action_pressed("ring_menu") and ring_menu.visible:
			ring_menu.close()
			InputContextManager.switch_context(InputContextType.GAME)
	
	# Process only if in GAME context
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
		# Open ring menu
	if Input.is_action_just_pressed("ring_menu") and not ring_menu.visible:
		#var ring_items: Array = PlayerEntity.get_skills_in_tree("throw")
		var ring_items : Array[String] = ["triple_throw", "octo_throw", "multiplying_shuriken"]
		if ring_items:
			ring_menu.initialize_items(ring_items)
			ring_menu.open()
		
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var position_offset = INITIAL_POS_OFFSET
		var rotation_offset = Vector3.ZERO
		fire_shuriken(position_offset, rotation_offset)
	elif Input.is_action_just_pressed("attack_secondary"):
		if current_skill:
			print("activating skill ", current_skill)
			if current_skill == "triple_throw":
				triple_throw()
			elif current_skill == "octo_throw":
				octo_throw()
			elif current_skill == "multiplying_shuriken":
				throw_multiplying()
	elif Input.is_action_just_pressed("activate"):
		if current_skill:
			if current_skill == "multiplying_shuriken" and "multiplying_shuriken" in shurikens_map:
				shurikens_map["multiplying_shuriken"]
				var shuriken = shurikens_map["multiplying_shuriken"].pop_back()
				if shuriken:
					multiply_shuriken(shuriken)
	

func generate_points_on_sphere(num_points, radius):
	var points = []
	
	for i in range(num_points):
		var new_point = random_point_on_sphere(radius)
		points.append(new_point)
	
	return points
	

func random_point_on_sphere(radius):
	var phi = randf_range(0, 2 * PI)
	var costheta = randf_range(-1, 1)
	var theta = acos(costheta)
	
	var x = radius * sin(theta) * cos(phi)
	var y = radius * sin(theta) * sin(phi)
	var z = radius * cos(theta)
	
	return Vector3(x, y, z)
	

func multiply_shuriken(shuriken):
	var initial_pos = shuriken.global_position
	shuriken.queue_free()
	
	var points = [
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.766, 0.642, 0.0),
		Vector3(0.0, 1.0, 0.0),
		Vector3(-0.766, 0.642, 0.0),
		Vector3(-1.0, 0.0, 0.0),
		Vector3(-0.766, -0.642, 0.0),
		Vector3(0.0, -1.0, 0.0),
		Vector3(0.766, -0.642, 0.0),
		Vector3(0.766, 0.0, 0.642),
		Vector3(0.5, 0.866, 0.0),
		Vector3(0.0, 0.766, 0.642),
		Vector3(-0.5, 0.866, 0.0),
		Vector3(-0.766, 0.0, 0.642),
		Vector3(-0.5, -0.866, 0.0),
		Vector3(0.0, -0.766, 0.642),
		Vector3(0.5, -0.866, 0.0),
		Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.766, -0.642),
		Vector3(0.0, -0.766, -0.642),
	]
	
	for point in points:
		DebugCanvas.debug_point(initial_pos + point, Color.GREEN, 7, 10)
		var projectile = projectile_scene.instantiate()
		get_tree().get_root().add_child(projectile)

		projectile.global_position = initial_pos
		projectile.look_at(initial_pos + point)

		projectile.item_id = ITEM_ID
		projectile.restart()
	

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
	var projectile = projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = position_offset + global_position
	projectile.global_rotation_degrees = rotation_offset
	
	projectile.item_id = ITEM_ID
	projectile.restart()
	

func fire_static_shuriken_at_pos(position, rotation_offset):
	var projectile = projectile_scene.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = position
	projectile.global_rotation_degrees = rotation_offset
	
	projectile.item_id = ITEM_ID
	projectile.restart()
	

func throw_many_static_shuriken_at_pos(position, rotation_offset_array: Array):
	for i in rotation_offset_array.size():
		fire_static_shuriken_at_pos(position, rotation_offset_array[i])
	

func octo_throw():
	var position_offsets = []
	var rotation_offsets = []
	var count = 8
	var part = 360 / count
	var camera_y = CameraEntity.main_camera.global_rotation_degrees.y
	
	for i in range(count):
		var degrees = part * i
		var position_offset = INITIAL_POS_OFFSET.rotated(Vector3(0, 1, 0), deg_to_rad(degrees + camera_y))
		var rotation_offset = Vector3(0, degrees + camera_y, 90)
		
		position_offsets.append(position_offset)
		rotation_offsets.append(rotation_offset)
	
	throw_many_static_shuriken(position_offsets, rotation_offsets)
	

func skill_selected(skill_name):
	current_skill = skill_name
	print(skill_name)
	

func throw_multiplying():
	var position_offset = INITIAL_POS_OFFSET
	var rotation_offset = Vector3.ZERO
	fire_shuriken(position_offset, rotation_offset, "multiplying_shuriken")
	

func context_changed(old_context, new_context):
	# In case context changed, we cancel the ring menu without activating a skill
	if old_context == InputContextType.RING_MENU and new_context != old_context:
		if ring_menu.visible == true:
			ring_menu.close_no_signal()
	
