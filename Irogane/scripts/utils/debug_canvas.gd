extends Control

var lines = []
var points = []
var texts = []

var default_font = ThemeDB.fallback_font
var default_font_size = ThemeDB.fallback_font_size

func _ready():
	add_debug_commands()
	

func _process(_delta):
	queue_redraw()
	

func _draw():
	var camera = CameraEntity.active_camera
	
	# If camera was freed due to scene loading
	if not is_instance_valid(camera):
		return
	
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
			
		var pos = camera.unproject_position(point["position"])
		var color = point["color"]
		var radius = point["radius"]
		
		draw_circle(pos, radius, color)
		
	for text in texts:
		# Don't draw if behind camera
		if camera.is_position_behind(text["position"]):
			continue
		
		var pos = camera.unproject_position(text["position"])
		var string = text["string"]
		var color = text["color"]
		
		draw_string(default_font, pos, string, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, color)
	

func draw_triangle(pos, dir, triangle_size, color):
	var a = pos + dir * triangle_size
	var b = pos + dir.rotated(2*PI/3) * triangle_size
	var c = pos + dir.rotated(4*PI/3) * triangle_size
	var triangle_points = PackedVector2Array([a, b, c])
	draw_polygon(triangle_points, PackedColorArray([color]))
	

func debug_line(from, to, color = Color.GREEN, width = 3, duration = 0.1):
	var line = {
		"from" : from,
		"to" : to,
		"width" : width,
		"color" : color}
	
	lines.append(line)
	
	await get_tree().create_timer(duration).timeout
	
	lines.erase(line)
	

func debug_point(_position, color = Color.GREEN, radius = 7, duration = 0.1):
	var point = {
		"position" : _position,
		"radius" : radius,
		"color" : color}
	
	points.append(point)
	
	await get_tree().create_timer(duration).timeout
	
	points.erase(point)
	

func debug_basis(_position, _basis, duration = 0.1):
	DebugCanvas.debug_line(_position, _position + _basis.x, Color.RED, 3, duration)
	DebugCanvas.debug_line(_position, _position + _basis.y, Color.GREEN_YELLOW, 3, duration)
	DebugCanvas.debug_line(_position, _position + _basis.z, Color.BLUE, 3, duration)
	

func debug_text(string, _position, color = Color.RED, duration = 0.1):
	var text = {
		"string" : string,
		"position" : _position,
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
	
