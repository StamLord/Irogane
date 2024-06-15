extends Node3D

@onready var main_camera = $"../.."
var coin_prefab = preload("res://prefabs/coin_prefab.tscn")

func _process(delta):
	if Input.is_action_just_pressed("attack_primary"):
		throw_coin()
	

func throw_coin():
	var coin : RigidBody3D = coin_prefab.instantiate()
	get_tree().root.add_child(coin)
	coin.global_position = global_position - main_camera.global_basis.z * 1.2
	
	coin.apply_impulse(-main_camera.global_basis.z * 10.0)
	coin.angular_velocity = main_camera.global_basis * Vector3.RIGHT * 20
	
