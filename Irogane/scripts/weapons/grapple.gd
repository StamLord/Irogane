extends Node3D

@onready var rope = $Rope
@onready var ray_cast = $"../../grappling_ray_cast"
@onready var end_target = $Rope/end_target
@onready var grappling_decal = $"../../grappling_decal"

const rope_script = preload("res://scripts/procedural/new_rope.gd")
var rope_scripts = []
var stashed_scripts = []

var is_grappling = false
var start_distance = 0.0

var pitons = []
var stashed_pitons = []

func _process(delta):
	if ray_cast.is_colliding():
		grappling_decal.global_position = ray_cast.get_collision_point()
		Utils.rotate_y_to_target(grappling_decal, ray_cast.get_collision_point() - ray_cast.get_collision_normal())
		grappling_decal.visible = true
	else:
		grappling_decal.visible = false
		
	if Input.is_action_just_pressed("attack_primary") and ray_cast.is_colliding():
		spawn_piton(ray_cast.get_collision_point() + ray_cast.get_collision_normal() * 0.1)
		end_target.global_position = ray_cast.get_collision_point()
		rope.set_start_target(self)
		rope.set_end_target(end_target)
		rope.visible = true
		is_grappling = true
		start_distance = (self.global_position - end_target.global_position).length()
	elif is_grappling and Input.is_action_just_pressed("crouch"):
		rope.visible = false
		is_grappling = false
		stash_pitons()
	

func spawn_piton(piton_position : Vector3):
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.mesh.size = Vector3.ONE * 0.2
	
	get_tree().root.add_child(mesh)
	mesh.global_position = piton_position
	
	pitons.append(mesh)
	update_rope_through_pitons()
	

func update_rope_through_pitons():
	for i in range(pitons.size() - 1):
		if i >= rope_scripts.size():
			var new = rope_script.new()
			new.rope_width = 0.03
			new.resolution = 4
			add_child(new)
			new.top_level = true
			rope_scripts.append(new)
		
		rope_scripts[i].set_start_target(pitons[i])
		rope_scripts[i].set_end_target(pitons[i + 1])
	

func stash_pitons():
	stashed_pitons = pitons
	pitons.clear()
	stashed_scripts = rope_scripts
	rope_scripts.clear()
	
