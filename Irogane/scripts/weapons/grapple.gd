extends Node3D

@onready var rope = $Rope
@onready var ray_cast = $"../../grappling_ray_cast"
@onready var start_target = $start_target
@onready var end_target = $end_target
@onready var state_machine = $"../../../.."

var is_grappling = false
var prev_raycast_collider = null
var grappling_point = null
var grapple_point_mesh = null

var start_distance = 0.0

func _process(_delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_secondary"):
		Engine.time_scale = 0.25
	elif Input.is_action_just_released("attack_secondary"):
		Engine.time_scale = 1.0
	
	# TODO: Decide if we want to stop on release
	#if Input.is_action_just_released("attack_primary"):
		#state_machine.end_roped()
		#state_machine.transition("air")
	
	if ray_cast.is_colliding():
		var raycast_collider = ray_cast.get_collider()
		if raycast_collider != prev_raycast_collider:
			highlight_mesh(prev_raycast_collider, false)
			highlight_mesh(raycast_collider, true)
			prev_raycast_collider = raycast_collider
		
		if Input.is_action_just_pressed("attack_primary"):
			if raycast_collider != grappling_point:
				var attachment_point = raycast_collider.global_position + Vector3.DOWN * 0.35
				spawn_grapple_mesh(attachment_point, raycast_collider)
				
				end_target.global_position = attachment_point
				end_target.top_level = true
				rope.set_end_target(end_target)
				
				start_target.top_level = false
				rope.set_start_target(start_target)
				
				rope.visible = true
				is_grappling = true
				grappling_point = raycast_collider
				highlight_mesh(grappling_point, false)
				start_distance = (start_target.global_position - end_target.global_position).length()
				if state_machine:
					state_machine.start_roped(self)
	else:
		highlight_mesh(prev_raycast_collider, false)
		prev_raycast_collider = null
	
	# Adjust distance as long as we are not in these states
	if is_grappling and state_machine.current_state.name.to_lower() not in ["air", "roped"]:
		start_distance = (self.global_position - end_target.global_position).length()
	

func spawn_grapple_mesh(mesh_position : Vector3, parent : Node3D):
	var mesh = MeshInstance3D.new()
	mesh.mesh = TorusMesh.new()
	mesh.mesh.inner_radius = 0.2
	mesh.mesh.outer_radius = 0.1
	mesh.mesh.rings = 8
	mesh.mesh.ring_segments = 6
	
	parent.add_child(mesh)
	mesh.global_position = mesh_position
	mesh.rotation_degrees.z = 90
	
	clear_grapple_mesh()
	grapple_point_mesh = mesh
	

func clear_grapple_mesh():
	if grapple_point_mesh == null:
		return
	
	grapple_point_mesh.queue_free()
	

func end_rope():
	rope.visible = false
	is_grappling = false
	grappling_point = null
	clear_grapple_mesh()
	

func highlight_mesh(object, state):
	if object != null:
		var mesh = object.get_node("mesh")
		if mesh != null and mesh is MeshInstance3D:
			mesh.get_active_material(0).emission_enabled = state
	
