@tool
extends Node3D

@export var update = false:
	set(value):
		update = value
		if Engine.is_editor_hint():
			update_tree()

@export var tree_height = 10.0
@export var trunk_width = 10.0
@export var top_width = 10.0

@export var branch_start_height = 3
@export var branch_levels = 4
@export var branch_amount = 3
@export var branch_length = 1.0
@export var branch_length_falloff : CurveTexture
@export var branch_width = .2
@export var branch_tip = .1
@export var branch_angle = -20.0
@export var branch_segments = 1
@export var branch_segment_angle = 10.0
@export var branch_angle_falloff : CurveTexture

@export var mesh_radial_segments = 4
@export var mesh_rings = 1

func _ready():
	update_tree()
	

func update_tree():
	# Clear tree
	for child in get_children():
		child.queue_free()
	
	# Create trunk
	var trunk = MeshInstance3D.new()
	trunk.mesh = CylinderMesh.new()
	
	trunk.global_position.y = tree_height * 0.5
	trunk.mesh.radial_segments = mesh_radial_segments
	trunk.mesh.rings = mesh_rings
	trunk.mesh.height = tree_height
	trunk.mesh.bottom_radius = trunk_width
	trunk.mesh.top_radius = top_width
	
	add_child(trunk)
	create_collider(trunk)
	
	# Create branches
	var branch_area = tree_height - branch_start_height
	var branch_spacing = branch_area / branch_levels
	var angle_space = 360.0 / branch_amount
	
	for i in range(branch_levels):
		var height = branch_start_height + i * branch_spacing
		var length = branch_length * branch_length_falloff.curve.sample(float(i) / branch_levels)
		var branch_segment_length = length / branch_segments
		for j in range(branch_amount):
			var prev_branch = null
			for k in range(branch_segments):
				var t = float(k) / branch_segments	# Percentage used for lerping 
													# and sampling curves
				# Create branch mesh
				var mesh = MeshInstance3D.new()
				mesh.mesh = CylinderMesh.new()
				mesh.mesh.radial_segments = mesh_radial_segments
				mesh.mesh.rings = mesh_rings
				mesh.mesh.height = branch_segment_length
				mesh.mesh.bottom_radius = lerp(branch_width, branch_tip, t)
				mesh.mesh.top_radius = lerp(branch_width, branch_tip, float(k + 1) / branch_segments)
				
				# Add as child of previous branch or tree
				if prev_branch:
					prev_branch.add_child(mesh)
					var angle = branch_segment_angle * branch_angle_falloff.curve.sample(t)
					mesh.set_rotation_degrees(Vector3(angle,0,0))
					mesh.position += mesh.basis.y * branch_segment_length
				else:
					add_child(mesh)
					mesh.position.y = height
					# Add offset for every other level
					var offset_angle = angle_space * 0.5 if i % 2 == 0 else 0
					mesh.set_rotation_degrees(Vector3(90+branch_angle, angle_space * j + offset_angle, 0))
					mesh.position += mesh.basis.y * branch_segment_length * 0.5
				
				create_collider(mesh, 3)
				
				prev_branch = mesh

func create_collider(mesh, dimensions_multiplier = 1):
	var body = StaticBody3D.new()
	var collider = CollisionShape3D.new()
	collider.shape = BoxShape3D.new()
	collider.shape.size.y = mesh.mesh.height
	var radius = (mesh.mesh.top_radius + mesh.mesh.bottom_radius) / 2
	collider.shape.size.x = radius * dimensions_multiplier
	collider.shape.size.z = radius * dimensions_multiplier
	body.add_child(collider)
	mesh.add_child(body)
	
