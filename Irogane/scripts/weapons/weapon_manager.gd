extends Node
class_name WeaponManager

@onready var quick_slots = null:
	get:
		if quick_slots == null:
			quick_slots = PlayerEntity.get_quick_slots()
		
		if quick_slots == null:
			print("Got quick_slots null from player entity! This shouldn't happen!")
		return quick_slots
	

@onready var ring_menu = %ring_menu

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
	if Input.is_action_just_pressed("scroll_up"):
		switch_to(index + 1)
	elif Input.is_action_just_pressed("scroll_down"):
		switch_to(index - 1)
	elif Input.is_action_just_pressed("alpha1"):
		switch_to(0)
	elif Input.is_action_just_pressed("alpha2"):
		switch_to(1)
	elif Input.is_action_just_pressed("alpha3"):
		switch_to(2)
	elif Input.is_action_just_pressed("alpha4"):
		switch_to(3)
	elif Input.is_action_just_pressed("alpha5"):
		switch_to(4)
	elif Input.is_action_just_pressed("alpha6"):
		switch_to(5)
	elif Input.is_action_just_pressed("alpha7"):
		switch_to(6)
	elif Input.is_action_just_pressed("alpha8"):
		switch_to(7)
	elif Input.is_action_just_pressed("alpha9"):
		switch_to(8)
	elif Input.is_action_just_pressed("alpha0"):
		switch_to(9)
	

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
		ring_menu.disabled = true
		var skills: Array[String] = ["Shuriken", "Jump", "Stance", "Kobey", "Tim Cain"]
		ring_menu.initialize_items(skills)
	

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
	ring_menu.disabled = true
	

func on_slot_changed(slot_index):
	if index == slot_index:
		switch_to(slot_index)
	
