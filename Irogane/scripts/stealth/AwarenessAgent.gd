extends Area3D
class_name AwarenessAgent

@onready var sight_cast = $sight_cast

@onready var direct_vision_cone = $vision_cone
@onready var direct_cone_mesh = $vision_cone/cone_mesh
@onready var direct_sphere_mesh = $vision_cone/sphere_mesh

@onready var peripheral_vision_cone = $peripheral_vision_cone
@onready var peripheral_cone_mesh = $peripheral_vision_cone/cone_mesh
@onready var peripheral_sphere_mesh = $peripheral_vision_cone/sphere_mesh

@export var direct_sight_range = 20.0
@export var direct_sight_angle = Vector2(30, 20)

@export var peripheral_sight_range = 5.0
@export var peripheral_sight_angle = Vector2(160, 20)

@export_flags_3d_physics var sight_obstacle_mask = 17 # Bit mask for layers, 17 is 1 - Default, 5 - Stealth

@export var direct_detection_rate = 10.0
@export var perepherial_detection_rate = 1.0
@export var undetection_rate = 0.5

@export var alert_mode = false
@export var alert_detection_rate = 10.0

static var debug = false

var almost_visible_agents  = {} # Dictionary of agent: 0.0-1.0 (vision percent)
var visible_agents  = []

signal on_sound_heard(sound_position)
signal on_enemy_seen(enemy)
signal on_enemy_lost(enemy)

func _ready():
	DebugCommandsManager.add_command(
		"display_vision_cone",
		set_debug,
		 [{
				"arg_name" : "1/0",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : "1: True, 0: False"
			}],
		"Displays/Hides vision cone on AwarenessAgent(s)"
		)
	

func set_alert_mode(new_state):
	alert_mode = new_state
	

func get_detection_rate(is_direct):
	var detection_rate = direct_detection_rate if is_direct else perepherial_detection_rate
	return alert_detection_rate if alert_mode else detection_rate
	

func get_visible(delta):
	# Get agents in direct sight range
	var peripheral_stealth_agents = []
	sight_cast.shape.radius = peripheral_sight_range
	sight_cast.force_shapecast_update()
	for i in range(sight_cast.get_collision_count()):
		var col = sight_cast.get_collider(i)
		if col is StealthAgent:
			peripheral_stealth_agents.append(col)
	
	# Get agents in peripheral sight range
	var direct_stealth_agents = []
	sight_cast.shape.radius = direct_sight_range
	sight_cast.force_shapecast_update()
	for i in range(sight_cast.get_collision_count()):
		var col = sight_cast.get_collider(i)
		if col is StealthAgent:
			direct_stealth_agents.append(col)
		
	# Filter according to angles and line of sight
	var agents_in_sight = {}
	
	for agent in peripheral_stealth_agents:
		if not is_within_angle(agent, peripheral_sight_angle.x, peripheral_sight_angle.y):
			continue
		if not is_line_of_sight(agent):
			continue
		agents_in_sight[agent] = false
	
	for agent in direct_stealth_agents:
		if not is_within_angle(agent, direct_sight_angle.x, direct_sight_angle.y):
			continue
		if not is_line_of_sight(agent):
			continue
		agents_in_sight[agent] = true
	
	# Remove from visible agents that are not in sight
	for agent in visible_agents:
		if not agents_in_sight.has(agent):
			almost_visible_agents[agent] = 1
			visible_agents.erase(agent)
			on_enemy_lost.emit(agent)
	
	# Increment vision to almost visible
	for agent in almost_visible_agents.keys():
		if agents_in_sight.has(agent):
			var detection_rate = get_detection_rate(agents_in_sight[agent])
			almost_visible_agents[agent] += detection_rate * agent.detection_multiplier * delta
			agents_in_sight.erase(agent)
		else:
			almost_visible_agents[agent] -= undetection_rate * delta
		
		# Update stealth agent how visible it is
		agent.update_watcher(self, almost_visible_agents[agent])
		
		# Move to visible
		if almost_visible_agents[agent] >= 1:
			almost_visible_agents.erase(agent)
			visible_agents.append(agent)
			on_enemy_seen.emit(agent)
		# Remove from almost_visible
		elif almost_visible_agents[agent] <= 0:
			almost_visible_agents.erase(agent)
			agent.remove_watcher(self)
			
	
	# Agents that existed in almost_visible_agents were removed
	# All agents left need to be added
	for agent in agents_in_sight:
		if not visible_agents.has(agent):
			var detection_rate = get_detection_rate(agents_in_sight[agent])
			almost_visible_agents[agent] = detection_rate * agent.detection_multiplier * delta
	

func is_within_angle(agent, horizontal_angle, vertical_angle):
	# Position in our local space
	var agent_local_pos = to_local(agent.global_position) 
	
	# Horizontal range
	var h_agent_pos = Vector2(agent_local_pos.z, agent_local_pos.x) # Z axis first to get angle from it
	var h_angle = get_angle(Vector2.ZERO, h_agent_pos) # Calculate against our origin
	
	# Skip agent if outside of horizontal range
	if h_angle > horizontal_angle * 0.5 or h_angle < -horizontal_angle * 0.5:
		return false
	
	# Vertical range
	var v_agent_pos = Vector2(agent_local_pos.z, agent_local_pos.y) # Z axis first to get angle from it
	var v_angle = get_angle(Vector2.ZERO, v_agent_pos) # Calculate against our origin
	
	# Skip agent if outside of vertical range
	if v_angle > vertical_angle * 0.5 or v_angle < -vertical_angle * 0.5:
		return false
	
	return true
	

func _process(delta):
	get_visible(delta)
	
	if debug:
		if direct_vision_cone != null:
			direct_vision_cone.visible = true
			update_cone_mesh(direct_sight_range, direct_sight_angle, direct_cone_mesh, direct_sphere_mesh)
		
		if peripheral_vision_cone != null:
			peripheral_vision_cone.visible = true
			update_cone_mesh(peripheral_sight_range, peripheral_sight_angle, peripheral_cone_mesh, peripheral_sphere_mesh)
	else:
		if direct_vision_cone != null:
			direct_vision_cone.visible =  false
		
		if peripheral_vision_cone != null:
			peripheral_vision_cone.visible = false
	

func get_angle(point1 : Vector2, point2 : Vector2):
	return atan2(point2.y - point1.y, point2.x - point1.x) * 180 / PI
	

func is_line_of_sight(agent):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position, 			# Our position
		agent.global_position,		# Stealth agent's position
		sight_obstacle_mask,		# Collision mask for obstacles
		[self]) 					# Exclude self
	
	query.collide_with_areas = true	# Collide with areas like stealth areas
	
	var result = space_state.intersect_ray(query)
	
	if result.has("collider"):
		# Either the collider is the stealth agent
		# or the collider is the stealth agent's owner - like CharacterBody3D
		return result["collider"] in [agent, agent.owner]
	else:
		return false
	

func update_cone_mesh(sight_range, sight_angle, cone_mesh, sphere_mesh):
	# Calculate the cone base
	# ___a_________ 
	# \     |     /   # a - Half the cone base
	#  \    |    /
	#   \   |b  /     # b - sight_range
	#    \  |  /
	#     \o| /       # o - Half our sight_angle.x
	#      \|/
	#       V
	
	cone_mesh.height = sight_range
	var cone_base = sight_range * tan(deg_to_rad(sight_angle.x * 0.5))
	cone_mesh.radius = cone_base
	cone_mesh.position.z = cone_mesh.height * 0.5
	cone_mesh.scale.z = sight_angle.y / sight_angle.x # Scale mesh vertically to match y angle
	
	# Sphere mesh is used to intersect the cone and siplay a spherical base
	sphere_mesh.radius = sight_range
	

func hear_sound(sound_position):
	on_sound_heard.emit(sound_position)
	pass
	

func set_debug(args: Array):
	debug = bool(args[0])
	
