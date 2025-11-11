shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D chalk_lines;
uniform sampler2D noise;
uniform sampler2D brush_texture;

uniform float time;
uniform bool is_chalk = false;
uniform vec2 brush_pos = vec2(-1.0);
uniform float brush_size = 0.505;
uniform vec4 ink_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Original border discard logic
    if (distance(SCREEN_UV, vec2(0.5, 0.5)) >= 0.501) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
	
    else {
	    vec2 brush_to_frag = uv - brush_pos;
	    float brush_radius = brush_size * 0.1;
	    
	    vec2 brush_uv = (brush_to_frag / brush_radius) * 0.5 + 0.5;
	    bool is_in_brush_area = all(greaterThanEqual(brush_uv, vec2(0.0))) && 
	                            all(lessThanEqual(brush_uv, vec2(1.0)));
	    
	    vec4 color = texture(TEXTURE, uv);
	    
	    if (is_in_brush_area) {
	        float brush_alpha = texture(brush_texture, brush_uv).a; 
	        if (brush_alpha > 0.0) 
	            color = ink_color;
	    }
		
	    vec4 chalk = texture(chalk_lines, uv);
	    if (!is_chalk || chalk.a <= 0.0){
	        color.a -= texture(noise, UV + vec2(time * 0.1, 0.0)).r * 0.05;
	    }
	    
	    COLOR = color;
	}
}
