extends Slider

@export var scroll_container : ScrollContainer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if scroll_container:
		update_scroll_container(value / max_value)
		
		scroll_container.get_v_scroll_bar().value_changed.connect(update_scroll_bar)
		scroll_container.get_h_scroll_bar().value_changed.connect(update_scroll_bar)
	

func _value_changed(new_value):
	update_scroll_container(new_value / max_value)
	

# Update container based on our value
func update_scroll_container(new_value):
	if scroll_container == null:
		return
	
	var scroll_container_child = scroll_container.get_child(0)
	if scroll_container_child == null:
		return
	
	var pixels_out_of_sight = scroll_container_child.size - scroll_container.size
	
	var self_ref = self
	if self_ref is VSlider and pixels_out_of_sight.y > 0:
		scroll_container.set_v_scroll(pixels_out_of_sight.y * (1 - new_value)) # Invert value on vertical
	elif self_ref is HSlider and pixels_out_of_sight.x > 0:
		scroll_container.set_h_scroll(pixels_out_of_sight.x * new_value)
	

# Update our value based on container
func update_scroll_bar(new_value):
	if scroll_container == null:
		return
	
	var scroll_container_child = scroll_container.get_child(0)
	if scroll_container_child == null:
		return
	
	var pixels_out_of_sight = scroll_container_child.size - scroll_container.size
	var self_range = max_value - min_value
	
	var self_ref = self
	if self_ref is VSlider and pixels_out_of_sight.y > 0:
		set_value_no_signal(self_range * (1 - new_value / pixels_out_of_sight.y))
	elif self_ref is HSlider and pixels_out_of_sight.x > 0:
		set_value_no_signal(self_range * (new_value / pixels_out_of_sight.x))
	
