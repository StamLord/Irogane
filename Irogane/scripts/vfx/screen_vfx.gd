extends Control

@onready var vignette_vfx = $vignette_vfx
@onready var distortion_vfx = $distortion_vfx

@export var vignette_curve : Curve
@export var distortion_curve : Curve

@export var medicine_color = Color("61ff00")
@export var medicine_duration = 1.0

@export var physical_damage_color = Color("c40000")
@export var physical_damage_distortion_duration = 0.5
@export var physical_damage_vignette_duration = 2.0

func _ready():
	subscribe_to_player(PlayerEntity.player_node)
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	
	add_debug_commands()
	

func subscribe_to_player(player_node):
	var stats = player_node.get_node("stats")
	if stats:
		stats.on_medicine_used.connect(medicine_vfx)
		stats.on_health_depleted.connect(physical_damage_vfx)
	

func animate_vfx(texture, parameter : String, color : Color, duration : float, curve : Curve):
	var start_time = Time.get_ticks_msec()
	texture.material.set_shader_parameter("color", color)
	while Time.get_ticks_msec() - start_time <= duration:
		var t =  (Time.get_ticks_msec() - start_time) / duration

		texture.material.set_shader_parameter(parameter, curve.sample(t))
		await get_tree().process_frame
	
	texture.material.set_shader_parameter(parameter, 0)
	

func animate_vignette(duration, color):
	animate_vfx(vignette_vfx, "strength", color, duration, vignette_curve)
	

func animate_distortion(duration):
	animate_vfx(distortion_vfx, "distortion_amount", Color.WHITE, duration, distortion_curve)
	

func medicine_vfx(medicine):
	animate_vignette(medicine_duration * 1000, medicine_color)
	

func physical_damage_vfx(hurt):
	animate_vignette(physical_damage_vignette_duration * 1000, physical_damage_color)
	#animate_distortion(physical_damage_distortion_duration * 1000)
	

func add_debug_commands():
	DebugCommandsManager.add_command("medicine_vfx", debug_medicine_vfx, [], "Play medicine vfx on screen.")
	DebugCommandsManager.add_command("hurt_vfx", debug_hurt_vfx, [], "Play hurt vfx on screen.")
	

func debug_medicine_vfx(_empty):
	medicine_vfx(null)
	

func debug_hurt_vfx(empty):
	physical_damage_vfx(null)
	
