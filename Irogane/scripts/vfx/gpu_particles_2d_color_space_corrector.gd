@tool
extends GPUParticles2D

@export var color : Color
@export var is_linear_to_srgb = false :
	set(value):
		is_linear_to_srgb = value
		if is_linear_to_srgb:
			set_color_linear_to_srgb()
		else:
			set_color_srgb_to_linear()
	

func set_color_linear_to_srgb():
	process_material.set("color", color.linear_to_srgb())
	

func set_color_srgb_to_linear():
	process_material.set("color", color.srgb_to_linear())
	
