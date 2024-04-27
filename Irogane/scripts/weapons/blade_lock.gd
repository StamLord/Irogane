extends Node3D
class_name BladeLock

var a : Stats
var b : Stats

var struggle_value = 0 # -100 .. 100
var struggle_bar = null
var struggle_vfx = null
var struggle_right_line = null

var start_size_x = null
var start_bar_position = null

const time_limit = 5
var current_time = 0

var win_condition = 33

var is_started = false

signal on_struggle_value_update(new_value : int)
signal on_struggle_end(winner : Stats)

func register_a(stats : Stats):
	a = stats
	

func register_b(stats : Stats):
	b = stats
	

func start_struggle():
	if a == null or b == null:
		return
	
	var bar = UIManager.ui_node.get_node("blade_lock_bar")
	if bar:
		struggle_bar = bar
		struggle_bar.visible = true
		
		start_size_x = struggle_bar.size.x
		start_bar_position = struggle_bar.position
		
		var vfx = bar.get_node("blade_lock_vfx")
		if vfx:
			struggle_vfx = vfx
		
		var right_line = bar.get_node("red_line")
		if right_line:
			struggle_right_line = right_line
	
	align_sides()
	
	struggle_value = 0
	current_time = 0
	is_started = true
	

func _process(delta):
	if not is_started:
		return
	
	if current_time < time_limit:
		# Edges close in
		var t = clamp(current_time / time_limit, 0.0, 1.0)
		var max_value = lerp(100, win_condition, t)
		var size_x = lerp(start_size_x, start_size_x * (win_condition / 100.0), t)
		
		struggle_bar.max_value = max_value
		struggle_bar.min_value = -max_value
		struggle_bar.size.x = size_x
		struggle_bar.position.x = start_bar_position.x + 0.5 * (start_size_x - size_x)
		
		if struggle_right_line:
			struggle_right_line.position.x = struggle_bar.size.x
	else:
		end_struggle()
	
	current_time += delta
	

func align_sides():
	var body_a = a.get_parent()
	var body_b = b.get_parent()
	var center = lerp(body_a.global_position, body_b.global_position, 0.5)
	var target_a = center + (body_a.global_position - center).normalized() * 0.5
	var target_b = center + (body_b.global_position - center).normalized() * 0.5
	
	# Rotate
	Utils.rotate_y_to_target(body_a, body_b.global_position)
	Utils.rotate_y_to_target(body_b, body_a.global_position)
	
	# Move
	var duration = 0.2 * 1000
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		body_a.global_position = lerp(body_a.global_position, target_a, t)
		body_b.global_position = lerp(body_b.global_position, target_b, t)
		await get_tree().process_frame
	
	body_a.global_position = target_a
	body_b.global_position = target_b
	

func side_increase(side : Stats, amount):
	if side == a:
		side_a_increase(amount)
	elif side == b:
		side_b_increase(amount)
	

func side_a_increase(amount):
	update_struggle_value(amount)
	

func side_b_increase(amount):
	update_struggle_value(-amount)
	

func get_value(side : Stats):
	if side == a:
		return struggle_value / 100.0
	elif side == b:
		return -struggle_value / 100.0
	
	print("blade_lock: Can't get value for a non participant! This shouldn't happen!")
	return null
	

func update_struggle_value(amount):
	var old_value = struggle_value
	struggle_value = clamp(struggle_value + amount, -100, 100)
	
	if old_value != struggle_value:
		on_struggle_value_update.emit(struggle_value)
		if struggle_bar:
			struggle_bar.value = struggle_value
			if struggle_vfx:
				struggle_vfx.position.x =  Utils.remap_value(
				struggle_bar.value, struggle_bar.min_value, struggle_bar.max_value, 
				0, struggle_bar.size.x) - struggle_vfx.size.x * 0.5
	
	if abs(struggle_value) >= struggle_bar.max_value:
		end_struggle()
	

func end_struggle():
	is_started = false
	struggle_bar.visible = false
	reset_struggle_bar()
	
	var winner = null
	
	if struggle_value >= win_condition:
		winner = a
	elif struggle_value <= -win_condition:
		winner = b
	
	on_struggle_end.emit(winner)
	

func reset_struggle_bar():
	if not struggle_bar:
		return
	
	struggle_bar.size.x = start_size_x
	struggle_bar.position = start_bar_position
	struggle_bar.min_value = -100
	struggle_bar.max_value = 100
	struggle_bar.value = 0
	
	if struggle_right_line:
		struggle_right_line.position.x = struggle_bar.size.x
	
	print("RESET BAR")
	print(struggle_bar.size.x)
	
