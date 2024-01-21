@tool
extends Button

@onready var lines = get_children()

@export var required_node_paths = []
enum line_origin_enum {TOP, BOTTOM, LEFT, RIGHT}
@export var line_origin = line_origin_enum.LEFT

var required_nodes = []

func _enter_tree() -> void:
	set_notify_transform(true)
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_all_lines()
	

func _ready():
	for path in required_node_paths:
		required_nodes.append(get_node(path))
	

func update_all_lines():
	for i in range(lines.size()):
		update_line(required_nodes[i], lines[i])
	

func update_line(node, line):
	if not node is Control or line == null:
		return
	
	var global_delta = node.global_position - global_position
	
	# Left edge of this node
	var start_pos = get_start_pos()
	# Right edge of other node
	var end_pos = Vector2(global_delta.x + node.size.x, global_delta.y + node.size.y * 0.5)
	
	# Set points
	line.clear_points()
	line.add_point(start_pos)
	line.add_point(end_pos)
	
	# Diagonal lines are not allowed
	if global_delta.y != 0:
		# Create 2 points in the center
		if line_origin == line_origin_enum.LEFT or line_origin == line_origin_enum.RIGHT:
			var mid_point = lerp(start_pos, end_pos, 0.5)
			line.add_point(Vector2(mid_point.x, start_pos.y), 1)
			line.add_point(Vector2(mid_point.x, end_pos.y), 2)
		# Create 1 point above / below
		elif line_origin == line_origin_enum.TOP or line_origin == line_origin_enum.BOTTOM:
			line.add_point(Vector2(start_pos.x, end_pos.y), 1)
	

func get_start_pos():
	if line_origin == line_origin_enum.LEFT:
		return Vector2(0, size.y * 0.5)
	elif line_origin == line_origin_enum.RIGHT:
		return Vector2(size.x, size.y * 0.5)
	elif line_origin == line_origin_enum.TOP:
		return Vector2(size.x * 0.5, 0)
	elif line_origin == line_origin_enum.BOTTOM:
		return Vector2(size.x * 0.5, size.y)
	
