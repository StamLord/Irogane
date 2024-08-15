extends Node3D

@onready var main_camera = $"../.."

@onready var visual_pull = $visual_pull
@onready var visual_pull_min = $visual_pull_min
@onready var visual_pull_max = $visual_pull_max

@onready var visual_sling = $visual
@onready var visual_sling_min = $visual_sling_min
@onready var visual_sling_max = $visual_sling_max

const SLINGSHOT_BULLET = preload("res://prefabs/slingshot_bullet.tscn")

@export var bullet_min_force = 10.0
@export var bullet_max_force = 60.0
@export var aim_max_time = 0.5

@export var visual_pull_min_position: float = -0.45
@export var visual_pull_max_position: float = -0.15

var is_aiming: bool = false
var aim_start_time: int = -1
var aim_percentage: float = 0.0
var last_owner_postion = Vector3.ZERO
var owner_velocity = Vector3.ZERO

var bullet = null

func _process(delta):
	if not visible:
		return
	
	if Input.is_action_just_pressed("attack_primary"):
		start_aim()
	
	if is_aiming:
		aim_percentage = (Time.get_ticks_msec() - aim_start_time) / (aim_max_time * 1000)
		aim_percentage = clamp(aim_percentage, 0.0, 1.0)
		
		if Input.is_action_just_pressed("attack_secondary"):
			cancel_aim()
		elif Input.is_action_just_released("attack_primary"):
			cancel_aim()
			shoot()
	
	update_slingshot_visual(delta)
	

func _physics_process(delta):
	owner_velocity = (owner.global_position - last_owner_postion) / delta
	last_owner_postion = owner.global_position
	

func start_aim():
	is_aiming = true
	aim_start_time = Time.get_ticks_msec()
	aim_percentage = 0.0
	

func cancel_aim():
	is_aiming = false
	

func shoot():
	bullet = SLINGSHOT_BULLET.instantiate()
	get_tree().root.add_child(bullet)
	
	bullet.global_position = global_position - main_camera.global_basis.z * 1.2
	bullet.look_at(global_position - main_camera.global_basis.z * 10)
	bullet.speed = lerp(bullet_min_force, bullet_max_force, aim_percentage)
	bullet.restart()
	

func update_slingshot_visual(delta):
	if is_aiming:
		visual_pull.position = lerp(visual_pull_min.position, visual_pull_max.position, aim_percentage)
		visual_sling.position = lerp(visual_sling_min.position, visual_sling_max.position, aim_percentage)
		visual_sling.rotation = lerp(visual_sling_min.rotation, visual_sling_max.rotation, aim_percentage)
	else:
		visual_pull.position = lerp(visual_pull.position, visual_pull_min.position, delta * 50.0)
		visual_sling.position = lerp(visual_sling.position, visual_sling_min.position, delta * 50.0)
		visual_sling.rotation = lerp(visual_sling.rotation, visual_sling_min.rotation, delta * 50.0)
	
