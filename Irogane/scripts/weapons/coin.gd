extends Node3D

@onready var main_camera = $"../.."

var coin_prefab = preload("res://prefabs/coin_prefab.tscn")

var last_owner_postion = Vector3.ZERO
var owner_velocity = Vector3.ZERO

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		throw_coin()
	

func _physics_process(delta):
	owner_velocity = (owner.global_position - last_owner_postion) / delta
	last_owner_postion = owner.global_position
	

func throw_coin():
	var coin : RigidBody3D = coin_prefab.instantiate()
	get_tree().root.add_child(coin)
	coin.name = "CoinPrefab"	# If we don't set the name, 
								# after the first one the rest will be named @Rigidbody#
	coin.global_position = global_position - main_camera.global_basis.z * 1.2
	
	coin.linear_velocity = owner_velocity
	coin.apply_impulse(-main_camera.global_basis.z * 10.0)
	coin.angular_velocity = main_camera.global_basis * Vector3.RIGHT * 20
	
