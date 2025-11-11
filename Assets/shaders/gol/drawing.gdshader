shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D chalk_lines;
uniform sampler2D noise;

uniform float time;
uniform bool is_chalk = false;
uniform vec2 brush_pos = vec2(-1.0);
uniform float brush_size = 0.505;
uniform vec4 ink_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 current = texture(TEXTURE, uv);
	vec4 chalk = texture(chalk_lines, uv);
	if (!is_chalk || chalk.a <= 0.0){
		current.a -= texture(noise, UV + vec2(time * 0.1, 0.0)).r * 0.05;
	}
	if (distance(brush_pos, SCREEN_UV) <= brush_size * 0.1)
		current = ink_color;
	COLOR = current;
}
