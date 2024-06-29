extends Node3D

var key_collection = null
@export var use_test_collection = false
@export var test_key_collection = {0 : {Key.key_color.BRASS : 5}}

@onready var key_ui_window = $"../../../key_ui_window"

@onready var mesh_key_dict = {
	$brass_key/brass_key_0 : Key.key_color.BRASS,
	$silver_key/silver_key_0 : Key.key_color.SILVER,
	$gold_key/gold_key_0 : Key.key_color.GOLD }

func _ready():
	prepare_materials()
	
	if PlayerEntity.player_node:
		var interaction = PlayerEntity.player_node.get_node("head/main_camera/interaction")
		if interaction != null:
			key_collection = interaction.key_ring
	
	update_keys()
	
	if key_ui_window != null:
		key_ui_window.visibility_changed.connect(update_keys)
	

func update_keys():
	if not visible:
		return
		
	var collection = test_key_collection if use_test_collection else key_collection
	if collection == null:
		return
	
	var id = name.to_int()
	
	for key in mesh_key_dict:
		for i in range(key.get_surface_override_material_count()):
			var mat = key.get_active_material(i)
			if collection.has(id) and collection[id].has(mesh_key_dict[key]):
				mat.albedo_color.a = 1.0
			else:
				mat.albedo_color.a = 0.1
	

func prepare_materials():
	for mesh in mesh_key_dict:
		for i in range(mesh.get_surface_override_material_count()):
			var dup = mesh.get_active_material(i).duplicate()
			dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			dup.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
			mesh.set_surface_override_material(i, dup)
	
