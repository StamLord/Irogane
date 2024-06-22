extends Node3D

@onready var cross = $cross
@onready var player = owner
@onready var stats = %stats

var cross_start_pos = null
var cross_start_rot = null

var cross_prayer_pos = Vector3(0.0, -0.2, -0.5)
var cross_prayer_rot = Vector3.ZERO

var prayer_total_time = 4.0
var is_praying = false
var prayer_start_time = 0

signal on_prayer_update(time)
signal on_prayer_interrupted()
signal on_prayer_finished()

func _ready():
	if cross != null:
		cross_start_pos = cross.position
		cross_start_rot = cross.rotation_degrees
	
	if stats != null:
		stats.on_hit.connect(hit)
	

func _process(delta):
	if not visible:
		return
	
	# Animate cross to idle position
	var target_pos = cross_start_pos if not is_praying else cross_prayer_pos
	var target_rot = cross_start_rot if not is_praying else cross_prayer_rot
	
	cross.position = lerp(cross.position, target_pos, delta * 10)
	cross.rotation_degrees = lerp(cross.rotation_degrees, target_rot, delta * 10)
	
	# Start praying
	var lmb_start = Input.is_action_just_pressed("attack_primary")
	var rmb_start = Input.is_action_just_pressed("attack_secondary")
	
	if (lmb_start or rmb_start) and not is_player_moving() and not is_praying:
		start_prayer()
	
	if not is_praying:
		return
	
	var lmb_pressed = Input.is_action_pressed("attack_primary")
	var rmb_pressed= Input.is_action_pressed("attack_secondary")
	
	# Must not be moving
	if not lmb_pressed and not rmb_pressed or is_player_moving():
		interrupt_prayer()
		return
	
	# Send updates
	var t = get_prayer_percentage()
	on_prayer_update.emit(get_prayer_time())
	
	if t >= 1:
		finish_prayer()
	

func start_prayer():
	prayer_start_time = Time.get_ticks_msec()
	is_praying = true
	

func get_prayer_time():
	return (Time.get_ticks_msec() - prayer_start_time)
	

func get_prayer_percentage():
	return get_prayer_time() / (prayer_total_time * 1000)
	

func finish_prayer():
	is_praying = false
	on_prayer_update.emit(0)
	on_prayer_finished.emit()
	

func interrupt_prayer():
	is_praying = false
	on_prayer_update.emit(0)
	on_prayer_interrupted.emit()
	

func is_player_moving():
	return player.velocity.length() >= 1.0
	

func hit(attack_info):
	if is_praying:
		interrupt_prayer()
	
