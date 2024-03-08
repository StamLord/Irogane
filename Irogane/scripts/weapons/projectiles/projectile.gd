extends Node3D

@export_flags_3d_physics var collision_mask
@onready var hitbox = %hitbox
@onready var trail3d = $trail3d
@export var attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)

var speed = 20
var item_id = null

# Internal vars
var start_time
var start_pos
var last_pos
var start_speed
var stopped = false
var bounce_count = 0

func _ready():
	restart()
	hitbox.set_active(true)
	hitbox.on_collision.connect(hit)
	hitbox.on_block.connect(hit_guarded)
	

func hit(area, _hitbox):
	if area is Hurtbox:
		var attack_info = attack_info.clone()
		attack_info.force = get_global_transform().basis * attack_info.force
		
		area.hit(attack_info)
	

func hit_guarded(area : Guardbox, _hitbox):
	if area.is_perfect:
		reflect_trajectory(global_basis.z)
	else:
		reflect_trajectory(area.global_basis.z)
	
	area.guard(attack_info, _hitbox)
	

func restart():
	start_time = Time.get_ticks_msec()
	start_pos = global_position
	last_pos = start_pos
	start_speed = -basis.z * speed
	stopped = false
	
	if trail3d:
		trail3d.trailEnabled = true
	

func deactivate_hitbox():
	await get_tree().create_timer(0.1).timeout
	hitbox.set_active(false)
	

func _process(delta):
	if stopped:
		deactivate_hitbox()
		return
	
	# Calculate position
	var time_passed = (Time.get_ticks_msec() - start_time) / 1000.0;
	var new_pos = start_pos + start_speed * time_passed;
	
	# Add gravity
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	new_pos.y = start_pos.y + start_speed.y * time_passed - gravity * time_passed  * time_passed * 0.5
	
	# Set new position
	global_position = new_pos;
	
	# Rotate in direction of flight
	#transform.forward = transform.position - lastPosition;
	
	# Rotate visual object
	#if(visual) 
	#{
	#	//visual.transform.Rotate(visualRotationPerSecond.x * Time.deltaTime, 0, 0, Space.Self);
	#	visual.transform.RotateAround(visual.transform.right, visualRotationPerSecond.x * Time.deltaTime);
	#	visual.transform.RotateAround(transform.forward, visualRotationPerSecond.z * Time.deltaTime);
	#}
	
	collision_check(delta)
	last_pos = new_pos;
	

func collision_check(delta):
	var ray_origin = global_position
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(last_pos, ray_origin, collision_mask)
	var result = space_state.intersect_ray(query)
	
	if result:
		stopped = true
		
		if bounce_count > 0:
			reflect_trajectory(result.normal)
			bounce_count -= 1
			return
		
		var global_rot = global_rotation
		get_tree().get_root().remove_child(self)
		result.collider.add_child(self)
		global_position = result.position
		global_rotation = global_rot
		#global_rotation = CameraEntity.main_camera.global_rotation
		
		for child in get_children():
			if child is Pickup:
				child.item_id = item_id
				child.get_children()[0].disabled = false
		
		if trail3d:
			trail3d.trailEnabled = false
	

func reflect_trajectory(normal):
	# Reposition under root
	var old_pos = global_position
	var old_rot = global_rotation
	var root = get_tree().get_root()
	get_parent().remove_child(self)
	root.add_child(self)
	global_position = old_pos
	global_rotation = old_rot
	
	# Orient to new reflected forward
	var new_forward = global_basis.z.reflect(normal)
	var new_basis = Basis()
	new_basis.z = -new_forward
	new_basis.x = Vector3.UP.cross(new_forward).normalized()
	new_basis.y = new_basis.x.cross(new_basis.z).normalized()
	
	global_basis = new_basis
	restart()
	
