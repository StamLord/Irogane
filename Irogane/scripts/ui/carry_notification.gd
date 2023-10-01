extends Label

@export var message_duration = 2.0
@onready var interaction = $"/root/world/player/head/main_camera/interaction"

var base_color
var is_showing = false

func _ready():
	base_color = get_theme_color("font_color")
	interaction.too_heavy.connect(show_message)

func show_message(weight):
	if is_showing:
		return
	
	is_showing = true
	var startTime = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - startTime <= message_duration * 1000:
		var t = (Time.get_ticks_msec() - startTime) / (message_duration * 1000)
		var color = lerp(Color(base_color.r, base_color.g, base_color.b, 1), base_color, t)
		add_theme_color_override("font_color", color)
		await get_tree().create_timer(0).timeout
	
	add_theme_color_override("font_color", base_color)
	is_showing = false
