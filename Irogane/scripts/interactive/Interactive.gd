extends Area3D
class_name Interactive

@export var interaction_text = "Use"
@export var mesh : MeshInstance3D

const HIGHLIGHT_EMMISION = 0.25

var active_material = null

var base_emission_enabled = false
var base_emission_energy_multiplier = 0
var base_emission_texture = null
var base_emission_operation = null

func _ready():
	if mesh != null:
		# Set a clone of the active material as override to make local changes
		active_material = mesh.get_surface_override_material(0).duplicate()
		
		mesh.set_surface_override_material(0, active_material)
		
		# Get defaults to turn back off
		base_emission_enabled = active_material.emission_enabled
		base_emission_energy_multiplier = active_material.emission_energy_multiplier
		base_emission_texture = active_material.emission_texture
		base_emission_operation = active_material.emission_operator
		
	

func get_text():
	return interaction_text
	

func use(interactor):
	pass
	

func highlight_on():
	if active_material != null:
		active_material.emission_enabled = true
		var new_emission_multiplier = HIGHLIGHT_EMMISION if base_emission_energy_multiplier == 0 else base_emission_energy_multiplier * 3
		active_material.emission_energy_multiplier = new_emission_multiplier
		active_material.emission_operator = StandardMaterial3D.EMISSION_OP_MULTIPLY
		active_material.emission_texture = active_material.albedo_texture
	

func highlight_off():
	if active_material != null:
		active_material.emission_enabled = base_emission_enabled
		active_material.emission_energy_multiplier = base_emission_energy_multiplier
		active_material.emission_operator = base_emission_operation
		active_material.emission_texture = base_emission_texture
	
