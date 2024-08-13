extends ShapeCast3D

@export var projectile: Projectile

func _ready():
	if projectile != null:
		projectile.on_stopped.connect(impact)
	

func impact(projectile):
	force_shapecast_update()
	print(get_collision_count())
	for i in range(get_collision_count()):
		var collider = get_collider(i)
		print(collider)
		print(collider is LightSwitch)
		if not collider is LightSwitch:
			continue
		
		print(collider.state)
		if collider.state:
			collider.use(null)
	
