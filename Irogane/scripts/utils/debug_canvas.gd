extends Control

var lines = []
var points = []
var texts = []

var default_font = ThemeDB.fallback_font
var default_font_size = ThemeDB.fallback_font_size

func _ready():
	add_debug_commands()
	

func _process(delta):
	queue_redraw()
	

func _draw():
	var camera = CameraEntity.active_camera
	
	for line in lines:
		# Don't draw if behind camera
		if camera.is_position_behind(line["from"]) or camera.is_position_behind(line["to"]):
			continue
		
		var start = camera.unproject_position(line["from"])
		var end = camera.unproject_position(line["to"])
		var color = line["color"]
		var width = line["width"]
		
		draw_line(start, end, color, width)
		draw_triangle(end, start.direction_to(end), width * 4, color)
	
	for point in points:
		# Don't draw if behind camera
		if camera.is_position_behind(point["position"]):
			continue
			
		var position = camera.unproject_position(point["position"])
		var color = point["color"]
		var radius = point["radius"]
		
		draw_circle(position, radius, color)
		
	for text in texts:
		# Don't draw if behind camera
		if camera.is_position_behind(text["position"]):
			continue
		
		var position = camera.unproject_position(text["position"])
		var string = text["string"]
		var color = text["color"]
		
		draw_string(default_font, position, string, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, color)
	

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PackedVector2Array([a, b, c])
	draw_polygon(points, PackedColorArray([color]))
	

func debug_line(from, to, color = Color.GREEN, width = 3, duration = 0.1):
	var line = {
		"from" : from,
		"to" : to,
		"width" : width,
		"color" : color}
	
	lines.append(line)
	
	await get_tree().create_timer(duration).timeout
	
	lines.erase(line)
	

func debug_point(position, color = Color.GREEN, radius = 7, duration = 0.1):
	var point = {
		"position" : position,
		"radius" : radius,
		"color" : color}
	
	points.append(point)
	
	await get_tree().create_timer(duration).timeout
	
	points.erase(point)
	

func debug_text(string, position, color = Color.RED, duration = 0.1):
	var text = {
		"string" : string,
		"position" : position,
		"color" : color}
	
	texts.append(text)
	
	await get_tree().create_timer(duration).timeout
	
	texts.erase(text)
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"display_debug_canvas", 
		display_debug_canvas, 
		[{	"arg_name" : "1/0",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "1: True, 0: False"}])
	

func display_debug_canvas(args: Array):
	visible = bool(args[0])
	
