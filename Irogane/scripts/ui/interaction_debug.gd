extends Label

var interaction_node = null

func _ready():
	DebugCommandsManager.add_command(
		"display_interaction_debug",
		set_debug_visible,
		 [{
				"arg_name" : "visible",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : "1/0 to show/hide interaction debug"
			}],
			"Show/hide interaction debug")
		
	if PlayerEntity.player_node != null:
		interaction_node = PlayerEntity.player_node.get_node("%interaction")
	

func _process(delta):
	if not visible or not interaction_node:
		return
	
	var current = interaction_node.current_interactive
	if not current:
		text = ""
		return
	
	var parent = current.get_parent()
	text = "[ parent: " + str(parent.name) + " ]\n[ " + str(interaction_node.current_interactive) + " ]"
	

func set_debug_visible(args: Array):
	visible = bool(args[0])
	
