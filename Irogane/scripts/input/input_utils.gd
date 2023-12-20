extends Node

const double_input_window = 0.2
const monitored_actions = ["forward", "backward", "left", "right"]

var actions = {}
var double_actions = []

func _process(_delta):
	clean_actions()
	clean_double_actions()
	

func _input(event):
	var is_monitored = false
	var action_name = ""
	for monitored in monitored_actions:
		if event.is_action_pressed(monitored):
			is_monitored = true
			action_name = monitored
			break
	
	if not is_monitored:
		return
	
	# If already pressed once, this is a double action
	if actions.has(action_name):
		double_actions.append(action_name)
		actions.erase(action_name)
	else:
		actions[action_name] = Time.get_ticks_msec()
	

func is_action_just_double_pressed(action):
	return double_actions.has(action)
	

func clean_actions():
	for action in actions:
		if Time.get_ticks_msec() - actions[action] >= double_input_window * 1000:
			actions.erase(action)
	

func clean_double_actions():
	double_actions.clear()
	
