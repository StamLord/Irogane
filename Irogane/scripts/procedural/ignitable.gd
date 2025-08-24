extends Area3D
class_name Ignitable

@export var node : Node3D

func ignite():
	if node.visible:
		return
	
	node.visible = true
	

func extinguish():
	if not node.visible:
		return
	
	node.visible = false
	
