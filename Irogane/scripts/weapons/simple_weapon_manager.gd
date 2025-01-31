extends Node
class_name SimpleWeaponManager

@onready var stats = %stats

@onready var tools = [null, null, null, null, null, null, null, null] 	# Used for hotkeys
var existing_indexes = [0] # Used for scrolling through the tools we have

enum tool_type {
	EMPTY,
	SLINGSHOT,
	GRAPPLE,
	LOCKPICK,
	TELESCOPE,
	COIN,
	PRAYER_BEADS,
	CANDLE
}

@onready var tool_dict = {
	tool_type.EMPTY : null,
	tool_type.SLINGSHOT : $slingshot,
	tool_type.GRAPPLE : $grapple,
	tool_type.LOCKPICK : $lockpick,
	tool_type.TELESCOPE : $telescope,
	tool_type.COIN : $coin,
	tool_type.PRAYER_BEADS : $prayer_beads,
	tool_type.CANDLE : $candle
}

var index = 0
var scroll_index = 0

@onready var current_template = null

signal on_index_changed(index : int, exist : bool)

func _ready():
	DebugCommandsManager.add_command(
		"add_tool",
		add_tool_debug,
		 [{
				"arg_name" : "tool_index",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : tool_type.keys()
			}],
		"Adds tool to the player"
		)
	

func _process(_delta):
	if not InputContextManager.is_current_context(InputContextType.GAME):
		return
	
	if Input.is_action_pressed("attack_secondary"):
		return
	
	if Input.is_action_just_pressed("scroll_up"):
		scroll_to(scroll_index + 1)
	elif Input.is_action_just_pressed("scroll_down"):
		scroll_to(scroll_index - 1)
	else:
		var hotkey = InputUtils.get_hotkeys_input()
		if hotkey != null and hotkey > 0 and hotkey <= tools.size():
			switch_to(hotkey - 1)
	

func scroll_to(new_index):
	if existing_indexes.size() == 0:
		return
	
	if new_index < 0:
		new_index += existing_indexes.size()
	elif new_index > existing_indexes.size() - 1:
		new_index -= existing_indexes.size()
	
	scroll_index = new_index
	
	switch_to(existing_indexes[new_index])
	

func switch_to(new_index, activate_slot = true):
	if new_index < 0:
		new_index += tools.size()
	elif new_index > tools.size() - 1:
		new_index -= tools.size()
	
	# Activate corresponding template
	var exist = tools[new_index] != null
	activate_template(tools[new_index])
	
	index = new_index
	var found = existing_indexes.find(index)
	if found >= 0:
		scroll_index = found
	
	on_index_changed.emit(index, exist)
	

func activate_template(template):
	if current_template == template:
		return
	
	deactivate_template(current_template)
	
	if template != null:
		template.visible = true
	
	current_template = template
	

func deactivate_template(template):
	if current_template != null:
		template.visible = false
	

func add_tool_debug(args : Array):
	var index = args[0]
	var size = tool_type.keys().size()
	
	if index >= size or index < 0:
		return "Index provided is outside of the legal range: 0.." + str(size - 1)
	
	add_tool(index)
	

func add_tool(type : tool_type):
	if not tool_dict.has(type):
		return
	
	var index = int(type) # Use enum order
	tools[index] = tool_dict[type]
	existing_indexes.append(index)
	existing_indexes.sort()
	switch_to(index)
	

func remove_tool(type : tool_type):
	if not tool_dict.has(type):
		return
	
	var index = int(type) # Use enum order
	tools[index] = null
	existing_indexes.remove(index)
	existing_indexes.sort()
	
	if self.index == index:
		switch_to(0)
	
