extends Node
class_name SimpleWeaponManager

@onready var stats = %stats

@onready var tools = [$pocket_mirror, $rope]
var index = 0

@onready var current_template = null

signal on_index_changed(index)

func _process(delta):
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if Input.is_action_just_pressed("scroll_up"):
		switch_to(index + 1, false)
	elif Input.is_action_just_pressed("scroll_down"):
		switch_to(index - 1, false)
	else:
		var hotkey = InputUtils.get_hotkeys_input()
		if hotkey != null and hotkey > 0 and hotkey <= tools.size():
			switch_to(hotkey - 1)
	

func switch_to(new_index, activate_slot = true):
	if new_index < 0:
		new_index += tools.size()
	elif new_index > tools.size() - 1:
		new_index -= tools.size()
	
	# Activate corresponding template
	activate_template(tools[new_index])
	
	index = new_index
	on_index_changed.emit(index)
	

func activate_template(template):
	if current_template == template:
		return
	
	if current_template != null:
		deactivate_template(current_template)
	
	template.visible = true
	current_template = template
	

func deactivate_template(template):
	template.visible = false
	
