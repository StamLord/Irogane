extends Node3D

@onready var walk = $"%states/walk"
@onready var run = $"%states/run"
@onready var player = owner

var x_offset = 0.25
var y_offset = 0.5
var step_timer = 0.0

func _ready():
	add_debug_commands()
	

func _process(delta):
	if not is_moving():
		step_timer = 0.0
		position.x = lerp(position.x, 0.0, delta)
		position.y = lerp(position.y, 0.0, delta)
		return
	
	var step_duration = get_step_duration()
	
	step_timer += delta
	if step_timer > step_duration * 2: # Reset at twice duration to allow left/right wave to complete
		step_timer -= step_duration * 2
	
	var step_percentage = step_timer / step_duration * TAU # Convert to -1..1
	
	var target_pos_x = sin(step_percentage * 0.5) * x_offset	# Left/right wave takes twice as much
	var target_pos_y = sin(step_percentage + PI) * y_offset 	# Add PI so wave starts downward
	
	position.x = lerp(position.x, target_pos_x, delta)
	position.y = lerp(position.y, target_pos_y, delta)
	

func is_moving():
	if player == null:
		return
		
	if player.current_state == walk or player.current_state == run:
		return abs(player.velocity.length()) > 0.1
		
	return false
	

func get_step_duration():
	if player.current_state != walk and player.current_state != run:
		return 0.5
	
	var speed = player.current_state.speed    # Distance over second
	var number_of_steps = speed / 2         # Average step is ~0.8 meters
	var step_duration = 1 / number_of_steps
	
	return step_duration
	

func set_y_offset(args: Array):
	y_offset = args[0]
	

func set_x_offset(args: Array):
	x_offset = args[0]
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"set_bob_x",
		set_x_offset,
		 [{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New x offset value"
			}],
		"Sets the player camera's head bob x offset to the new value"
		)
	
	DebugCommandsManager.add_command(
		"set_bob_y",
		set_y_offset,
		 [{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.FLOAT,
				"arg_desc" : "New y offset value"
			}],
		"Sets the player camera's head bob y offset to the new value"
		)
	
