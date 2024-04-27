extends Area3D
class_name Hitbox

@export var collide_with_self = false
@export var avoid_multiple_collisions = true
@export var is_heavy = false

@export var inactive_color = Color("ff000040")
@export var active_color = Color("ff0000c0")

@onready var mesh = $mesh

static var debug = false

# Array of collisions used to avoid multiple collisions on same object
var collisions = []

signal on_collision(area, hitbox)
signal on_block(area : Guardbox, hitbox)
signal on_heavy_clash(area : Hitbox, hitbox)
signal on_blade_lock_invite(stats : Stats)

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
			on_block.emit(col, self)
			set_active(false)
			return
		elif is_heavy and col is Hitbox and col.is_heavy:
			on_heavy_clash.emit(col, self)
			set_active(false)
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
	

func set_heavy(state : bool):
	is_heavy = state
	

func invite_to_blade_lock(blade_lock : BladeLock):
	on_blade_lock_invite.emit(blade_lock)
	
