extends TextureButton

var initial_pos
var selected = false
@export var skill_name = ""

signal skill_selected(skill_name)

func _ready():
	initial_pos = get_position()
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	

func _mouse_entered():
	if selected:
		return
	
	var curr_pos = initial_pos
	curr_pos.x -= 10
	set_position(curr_pos)
	

func _mouse_exited():
	if selected:
		return
	
	set_position(initial_pos)
	

func select():
	if selected:
		return
	
	selected = true
	var curr_pos = initial_pos
	curr_pos.x -= 20
	set_position(curr_pos)
	

func deselect():
	selected = false
	set_position(initial_pos)
	

func _pressed():
	select()
	skill_selected.emit(skill_name)
	
