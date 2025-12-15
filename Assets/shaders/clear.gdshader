shader_type canvas_item;
render_mode blend_mul;


void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 current = texture(TEXTURE, uv);
	if(abs(current.r - current.g) < 0.001  &&
	 abs(current.g - current.b) < 0.001 && current.a > 0.9){
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else COLOR = vec4(0.0);
}
