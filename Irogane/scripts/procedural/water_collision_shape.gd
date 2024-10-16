@tool
extends CollisionShape3D

const WATER_MAT = preload("res://assets/models/env/river_bed/water.tres")
const UNDERWATER_MAT = preload("res://assets/shaders/underwater_material.tres")

var old_size = Vector3.ZERO

func _process(delta):
	if not Engine.is_editor_hint():
		return
	
	if shape is BoxShape3D:
		if shape.size != old_size:
			update_size(shape.size)
			old_size = shape.size
	

func update_size(size: Vector3):
	var surface_mesh = get_node("../surface")
	if surface_mesh != null:
		surface_mesh.mesh = QuadMesh.new()
		surface_mesh.mesh.size = Vector2(size.x, size.z)
		surface_mesh.mesh.material = WATER_MAT
		surface_mesh.position = position
		surface_mesh.position.y += size.y * 0.5
	
	var under_water_mesh = get_node("../under_water")
	if under_water_mesh != null:
		under_water_mesh.mesh = BoxMesh.new()
		under_water_mesh.mesh.size = size * 0.9999 # Leave a gap to prevent z fighting on edges
		under_water_mesh.mesh.material = UNDERWATER_MAT
		under_water_mesh.position = position
	
