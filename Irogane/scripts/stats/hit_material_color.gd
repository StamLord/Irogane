extends Node3D

@export var stats : Stats
@export var model : MeshInstance3D

@export var flash_color = Color.RED
@export var flash_duration = 0.2

var original_color = Color.WHITE
func _ready():
	stats.on_hit.connect(color_flash)
	if model and model.get_active_material(0):
		original_color = model.get_active_material(0).albedo_color
	

func color_flash(amount):
	if model == null:
		return
	
	var mat = model.get_active_material(0)
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= flash_duration * 1000:
		mat.albedo_color = original_color.lerp(flash_color, (Time.get_ticks_msec() - start_time) / (flash_duration * 1000))
		await get_tree().process_frame
	mat.albedo_color = original_color
	
