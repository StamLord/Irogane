extends HBoxContainer

@onready var icon_prefab = $icon_prefab
@onready var stats = PlayerEntity.player_node.stats

var icon_dict = {} # status_name : icon_node

func _ready():
	stats.on_status_added.connect(status_added)
	stats.on_status_removed.connect(status_removed)
	

func status_added(status_name):
	if icon_dict.has(status_name):
		return
	
	var status = StatusDb.get_status(status_name)
	if status == null:
		return
	
	var new_icon = icon_prefab.duplicate()
	new_icon.visible = true
	new_icon.texture = status.icon
	add_child(new_icon)
	icon_dict[status_name] = new_icon
	

func status_removed(status_name):
	if not icon_dict.has(status_name):
		return
	
	icon_dict[status_name].queue_free()
	icon_dict.erase(status_name)
	
