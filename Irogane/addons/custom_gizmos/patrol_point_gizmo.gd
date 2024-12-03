extends EditorNode3DGizmoPlugin

const icon_path = "res://addons/custom_gizmos/icon/patrol_point.svg"

func _get_gizmo_name():
	return "PatrolPoint"
	

func _has_gizmo(node):
	return node is PatrolPoint
	

func _init():
	var icon_texture = load(icon_path)
	if icon_texture:
		create_icon_material("icon", icon_texture, false, Color.CYAN)
	

func _redraw(gizmo):
	gizmo.clear()
	gizmo.add_unscaled_billboard(get_material("icon", gizmo), 0.05)
	
