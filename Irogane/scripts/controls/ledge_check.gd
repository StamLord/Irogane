extends Node3D

@onready var raycasts = get_children()
var colliding = false
var collider = null
var normal = null
var point = null

func _ready():
	if not owner is CollisionObject3D:
		return
	
	for ray in raycasts:
		ray.add_exception(owner)
	

func _process(_delta):
	colliding = false
	collider = null
	normal = null
	point = null
	for ray in raycasts:
		if ray.is_colliding():
			colliding = true
			collider = ray.get_collider()
			normal = ray.get_collision_normal()
			point = ray.get_collision_point()
	

func is_colliding():
	return colliding
	

func get_collider():
	return collider
	

func get_collision_normal():
	return normal
	

func get_collision_point():
	return point
	
