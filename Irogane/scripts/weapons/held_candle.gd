extends Node3D

@onready var candle_object = $candle_object
@onready var candle_target = $candle_target
@onready var ignitable_area = $candle_object/MeshInstance3D/ignitable_area

const candle_speed = 10.0
var candle_origin: Vector3

func _ready():
	if candle_object:
		candle_origin = candle_object.position
	
	visibility_changed.connect(on_visibility_changed)
	

func _process(delta):
	if not visible or not candle_object or not candle_target:
		return
	
	var is_pressed = Input.is_action_pressed("attack_primary")
	var target_position = candle_target.position if is_pressed else candle_origin
	
	candle_object.position = lerp(candle_object.position, target_position, candle_speed * delta)
	

func on_visibility_changed():
	if not visible and ignitable_area:
		ignitable_area.extinguish()
	
