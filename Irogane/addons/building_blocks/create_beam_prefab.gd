@tool
extends EditorScript

var default_dimensions = Vector3(1, 0.3, 0.3)
var offset = Vector3(0, 6, 0)

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var edited_scene = get_scene()
	create_collider(edited_scene)
	scene_to_static_body(edited_scene)
	

func create_collider(edited_scene):
	# Get or create a new collider
	var collider = edited_scene.get_node("collider")
	
	if collider == null:
		collider = CollisionShape3D.new()
		edited_scene.add_child(collider)
		collider.owner = edited_scene # Make changes persist in saved scene file
	
	# Scene name should end with dimensions <X>x<Y>x<Z>
	var split_scene_name = edited_scene.name.split("_")
	var dimensions_from_scene_name = split_scene_name[split_scene_name.size() - 1]
	
	# Dimensions can be floats with "-" instead of "."
	var parsed_dimensions = dimensions_from_scene_name.replace("-", ".")
	var split_dimensions = parsed_dimensions.split("x")
	
	var dimensions = default_dimensions
	
	if split_dimensions.size() > 0 and split_dimensions[0].is_valid_float():
		dimensions.x = split_dimensions[0].to_float()
	
	if split_dimensions.size() > 1 and split_dimensions[1].is_valid_float():
		dimensions.y = split_dimensions[1].to_float()
	
	if split_dimensions.size() > 2 and split_dimensions[2].is_valid_float():
		dimensions.z = split_dimensions[2].to_float()
	
	# Update collider
	collider.shape = BoxShape3D.new()
	collider.shape.size = dimensions
	collider.position += offset
	collider.name = "collider"
	

func scene_to_static_body(edited_scene):
	var static_body = StaticBody3D.new()
	static_body.name = edited_scene.name
	
	edited_scene.replace_by(static_body)
	
