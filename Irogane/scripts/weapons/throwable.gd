extends Node3D

@onready var projectile_scene = load("res://prefabs/weapons/projectiles/shuriken.tscn")

var drop_offset = Vector3(0, 0, -0.6)

const ITEM_ID = "shuriken"

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var pickup =  projectile_scene.instantiate()
		get_tree().get_root().add_child(pickup)
		
		pickup.global_position = (CameraEntity.main_camera.global_basis * drop_offset) + global_position
		pickup.global_rotation = CameraEntity.main_camera.global_rotation
		pickup.item_id = ITEM_ID
		pickup.restart()
	
