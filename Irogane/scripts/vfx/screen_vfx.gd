extends Control

@onready var medicine_texture = $medicine_vfx
@export var medicine_curve : Curve
var medicine_duration = 1.0
var medicine_start = null

@onready var hurt_texture = $hurt_vfx
@export var hurt_curve : Curve
var hurt_duration = 1.0
var hurt_start = null

func _ready():
	subscribe_to_player(PlayerEntity.player_node)
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	
	add_debug_commands()
	

func subscribe_to_player(player_node):
	var stats = player_node.get_node("stats")
	if stats:
		stats.medicine_used.connect(medicine_vfx)
	

func medicine_vfx(medicine):
	medicine_start = Time.get_ticks_msec()
	var duration = medicine_duration * 1000
	while Time.get_ticks_msec() - medicine_start <= duration:
		var t =  (Time.get_ticks_msec() - medicine_start) / duration
		medicine_texture.material.set_shader_parameter("strength", medicine_curve.sample(t))
		await get_tree().process_frame
	
	medicine_texture.material.set_shader_parameter("strength", 0)
	

func hurt_vfx(hurt):
	hurt_start = Time.get_ticks_msec()
	var duration = hurt_duration * 1000
	while Time.get_ticks_msec() - hurt_start <= duration:
		var t =  (Time.get_ticks_msec() - hurt_start) / duration
		hurt_texture.material.set_shader_parameter("distortion_amount", hurt_curve.sample(t))
		await get_tree().process_frame
	
	hurt_texture.material.set_shader_parameter("distortion_amount", 0)
	

func add_debug_commands():
	DebugCommandsManager.add_command("medicine_vfx", debug_medicine_vfx, [], "Play medicine vfx on screen.")
	DebugCommandsManager.add_command("hurt_vfx", debug_hurt_vfx, [], "Play hurt vfx on screen.")
	

func debug_medicine_vfx(empty):
	medicine_vfx(null)
	

func debug_hurt_vfx(empty):
	hurt_vfx(null)
	
