extends Label

func _process(delta):
	if visible:
		text = str(Engine.get_frames_per_second())
	
