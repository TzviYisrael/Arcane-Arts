shader_type canvas_item;
render_mode blend_mul;


void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 current = texture(TEXTURE, uv);
	if(abs(current.r - current.g) < 0.0001  &&
	 abs(current.g - current.b) < 0.0001 && current.a > 0.9){
		COLOR = current;
	}
	else COLOR = vec4(current.rgb, 0.0);
}

