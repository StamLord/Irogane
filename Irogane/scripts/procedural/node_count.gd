extends Node3D


func count_nodes(root: Node) -> int:
	var count = 1  # Count the root node itself
	for child in root.get_children():
		count += count_nodes(child)  # Recursively count child nodes
	return count
	

func _ready():
	var total_nodes = count_nodes(get_tree().root)
	print("Total nodes in the scene:", total_nodes)
	
