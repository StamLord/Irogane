extends Throwable

@export var fire_cooldown = 1.0

var last_throw = 0

func _ready():
	pass 

func _process(delta):
	if Time.get_ticks_msec() - last_throw > fire_cooldown * 1000:
		fire_shuriken(shoot_pos_offset[ShootPos.BOTTOM_RIGHT], Vector3.ZERO)
		last_throw = Time.get_ticks_msec()
	

func fire_shuriken(position_offset, rotation_offset, type = null):
	var projectile = shuriken_prefab.instantiate()
	get_tree().get_root().add_child(projectile)
	
	projectile.global_position = global_basis * position_offset + global_position
	projectile.global_rotation = global_rotation + rotation_offset
	projectile.item_id = ITEM_ID
	projectile.restart()
