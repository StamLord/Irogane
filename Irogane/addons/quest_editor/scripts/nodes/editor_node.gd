@tool
class_name EditorNode
extends GraphNode

func _ready():
	resize_request.connect(_on_resize_request)
	close_request.connect(_on_close_request)
	

func _on_resize_request(new_minsize):
	set_size(new_minsize)
	

func _on_close_request():
	owner.remove_all_node_connections(name)
	queue_free()
	
