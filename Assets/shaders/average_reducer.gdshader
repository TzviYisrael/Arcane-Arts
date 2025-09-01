//shader_type canvas_item;
//
//
//void fragment() {
	//vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
    //// Get the current fragment's UV coordinates
    //vec2 uv = UV;
//
    //// Scale UV coordinates to pixel space of the texture (e.g., 1024x1024)
    //vec2 pixel_pos = uv * texture_size;
//
    //// Round down to the nearest multiple of 2 to get the top-left corner of the 2x2 block
    //pixel_pos = floor(pixel_pos / 2.0) * 2.0;
//
    //// Add an offset of 1 pixel to get to the center of the 2x2 block
    //vec2 sample_pos = pixel_pos + vec2(1.0, 1.0);
//
    //// Scale back to UV space for sampling the texture
    //vec2 sample_uv = sample_pos / texture_size;
//
    //// Sample the texture at the calculated UV and set the color
    //COLOR = texture(TEXTURE, sample_uv);
//}
shader_type canvas_item;

void fragment() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	
    // Convert UV to pixel coordinates
    vec2 pixel_pos = UV * texture_size;

    // Find the top-left pixel of the 2x2 block
    pixel_pos = floor(pixel_pos / 2.0) * 2.0;

    // Calculate UVs for all four pixels in the 2x2 block
    vec2 uv00 = pixel_pos / texture_size;
    vec2 uv10 = (pixel_pos + vec2(1.0, 0.0)) / texture_size;
    vec2 uv01 = (pixel_pos + vec2(0.0, 1.0)) / texture_size;
    vec2 uv11 = (pixel_pos + vec2(1.0, 1.0)) / texture_size;

    // Sample the color of each pixel
    vec4 color00 = texture(TEXTURE, uv00);
    vec4 color10 = texture(TEXTURE, uv10);
    vec4 color01 = texture(TEXTURE, uv01);
    vec4 color11 = texture(TEXTURE, uv11);

    // Average the colors and set the fragment color
    COLOR = (color00 + color10 + color01 + color11) / 4.0;
}
