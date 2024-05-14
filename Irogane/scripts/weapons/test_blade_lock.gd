extends Node3D

@export var hitbox : Hitbox
@export var stats : Stats
@export var press_cooldown = 0.2
@export var katana_hands : Node3D

var animation_tree : AnimationTree = null

var is_in_blade_lock = false
var current_blade_lock : BladeLock = null

var last_press = 0

func _ready():
	hitbox.on_blade_lock_invite.connect(join_blade_lock)
	if katana_hands:
		animation_tree = katana_hands.get_node("AnimationTree")

func join_blade_lock(blade_lock : BladeLock):
	blade_lock.register_b(stats)
	blade_lock.on_struggle_end.connect(end_blade_lock)
	current_blade_lock = blade_lock
	is_in_blade_lock = true
	
	if animation_tree:
		animation_tree["parameters/playback"].start("blade_lock")
	

func end_blade_lock(winner : Stats):
	is_in_blade_lock = false
	current_blade_lock = null
	
	if animation_tree:
		animation_tree["parameters/playback"].start("idle")
	

func _process(delta):
	if is_in_blade_lock:
		if animation_tree:
			animation_tree.set("parameters/blade_lock/blend_position", current_blade_lock.get_value(stats))
		
		if Time.get_ticks_msec() - last_press >= press_cooldown * 1000:
			current_blade_lock.side_increase(stats, 4)
			last_press = Time.get_ticks_msec()
	
