extends ShapeCast3D

@export var projectile: Projectile

func _ready():
	if projectile != null:
		projectile.on_stopped.connect(impact)
	

func impact(projectile):
	force_shapecast_update()
	for i in range(get_collision_count()):
		var collider = get_collider(i)
		if collider is Ignitable:
			collider.extinguish()
		
		if collider is LightSwitch:
			if collider.state:
				collider.use(null)
	
