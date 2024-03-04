extends Area3D

@export var collide_with_self = false
@export var avoid_multiple_collisions = true

@export var inactive_color = Color("ff000040")
@export var active_color = Color("ff0000c0")

@onready var mesh = $mesh

static var debug = false

# Array of collisions used to avoid multiple collisions on same object
var collisions = []

signal on_collision(area, hitbox)
signal on_guard(area : Guardbox, hitbox)

func set_active(active):
	monitoring = active
	
	if not monitoring:
		clear_collisions()
	
	if mesh:
		mesh.material_override.albedo_color = active_color if monitoring else inactive_color
	

func _process(delta):
	if mesh:
		mesh.visible = debug
	
	if monitoring:
		collision_check()
	

func collision_check():
	var colliders = get_overlapping_areas()
	
	for col in colliders:
		if col is Guardbox:
			on_guard.emit(col, self)
			set_active(false)
			print(name + ": guarded by " + col.name)
			return
		
		if not collide_with_self and col.owner == self.owner:
			continue
		
		if avoid_multiple_collisions and collisions.has(col):
			continue
		
		collisions.append(col)
		on_collision.emit(col, self)
		
		# Debug
		print(name + ": collision with " + col.name)
	

func collision(area):
	# Don't collide with other children of same owner (scene root)
	if not collide_with_self and area.owner == self.owner:
		return
	
	# Don't collide more than once with a collider (Resets when hitbox is deactivated)
	if avoid_multiple_collisions and collisions.has(area):
		return
	
	collisions.append(area)
	on_collision.emit(area, self)
	
	# Debug
	print(name + ": collision with " + area.name)
	

func clear_collisions():
	collisions.clear()
	
