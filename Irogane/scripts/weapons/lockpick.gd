extends Node3D

@onready var raycast = $raycast

var minigame = null

func _ready():
	var game_ui = UIManager.ui_node
	
	# In testing this should work if game_ui.tscn is not instantiated by UIManager
	if game_ui == null:
		game_ui = owner.get_node("../game_ui")
	
	if game_ui != null:
		minigame = game_ui.get_node("LockpickingMinigame/outer_gear")
	

func _process(delta):
	if not visible:
		return
	
	if minigame.is_visible_in_tree():
		if Input.is_action_just_released("attack_primary"):
			quit_minigame()
	else:
		if raycast.is_colliding() and Input.is_action_just_pressed("attack_primary"):
			var collider = raycast.get_collider()
			if collider is Lock and not collider.is_unlocked:
				start_minigame(raycast.get_collider())
	

func start_minigame(lock_object):
	if minigame != null:
		minigame.start_minigame()
		minigame.success.connect(success.bind(lock_object))
	

func quit_minigame():
	if minigame != null:
		minigame.end_minigame()
		minigame.success.disconnect(success)
	

func success(lock_object):
	if lock_object is Lock:
		lock_object.unlock()
	
	quit_minigame()
	
