extends Area3D
class_name AwarenessAgent

@onready var sight_cast = $sight_cast

@onready var vision_cone = $vision_cone
@onready var cone_mesh = $vision_cone/cone_mesh
@onready var sphere_mesh = $vision_cone/sphere_mesh

@export var sight_angle = Vector2(90, 90)
@export var sight_range = 10.0
@export_flags_3d_physics var sight_obstacle_mask = 17 # Bit mask for layers, 17 is 1 - Default, 5 - Stealth

@export var detection_rate = 1.0
@export var undetection_rate = 0.5

@export var alert_mode = false
@export var alert_detection_rate = 10

static var debug = false

var almost_visible_agents  = {} # Dictionary of agent: 0.0-1.0 (vision percent)
var visible_agents  = []

signal on_sound_heard(sound_position)
signal on_enemy_seen(enemy)
signal on_enemy_lost(enemy)

func _ready():
	debug = true
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
	

func get_detection_rate():
	return alert_detection_rate if alert_mode else detection_rate
	

func get_visible(delta):
	# Get all in range
	sight_cast.shape.radius = sight_range
	sight_cast.force_shapecast_update()
	
	var stealth_agents = []
	for i in range(sight_cast.get_collision_count()):
		var col = sight_cast.get_collider(i)
		if col is StealthAgent:
			stealth_agents.append(col)
		
	# Filter according to angle and line of sight
	var agents_in_sight = []
	
	for agent in stealth_agents:
		# Position in our local space
		var agent_local_pos = to_local(agent.global_position) 
		
		# Horizontal range
		var h_agent_pos = Vector2(agent_local_pos.z, agent_local_pos.x) # Z axis first to get angle from it
		var h_angle = get_angle(Vector2.ZERO, h_agent_pos) # Calculate against our origin
		
		# Skip agent if outside of horizontal range
		if h_angle > sight_angle.x * 0.5 or h_angle < -sight_angle.x * 0.5:
			continue
		
		# Vertical range
		var v_agent_pos = Vector2(agent_local_pos.z, agent_local_pos.y) # Z axis first to get angle from it
		var v_angle = get_angle(Vector2.ZERO, v_agent_pos) # Calculate against our origin
		
		# Skip agent if outside of vertical range
		if v_angle > sight_angle.y * 0.5 or v_angle < -sight_angle.y * 0.5:
			continue
		
		# Check if in line of sight
		if not is_line_of_sight(agent):
			continue
		
		agents_in_sight.append(agent)
	
	# Remove from visible agents that are not in sight
	for agent in visible_agents:
		if not agents_in_sight.has(agent):
			almost_visible_agents[agent] = 1
			visible_agents.erase(agent)
			on_enemy_lost.emit(agent)
	
	# Increment vision to almost visible
	for agent in almost_visible_agents.keys():
		if agents_in_sight.has(agent):
			almost_visible_agents[agent] += get_detection_rate() * agent.detection_multiplier * delta
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
			almost_visible_agents[agent] = get_detection_rate() * agent.detection_multiplier * delta
	

func _process(delta):
	get_visible(delta)
	
	if debug:
		vision_cone.visible = true
		update_cone_mesh()
	else:
		vision_cone.visible =  false
	

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
	

func update_cone_mesh():
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
	print("Heard sound at: " + str(sound_position))
	on_sound_heard.emit(sound_position)
	pass
	

func set_debug(args: Array):
	debug = bool(args[0])
	
