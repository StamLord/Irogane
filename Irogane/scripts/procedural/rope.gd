extends Node3D
class_name Rope

@onready var head = $head
@onready var tail = $tail

#@export var length: float = 10
@export var segments_per_unit: int = 1
@export var width: float = 0.25
var mass: float = 1.0
@export var damp: float = 1
@export var angular_damp: float = 1

@export var static_head: bool = true
@export var static_tail: bool = false
@export var inner_collisions: bool = false
@export var joint_meshes: bool = true

@export_flags_3d_physics var layer
@export_flags_3d_physics var mask

var rope : Array
var segment_length
func _ready():
	create_rope()

func create_rope():
	
	if head == null or tail == null:
		return
	
	var length = (tail.position - head.position).length()
	var direction = (tail.position - head.position).normalized()
	var segments = int(ceil(length * segments_per_unit))
	segment_length = length / segments
	
	for i in range(segments):
		
		# Setup rigid
		var rigid = RigidBody3D.new()
		rigid.name = "rope_segment_" + str(i)
		rigid.mass = mass
		rigid.linear_damp = damp
		rigid.angular_damp = angular_damp
		rigid.axis_lock_angular_y = true
		rigid.collision_layer = layer
		rigid.collision_mask = mask
		
		# Freeze first and last segments as necessary
		if i == 0 and static_head or i == segments - 1 and static_tail:
			rigid.freeze = true
		
		# Setup collider
		var collider = CollisionShape3D.new()
		collider.shape = CylinderShape3D.new()
		collider.shape.height = segment_length
		collider.shape.radius = width
		
		# Setup mesh
		var mesh = MeshInstance3D.new()
		mesh.mesh = CylinderMesh.new()
		mesh.mesh.height = segment_length
		mesh.mesh.top_radius = width
		mesh.mesh.bottom_radius = width
		
		# Add to family
		add_child(rigid)
		rigid.add_child(collider)
		rigid.add_child(mesh)
		
		# Sphere meshes to cover joints
		if joint_meshes:
			var mesh_2 = MeshInstance3D.new()
			mesh_2.mesh = SphereMesh.new()
			mesh_2.mesh.radius = width * 1.01
			mesh_2.mesh.height = width * 2.02
			rigid.add_child(mesh_2)
		
		# Position
		rigid.position = head.position + direction * segment_length * i
		
		# Move children down so our anchor is at base of segment
		collider.position = direction * segment_length * 0.5
		mesh.position = collider.position
		
		# Link segment to previous
		if i != 0:
			var joint := PinJoint3D.new()
			joint.node_a = rigid.get_path()
			joint.node_b = rope[i-1].get_path()
			joint.exclude_nodes_from_collision = !inner_collisions
			joint.position = rigid.position
			add_child(joint)
		
		# Add to rope array
		rope.push_back(rigid)

func get_closest_segment_index(position):
	var closest_segment = -1
	var closest_distance = INF
	for i in range(rope.size()):
		var distance = rope[i].global_position.distance_to(position)
		if  distance < closest_distance:
			closest_distance = distance
			closest_segment = i
			
	return closest_segment

func get_direction_to_segment(position, index):
	# Flatten position to rope axis
	position.x = rope[index].global_position.x
	position.z = rope[index].global_position.z
	return (rope[index].global_position - position).normalized()

func is_valid_segment_index(index):
	return index > 0 and index < rope.size()

func get_position_on_segment(index, percentage):
	percentage = clampf(percentage, 0.0, 1.0)
	var length = segment_length * percentage
	return rope[index].global_position + Vector3.DOWN * rope[index].basis * length
