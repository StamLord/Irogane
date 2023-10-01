extends Area3D
class_name Interactive

@export var interaction_text = "Use"
@onready var mesh = $"../mesh"

func get_text():
	return interaction_text
	
func use(interactor):
	pass

func highlight_on():
	if mesh != null and mesh.material_override != null:
		mesh.material_override.next_pass.set_shader_parameter("on", 1.0)

func highlight_off():
	if mesh != null and mesh.material_override != null:
		mesh.material_override.next_pass.set_shader_parameter("on", 0.0)
