extends Decal

const RAY_LENGTH = 1000.0
const Z_MAX = 20

func _input(event):
	if not visible: 
		return
	
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if event is InputEventMouseMotion:
		move_to_raycast_pos()
	

func move_to_raycast_pos():
	var mouse_pos = get_viewport().get_mouse_position()
	var camera3d = DebugCommandsManager.main_camera
	var from = camera3d.project_ray_origin(mouse_pos)
	var to = from + camera3d.project_ray_normal(mouse_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var space_state = camera3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result.position
		global_rotation = Vector3.ZERO
		position.z = clamp(position.z, -Z_MAX, Z_MAX)
	

func _on_visibility_changed():
	if visible:
		move_to_raycast_pos()
