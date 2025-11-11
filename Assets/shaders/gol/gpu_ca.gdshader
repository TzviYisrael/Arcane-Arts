shader_type canvas_item;
//render_mode blend_sub;

uniform bool run = false;
uniform float power = 0.007;

const float color_threshold = 0.01;
const vec3 black_rgb = vec3(0.0, 0.0, 0.0);
const vec3 white_rgb = vec3(1.0, 1.0, 1.0);
const vec3 red_rgb = vec3(1.0, 0.0, 0.0);

//for any shade of black and gray
bool is_monochrome(vec4 color) {
	return (abs(color.r - color.g) < color_threshold  &&
	 abs(color.g - color.b) < color_threshold && color.a > 0.9);
}

bool is_white(vec4 color) {
    return distance(color.rgb, white_rgb) < color_threshold;
}

bool is_red(vec4 color) {
    return distance(color.rgb, red_rgb) < color_threshold;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 sz = SCREEN_PIXEL_SIZE;
	vec4 result_color = vec4(0.0, 0.0, 0.0, 0.0); // default: transparent

	vec2 center = vec2(0.5, 0.5);
	float radius = 0.501;

	if(distance(uv, center) > radius){
		result_color = vec4(0.0);// transparent outside circle
	}
	else if (!run) {
		result_color = texture(TEXTURE, uv);
	} else {
		vec4 current = texture(TEXTURE, uv);

		if(is_white(current)) result_color = vec4(1.0, 0.0, 0.0, 1.0);
		else if(is_red(current)) result_color = current;
		else
		{
			vec2 offsets[4] = vec2[](
				vec2(-1.0, 0.0),
				vec2(1.0, 0.0),
				vec2(0.0, -1.0),
				vec2(0.0, 1.0)
			);
			if(current.a < 0.05){//tranparent pixel
				result_color = vec4(0.0);
				for (int i = 0; i < 4; i++) {
					vec4 neighbor = texture(TEXTURE, uv + offsets[i] * sz);
					if (!is_monochrome(neighbor) && neighbor.a > 0.9) {
						result_color = neighbor;
						break;
					}
				}
			}
			else if(is_monochrome(current)){
				for (int i = 0; i < 4; i++) {
					vec4 neighbor = texture(TEXTURE, uv + offsets[i] * sz);
					if (is_red(neighbor)) {
						result_color = vec4(current.rgb + power, 1.0);
					}
				}
			}
			else
			{
				result_color = current;
				for (int i = 0; i < 4; i++) {
					vec4 neighbor = texture(TEXTURE, uv + offsets[i] * sz);
					if (is_red(neighbor)) {
						result_color = vec4(black_rgb.rgb + (power * 100.0), 1.0);
					}
				}
			}
		}
	}

	if(result_color.a < 0.05) result_color = vec4(0.0);
	COLOR = result_color;
}
