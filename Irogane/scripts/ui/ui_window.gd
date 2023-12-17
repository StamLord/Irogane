extends Control
class_name UIWindow

@export var drag_area : Area2D
@export var button : String
@export var close_on_back: bool = true
@export var from_main_menu: bool = false

var offset
var dragging : bool
var new_position : Vector2
var mouse_in : bool

func _ready():
	set_drag_area()

func _process(delta):
	if not button: return
	
	if Input.is_action_just_pressed(button):
		if visible:
			close()
		else:
			open()


func set_drag_area():
	if drag_area:
		drag_area.mouse_entered.connect(mouse_enter)
		drag_area.mouse_exited.connect(mouse_exit)

func open():
	visible = true
	UIManager.add_window(self)
	
func close():
	visible = false
	UIManager.remove_window(self)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && mouse_in:
			offset = (get_viewport().get_mouse_position() - position)
			dragging = true
			new_position = get_viewport().get_mouse_position() - offset
		else:
			dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			new_position = get_viewport().get_mouse_position() - offset
			position = new_position
	
func mouse_enter():
	mouse_in = true;
	
func mouse_exit():
	mouse_in = false;
