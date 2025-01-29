extends Area3D
class_name Breaker

@export var rigidbody: RigidBody3D

func get_velocity():
	return rigidbody.linear_velocity
	
