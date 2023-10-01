extends UIWindow
class_name InventoryWindow

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if visible:
			close()
		else:
			open()
