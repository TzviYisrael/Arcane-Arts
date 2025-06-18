shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
  // Load the Game of Life current state
  COLOR = texture(TEXTURE, UV);

  // And add some historical state for a nice effect
  COLOR += texture(SCREEN_TEXTURE, UV) * 0.1;
}
