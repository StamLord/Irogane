extends SpotLight3D

func _process(_delta):
	if Input.is_action_just_pressed("nightvision"):
		visible = !visible
	
