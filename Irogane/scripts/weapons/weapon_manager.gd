extends Node
class_name WeaponManager

@onready var quick_slots = null:
	get:
		if quick_slots == null:
			quick_slots = PlayerEntity.get_quick_slots()
		
		if quick_slots == null:
			print("Got quick_slots null from player entity! This shouldn't happen!")
		return quick_slots
	

@onready var melee = $melee
@onready var sword = $sword
@onready var shuriken = $shuriken
@export var staff : Node3D
@export var kanabo : Node3D
@export var bow : Node3D
@export var bomb : Node3D
@export var grappling_hook : Node3D

var index = 0
@onready var current_template = null

func _ready():
	PlayerEntity.slot_changed.connect(on_slot_changed)
	

func _process(delta):
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if Input.is_action_just_pressed("scroll_up"):
		switch_to(index + 1)
	elif Input.is_action_just_pressed("scroll_down"):
		switch_to(index - 1)
	else:
		var hotkey = InputUtils.get_hotkeys_input()
		if hotkey != null and hotkey > 0 and hotkey <= quick_slots.slots.size():
			switch_to(hotkey - 1)
	

func switch_to(new_index):
	if new_index < 0:
		new_index += 10
	elif new_index > 9:
		new_index -= 10
	
	index = new_index
	
	var item = quick_slots.get_item_in_slot(index)
	
	if item == null or item.get_meta("id") == "":
		activate_template(melee)
	elif item.get_meta("id")  == "katana":
		activate_template(sword)
	elif item.get_meta("id") == "shuriken":
		activate_template(shuriken)
	

func activate_template(template):
	if current_template == template:
		print("Same Template")
		return
	
	if current_template != null:
		deactivate_template(current_template)
	
	print("Activating: " + str(template))
	template.visible = true
	current_template = template
	

func deactivate_template(template):
	template.visible = false
	

func on_slot_changed(slot_index):
	if index == slot_index:
		switch_to(slot_index)
	
