extends Node3D

@onready var interact_check = $interact_check
@onready var inventory = null : 
	get:
		if inventory == null:
			inventory = PlayerEntity.get_inventory()
			
		if inventory == null:
			print("Got inventory null from player entity! This shouldn't happen!")
		
		return inventory
	
@onready var tool_manager = $"../simple_weapon_manager"
@onready var strength = $"%stats/strength"

@export var carry_start_time = 0.8
@export var carry_distance = 1.5
@export var carry_force = 10.0
@export var throw_force = 10.0
@export var carry_drop_distance = 2.0
@export var carry_angular_damp = 10.0
@export_flags_3d_physics var carry_layer

@export var light_threshold = 1
@export var medium_threshold = 4
@export var heavy_threshold = 8

var start_press_interactive # Interactive we started to press "use" on
var current_interactive # Current interactive we look at
var is_carrying = false
var last_button_press = INF

var old_angular_damp
var old_layer

var released_last_frame = false

# tower_id : { key_color : uses_left } eg:  {Key.key_color.BRASS : 5}  
var key_ring = {}#{1 : {Key.key_color.BRASS : 5}}

signal interactive_changed(new_interactive_text)
signal press_time_update(time)
signal too_heavy(weight)

func _ready():
	add_debug_commands()
	

func _input(event):
	if is_carrying and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		throw_carry_object()
	

func _process(delta):
	if is_carrying:
		update_carry_object(delta)
		
		if Input.is_action_just_pressed("use"):
			released_last_frame = true
			stop_carrying()
	else:
		# Get current interactive object
		if interact_check.is_colliding():
			var collider = interact_check.get_collider()
			if collider is Interactive:
				set_interactive(collider)
			else:
				set_interactive(null)
		else:
			set_interactive(null)
		
		if current_interactive != null:
			if Input.is_action_just_pressed("use"):
				last_button_press = Time.get_ticks_msec()
				start_press_interactive = current_interactive
			
			elif Input.is_action_just_released("use"):
				reset_button_time()
				# Prevent interacting after you just released the carried object
				if released_last_frame:
					released_last_frame = false
				# Make sure we release on the same interactive we started on
				elif current_interactive == start_press_interactive:
					current_interactive.use(self)
					if current_interactive is Pickup:
						set_interactive(null) # Reset in case it's destroyed
			
			if Input.is_action_pressed("use") and current_interactive is Carriable:
				var time = Time.get_ticks_msec() - last_button_press
				press_time_update.emit(time)
				if time >= carry_start_time * 1000:
					if can_carry(current_interactive.weight):
						start_carry()
					else:
						too_heavy.emit(current_interactive.weight)
		else:
			if Input.is_action_just_pressed("use"):
				# Prevents cases where we press on an empty space
				# and move to the same interactive we last pressed on
				start_press_interactive = null
	

func set_interactive(interactive):
	# If new value is null, always continue to handle cases where node was freed
	if current_interactive == interactive:
		return
	
	# Reset button press if we switched interactive
	reset_button_time()
	
	# De-highlight old
	if current_interactive != null:
		current_interactive.highlight_off()
	
	current_interactive = interactive
	
	# Highlight new
	if current_interactive != null:
		current_interactive.highlight_on()
	
	# Update text
	var text = ""
	if current_interactive != null:
		text = current_interactive.get_text()
	
	interactive_changed.emit(text)
	

func reset_button_time():
	last_button_press = INF
	press_time_update.emit(0)
	

func can_carry(weight):
	if weight == Carriable.CarryWeight.LIGHT:
		return strength.get_value() >= light_threshold
	elif weight == Carriable.CarryWeight.MEDIUM:
		return strength.get_value() >= medium_threshold
	elif weight == Carriable.CarryWeight.HEAVY:
		return strength.get_value() >= heavy_threshold
	return false
	

func start_carry():
	reset_button_time()
	is_carrying = true
	
	# Swap rigidbody values
	var object = current_interactive.get_parent()
	if object is RigidBody3D:
		old_angular_damp = object.angular_damp
		old_layer = object.collision_layer
		object.angular_damp = carry_angular_damp
		object.collision_layer = carry_layer
	

func stop_carrying():
	is_carrying = false
	
	# Return old values
	var object = current_interactive.get_parent()
	if object is RigidBody3D:
		object.angular_damp = old_angular_damp
		object.collision_layer = old_layer
		object.linear_velocity = Vector3.ZERO # For some reason unfreezes the object
	

func update_carry_object(_delta):
	if current_interactive == null:
		return
	
	var object = current_interactive.get_parent()
	var carry_point = global_position + global_transform.basis * Vector3.FORWARD * carry_distance
	var direction = carry_point - object.global_position
	
	# Drop object if too far from carry point
	var distance = object.global_position.distance_to(carry_point)
	if  distance > carry_drop_distance:
		stop_carrying()
		return
	
	if object is RigidBody3D:
		object.linear_velocity = direction * carry_force
	else:
		object.global_position = carry_point
	

func throw_carry_object():
	if current_interactive == null:
		return
	
	stop_carrying()
	
	var object = current_interactive.get_parent()
	if object is RigidBody3D:
		object.linear_velocity = global_transform.basis * Vector3.FORWARD * throw_force
	

func add_item(item_id):
	var item = ItemDB.get_item(item_id)
	
	# Handle tools
	if item.slot == "TOOL":
		return add_tool(item)
	
	# Handle items
	if inventory == null:
		return false
	
	return inventory.pickup_item(item_id)
	

func add_tool(tool):
	if tool_manager == null:
		return false
	
	if not tool.has("type") or not tool.type is SimpleWeaponManager.tool_type:
		return false
		
	tool_manager.add_tool(tool.type)
	return true
	

func add_key(tower_id : int, key_color : Key.key_color, uses : int):
	if uses < 1:
		print(name, " :: Tried to add non positive number of uses to a key: ", uses)
		return
	
	if key_ring.has(tower_id):
		if key_ring[tower_id].has(key_color):
			key_ring[tower_id][key_color] += uses
		else:
			key_ring[tower_id][key_color] = uses
	else:
		key_ring[tower_id] = {key_color : uses}
	

func remove_key(tower_id : int, key_color : Key.key_color):
	if key_ring.has(tower_id):
		key_ring[tower_id].erase(key_color)
	

func use_key(tower_id : int, key_color : Key.key_color) -> bool :
	if key_ring.has(tower_id) and key_ring[tower_id].has(key_color):
		key_ring[tower_id][key_color] -= 1
		if key_ring[tower_id][key_color] <= 0:
			remove_key(tower_id, key_color)
		return true
	return false
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"skeletonkey",
		add_all_keys,
		 [],
		"Adds all keys directly to your inventory"
		)
	

func add_all_keys(args):
	var max_int = 9223372036854775807
	for i in range(10):
		add_key(i, Key.key_color.BRASS, max_int)
		add_key(i, Key.key_color.SILVER, max_int)
		add_key(i, Key.key_color.GOLD, max_int)
	
