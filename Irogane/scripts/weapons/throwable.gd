extends Node3D

const item_base = preload("res://scripts/ui/item_base.tscn")
const pickup_base = preload("res://prefabs/pickups/pickup.tscn")
@onready var drop_origin = PlayerEntity.player_node
var drop_offset = Vector3(0, 1.8, -1.5)
@export var throw_force = 15.0


func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		var item_id = "shuriken"
		var pickup =  ItemDB.get_item(item_id)["pickup"].instantiate()
		get_tree().get_root().add_child(pickup)
		
		pickup.global_position = global_position #drop_origin.global_position + drop_origin.get_global_transform().basis * drop_offset
		pickup.restart()
		# Set item
		for child in pickup.get_children():
			if child is Pickup:
				child.item_id = item_id
	
