extends MeshInstance3D

@export var target_node: Node3D
@export var noise: FastNoiseLite
@export var noise_intensity: Curve
@export var material: Material

const RESOLUTION = 4 # Points per 1 meter
const MESH_WIDTH = 0.1 # How wide is the tube like mesh

var generated_path: PackedVector3Array

var last_mesh_origin_vertices = null

var debug = false

#func _ready():
	#start_smoke_debug()
	#

func start_smoke_debug():
	start_smoke(target_node.global_position)
	

func start_smoke(target_position: Vector3):
	generated_path = generate_path(global_position, target_position)
	
	var _mesh = generate_mesh(generated_path)
	_mesh.surface_set_material(0, material) # Optional material
	#material.set_shader_parameter("progress", 0.0)  
	mesh = _mesh
	
	reparent(get_tree().root) # Needs to be non local for moving smoke origin
	

func _process(delta):
	if debug and generated_path != null:
		draw_path(generated_path)
	

func update_smoke_origin(from: Vector3, to: Vector3):
	print(from, " : ", to)
	from = to_local(from)
	to = to_local(to)
	var new_path = generate_path(from, to)
	var _mesh = generate_mesh(new_path, false)
	var _material = material.duplicate() # New section must have 1.0 progress
	_material.set_shader_parameter("progress", 1.0)  
	_mesh.surface_set_material(0, _material)
	
	var new_mesh = MeshInstance3D.new()
	add_child(new_mesh)
	new_mesh.mesh = _mesh
	

func generate_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var direction = (to - from).normalized()
	var distance = from.distance_to(to)
	var points = distance * RESOLUTION
	
	var path: PackedVector3Array
	for i in range(points):
		var t = i / float(points)
		var point = lerp(from, to, t)
		
		var offset_x = noise.get_noise_2d(i, 0)
		var offset_y = noise.get_noise_2d(i, 1)
		
		var local_x = Vector3.UP.cross(direction).normalized()
		var local_y = -local_x.cross(direction).normalized()
		
		var intensity = noise_intensity.sample(t)
		point += local_x * offset_x * intensity
		point += local_y * offset_y * intensity
		
		path.append(point)
	
	return path
	

func draw_path(points: PackedVector3Array):
	var last_vertice = null
	
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var forward = (b - a).normalized()
		var up = Vector3.UP
		var right = up.cross(forward).normalized() * MESH_WIDTH
		
		var vertice_a = generate_vertice(a, right, forward) if last_vertice == null else last_vertice
		var vertice_b = generate_vertice(b, right, forward)
		last_vertice = vertice_b
		
		DebugCanvas.debug_point(a)
		DebugCanvas.debug_point(to_global(vertice_a[0]), Color.PURPLE, 2.0)
		DebugCanvas.debug_point(to_global(vertice_a[1]), Color.PURPLE, 2.0)
		DebugCanvas.debug_point(to_global(vertice_a[2]), Color.PURPLE, 2.0)
	

func generate_mesh(points: PackedVector3Array, first_mesh = true):
	var prev_vertices = null
	var _mesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var forward = (b - a).normalized()
		var up = Vector3.UP
		var right = up.cross(forward).normalized() * MESH_WIDTH
		
		var vertice_a = generate_vertice(a, right, forward) if prev_vertices == null else prev_vertices
		var vertice_b = null
		
		if i == points.size() - 2 and not first_mesh and last_mesh_origin_vertices != null:
			vertice_b = last_mesh_origin_vertices
		else:
			vertice_b = generate_vertice(b, right, forward)
		
		# Save vertices for next iteration
		prev_vertices = vertice_b
		
		# Save the first vertices
		if i == 0:
			last_mesh_origin_vertices = vertice_a
		
		var uv_y_1 = float(i) / (points.size() - 1)
		var uv_y_2 = float(i + 1) / (points.size() - 1)
		
		var uv1 = Vector2(0.0, uv_y_1)
		var uv2 = Vector2(1.0/3, uv_y_1)
		var uv3 = Vector2(0.0, uv_y_2)
		var uv4 = Vector2(1.0/3, uv_y_2)
		add_quad(st, vertice_a[0], vertice_a[1], vertice_b[0], vertice_b[1], uv1, uv2, uv3, uv4)
		
		uv1 = Vector2(1.0/3, uv_y_1)
		uv2 = Vector2(2.0/3, uv_y_1)
		uv3 = Vector2(1.0/3, uv_y_2)
		uv4 = Vector2(2.0/3, uv_y_2)
		add_quad(st, vertice_a[1], vertice_a[2], vertice_b[1], vertice_b[2], uv1, uv2, uv3, uv4)
		
		uv1 = Vector2(2.0/3, uv_y_1)
		uv2 = Vector2(1.0, uv_y_1)
		uv3 = Vector2(2.0/3, uv_y_2)
		uv4 = Vector2(1.0, uv_y_2)
		add_quad(st, vertice_a[2], vertice_a[0], vertice_b[2], vertice_b[0], uv1, uv2, uv3, uv4)
		
	st.generate_normals()
	st.index()
	st.commit(_mesh)
	return _mesh
	

func generate_vertice(point: Vector3, right: Vector3, forward: Vector3) -> PackedVector3Array:
	var p1 = point + right.rotated(forward, TAU / 3)
	var p2 = point + right.rotated(forward, 2 * TAU / 3)
	var p3 = point + right
	
	return PackedVector3Array([to_local(p1), to_local(p2), to_local(p3)])
	

func add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, uv1: Vector2, uv2: Vector2, uv3: Vector2, uv4: Vector2):
	st.set_uv(uv1)
	st.add_vertex(a)
	
	st.set_uv(uv3)
	st.add_vertex(c)
	
	st.set_uv(uv2)
	st.add_vertex(b)
	
	st.set_uv(uv2)
	st.add_vertex(b)
	
	st.set_uv(uv3)
	st.add_vertex(c)
	
	st.set_uv(uv4)
	st.add_vertex(d)
	

func add_mesh_section(a: Vector3, b: Vector3):
	var forward = (b - a).normalized()
	var up = Vector3.UP
	var right = up.cross(forward).normalized() * MESH_WIDTH
	
	var vertice_a = generate_vertice(a, right, forward)
	var vertice_b = generate_vertice(b, right, forward)
	
