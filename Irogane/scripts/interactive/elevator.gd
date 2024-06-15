extends Node3D

@export var switches : Array[Switch]
@export var levels : Array[float]
@export var speed = 4.0

var target_floor = null

signal reached_floor(index)

func _ready():
	for i in range(switches.size()):
		switches[i].on_state_changed.connect(goto_floor.bind(i))
	

func _process(delta):
	if target_floor == null or target_floor > levels.size():
		return
	
	var target_height = levels[target_floor]
	var vertical_movement = clamp(target_height - global_position.y, -speed, speed)
	global_position.y += vertical_movement * delta
	
	if abs(vertical_movement) < 0.1:
		reached_floor.emit(target_floor)
		target_floor = null
	

func goto_floor(state, index):
	if not state or target_floor != null:
		return
	
	target_floor = index
	
