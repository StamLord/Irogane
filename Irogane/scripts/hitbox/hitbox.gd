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
signal on_block(area : Guardbox, hitbox)

func set_active(active):
	monitoring = active
	
	if not monitoring:
		clear_collisions()
	
	if mesh:
		mesh.material_override.albedo_color = active_color if monitoring else inactive_color
	

func is_active():
	return monitoring
	

func _process(delta):
	if mesh:
		mesh.visible = debug
	
	if monitoring:
		collision_check()
	

func collision_check():
	var colliders = get_overlapping_areas()
	
	for col in colliders:
		if col is Guardbox:
			on_block.emit(col, self)
			set_active(false)
			#print(name + ": guarded by " + col.name)
			return
	
	for col in colliders:
		if not collide_with_self and col.owner == self.owner:
			continue
		
		if avoid_multiple_collisions and collisions.has(col):
			continue
		
		collisions.append(col)
		on_collision.emit(col, self)
	

func clear_collisions():
	collisions.clear()
	
