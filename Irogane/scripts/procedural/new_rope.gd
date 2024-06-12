@tool
extends MeshInstance3D

var start_target = null
var end_target = null

var start_position = Vector3.ZERO
var end_position = Vector3.ZERO

var is_first_time = true

@export var point_count = 10
var points = []
var prev_points = []

var rope_length = 0
var point_spacing = 0

@export var iterations = 10

var gravity_default = 10.0

var normal_array = []
var tangent_array = []

var index_array = []
var vertex_array = []

@export var resolution = 10
@export var rope_width = 1.0

func _ready():
	if mesh == null:
		mesh = ImmediateMesh.new()
	
	set_start_target($start_target)
	set_end_target($end_target)
	

func set_start_target(start : Node3D):
	start_target = start
	

func set_end_target(end : Node3D):
	end_target = end
	is_first_time = true
	

func set_start_position(start : Vector3):
	start_position = to_local(start)
	

func set_end_position(end : Vector3):
	end_position = to_local(end)
	is_first_time = true
	

func _process(delta):
	if end_target == null or start_target == null:
		return
	
	if is_first_time:
		prepare_points()
		is_first_time = false
	
	update_points(delta)
	generate_mesh()
	

func prepare_points():
	points.clear()
	prev_points.clear()
	
	for i in range(point_count):
		var t = i / (point_count - 1)
		var p = lerp(to_local(start_target.global_position), to_local(end_target.global_position), t)
		points.append(p)
		prev_points.append(p)
	
	update_point_spacing()
	

func update_point_spacing():
	rope_length = (to_local(end_target.global_position) - to_local(start_target.global_position)).length()
	point_spacing = rope_length / (point_count - 1)
	

func update_points(delta):
	points[0] = to_local(start_target.global_position)
	points[point_count - 1] = to_local(end_target.global_position)
	
	update_point_spacing()
	
	for i in range(1, point_count - 1):
		var curr = points[i]
		points[i] = points[i] + (points[i] - prev_points[i]) + (Vector3.DOWN * gravity_default * delta * delta)
		prev_points[i] = curr
	
	for i in range(iterations):
		constraint_connections()
	

func constraint_connections():
	for i in range(point_count - 1):
		var center = (points[i+1] + points[i]) / 2.0 # HMM
		var offset = points[i+1] - points[i]
		var length = offset.length()
		var dir = offset.normalized()
		
		var d = length - point_spacing
		
		# Not first, move towards next
		if i != 0:
			points[i] += dir * d * 0.5
		
		# Not last, move towards prev
		if i + 1 != point_count - 1:
			points[i+1] -= dir * d * 0.5
	

func calculate_normals():
	normal_array.clear()
	tangent_array.clear()
	var helper
	
	for i in range(point_count):
		var tangent = Vector3.ZERO
		var normal = Vector3.ZERO
		var temp_helper_vector = Vector3.ZERO
		
		if i == 0:
			tangent = (points[i + 1] - points[i]).normalized()
		elif i == point_count - 1:
			tangent = (points[i] - points[i - 1]).normalized()
		else:
			tangent = (points[i + 1] - points[i]).normalized() + (points[i] - points[i - 1]).normalized()
		
		if i == 0:
			temp_helper_vector = -Vector3.FORWARD if tangent.dot(Vector3.UP) > 0.5 else Vector3.UP
			normal = temp_helper_vector.cross(tangent).normalized()
		else:
			var tangent_prev = tangent_array[i - 1]
			var normal_prev = normal_array[i - 1]
			var bitangent = tangent_prev.cross(tangent)
			
			if bitangent.length() == 0:
				normal = normal_prev
			else:
				var bitangent_dir = bitangent.normalized()
				var theta = acos(tangent_prev.dot(tangent))
				
				var rotate_matrix = Basis(bitangent_dir, theta)
				normal = rotate_matrix * normal_prev
		
		tangent_array.append(tangent)
		normal_array.append(normal)
	

func generate_mesh():
	vertex_array.clear()
	calculate_normals()
	index_array.clear()
	
	for p in range(point_count):
		var center = points[p]
		var forward = tangent_array[p]
		var norm = normal_array[p]
		var bitangent = norm.cross(forward).normalized()
		
		for c in range(resolution):
			var angle = (float(c) / resolution) * 2.0 * PI
			
			var xVal = sin(angle) * rope_width
			var yVal = cos(angle) * rope_width
			
			var point = (norm * xVal) + (bitangent * yVal) + center
			vertex_array.append(point)
			
			if p < point_count - 1:
				var start_index = resolution * p
				#INT values
				index_array.append(start_index + c);
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + (c + 1) % resolution);
				
				index_array.append(start_index + (c + 1) % resolution);
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + (c + 1) % resolution + resolution);
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(index_array.size() / 3):
		var p1 = vertex_array[index_array[3 * i]]
		var p2 = vertex_array[index_array[3 * i + 1]]
		var p3 = vertex_array[index_array[3 * i + 2]]
		
		var tangent = Plane(p1, p2, p3)
		var normal = tangent.normal
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p1)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p2)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p3)
	
	mesh.surface_end()
	
