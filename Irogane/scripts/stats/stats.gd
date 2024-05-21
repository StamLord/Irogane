extends Node
class_name Stats

@export var char_name : String

@export_range(1,20) var level : int
@export var experience : int

@export var max_level = 20

@onready var health : Depletable = $health
@onready var stamina : Depletable = $stamina

@export var hurtboxes : Array[Hurtbox]
@onready var guardboxes : Array[Guardbox] 
#= $"../head/main_camera/weapon_manager/sword/katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/guard_hitbox"

@export var attr_points = 10

@onready var strength = $strength
@onready var agility = $agility
@onready var dexterity = $dexterity
@onready var wisdom = $wisdom

var statuses = {} # status_name : { start_time : timestamp, last_update: timestamp }

signal on_status_added(status_name)
signal on_status_removed(status_name)

var boons = []
var flaws = []

var in_battle = false
signal started_battle()
signal ended_battle()

var last_medicine = null
signal on_medicine_used(medicine)
signal on_hit(attack_info)
signal on_heavy_hit(force : Vector3)
signal on_health_depleted(amount)
signal on_death()

var is_guard_broken : bool = false

var is_staggered : bool = false
var stagger_timer = Timer.new()

func _ready():
	if get_owner().name == "player":
		add_debug_commands()
	
	for h in hurtboxes:
		h.on_hit.connect(hit)
	
	var weapons_parent = get_node("../head/main_camera/weapon_manager")
	if weapons_parent != null:
		get_all_guardboxes(weapons_parent)
	
	for g in guardboxes:
		g.on_guard.connect(guard)
	
	add_child(stagger_timer)
	stagger_timer.one_shot = true
	stagger_timer.timeout.connect(end_stagger)
	

func get_all_guardboxes(node : Node):
	for n in node.get_children():
		if n is Guardbox:
			guardboxes.append(n)
		get_all_guardboxes(n)
	

func _process(delta):
	update_statuses()
	

func hit(attack_info : AttackInfo):
	deplete_health(attack_info.soft_damage)
	add_statuses(attack_info.statuses)
	
	if attack_info.is_heavy:
		on_heavy_hit.emit(attack_info.force)
	
	on_hit.emit(attack_info)
	
	if attack_info.soft_damage >= 40:
		start_stagger(0.2)
	else:
		start_stagger(0.4)
	

func guard(attack_info : AttackInfo, hitbox):
	if attack_info.is_heavy:
		on_heavy_hit.emit(attack_info.force)
	

func deplete_health(amount : int):
	if health:
		on_health_depleted.emit(amount)
		if health.get_value() < 1:
			die()
		return health.deplete(amount)
	return false
	

func die():
	on_death.emit()
	

func replenish_health(amount: int):
	if health:
		return health.replenish(amount)
	return false
	

func deplete_stamina(amount : int):
	if stamina:
		return stamina.deplete(amount)
	return false
	

func replenish_stamina(amount: int):
	if stamina:
		return stamina.replenish(amount)
	return false
	

func add_statuses(new_statuses):
	for s in new_statuses:
		add_status(s)
	

func add_status(new_status_name) -> bool:
	if validate_status(new_status_name):
		var new_status = StatusDb.get_status(new_status_name)
		if new_status == null:
			return false
		
		for status_name in new_status.cures:
			remove_status(status_name)
		
		if statuses.has(new_status_name):
			statuses[new_status_name]["start_time"] = Time.get_ticks_msec()
		else:
			statuses[new_status_name] = {
				"start_time" : Time.get_ticks_msec(),
				"last_update" : Time.get_ticks_msec() - 1000 # We want the status update to trigger immediately
				}
		on_status_added.emit(new_status_name)
		return true
	
	return false
	

func validate_status(new_status):
	for s in statuses:
		var status : Status = StatusDb.get_status(s)
		if status and new_status in status.prevents:
			return false
	return true
	

func remove_status(status_name) -> bool:
	if statuses.erase(status_name):
		on_status_removed.emit(status_name)
		return true
	
	return false
	

func update_statuses():
	for status_name in statuses:
		var status = StatusDb.get_status(status_name)
		if status == null:
			continue
		
		if Time.get_ticks_msec() - statuses[status_name]["last_update"] >= 1000:
			deplete_health(status.health_per_sec)
			deplete_stamina(status.stamina_per_sec)
			statuses[status_name]["last_update"] = Time.get_ticks_msec()
		
		if Time.get_ticks_msec() - statuses[status_name]["start_time"] >= status.duration_in_sec * 1000:
			remove_status(status_name)
	

func add_boon(boon_name):
	return add_boon_or_flaw(boon_name, boons)
	

func remove_boon(boon_name):
	return remove_boon_or_flaw(boon_name, boons)
	

func add_flaw(flaw_name):
	return add_boon_or_flaw(flaw_name, flaws)
	

func remove_flaw(flaw_name):
	return remove_boon_or_flaw(flaw_name, flaws)
	

func add_boon_or_flaw(quality_name, quality_array):
	if quality_array.has(quality_name):
		return false
	
	quality_array.append(quality_name)
	
	var quality = QualityDb.get_quality(quality_name)
	if quality != null:
		for effect in quality.effects:
			var signal_name = effect.signal_name
			
			if not signal_name:
				continue
			
			var node = get_node_from_effect(effect)
			
			# Subscribe to signal
			if node != null:
				node.connect(signal_name, update_quality.bind(quality))
		
		update_quality(quality)
	
	return true
	

func remove_boon_or_flaw(quality_name, quality_array):
	if not quality_array.has(quality_name):
		return false
	
	quality_array.erase(quality_name)
	
	var quality = QualityDb.get_quality(quality_name)
	if quality != null:
		remove_quality(quality)
	
	return true
	

# Updates the quality to either add or remove the modifiers based on hooks
func update_quality(quality : Quality):
	for effect in quality.effects:
		var attribute_name = effect.attribute_name
		var modifier = effect.modifier
		var flag_name = effect.flag_name
		
		# No modifier or attribute
		if modifier == null or attribute_name == null:
			continue
		
		# No such attribute
		if not attribute_name in self or not self[attribute_name] is Attribute:
			continue
		
		var node = get_node_from_effect(effect)
		if node == null:
			continue
		
		# No flag or valid flag
		if not flag_name or validate_flag(node, flag_name):
			self[attribute_name].add_modifier(modifier)
		else:
			self[attribute_name].remove_modifier(modifier)
	

# Removes the modifiers of this quality. Use only when removing a boon/flaw!
# Use update_quality if you need to add/remove modifiers based on the hook!
func remove_quality(quality : Quality):
	for effect in quality.effects:
		var attribute_name = effect.attribute_name
		var modifier = effect.modifier
		var signal_name = effect.signal_name
		
		if signal_name:
			# Unregister from signal
			var node = get_node_from_effect(effect)
			if node != null and node.is_connected(signal_name, update_quality):
				node[signal_name].disconnect(update_quality)
		
		if modifier == null or attribute_name == null:
			continue
		
		# No such attribute
		if not attribute_name in self or not self[attribute_name] is Attribute:
			continue
		
		self[attribute_name].remove_modifier(modifier)
	

func validate_flag(node, flag_name):
	if not flag_name in node:
		return false
	
	return node[flag_name]
	

func start_battle():
	started_battle.emit()
	

func exit_battle():
	ended_battle.emit()
	

func use_medicine(medicine):
	if medicine.has("hp_restore"):
		replenish_health(medicine.hp_restore)
	if medicine.has("st_restore"):
		replenish_stamina(medicine.st_restore)
	
	last_medicine = Time.get_ticks_msec()
	on_medicine_used.emit(medicine)
	return true
	

func start_guard_break(duration):
	is_guard_broken = true
	start_stagger(duration)
	await get_tree().create_timer(duration).timeout
	is_guard_broken = false
	

func start_stagger(duration):
	is_staggered = true
	stagger_timer.start(duration)
	

func end_stagger():
	is_staggered = false
	

func got_perfect_blocked():
	start_stagger(1.0)
	

func save_data():
	var data = {
		"name" : char_name,
		"level" : level,
		"experience" : experience,
		"health" : health.save_data(),
		"stamina" : stamina.save_data(),
		"attr_points" : attr_points,
		"strength" : strength.save_data(),
		"agility" : agility.save_data(),
		"dexterity" : dexterity.save_data(),
		"wisdom" : wisdom.save_data(),
		"boons" : boons,
		"flaws" : flaws,
	}
	
	return data
	

func load_data(data):
	char_name = data["name"]
	level = data["level"] if "level" in data else 1
	experience = data["experience"] if "experience" in data else 0
	
	health.load_data(data["health"]) if "health" in data else 50
	stamina.load_data(data["stamina"]) if "stamina" in data else 50
	
	attr_points = data["attr_points"]
	
	strength.load_data(data["strength"])
	agility.load_data(data["agility"])
	dexterity.load_data(data["dexterity"])
	wisdom.load_data(data["wisdom"])
	
	boons = data["boons"]
	flaws = data["flaws"]
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"set_attr",
		set_attribute,
		 [{
				"arg_name" : "attribute",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Attribute name"
			},
			{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : "Attribute value"
		}],
		"Set attribute to a new value within the valid range"
		)
	
	DebugCommandsManager.add_command(
		"set_hp",
		set_health,
		[{
			"arg_name" : "value",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "New value"
		}],
		"Sets health to a new value"
		)
		
	DebugCommandsManager.add_command(
		"set_st",
		set_stamina,
		[{
			"arg_name" : "value",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "New value"
		}],
		"Sets stamina to a new value"
		)
	
	DebugCommandsManager.add_command(
		"add_boon",
		add_boon,
		[{
			"arg_name" : "name",
			"arg_type" : DebugCommandsManager.ArgumentType.STRING,
			"arg_desc" : "Boon name"
		}],
		"Adds a boon"
		)
	
	DebugCommandsManager.add_command(
		"remove_boon",
		remove_boon,
		[{
			"arg_name" : "name",
			"arg_type" : DebugCommandsManager.ArgumentType.STRING,
			"arg_desc" : "Boon name"
		}],
		"Removes a boon"
		)
	
	DebugCommandsManager.add_command(
		"add_flaw",
		add_flaw,
		[{
			"arg_name" : "name",
			"arg_type" : DebugCommandsManager.ArgumentType.STRING,
			"arg_desc" : "Flaw name"
		}],
		"Adds a flaw"
		)
	
	DebugCommandsManager.add_command(
		"remove_flaw",
		remove_flaw,
		[{
			"arg_name" : "name",
			"arg_type" : DebugCommandsManager.ArgumentType.STRING,
			"arg_desc" : "Flaw name"
		}],
		"Removes a flaw"
		)
	
	DebugCommandsManager.add_command(
		"godmode",
		set_godmode,
		[{
			"arg_name" : "1/0",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "1: True, 0: False"
		}],
		"Sets godmode on or off"
		)
	
	DebugCommandsManager.add_command(
		"add_status",
		add_statuses,
		 [{
				"arg_name" : "status",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Status name"
			}],
		"Adds a status"
		)
	
	DebugCommandsManager.add_command(
		"remove_status",
		remove_status,
		 [{
				"arg_name" : "status",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Status name"
			}],
		"Removes a status"
		)
	

# args = [attribute name : String, value : Int]
func set_attribute(args : Array):
	if args[0] not in self:
		return "Invalid attribute name. Try again dumbass."
	
	self[args[0]].set_value(args[1])
	

func set_health(args : Array):
	health.set_value(args[0])
	

func set_stamina(args : Array):
	stamina.set_value(args[0])
	

func set_godmode(args: Array):
	health.set_godmode(args[0])
	stamina.set_godmode(args[0])
	

func get_node_from_effect(effect : Effect):
	var signal_path = effect.signal_path
	
	if signal_path == "":
		signal_path = "." # Self or root depenending on is_signal_path_local
	
	return get_node(signal_path) if effect.is_signal_path_local else get_tree().root.get_node(signal_path)
	
