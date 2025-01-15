extends Area3D

func _ready():
	area_entered.connect(on_area_entered)
	

func on_area_entered(area):
	if not is_visible_in_tree():
		return
	
	if not area is Ignitable:
		return
	
	area.ignite()
	
