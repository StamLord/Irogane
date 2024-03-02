extends Control

@onready var medicine_texture = $medicine_vfx

@export var medicine_curve : Curve
var medicine_duration = 1.5
var medicine_start = null

func _ready():
	subscribe_to_player(PlayerEntity.player_node)
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	

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
	
