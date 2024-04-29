extends Node3D
class_name Throwable

# Prefab
@onready var projectile_prefab = load("res://prefabs/weapons/projectiles/shuriken.tscn")

# Skill Menu
@onready var ring_menu = $shuriken_ring_menu
@onready var skill_zone = %skill_zone

const ITEM_ID = "shuriken"
const INITIAL_POS_OFFSET =  Vector3(0, 0, -0.5)
const HIP_POS_OFFSET = Vector3(0.15, -0.1, -0.5)

var current_skill = ""
var active_shurikens = {}

func _ready():
	ring_menu.item_selected.connect(skill_selected)
	InputContextManager.context_changed.connect(context_changed)
	

func track_shuriken(type, shuriken):
	if type not in active_shurikens:
		active_shurikens[type] = []
	
	active_shurikens[type].append(shuriken)
	

func get_target_point():
	var RAY_LENGTH = 100
	var mouse_pos = get_viewport().get_mouse_position()
	var camera3d = CameraEntity.main_camera
	var from = camera3d.project_ray_origin(mouse_pos)
	var to = from + camera3d.project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var space_state = camera3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		#DebugCanvas.debug_point(result.position, Color.BLUE, 7, 10)
		return result.position
	else:
		#DebugCanvas.debug_point(to, Color.RED, 7, 10)
		return to
	

func fire_shuriken(position_offset, rotation_offset, type = null):
	var projectile =  projectile_prefab.instantiate()
	
	if type:
		track_shuriken(type, projectile)
	
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = (CameraEntity.main_camera.global_basis * position_offset) + CameraEntity.main_camera.global_position
	projectile.global_rotation = rotation_offset
	projectile.item_id = ITEM_ID
	var target_point = get_target_point()
	projectile.look_at(target_point)
	projectile.restart()
	
	if type == "bouncing_shuriken":
		projectile.bounce_count = 3
	

func _process(delta):
	if not visible:
		return
	
	# Close ring menu if open
	if InputContextManager.is_ring_menu_context():
		if not Input.is_action_pressed("ring_menu") and ring_menu.visible:
			ring_menu.close()
			InputContextManager.switch_context(InputContextType.GAME)
	
	# Process only if in GAME context
	if not InputContextManager.is_game_context():
		return
	
	# Open ring menu
	if Input.is_action_just_pressed("ring_menu") and not ring_menu.visible:
		#var ring_items: Array = PlayerEntity.get_skills_in_tree("throw")
		var ring_items : Array[String] = ["triple_throw", "octo_throw", "multiplying_shuriken", "body_switch", "bouncing_shuriken", "metal_shower"]
		if ring_items:
			ring_menu.initialize_items(ring_items)
			ring_menu.open()
		
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		fire_shuriken(HIP_POS_OFFSET, Vector3.ZERO)
	elif Input.is_action_just_pressed("attack_secondary"):
		if current_skill == "triple_throw":
			triple_throw()
		elif current_skill == "octo_throw":
			octo_throw()
		elif current_skill == "multiplying_shuriken":
			fire_shuriken(INITIAL_POS_OFFSET, Vector3.ZERO, "multiplying_shuriken")
		elif current_skill == "body_switch":
			fire_shuriken(INITIAL_POS_OFFSET, Vector3.ZERO, "body_switch")
		elif current_skill == "bouncing_shuriken":
			fire_shuriken(INITIAL_POS_OFFSET, Vector3.ZERO, "bouncing_shuriken")
		elif current_skill == "metal_shower":
			show_metal_shower_zone()
	elif Input.is_action_just_pressed("activate"):
		activate_special_shuriken(current_skill)
	
	if Input.is_action_just_released("attack_secondary"):
		if current_skill == "metal_shower":
			activate_metal_shower()
	

func show_metal_shower_zone():
	skill_zone.visible = true
	

# Raycastas 10 meters up from a point, if it's available 
func get_floating_throw_pos(pos: Vector3):
	var default_height = Vector3(pos.x, pos.y + 10, pos.z)
	var query = PhysicsRayQueryParameters3D.create(pos, default_height)
	var camera3d = CameraEntity.main_camera
	var space_state = camera3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	
	return default_height
	

func activate_metal_shower():
	var initial_pos = skill_zone.global_position
	DebugCanvas.debug_point(initial_pos, Color.BLUE, 7, 10)
	for point in generate_points_inside_circle(20, 1.5):
		var ground_pos = initial_pos + Vector3(point.x, 0, point.y)
		var throw_pos = get_floating_throw_pos(ground_pos)
		
		DebugCanvas.debug_point(throw_pos, Color.GREEN, 7, 10)
		DebugCanvas.debug_point(ground_pos, Color.RED, 7, 10)
		
		var projectile = projectile_prefab.instantiate()
		get_tree().get_root().add_child(projectile)
		projectile.global_position = throw_pos
		projectile.look_at(ground_pos + Vector3(0.001, 0.0, 0.0))  # Small margin because look_at freaks out when ground_pos is almost identical to position
		projectile.item_id = ITEM_ID
		
		projectile.restart()
	
	skill_zone.visible = false
	

func activate_special_shuriken(type: String):
	if type in active_shurikens:
		var shuriken = active_shurikens[type].pop_back()
		if shuriken:
			if type == "multiplying_shuriken":
				multiply_shuriken(shuriken)
			elif type == "body_switch":
				body_switch(shuriken)
	

func body_switch(shuriken):
	var shuriken_pos = shuriken.global_position
	var player_pos = PlayerEntity.player_node.global_position 
	
	PlayerEntity.player_node.global_position = shuriken_pos
	shuriken.stopped = true
	shuriken.global_position = player_pos
	

func generate_points_on_sphere(num_points):
	var points = []
	for i in range(num_points):
		var phi = acos(1 - 2 * (i + 0.5) / num_points)
		var theta = PI * (1 + sqrt(5)) * (i + 0.5)
		var x = cos(theta) * sin(phi)
		var y = sin(theta) * sin(phi)
		var z = cos(phi)
		points.append(Vector3(x, y, z))
	return points
	

func generate_points_inside_circle(num_points: int, radius: float) -> Array:
	var points = []
	var angle_increment = 2 * PI * (1 + sqrt(5)) / 2
	var golden_ratio = (1 + sqrt(5)) / 2
	for i in range(num_points):
		var scaled_radius = sqrt(i + 0.5) / sqrt(num_points) * golden_ratio * radius
		var angle = i * angle_increment
		var x = cos(angle) * scaled_radius
		var y = sin(angle) * scaled_radius
		points.append(Vector2(x, y))
	return points
	

func multiply_shuriken(shuriken):
	var initial_pos = shuriken.global_position
	shuriken.queue_free()
	
	
	for point in generate_points_on_sphere(20):
		DebugCanvas.debug_point(initial_pos + point, Color.GREEN, 7, 10)
		var projectile = projectile_prefab.instantiate()
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
	var projectile = projectile_prefab.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = position_offset + global_position
	projectile.global_rotation_degrees = rotation_offset
	
	projectile.item_id = ITEM_ID
	projectile.not_persistent = true
	projectile.restart()
	

func fire_static_shuriken_at_pos(position, rotation_offset):
	var projectile = projectile_prefab.instantiate()
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
	

func context_changed(old_context, new_context):
	# In case context changed, we cancel the ring menu without activating a skill
	if InputContextManager.is_ring_menu_context() and new_context != old_context:
		if ring_menu.visible == true:
			ring_menu.close_no_signal()
	
