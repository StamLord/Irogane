extends TextureProgressBar
class_name DepletableBar

@export var bar_name: String
@export var change_max_value: bool = true
@export var hide: bool = false
@export var hide_after_seconds: int = 4.0
@export var hide_after_seconds_full: int = 1.0

@onready var stats = PlayerEntity.player_node.stats

var timer: Timer = null

func _ready():
	var depletable = stats.get_node(bar_name)
	
	if depletable == null:
		return
	
	depletable.value_changed.connect(update_value)
	
	if change_max_value:
		depletable.max_value_changed.connect(update_max_value)
	
	value = depletable.get_value()
	
	if change_max_value:
		max_value = depletable.max_value
	
	if hide:
		timer = Timer.new()
		timer.timeout.connect(hide_bar)
		add_child(timer)
	

func update_value(new_value):
	var old_value = value
	value = new_value
	if hide and value != old_value:
		show_bar()
	

func update_max_value(new_max_value):
	max_value = new_max_value
	

func hide_bar():
	animate_alpha(0.0)
	

func show_bar():
	animate_alpha(1.0)
	
	var duration = hide_after_seconds
	if value == max_value:
		duration = hide_after_seconds_full
	
	timer.start(duration)
	timer.paused = false
	

func animate_alpha(alpha):
	var start_a = tint_progress.a
	var duration = 1.0 * 1000
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time < duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		tint_progress.a = lerp(start_a, alpha, t)
		await get_tree().process_frame
	
	tint_progress.a = alpha
	
