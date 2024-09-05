extends Control

var circles = []

func add_circle(radius: float, sides: int, width: float, color: Color, outline: Color = Color.TRANSPARENT):
	circles.append({
		"radius": radius, 
		"sides": sides, 
		"width": width,
		"color": color,
		"outline": outline })
	

func _draw():
	for circle in circles:
		draw_outline_circle(circle["radius"], circle["sides"], circle["width"], circle["color"])
		if circle["color"] != Color.TRANSPARENT:
			draw_outline_circle(circle["radius"] + circle["width"], circle["sides"], 1.0, circle["outline"])
			draw_outline_circle(circle["radius"] - circle["width"], circle["sides"], 1.0, circle["outline"])
	

func draw_outline_circle(radius: float, sides: int, width: float, color: Color):
	var _radius = Vector2.UP * radius
	var line_origin = _radius
	
	for i in range(sides):
		var line_end = _radius.rotated(deg_to_rad(360.0 / sides * i))
		draw_line(line_origin, line_end, color, width)
		line_origin = line_end
	
	draw_line(line_origin, _radius, color, width)
	
