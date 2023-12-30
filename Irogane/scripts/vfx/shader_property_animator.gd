extends TextureRect

@export var parameter_name = "panning"
@export var start_value = 1.0
@export var end_value = -0.5
@export var animate_duration = 2.0

func _ready():
	animate_property()
	

func animate_property():
	if not material is ShaderMaterial:
		return
	
	var start_time = Time.get_ticks_msec()
	var duration = animate_duration * 1000
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		var value = lerp(start_value, end_value, t)
		material.set_shader_parameter(parameter_name, value)
		
		await get_tree().process_frame
	
	material.set_shader_parameter(parameter_name, end_value)
	
