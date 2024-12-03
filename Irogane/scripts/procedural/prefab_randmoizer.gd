@tool
extends Node3D

@export var override = -1:
	set(value):
		value = clampi(value, -1, get_child_count() - 1)
		override = value
		if override >= 0:
			update_prefab(override)
		else:
			randomize_prefab()
	

var last_position: Vector3 = Vector3.ZERO

func _ready():
	randomize_prefab()
	
	if Engine.is_editor_hint():
		last_position = global_position
	

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	if global_position != last_position:
		randomize_prefab()
		last_position = global_position
	

func randomize_prefab():
	seed(global_position.x + global_position.y + global_position.z)
	var variance = randi_range(0, get_child_count() - 1)
	update_prefab(variance)
	

func update_prefab(id):
	var i = 0
	for child in get_children():
		child.visible = i == id
		i += 1
	
