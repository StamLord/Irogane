extends Node3D

var drop_offset = Vector3(0, 0, -0.6)


func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var item_id = "shuriken"
		var pickup =  ItemDB.get_item(item_id)["pickup"].instantiate()
		get_tree().get_root().add_child(pickup)
		
		pickup.global_position = (CameraEntity.main_camera.global_basis * drop_offset) + global_position
		pickup.global_rotation = CameraEntity.main_camera.global_rotation
		
		pickup.restart()
		
		# Set item
		for child in pickup.get_children():
			if child is Pickup:
				child.item_id = item_id
	
