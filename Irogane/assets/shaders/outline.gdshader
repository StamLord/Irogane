//Copyright 2021 redvillusion
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
//(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, 
//merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished
//to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
//OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
//LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
//IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
shader_type spatial;
 
render_mode unshaded, depth_draw_always, depth_test_disabled;
 
uniform float on : hint_range(0.0,1.0);
uniform float border_width : hint_range(0,1,0.001);
uniform vec4 color : source_color = vec4(1.0);
 
uniform bool pattern;
uniform float line_number : hint_range(0,100,1);
uniform float line_sharpness : hint_range(0,10,0.001);
 
uniform bool pulse;
uniform float pulse_speed : hint_range(0,100,1);
 
uniform bool line_movement;
uniform float line_movement_speed : hint_range(-100,100,1);
 
uniform bool wave;
 
void vertex() {
	VERTEX += VERTEX * border_width * on;
}
 
void fragment() {
	ALBEDO = color.xyz;
	if (pattern) 
	{
		vec2 uv = VERTEX.xy * line_number;
		ALBEDO = sin(uv.xxx + uv.yyy) * line_sharpness * color.xyz;
 
		if (pulse)
		{
			ALBEDO = sin(uv.xxx + uv.yyy) * line_sharpness * color.xyz * sin(TIME * pulse_speed);
		}
 
		if (line_movement)
		{
			ALBEDO = sin(uv.xxx + uv.yyy + TIME * line_movement_speed) * line_sharpness * color.xyz;
		}
 
		if (pulse && line_movement)
		{
			ALBEDO = sin(uv.xxx + uv.yyy + TIME * line_movement_speed) * line_sharpness * color.xyz * sin(TIME * pulse_speed);
		}
	}
 
	if (wave)
	{
		vec2 uv = VERTEX.xy * line_number;
		ALBEDO = sin(uv.xxx + TIME * line_movement_speed) * line_sharpness * color.xyz;
	}
 
}