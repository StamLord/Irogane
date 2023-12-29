extends Node3D
class_name NpcState

@export var movement_speed = 2.0
@export var rotation_speed = 2.0

var state_machine : NpcStateMachine
var enter_time

signal Transitioned(state, new_state_name)

func enter(state_machine):
	enter_time = Time.get_ticks_msec()
	

func update(_delta):
	pass
	

func physics_update(state_machine, _delta):
	pass
	

func exit(state_machine):
	pass
	

func set_in_blackboard(key, value):
	state_machine.blackboard[key] = value
	

func get_from_blackboard(key, erase = true):
	if not state_machine.blackboard.has(key):
		print("No %s in blackboard!" % key)
		return null
	
	var value = state_machine.blackboard[key]
	if erase:
		state_machine.blackboard.erase(key)
	
	return value
	

func set_alert_mode(new_state):
	state_machine.awareness_agent.set_alert_mode(new_state)
	

func set_target_position(target_position):
	state_machine.set_target_position(target_position)
	

func reset_target_position():
	state_machine.reset_target_position()
	

func set_target_rotation(target_rotation):
	state_machine.set_target_rotation(target_rotation)
	

func reset_rotation_target():
	state_machine.reset_target_rotation()
	

func perform_collisions(body, speed, push_force, delta):
	for i in body.get_slide_collision_count():
		var collision = body.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			# Ignore collisions for objects we stand on 
			# We test for less than .01 difference in height
			if body.position.y > collision.get_position().y:
				print("Skip Collision")
				continue
			
			collider.apply_central_impulse(-collision.get_normal() * speed * push_force * delta)
			collider.apply_impulse(-collision.get_normal() * 0.01, collision.get_position())
		elif collider is CharacterBody3D:
			collider.velocity += -collision.get_normal() * speed * push_force * delta
	

func get_state_time_in_seconds():
	return (Time.get_ticks_msec() - enter_time) / 1000
	

func is_navigation_finished():
	return state_machine.pathfinding.nav.is_navigation_finished()
	

func get_total_path_distance():
	return state_machine.get_total_path_distance()
	

func get_body_position():
	return state_machine.pathfinding.global_position
	

func get_current_task():
	return state_machine.schedule_agent.get_current_task()
	
