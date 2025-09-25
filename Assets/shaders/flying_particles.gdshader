shader_type particles;

uniform int grid_size_x = 20;
uniform int grid_size_z = 20;
uniform float spacing = 0.25;
uniform float speed = 2.0;

uniform sampler2D color_texture;
uniform vec4 filter_color : source_color = vec4(0.0);

uniform float total_lifetime = 2.5;
uniform float initial_flight_duration = 0.5;
uniform vec3 target_position = vec3(0.0, 10.0, 0.0);

void start() {
    uint particle_index = INDEX;
    float x_coord = float(particle_index % uint(grid_size_x));
    float z_coord = floor(float(particle_index) / float(grid_size_x));
    float grid_width = float(grid_size_x) * spacing;
    float grid_depth = float(grid_size_z) * spacing;

    vec3 offset = vec3(grid_width, 0.0, grid_depth) / 2.0;
    vec3 initial_pos = vec3(x_coord * spacing, 0.0, z_coord * spacing) + vec3(spacing/2.0, 0.0, spacing/2.0) - offset;

    vec2 uv = vec2(x_coord / float(grid_size_x - 1), z_coord / float(grid_size_z - 1));
    vec4 tex_color = texture(color_texture, uv);

    bool should_be_active = false;

    if (filter_color.a < 0.01) {
        bool is_transparent = tex_color.a < 0.01;
        bool is_black = dot(tex_color.rgb, vec3(1.0)) < 0.01;
        bool is_white = dot(tex_color.rgb, vec3(1.0)) > 2.99;
        
        if (!is_transparent && !is_black && !is_white) {
            should_be_active = true;
        }
    } else {
        float color_distance = distance(tex_color.rgb, filter_color.rgb);
        float alpha_distance = abs(tex_color.a - filter_color.a);
        
        if (color_distance < 0.05 && alpha_distance < 0.05) {
            should_be_active = true;
        }
    }

    if (should_be_active) {
        TRANSFORM[3].xyz = (EMISSION_TRANSFORM * vec4(initial_pos, 1.0)).xyz;
        
        // --- Radial Outward and Upward Velocity ---
        // Calculate the vector pointing from the center of the grid to the particle.
        // We use initial_pos because it's already centered.
        vec3 outward_direction = normalize(initial_pos);
        
        // Set the initial velocity to go outward and up.
        vec3 initial_velocity = vec3(outward_direction.x * speed, speed * 2.0, outward_direction.z * speed);
        
        VELOCITY = (EMISSION_TRANSFORM * vec4(initial_velocity, 0.0)).xyz;

        COLOR = tex_color;
    } else {
        ACTIVE = false;
    }
}

void process() {
    float age = LIFETIME * total_lifetime;
    
    if (age > initial_flight_duration) {
        vec3 direction_to_target = normalize(target_position - TRANSFORM[3].xyz);
        
        float time_in_flight = age - initial_flight_duration;
        float remaining_lifetime = total_lifetime - initial_flight_duration;
        float normalized_time = time_in_flight / remaining_lifetime;
        float acceleration_factor = pow(normalized_time, 2.0);
        
        VELOCITY = mix(VELOCITY, direction_to_target * speed * (1.0 + acceleration_factor), 0.1);
    }
}