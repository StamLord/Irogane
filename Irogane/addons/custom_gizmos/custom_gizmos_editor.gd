@tool
extends EditorPlugin

const patrol_point_gizmo_script = preload("res://addons/custom_gizmos/patrol_point_gizmo.gd")
var patrol_point_gizmo = patrol_point_gizmo_script.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(patrol_point_gizmo)
	

func _exit_tree():
	remove_node_3d_gizmo_plugin(patrol_point_gizmo)
	
