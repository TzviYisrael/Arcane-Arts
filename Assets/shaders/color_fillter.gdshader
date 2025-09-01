shader_type canvas_item;

uniform vec4 target_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float range = 0.1;

void fragment() {
	if(distance(texture(TEXTURE, UV), target_color) < range){
		COLOR = vec4(1.0);
	}
	else{
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}
