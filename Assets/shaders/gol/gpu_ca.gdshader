shader_type canvas_item;
render_mode blend_disabled;

// --- UNIFORMS ---

// 1. THE TRANSLATOR (3D Texture)
// Input: RGB Coordinate (The visual color)
// Output: Red Channel = ID (0.0 to 1.0)
uniform sampler3D color_to_id_lut : filter_nearest;

// 2. THE LOGIC (2D Texture)
// Input: X = Neighbor ID, Y = My ID
// Output: 
//   R = Resulting ID (What do I become?)
//   G = Reaction Type (0=Ignore, 0.5=Damage, 1.0=Swap/Spread)
//   B = Severity/Damage Amount
uniform sampler2D reaction_table : filter_nearest;

// 3. THE PAINTER (2D Texture)
// Input: X = ID
// Output: RGB = The Visual Color to draw
uniform sampler2D id_to_color_palette : filter_nearest;

// Settings
uniform float damage_speed = 0.01; 

// --- HELPER FUNCTIONS ---

float get_id_from_visual(vec3 visual_color) {
	// 3D Lookup: Use the color itself as the coordinate
	return texture(color_to_id_lut, visual_color).r;
}

vec4 get_visual_from_id(float id) {
	// 1D Lookup: Use the ID to fetch the color from the palette
	return texture(id_to_color_palette, vec2(id, 0.5));
}

void fragment() {
	vec2 sz = SCREEN_PIXEL_SIZE;
	vec4 current_color = texture(TEXTURE, UV);
	
	// 1. DECODE SELF
	float my_id = get_id_from_visual(current_color.rgb);
	float my_health = current_color.a; // We use Alpha for health!
	
	// Prepare next state (defaults to staying the same)
	float next_id = my_id;
	float next_health = my_health;
	
	// Define neighbors (Up, Down, Left, Right)
	vec2 offsets[4] = vec2[](vec2(-1,0), vec2(1,0), vec2(0,-1), vec2(0,1));
	
	// 2. INTERACT LOOP
	for (int i = 0; i < 4; i++) {
		vec4 neighbor_col = texture(TEXTURE, UV + offsets[i] * sz);
		
		// Optimization: Skip empty neighbors (assuming Alpha 0 is empty)
		if (neighbor_col.a <= 0.01) continue;
		
		float neighbor_id = get_id_from_visual(neighbor_col.rgb);
		
		// 3. CHECK REACTION TABLE
		// X = Neighbor, Y = Me
		vec4 reaction = texture(reaction_table, vec2(neighbor_id, my_id));
		
		int type = int(round(reaction.g * 10.0)); // 0=None, 5=Damage, 10=Swap
		float severity = reaction.b; // How strong is the reaction?
		
		// --- HANDLING CONFLICTS (LOGIC) ---
		
		// TYPE: INSTANT SWAP / SPREAD
		// Example: Water touches Fire -> Fire vanishes instantly
		if (type == 10) {
			next_id = reaction.r;
			next_health = 1.0; // Reset health for the new material
			break; // Critical change! Stop checking other neighbors.
		}
		
		// TYPE: DAMAGE / FADE
		// Example: Acid touches Metal -> Metal slowly corrodes
		else if (type == 5) {
			next_health -= (severity * damage_speed);
			// We DO NOT break here. 
			// Multiple neighbors can damage me at the same time (accumulate damage).
		}
	}
	
	// 4. RESOLVE DAMAGE
	if (next_health <= 0.0) {
		// I died from damage!
		// Check the table for what I turn into when I die (e.g., Metal -> Air)
		// We lookup Self vs Self (or a special "Death" column) to find the debris ID
		// For simplicity here, let's say we turn into the ID that damaged us last:
		// (A better system would store "DeathTransformID" in the reaction table)
		
		// Fallback: If health hits 0, vanish (ID 0) or change to a default "Ash" ID
		next_health = 0.0; 
	}
	
	// 5. ENCODE BACK TO VISUALS
	vec4 final_color = get_visual_from_id(next_id);
	
	// Preserve the calculated health in the Alpha channel
	final_color.a = next_health;
	
	COLOR = final_color;
}