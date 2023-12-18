extends Node3D

@export var node_to_follow : Node3D : 
	set(value):
		node_to_follow = value
		offset = global_position - value.global_position
	
@export var speed = 1.0
@export var max_distance = 1.0
@export var rotate = false

var offset

func _ready():
	if not node_to_follow:
		return
	
	# Move to global space
	get_parent().remove_child.call_deferred(self)
	get_tree().root.add_child.call_deferred(self)
	offset = global_position - node_to_follow.global_position
	

func _process(delta):
	if not node_to_follow:
		return
	
	var target_position = node_to_follow.global_position + offset
	
	# Clamp to max distance
	var position_delta = global_position - node_to_follow.global_position
	
	if position_delta.length() > max_distance:
		target_position -= position_delta.normalized() * max_distance
	
	global_position = lerp(global_position, target_position, delta * speed)
	
	if rotate:
		look_at(node_to_follow.global_position)
	else:
		global_rotation = lerp(global_rotation, node_to_follow.global_rotation, delta * speed)
