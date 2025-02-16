extends Area3D
class_name Interactive

@export var interaction_text = "Use"
@export var mesh : MeshInstance3D
@export var highlight_emission_multiplier = 3.0
@export var highlight_emission_operator = StandardMaterial3D.EMISSION_OP_MULTIPLY

const HIGHLIGHT_EMMISION = 0.1
const HIGHLIGHT_COLOR = Color.WHITE

var is_disabled = false

var active_material = null

var base_emission_enabled = false
var base_emission = null
var base_emission_energy_multiplier = 0
var base_emission_texture = null
var base_emission_operation = null

func _ready():
	if mesh != null:
		active_material = mesh.get_surface_override_material(0)
		
		if active_material == null:
			return
		
		# Set a clone of the active material as override to make local changes
		active_material = active_material.duplicate()
		mesh.set_surface_override_material(0, active_material)
		
		# Get defaults to turn back off
		if active_material is StandardMaterial3D:
			base_emission_enabled = active_material.emission_enabled
			base_emission = active_material.emission
			base_emission_energy_multiplier = active_material.emission_energy_multiplier
			base_emission_texture = active_material.emission_texture
			base_emission_operation = active_material.emission_operator
		elif active_material is ShaderMaterial:
			base_emission_energy_multiplier = active_material.get_shader_parameter("emission_multiplier")
	

func get_text():
	if is_disabled:
		return ""
	
	return interaction_text
	

func use(_interactor):
	pass
	

func highlight_on():
	if is_disabled or active_material == null:
		return
	
	var new_emission_multiplier = HIGHLIGHT_EMMISION if base_emission_energy_multiplier == 0 else base_emission_energy_multiplier * highlight_emission_multiplier
	
	if active_material is StandardMaterial3D:
		active_material.emission_enabled = true
		active_material.emission = HIGHLIGHT_COLOR if base_emission == Color.BLACK else base_emission
		active_material.emission_energy_multiplier = new_emission_multiplier
		active_material.emission_operator = highlight_emission_operator
		active_material.emission_texture = active_material.albedo_texture
		
	elif active_material is ShaderMaterial:
		active_material.set_shader_parameter("emission_multiplier", new_emission_multiplier)
	

func highlight_off():
	if is_disabled or active_material == null:
		return
	
	if active_material is StandardMaterial3D:
		active_material.emission_enabled = base_emission_enabled
		active_material.emission = base_emission
		active_material.emission_energy_multiplier = base_emission_energy_multiplier
		active_material.emission_operator = base_emission_operation
		active_material.emission_texture = base_emission_texture
	elif active_material is ShaderMaterial:
		active_material.set_shader_parameter("emission_multiplier", base_emission_energy_multiplier)
	

func set_disabled(state : bool):
	is_disabled = state
	
