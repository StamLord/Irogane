extends Label

var interaction_node = null

func _ready():
	if PlayerEntity.player_node != null:
		interaction_node = PlayerEntity.player_node.get_node("%interaction")
	

func _process(delta):
	if not interaction_node:
		return
	
	var current = interaction_node.current_interactive
	if not current:
		text = ""
		return
	
	var parent = current.get_parent()
	text = "[ parent: " + str(parent.name) + " ]\n[ " + str(interaction_node.current_interactive) + " ]"
	
