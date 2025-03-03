extends Node3D

@onready var shape_cast = $ShapeCast3D
@onready var smoke_mesh = $smoke_mesh

var smoke_material = null
var last_origin_pos = null

var remake_mesh = false

func _ready():
	visibility_changed.connect(start_smoke)
	

func _process(delta):
	if visible and smoke_material != null:
		var p = smoke_material.get_shader_parameter("progress")
		smoke_material.set_shader_parameter("progress", p + delta * 0.1)  
	
	if last_origin_pos != null:
		var distance = global_position.distance_to(last_origin_pos)
		if distance >= 0.01:
			if remake_mesh:
				start_smoke()
			else:
				smoke_mesh.update_smoke_origin(global_position, last_origin_pos)
			
			last_origin_pos = global_position
	

func start_smoke():
	last_origin_pos = global_position
	shape_cast.force_shapecast_update()
	
	var count = shape_cast.get_collision_count()
	for i in range(count):
		var col = shape_cast.get_collider(i)
		smoke_mesh.start_smoke(col.global_position)
		smoke_material = smoke_mesh.material
		return
	
