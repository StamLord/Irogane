@tool
extends Node3D
class_name Projectile

@export_flags_3d_physics var collision_mask
@onready var hitbox = %hitbox
@onready var trail3d = $trail3d
@onready var spin_vfx = $spin_vfx
@onready var impact_vfx = $impact_vfx
@onready var model = $model

@onready var audio = $audio
@export var flight_sfx_path = "res://assets/audio/shuriken/shuriken_flight_1.ogg"
@export var impact_sfx_path = "res://assets/audio/shuriken/shuriken_impact_1.ogg"

@onready var flight_sfx = null
@onready var impact_sfx = null

var attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)

@export var speed = 60
@export var gravity_multiplier = 1.0
@export var rotation_x_speed = 20.0
@export var impact_paricles_amount = 1
var item_id = null

# Internal vars
var start_time
var start_pos
var last_pos
var start_speed
var stopped = false
var despawn_after_stopping = false
var bounce_count = 0
var not_persistent = false

var original_speed = null
var original_gravity_mult = null

signal on_stopped(projectile)

func _ready():
	if Engine.is_editor_hint():
		return
	
	restart()
	hitbox.set_active(true)
	hitbox.on_collision.connect(hit)
	hitbox.on_block.connect(hit_guarded)
	
	if flight_sfx_path != null:
		flight_sfx = load(flight_sfx_path)
	
	if impact_sfx_path != null:
		impact_sfx = load(impact_sfx_path)
	

func hit(area, _hitbox):
	if area is Hurtbox:
		var new_attack_info = attack_info.clone()
		new_attack_info.force = get_global_transform().basis * new_attack_info.force
		
		area.hit(new_attack_info)
	

func hit_guarded(area : Guardbox, _hitbox):
	if area.is_perfect:
		reflect_trajectory(global_basis.z)
	else:
		reflect_trajectory(area.global_basis.z)
	
	area.guard(attack_info, _hitbox)
	

func restart():
	if original_speed != null:
		speed = original_speed
	
	if original_gravity_mult != null:
		gravity_multiplier = original_gravity_mult
	
	start_time = Time.get_ticks_msec()
	start_pos = global_position
	last_pos = start_pos
	start_speed = -basis.z * speed
	stopped = false
	
	if spin_vfx:
		spin_vfx.visible = true
	
	if audio:
		audio.stream = flight_sfx
		audio.pitch_scale = 1.0 - randf_range(-0.05, 0.05)
		audio.playing = true
	
	if trail3d:
		trail3d.set_lifespan(0.5)
		trail3d.trailEnabled = true
	

func deactivate_hitbox():
	await get_tree().create_timer(0.1).timeout
	hitbox.set_active(false)
	

func _process(delta):
	if Engine.is_editor_hint():
		rotate_model(delta)
		return
	
	if stopped:
		deactivate_hitbox()
		if despawn_after_stopping:
			despawn()
		return
	
	# Calculate position
	var time_passed = (Time.get_ticks_msec() - start_time) / 1000.0;
	var new_pos = start_pos + start_speed * time_passed;
	
	# Add gravity
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier
	new_pos.y = start_pos.y + start_speed.y * time_passed - gravity * time_passed  * time_passed * 0.5
	
	# Set new position
	global_position = new_pos;
	
	rotate_model(delta)
	collision_check()
	last_pos = new_pos;
	

func rotate_model(delta):
	if model:
		model.rotate_x(rotation_x_speed * delta)
	

func collision_check():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(last_pos, global_position, collision_mask)
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result.position # Move back to ray collision to avoid clipping
		
		emit_impact_vfx()
		
		if bounce_count > 0 and result.collider != PlayerEntity.player_node:
			reflect_trajectory(result.normal)
			bounce_count -= 1
			return
		
		stopped = true
		on_stopped.emit(self)
		
		if result.collider == PlayerEntity.player_node:
			despawn_after_stopping = true
		
		if spin_vfx:
			spin_vfx.visible = false
		
		if audio:
			audio.stream = impact_sfx
			audio.pitch_scale = 1.0 - randf_range(-0.05, 0.05)
			audio.play()
		
		# Reparent under collider
		var old_global_rot = global_rotation
		get_tree().get_root().remove_child(self)
		result.collider.add_child(self)
		global_position = result.position # Needed after reparenting child
		global_rotation = old_global_rot
		
		for child in get_children():
			if child is Pickup:
				child.item_id = item_id
				child.get_children()[0].disabled = false
		
		if trail3d:
			trail3d.trailEnabled = false
			trail3d.set_lifespan(0.25)
	

func reflect_trajectory(normal):
	# Orient to new reflected forward
	var new_forward = global_basis.z.reflect(normal)
	var new_basis = Basis()
	new_basis.z = -new_forward
	new_basis.x = Vector3.UP.cross(new_forward).normalized()
	new_basis.y = new_basis.x.cross(new_basis.z).normalized()
	
	global_basis = new_basis
	restart()
	

func set_temp_speed(value : float):
	original_speed = speed
	speed = value
	start_speed = -basis.z * speed
	

func set_temp_gravity_multiplier(value : float):
	original_gravity_mult = gravity_multiplier
	gravity_multiplier = value
	

func emit_impact_vfx():
	if impact_vfx:
		for i in range(impact_paricles_amount):
			impact_vfx.emit_particle(impact_vfx.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	

func despawn():
	model.visible = false
	await get_tree().create_timer(0.5).timeout
	queue_free()
	

func toggle_highlight():
	model.get_node("shuriken2").get_surface_override_material(0).no_depth_test = not model.get_node("shuriken2").get_surface_override_material(0).no_depth_test
	

func set_hightlight_color(color: Color):
	model.get_node("shuriken2").get_surface_override_material(0).albedo_color = color
	

