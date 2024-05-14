extends Node3D

@onready var hitbox = $"../katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/hitbox"

@onready var anim_tree : AnimationTree = $"../katana_pov_hands/AnimationTree"
@onready var anim_state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

@export var attack_info = AttackInfo.new(5, 10, DamageType.SLASH, true, Vector3.FORWARD * 10)
@export var fire_cooldown = 1.0
var last_attack = 0
var prev_animation

func _ready():
	hitbox.on_collision.connect(hit)
	hitbox.on_block.connect(hit_blocked)
	

func _process(delta):
	if Time.get_ticks_msec() - last_attack > fire_cooldown * 1000:
		animate_attack()
		last_attack = Time.get_ticks_msec()
	
	animation_change_check()
	

func animate_attack():
	anim_state_machine.start("heavy_1")
	

func hit(area, hitbox):
	if area is Hurtbox:
		area.hit(attack_info.get_translated(global_basis))
	

func hit_blocked(area : Guardbox, hitbox):
	area.guard(attack_info.get_translated(global_basis), hitbox)
	anim_state_machine.start("idle")
	

func animation_change_check():
	var current_animation = anim_state_machine.get_current_node()
	if current_animation != prev_animation:
		animation_changed(current_animation)
	prev_animation = current_animation
	

func animation_changed(new_name):
	if new_name == "idle":
		hitbox.set_active(false)
	elif new_name in ["light_1", "light_2", "light_3", "heavy_1", "heavy_3", 
	"iaido_light_1", "iaido_light_2", "iaido_light_3", "iaido_light_4"]:
		hitbox.set_active(true)
	
