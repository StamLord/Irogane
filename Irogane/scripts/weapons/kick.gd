extends WeaponBase

@onready var kick_hitbox = $Hitbox
@onready var hit_vfx = $hit_vfx
@onready var audio = $audio
@onready var hit_sounds = [
	preload ("res://assets/audio/melee/hit07.mp3"), 
	preload ("res://assets/audio/melee/hit08.mp3"), 
	preload ("res://assets/audio/melee/hit09.mp3"), 
	preload ("res://assets/audio/melee/hit16.mp3")]

var kick_attack_info = AttackInfo.new(4, 8, DamageType.BLUNT, true, Vector3.FORWARD * 7)

func _ready():
	kick_hitbox.on_collision.connect(hit)
	kick_hitbox.on_block.connect(hit_blocked)
	kick_hitbox.add_ignore(owner)
	

func _process(delta):
	if Input.is_action_just_pressed("kick") and not kick_hitbox.is_active():
		activate_hitbox()
	

func activate_hitbox():
	kick_hitbox.set_active(true)
	await get_tree().create_timer(0.1).timeout
	kick_hitbox.set_active(false)
	

func hit(area, hitbox):
	if area is Hurtbox:
		area.hit(kick_attack_info.get_translated(global_basis))
		audio.play(hit_sounds.pick_random(), hitbox.global_position)
	
	CameraShaker.shake(0.25, 0.2)
	
	hit_vfx.global_position = hitbox.global_position + Vector3.FORWARD * 0.5 + Vector3.UP * 0.5
	hit_vfx.emit_particle(hit_vfx.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	

func hit_blocked(area : Guardbox, hitbox):
	if area.is_perfect:
		CameraShaker.shake(0.5, 0.2)
	else:
		CameraShaker.shake(0.25, 0.2)
	
	area.guard(kick_attack_info.get_translated(global_basis), hitbox)
	
	hit_vfx.global_position = hitbox.global_position + Vector3.FORWARD * 0.5 + Vector3.UP * 0.5
	hit_vfx.emit_particle(hit_vfx.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	
