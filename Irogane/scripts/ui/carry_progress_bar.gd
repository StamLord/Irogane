extends TextureProgressBar

@export var path_on_player = "%interaction"
@export var signal_name = "press_time_update"
@export var max_time_var_name = "carry_start_time"

var context = null
var max_time = null

var visible_threshold_ms = 200

func _ready():
	if PlayerEntity.player_node != null:
		subscribe_to_player(PlayerEntity.player_node)
	
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	

func subscribe_to_player(player_node):
	context = PlayerEntity.player_node.get_node(path_on_player)
	if context != null:
		max_time = context[max_time_var_name] * 1000
		context[signal_name].connect(update_bar)
	

func update_bar(time):
	# time is in ms
	var v = (time - visible_threshold_ms) / (max_time - visible_threshold_ms)
	value = v * 100
	
