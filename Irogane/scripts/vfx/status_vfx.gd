extends Node3D

@export var stats : Stats

var vfx_dict = {} # status_name : vfx_node

func _ready():
	stats.on_status_added.connect(status_added)
	stats.on_status_removed.connect(status_removed)
	

func status_added(status_name):
	if vfx_dict.has(status_name):
		return
	
	var status = StatusDb.get_status(status_name)
	if status == null or status.vfx_prefab == null:
		return
	
	var new_vfx = status.vfx_prefab.instantiate()
	add_child(new_vfx)
	vfx_dict[status_name] = new_vfx
	

func status_removed(status_name):
	if not vfx_dict.has(status_name):
		return
	
	vfx_dict[status_name].queue_free()
	vfx_dict.erase(status_name)
	
