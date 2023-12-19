extends TextureProgressBar

@onready var interaction = PlayerEntity.player_node.get_node("head/main_camera/interaction")
@onready var max_time = interaction.carry_start_time * 1000

var visible_threshold_ms = 200

func _ready():
	interaction.press_time_update.connect(update_bar)

func update_bar(time):
	# time is in ms
	var v = (time - visible_threshold_ms) / (max_time - visible_threshold_ms)
	value = v * 100
