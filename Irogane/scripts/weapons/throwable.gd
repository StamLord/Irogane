extends Node3D
class_name Throwable
	
enum ShootPos {BOTTOM_RIGHT, BOTTOM_LEFT, TOP_RIGHT, TOP_LEFT}

const model_screen_pos = {
	ShootPos.BOTTOM_RIGHT: Vector3(0.4, -0.25, -0.4),
	ShootPos.BOTTOM_LEFT: Vector3(-0.4, -0.25, -0.4),
	ShootPos.TOP_RIGHT: Vector3(0.4, 0.25, -0.4),
	ShootPos.TOP_LEFT: Vector3(-0.4, 0.25, -0.4),
}

const shoot_pos_offset = {
	ShootPos.BOTTOM_RIGHT: Vector3(0.15, -0.1, 0),
	ShootPos.BOTTOM_LEFT: Vector3(-0.15, -0.1, 0),
	ShootPos.TOP_RIGHT: Vector3(0.15, 0.1, 0),
	ShootPos.TOP_LEFT: Vector3(-0.15, 0.1, 0)
}

# Prefab
@onready var shuriken_prefab = load("res://prefabs/weapons/projectiles/shuriken.tscn")
@onready var smoke_vanish_vfx = $smoke_vanish_vfx

# Skill Menu
@onready var ring_menu = $shuriken_ring_menu
@onready var skill_zone = %skill_zone

const ITEM_ID = "shuriken"

var current_skill = ""
var active_shurikens = {}
var shoot_pos = ShootPos.BOTTOM_RIGHT
var straight_shuriken_z_rotation = 33.0
var last_straight_shuriken_rotation = 20.0

func _ready():
	ring_menu.item_selected.connect(skill_selected)
	InputContextManager.context_changed.connect(context_changed)
	

func track_shuriken(type, shuriken):
	if type not in active_shurikens:
		active_shurikens[type] = []
	
	active_shurikens[type].append(shuriken)
	

func get_target_point_in_front():
	var RAY_LENGTH = 100
	var mouse_pos = get_viewport().get_mouse_position()
	var camera3d = CameraEntity.main_camera
	var from = camera3d.project_ray_origin(mouse_pos)
	var to = from + camera3d.project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var space_state = camera3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	else:
		return to
	

func spawn_shuriken_at_pos(global_spawn_pos):
	var shuriken =  shuriken_prefab.instantiate()
	
	get_tree().get_root().add_child(shuriken)
	
	shuriken.item_id = ITEM_ID
	shuriken.global_position = global_spawn_pos
	return shuriken
	

func fire_shuriken_from_point_to_point(from_global_pos, to_global_pos):
	var shuriken =  spawn_shuriken_at_pos(from_global_pos)
	shuriken.look_at(to_global_pos)
	shuriken.restart()
	
	return shuriken
	

func fire_vanishing_shuriken_from_point_to_point(from_global_pos, to_global_pos):
	var shuriken = fire_shuriken_from_point_to_point(from_global_pos, to_global_pos)
	shuriken.on_stopped.connect(vanish_shuriken)
	
	return shuriken
	

func fire_shuriken_from_point_in_direction(from_global_pos, from_global_rotation):
	var shuriken = spawn_shuriken_at_pos(from_global_pos)
	shuriken.global_rotation = from_global_rotation
	shuriken.restart()
	
	return shuriken
	

func fire_shuriken_straight():
	var starting_offset = shoot_pos_offset[shoot_pos]
	var starting_pos = (CameraEntity.main_camera.global_basis * starting_offset) + CameraEntity.main_camera.global_position
	var target_point = get_target_point_in_front()
	var shuriken = fire_shuriken_from_point_to_point(starting_pos, target_point)
	
	# Rotate for variety
	var max_rotation = straight_shuriken_z_rotation
	if last_straight_shuriken_rotation >= 0.0:
		max_rotation *= -1
	shuriken.global_rotation_degrees.z = randf_range(0, max_rotation)
	last_straight_shuriken_rotation = shuriken.global_rotation_degrees.z
	
	return shuriken
	

func fire_special_shuriken_straight(type):
	var shuriken = fire_shuriken_straight()
	track_shuriken(type, shuriken)
	return shuriken
	

func fire_bouncing_shuriken():
	var shuriken = fire_special_shuriken_straight("bouncing_shuriken")
	shuriken.bounce_count = 3
	

func change_shoot_pos_if_needed():
	for pos in ShootPos.values():
		var point = shoot_pos_offset[pos]
		var mouse_pos = get_viewport().get_mouse_position()
		var camera3d = CameraEntity.main_camera
		var from = (CameraEntity.main_camera.global_basis * point) + CameraEntity.main_camera.global_position
		var to = from + camera3d.project_ray_normal(mouse_pos) * 1.5
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var space_state = camera3d.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
			
		if not result:
			shoot_pos = pos 
			position = model_screen_pos[shoot_pos]
			return
	
	shoot_pos = ShootPos.BOTTOM_RIGHT
	position = model_screen_pos[shoot_pos]
	

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
	
	change_shoot_pos_if_needed()
	
	# Open ring menu
	if Input.is_action_just_pressed("ring_menu") and not ring_menu.visible:
		#var ring_items: Array = PlayerEntity.get_skills_in_tree("throw")
		var ring_items : Array[String] = ["triple_throw", "octo_throw", "multiplying_shuriken", "body_switch", "bouncing_shuriken", "metal_shower"]
		if ring_items:
			ring_menu.initialize_items(ring_items)
			ring_menu.open()
		
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		fire_shuriken_straight()
	elif Input.is_action_just_pressed("attack_secondary"):
		if current_skill == "triple_throw":
			triple_throw()
		elif current_skill == "octo_throw":
			octo_throw()
		elif current_skill == "multiplying_shuriken":
			fire_special_shuriken_straight("multiplying_shuriken")
		elif current_skill == "body_switch":
			fire_special_shuriken_straight("body_switch")
		elif current_skill == "bouncing_shuriken":
			fire_bouncing_shuriken()
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
	
	for point in generate_points_inside_circle(20, 1.5):
		var ground_pos = initial_pos + Vector3(point.x, 0, point.y)
		var throw_pos = get_floating_throw_pos(ground_pos) + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
		var target_pos = ground_pos + Vector3(0.001, 0.0, 0.0) # Small margin because look_at freaks out when ground_pos is almost identical to position
		delayed_vanishing_shuriken_from_point_to_point(throw_pos, target_pos, randf() * 0.2)
	
	skill_zone.visible = false
	

func delayed_vanishing_shuriken_from_point_to_point(from_global_pos, to_global_pos, delay: float):
	await get_tree().create_timer(delay).timeout
	fire_vanishing_shuriken_from_point_to_point(from_global_pos, to_global_pos)
	

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
		var proj = fire_shuriken_from_point_to_point(initial_pos, initial_pos + point)
		proj.set_temp_speed(proj.speed * 0.25)
		proj.set_temp_gravity_multiplier(4.0)
	

func triple_throw():
	const SPREAD_DISTANCE = 0.025
	const SPREAD_ANGLE = 0.08
	var starting_offset = shoot_pos_offset[shoot_pos]
	
	var starting_pos = (CameraEntity.main_camera.global_basis * starting_offset) + CameraEntity.main_camera.global_position
	var position_offset2 = starting_pos + Vector3(-SPREAD_DISTANCE, 0, 0)
	var position_offset3 = starting_pos + Vector3(SPREAD_DISTANCE, 0, 0)
	
	var rotation1 = CameraEntity.main_camera.global_rotation + Vector3(0, 0, deg_to_rad(90))
	var rotation2 = CameraEntity.main_camera.global_rotation + Vector3(0, SPREAD_ANGLE, deg_to_rad(90))
	var rotation3 = CameraEntity.main_camera.global_rotation + Vector3(0, -SPREAD_ANGLE, deg_to_rad(90))
	
	fire_shuriken_from_point_in_direction(starting_pos, rotation1)
	fire_shuriken_from_point_in_direction(position_offset2, rotation2)
	fire_shuriken_from_point_in_direction(position_offset3, rotation3)
	

func octo_throw():
	var global_positions = []
	var global_rotations = []
	var count = 8
	var part = 360 / count
	var camera_y = CameraEntity.main_camera.global_rotation_degrees.y
	
	for i in range(count):
		var degrees = part * i
		var position_offset = Vector3(0, -0.3, 0).rotated(Vector3(0, 1, 0), deg_to_rad(degrees + camera_y))
		var global_pos = (CameraEntity.main_camera.global_basis * position_offset) + CameraEntity.main_camera.global_position
		var global_rot = Vector3(0, deg_to_rad(degrees + camera_y), deg_to_rad(90))
		
		global_positions.append(global_pos)
		global_rotations.append(global_rot)
	
	for i in global_positions.size():
		fire_shuriken_from_point_in_direction(global_positions[i], global_rotations[i])
	

func skill_selected(skill_name):
	current_skill = skill_name
	

func context_changed(old_context, new_context):
	# In case context changed, we cancel the ring menu without activating a skill
	if InputContextManager.is_ring_menu_context() and new_context != old_context:
		if ring_menu.visible == true:
			ring_menu.close_no_signal()
	

func vanish_shuriken(shuriken):
	await get_tree().create_timer(1.0).timeout
	if smoke_vanish_vfx:
		for i in range(32):
			smoke_vanish_vfx.emit_particle(shuriken.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	shuriken.queue_free()
	
