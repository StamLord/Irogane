extends Control

var circles = []

func add_circle(radius: float, sides: int, width: float):
	circles.append({"radius": radius, "sides": sides, "width": width})
	

func _draw():
	for circle in circles:
		draw_outline_circle(circle["radius"], circle["sides"], circle["width"])
	

func draw_outline_circle(radius: float, sides: int, width: float):
	var color = Color.DARK_RED
	var _radius = Vector2.UP * radius
	var line_origin = _radius
	
	for i in range(sides):
		var line_end = _radius.rotated(deg_to_rad(360.0 / sides * i))
		draw_line(line_origin, line_end, color, width)
		line_origin = line_end
	
	draw_line(line_origin, _radius, color, width)
	
