extends UIWindow

@onready var stats = PlayerEntity.player_node.stats
@onready var str_value = $VBoxContainer/body/VBoxContainer/GridContainer/str_value
@onready var agi_value = $VBoxContainer/body/VBoxContainer/GridContainer/agi_value
@onready var dex_value = $VBoxContainer/body/VBoxContainer/GridContainer/dex_value
@onready var wis_value = $VBoxContainer/body/VBoxContainer/GridContainer/wis_value
@onready var points_value = $VBoxContainer/body/VBoxContainer/attribute_points/points

@onready var str_buttons = $VBoxContainer/body/VBoxContainer/GridContainer/str_buttons/str_buttons_parent
@onready var agi_buttons = $VBoxContainer/body/VBoxContainer/GridContainer/agi_buttons/agi_buttons_parent
@onready var dex_buttons = $VBoxContainer/body/VBoxContainer/GridContainer/dex_buttons/dex_buttons_parent
@onready var wis_buttons = $VBoxContainer/body/VBoxContainer/GridContainer/wis_buttons/wis_buttons_parent

@onready var apply_button = $VBoxContainer/body/VBoxContainer/Label/apply_button

@onready var str_add = $VBoxContainer/body/VBoxContainer/GridContainer/str_buttons/str_buttons_parent/str_add
@onready var str_remove = $VBoxContainer/body/VBoxContainer/GridContainer/str_buttons/str_buttons_parent/str_remove

@onready var agi_add = $VBoxContainer/body/VBoxContainer/GridContainer/agi_buttons/agi_buttons_parent/agi_add
@onready var agi_remove = $VBoxContainer/body/VBoxContainer/GridContainer/agi_buttons/agi_buttons_parent/agi_remove

@onready var dex_add = $VBoxContainer/body/VBoxContainer/GridContainer/dex_buttons/dex_buttons_parent/dex_add
@onready var dex_remove = $VBoxContainer/body/VBoxContainer/GridContainer/dex_buttons/dex_buttons_parent/dex_remove

@onready var wis_add = $VBoxContainer/body/VBoxContainer/GridContainer/wis_buttons/wis_buttons_parent/wis_add
@onready var wis_remove = $VBoxContainer/body/VBoxContainer/GridContainer/wis_buttons/wis_buttons_parent/wis_remove

var is_modifying = false

var old_str = 0
var old_agi = 0
var old_dex = 0
var old_wis = 0

var temp_points = 0
var temp_str = 0
var temp_agi = 0
var temp_dex = 0
var temp_wis = 0

func _ready():
	set_drag_area()
	
	str_add.pressed.connect(add_str)
	str_remove.pressed.connect(remove_str)
	
	agi_add.pressed.connect(add_agi)
	agi_remove.pressed.connect(remove_agi)
	
	dex_add.pressed.connect(add_dex)
	dex_remove.pressed.connect(remove_dex)
	
	wis_add.pressed.connect(add_wis)
	wis_remove.pressed.connect(remove_wis)
	
	apply_button.pressed.connect(apply_modifying)
	
	update_values()
	
func _process(_delta):
	if Input.is_action_just_pressed("stats"):
		if visible:
			close()
		else:
			open()
		
		if visible:
			if stats.attr_points > 0 and not is_modifying:
				start_modifying()
			update_values()
			
	var can_apply = temp_str > 0 or temp_agi > 0 or temp_dex > 0 or temp_wis > 0
	apply_button.visible = can_apply

func update_values():
	# Update text with modified values
	points_value.text = str(temp_points)
	str_value.text = str(stats.strength.get_value() + temp_str)
	agi_value.text = str(stats.agility.get_value() + temp_agi)
	dex_value.text = str(stats.dexterity.get_value() + temp_dex)
	wis_value.text = str(stats.wisdom.get_value() + temp_wis)

func start_modifying():
	is_modifying = true
	
	str_buttons.visible = true
	agi_buttons.visible = true
	dex_buttons.visible = true
	wis_buttons.visible = true
	
	old_str = stats.strength.get_unmodified()
	old_agi = stats.agility.get_unmodified()
	old_dex = stats.dexterity.get_unmodified()
	old_wis = stats.wisdom.get_unmodified()

	temp_points = stats.attr_points
	
	temp_str = 0
	temp_agi = 0
	temp_dex = 0
	temp_wis = 0
	
func apply_modifying():
	stats.attr_points = temp_points
	stats.strength.add_point(temp_str)
	stats.agility.add_point(temp_agi)
	stats.dexterity.add_point(temp_dex)
	stats.wisdom.add_point(temp_wis)
	
	temp_str = 0
	temp_agi = 0
	temp_dex = 0
	temp_wis = 0
	
	is_modifying = false
	
	update_values()

func add_str():
	if temp_points < 1:
		return
	
	if stats.strength.get_unmodified() + temp_str >= stats.strength.min_max.y:
		return
	
	temp_points -= 1
	temp_str += 1
	update_values()
	
func remove_str():
	if temp_str < 1:
		return
	
	temp_points += 1
	temp_str -= 1
	update_values()
	
func add_agi():
	if temp_points < 1:
		return
	
	if stats.agility.get_unmodified() + temp_agi >= stats.agility.min_max.y:
		return
	
	temp_points -= 1
	temp_agi += 1
	update_values()
	
func remove_agi():
	if temp_agi < 1:
		return
	
	temp_points += 1
	temp_agi -= 1
	update_values()
	
func add_dex():
	if temp_points < 1:
		return
	
	if stats.dexterity.get_unmodified() + temp_dex >= stats.dexterity.min_max.y:
		return
	
	temp_points -= 1
	temp_dex += 1
	update_values()
	
func remove_dex():
	if temp_dex < 1:
		return
	
	temp_points += 1
	temp_dex -= 1
	update_values()
	
func add_wis():
	if temp_points < 1:
		return
	
	if stats.wisdom.get_unmodified() + temp_wis >= stats.wisdom.min_max.y:
		return
	
	temp_points -= 1
	temp_wis += 1
	update_values()
	
func remove_wis():
	if temp_wis < 1:
		return
	
	temp_points += 1
	temp_wis -= 1
	update_values()
