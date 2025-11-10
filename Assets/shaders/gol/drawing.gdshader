shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D chalk_lines;
uniform sampler2D noise;

uniform float time;
uniform bool is_chalk = false;
uniform vec2 brush_pos = vec2(-1.0);
uniform float brush_size = 0.02;
uniform vec4 ink_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	//vec2 sz = SCREEN_PIXEL_SIZE;
	//vec4 result_color = vec4(0.0, 0.0, 0.0, 0.0); // default: transparent
//
	//vec2 center = vec2(0.5, 0.5);
	//float radius = 0.501;
//
	//if(distance(uv, center) > radius){
		//result_color = vec4(0.0);// transparent outside circle
	//}
	//result_color = texture(TEXTURE, uv);
	vec4 current = texture(TEXTURE, uv);
	vec4 chalk = texture(chalk_lines, uv);
	if (!is_chalk || chalk.a <= 0.0){
		current.a -= texture(noise, UV + vec2(time * 0.1, 0.0)).r * 0.05;
		//if (current.r >= 1.0)
			//current.a = 0.0;
	}
	if (distance(brush_pos, SCREEN_UV) <= brush_size)
		current = ink_color;
	COLOR = current;
}
