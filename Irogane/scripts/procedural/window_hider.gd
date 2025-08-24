@tool
extends Node3D

const HIDE_RANGE = 3
const WINDOW_DIMENSIONS = Vector2(1.5, 2)

var last_position: Vector3 = Vector3.ZERO

func _ready():
	if Engine.is_editor_hint():
		last_position = global_position
	
	check_collisions()
	
	if not Engine.is_editor_hint():
		set_script(null)
	

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	if global_position != last_position:
		check_collisions()
		last_position = global_position
	

func check_collisions():
	var space_state = get_world_3d().direct_space_state
	
	# Raycast in a grid of 3 x 3:
	var offsets = [
		Vector2(-1,1), Vector2(0, 1), Vector2(1, 1),
		Vector2(-1,0), Vector2(0, 0), Vector2(1, 0),
		Vector2(-1,-1), Vector2(0, -1), Vector2(1, -1),]
	
	for offset in offsets:
		var from2d = WINDOW_DIMENSIONS * 0.5 * offset
		var from = global_position + Vector3(from2d.x, from2d.y, 0)
		var to = from + global_basis.z * HIDE_RANGE
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_bodies = true
		query.collide_with_areas = true
		query.hit_from_inside = true
		query.hit_back_faces = true
	
		var result = space_state.intersect_ray(query)
		if result and result.collider.owner != owner:
			visible = false
			return
		
	visible = true
	
