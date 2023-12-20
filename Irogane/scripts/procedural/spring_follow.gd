extends Node3D

@export var node_to_follow : Node3D : 
	set(value):
		node_to_follow = value
		offset = global_position - node_to_follow.global_position

@export var stiffness = 0.5
@export var damping = 0.2
@export var max_distance = 1.0

var offset
var velocity = Vector3()

func _ready():
	if not node_to_follow:
		return
	
	offset = global_position - node_to_follow.global_position
	
	# Move to global space
	get_parent().remove_child.call_deferred(self)
	get_tree().root.add_child.call_deferred(self)
	

func _process(delta):
	if not node_to_follow:
		return
	
	var target_position = node_to_follow.global_position + offset
	var displacement = target_position - global_position
	var distance = displacement.length()
	
	# Calculate forces
	var spring_force = stiffness * displacement
	var damping_force = -damping * velocity
	
	var total_force = spring_force + damping_force
	velocity += total_force * delta
	
	# Clamp
	if distance > max_distance:
		global_position = target_position - displacement.normalized() * max_distance
	
	global_position += velocity * delta
	
