extends Node3D

@export var node_to_follow : Node3D

var offset = Vector3.ZERO

func _ready():
	if node_to_follow == null:
		return
	
	offset = global_position - node_to_follow.global_position
	

func _process(delta):
	if node_to_follow == null:
		return
	
	global_position = node_to_follow.global_position + offset
	
