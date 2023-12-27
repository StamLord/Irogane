extends Node3D

@onready var top_viewport = $Control/SubViewportContainer/top_viewport
@onready var bot_viewport = $Control/SubViewportContainer2/bot_viewport
@onready var front_viewport = $Control/SubViewportContainer3/front_viewport

@onready var top_camera = $Control/SubViewportContainer/top_viewport/top_camera
@onready var bot_camera = $Control/SubViewportContainer2/bot_viewport/bot_camera
@onready var front_camera = $Control/SubViewportContainer3/front_viewport/front_camera

@onready var light_stone = $Control/light_stone

@onready var player = $"../head/main_camera"
@onready var light_cast = $light_cast

@onready var light_beads_material = preload("res://assets/models/light_beads_3d.tres")

var detection_rate = .1
var last_detection = 0

func _process(delta):
	raycast_light_detection()
	

func get_light_level(viewport):
	var img = viewport.get_texture().get_image()
	img.flip_y()
	
	var highest_light = 0
	for y in img.get_height():
		for x in img.get_width():
			var pixel = img.get_pixel(x, y)
			var light = 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b
			if light > highest_light:
				highest_light = light
	
	return highest_light
	

func viewport_light_detection():
	if Time.get_ticks_msec() - last_detection < detection_rate * 1000:
		return
	
	# Move cameras with player
	var new_pos = player.global_transform.origin
	top_camera.global_transform.origin = new_pos
	bot_camera.global_transform.origin = new_pos
	
	# Get averages
	var top_light_average = get_light_level(top_viewport)
	var bottom_light_average = get_light_level(bot_viewport)
	
	var max_level = max(top_light_average, bottom_light_average)
	
	light_stone.modulate = Color(max_level, max_level, max_level, 1)
	last_detection = Time.get_ticks_msec()
	

func raycast_light_detection():
	# Get all light sources in range
	#light_cast.shape.radius = sight_range
	var light_sources = get_tree().get_nodes_in_group("light_source")
	
	# Filter
	var total_light = 0
	for light in light_sources:
		var light_origin = light.global_position
		
		# In case of direciton light, light origin is different
		if light is DirectionalLight3D:
			light_origin = global_position - light.global_transform.basis * Vector3.FORWARD * 1000
		
		var distance = light_origin.distance_to(global_position)
		
		# OmniLight too far
		if light is OmniLight3D and light.omni_range < distance:
			continue
			
		# Blocked by objects
		var from = light_origin
		var to = global_position
		
		DebugCanvas.debug_point(from)
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.hit_from_inside = false
		query.hit_back_faces = false

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		if result.has("collider") and result["collider"] != owner:
			continue
		
		if light is OmniLight3D:
			total_light += lerp(light.light_energy, 0.0, distance / light.omni_range)
		else:
			total_light += light.light_energy
	
	var color_clamp = clamp(total_light, 0.05, 1)
	light_stone.modulate = Color(color_clamp, color_clamp, color_clamp, 1)
	light_beads_material.albedo_color = Color(total_light, total_light, total_light, 1)
	
	print(total_light)
	
