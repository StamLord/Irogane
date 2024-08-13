extends Switch

@export var elevator : Elevator = null
@export var floor_index : int = 0

func _ready():
	if elevator != null:
		on_state_changed.connect(elevator.goto_floor.bind(floor_index))
	
