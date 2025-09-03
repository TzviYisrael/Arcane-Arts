shader_type canvas_item;

// Uniforms for the circles
uniform int circle_count = 0;
uniform vec2 circle_positions[100];
uniform vec4 circle_colors[100];

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 sz = SCREEN_PIXEL_SIZE; 
    vec4 result_color = texture(TEXTURE, uv);

    vec2 center = vec2(0.5, 0.5);
    float outer_radius = 0.502; // overall circular area
    float green_ring_width = 0.005; 
    float red_dot_radius = 0.01; // red central dot
	float circle_radius = 0.01;

    for (int i = 0; i < circle_count; ++i) {
        // Convert the position from pixel space to UV space
        // Assuming circle_positions are in pixel coordinates (e.g., 100, 200)
        // If your circle_positions are already in UV space [0,1], remove * sz
        vec2 circle_uv = circle_positions[i] * sz; 
        
        if (distance(uv, circle_uv) < circle_radius) { 
            result_color = circle_colors[i];
			//break;
        }
    }
	
    float dist_from_center = distance(uv, center);

    if (dist_from_center > outer_radius) {
        result_color = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (dist_from_center > outer_radius - green_ring_width) {
        result_color = vec4(0.0, 1.0, 0.0, 1.0);
    } else if (dist_from_center < red_dot_radius) {
        result_color = vec4(1.0, 0.0, 0.0, 1.0);
    }
    
    COLOR = result_color;
}