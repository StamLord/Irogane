extends Node
class_name WeaponManager

@onready var quick_slots = null:
	get:
		if quick_slots == null:
			quick_slots = PlayerEntity.get_quick_slots()
		
		if quick_slots == null:
			print("Got quick_slots null from player entity! This shouldn't happen!")
		return quick_slots
	
@onready var stats = %stats

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

@onready var template_dict = {
	"SWORD" : sword,
	"THROWABLE" : shuriken,
	}

func _ready():
	PlayerEntity.slot_changed.connect(on_slot_changed)
	

func _process(_delta):
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if Input.is_action_just_pressed("scroll_up"):
		switch_to(index + 1, false)
	elif Input.is_action_just_pressed("scroll_down"):
		switch_to(index - 1, false)
	else:
		var hotkey = InputUtils.get_hotkeys_input()
		if hotkey != null and hotkey > 0 and hotkey <= quick_slots.slots.size():
			switch_to(hotkey - 1)
	

func switch_to(new_index, activate_slot = true):
	if new_index < 0:
		new_index += 10
	elif new_index > 9:
		new_index -= 10
	
	# Fallback to melee if item is null or has no id
	var item = quick_slots.get_item_in_slot(new_index)
	if item == null or item.get_meta("id") == "":
		activate_template(melee)
		return
	
	# Fallback if item doesn't exist or has no type
	var item_data = ItemDB.get_item(item.get_meta("id"))
	if item_data == null or not item_data.has("type"):
		activate_template(melee)
		return
	
	# If item is MEDICINE, activate it without switching to it
	if item_data.type == "MEDICINE":
		if activate_slot:
			var used = stats.use_medicine(item_data)
			if used:
				quick_slots.remove_item_at_index(new_index)
		return
	
	# Activate corresponding template
	activate_template(template_dict[item_data.type])
	
	index = new_index
	

func activate_template(template):
	if current_template == template:
		return
	
	if current_template != null:
		deactivate_template(current_template)
	
	template.visible = true
	current_template = template
	

func deactivate_template(template):
	template.visible = false
	

func on_slot_changed(slot_index):
	if index == slot_index:
		switch_to(slot_index, false)
	
