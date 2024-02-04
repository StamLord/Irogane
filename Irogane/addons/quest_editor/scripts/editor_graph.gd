@tool
class_name EditorGraph
extends GraphEdit

@onready var add_node_window = %add_node_window
@onready var add_node_button = %add_node
var selected_quest_node = null


func get_all_node_connections(node_name: String):
	var connections = []
	for conn in get_connection_list():
		if conn.from_node == node_name or conn.to_node == node_name:
			connections.push_back(conn)
	
	return connections
	

func remove_all_node_connections(node_name: String):
	for conn in get_connection_list():
		if conn.from_node == node_name or conn.to_node == node_name:
			disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
	

func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)
	

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)
	

func _on_delete_nodes_request(nodes):
	for node in nodes:
		remove_all_node_connections(node)
		get_node(NodePath(node)).queue_free()
	

func _on_popup_request(position):
	if add_node_button.disabled:
		return
	
	add_node_window.position = get_global_mouse_position()
	add_node_window.popup()
	

