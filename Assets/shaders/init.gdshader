shader_type canvas_item;

//debug
uniform bool mouse_pressed = false;
uniform vec2 mouse_position = vec2(0.0, 0.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 sz = SCREEN_PIXEL_SIZE;
	vec4 result_color;
	
	vec2 center = vec2(0.5, 0.5);
	float radius = 0.502;
	
	if(distance(uv, center) > radius){
		result_color = vec4(0.0, 0.0, 0.0, 0.0);
	}
	else if(distance(uv, center) > radius - 0.005){
		result_color = vec4(0.0, 1.0, 0.0, 1.0);
	}
	
	else if (distance(uv, center) < 0.01) {
		result_color = vec4(1.0, 0.0, 0.0, 1.0);
	}
	else
	{
		result_color = texture(TEXTURE, uv);
	}
	
	COLOR = result_color;

}