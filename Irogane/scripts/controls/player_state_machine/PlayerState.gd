extends Node
class_name PlayerState

var state_machine : PlayerStateMachine
var recent_collisions = {}

signal Transitioned(state, new_state_name)

func Enter(_body):
	pass
	

func Update(_delta):
	pass
	

func PhysicsUpdate(_body, _delta):
	pass
	

func Exit(_body):
	pass
	

func PerformCollisions(body, speed, push_force, delta):
	for i in body.get_slide_collision_count():
		var collision = body.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			# Ignore recente collisions
			if recent_collisions.has(collider):
				var time = Time.get_ticks_msec()
				if time - recent_collisions[collider] <= 250:
					continue
			
			# Ignore collisions for objects we stand on 
			# We test for less than .01 difference in height
			#if body.position.y - collision.get_position().y < 0.01:
				#print("Skip Collision")
				#continue
			
			collider.apply_central_impulse(-collision.get_normal() * speed * push_force * delta)
			recent_collisions[collider] = Time.get_ticks_msec()
		elif collider is CharacterBody3D:
			collider.velocity += -collision.get_normal() * speed * push_force * delta
	
