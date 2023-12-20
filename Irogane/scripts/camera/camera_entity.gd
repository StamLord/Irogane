extends Node

var main_camera
var third_person_camera 
var active_camera

enum CameraType { 
	MAIN,
	THIRD_PERSON
}

func get_main_camera():
	return main_camera
	

func set_main_camera(camera):
	main_camera = camera
	active_camera = camera
	

func get_third_person_camera():
	return third_person_camera
	

func set_third_person_camera(camera):
	third_person_camera = camera
	

func get_active_camera():
	return active_camera
	

func set_active_camera(type: CameraType):
	if type == CameraType.MAIN:
		active_camera = main_camera
	elif type == CameraType.THIRD_PERSON:
		active_camera = third_person_camera
	else:
		print("Error, no camera type %s ", type)
	active_camera.current = true
	

func toggle_camera():
	if active_camera == main_camera:
		active_camera = third_person_camera
	elif active_camera == third_person_camera:
		active_camera = main_camera
	active_camera.current = true
	

func _process(delta):
	if Input.is_action_just_pressed("equals"):
		toggle_camera()
	


