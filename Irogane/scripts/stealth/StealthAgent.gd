extends Area3D
class_name StealthAgent

@export var base_detection_multiplier = 1
@export var crouch_detection_multiplier = 0.5
@export var state_machine : PlayerStateMachine

var detection_multiplier = 1

# Dictionary of AwarenessAgent : visiblity (0.0 - 1.0)
var watchers = {}

func _ready():
	if state_machine:
		state_machine.on_state_enter.connect(state_enter_check)
		state_machine.on_state_exit.connect(state_exit_check)
	
	SceneManager.on_scene_start_load.connect(scene_loading)
	

func set_crouch_detection():
	detection_multiplier = crouch_detection_multiplier
	

func set_base_detection():
	detection_multiplier = base_detection_multiplier
	

func update_watcher(watcher, detection):
	if not watchers.has(watcher):
		watcher.tree_exiting.connect(remove_watcher.bind(watcher))
	watchers[watcher] = clamp(detection, 0.0, 1.0)
	

func remove_watcher(watcher):
	watchers.erase(watcher)
	

func state_enter_check(state_name):
	if state_name == "crouch":
		set_crouch_detection()
	

func state_exit_check(state_name):
	if state_name == "crouch":
		set_base_detection()
	

func remove_all_watchers():
	watchers.clear()
	

func scene_loading(_scene_path):
	remove_all_watchers()
	
