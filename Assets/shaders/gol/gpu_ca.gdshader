shader_type canvas_item;

uniform bool run = true;
uniform float power = 0.1;

//debug
uniform bool mouse_pressed = false;
uniform vec2 mouse_position = vec2(0.0, 0.0);

/**
 * Procedural white noise
 */
highp float rand(vec2 co) {
	highp float a = 12.9898;
	highp float b = 78.233;
	highp float c = 43758.5453;
	highp float dt = dot(co.xy, vec2(a, b));
	highp float sn = mod(dt, 3.14);
	return fract(sin(sn) * c);
}

bool is_flooding_color(vec4 color) {
	// Check if pixel is red or green (with alpha), but not black
	if (color.a < 0.5) return false; // skip transparent
	bool is_red = (color.r > 0.8 && color.g < 0.2 && color.b < 0.2);
	bool is_green = ( color.r < 0.2 && color.g > 0.8 && color.b < 0.2);
	bool is_blue = (color.r < 0.2 && color.g < 0.2 && color.b > 0.8);
	return is_red || is_green || is_blue;
}

bool is_black(vec4 color) {
	return (color.r < 0.1 && color.g < 0.1 && color.b < 0.1 && color.a > 0.1);
}

bool is_red(vec4 color) {
	return (color.r > 0.9 && color.g < 0.1 && color.b < 0.1 && color.a > 0.9);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 sz = SCREEN_PIXEL_SIZE;
	vec4 result_color = vec4(0.0, 0.0, 0.0, 0.0); // default: transparent

	vec2 center = vec2(0.5, 0.5);
	float radius = 0.5;
	
	if(distance(uv, center) > radius){
		result_color = vec4(1.0, 1.0, 1.0, 0.0);// transparent outside circle
	}
	else if (!run) {
		//result_color = vec4(1.0, 1.0, 1.0, 0.0);// transparent outside circle
		result_color = vec4(1.0, 1.0, 0.0, 1.0); 
	} else {
		vec4 current = texture(TEXTURE, uv);
		vec2 dist_to_mouse = (uv / sz) - mouse_position;

		// Input: draw flood seeds for debug
		if (mouse_pressed && length(dist_to_mouse) < 20.0) {
			float noise = rand(dist_to_mouse * uv * 2.0);
			if (noise < 0.5) {
				result_color = vec4(1.0, 0.0, 0.0, 1.0); // red
			} else {
				result_color = vec4(0.0, 1.0, 0.0, 1.0); // green
			}
		}
		// Keep flood color if already filled
		else if (is_flooding_color(current)) {
			result_color = current; 
		}
		else {
			if (is_black(current)) {
				vec2 offsets[4] = vec2[](
					vec2(-1.0, 0.0),
					vec2(1.0, 0.0),
					vec2(0.0, -1.0),
					vec2(0.0, 1.0)
				);

				result_color = current;
				for (int i = 0; i < 4; i++) {
					vec4 neighbor = texture(TEXTURE, uv + offsets[i] * sz);
					if (is_red(neighbor)) {
						float new_alpha = max(0.0, current.a - power);
						result_color = vec4(1.0, 0.0, 0.0, 0.01);
						break;
					}
				}
			}
			// Otherwise: check neighbors to flood
			else if (current.a < 0.1){
				vec2 offsets[4] = vec2[](
					vec2(-1.0, 0.0),
					vec2(1.0, 0.0),
					vec2(0.0, -1.0),
					vec2(0.0, 1.0)
				);

				bool flooded = false;
				for (int i = 0; i < 4; i++) {
					vec4 neighbor = texture(TEXTURE, uv + offsets[i] * sz);
					if (is_flooding_color(neighbor)) {
						result_color = neighbor;
						flooded = true;
						break;
					}
				}

				// If not flooded, remain as-is
				if (!flooded) {
					result_color = vec4(0.0, 0.0, 0.0, 0.0);
				}
			}
		}
	}

	COLOR = result_color;
}
