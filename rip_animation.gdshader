shader_type canvas_item;

// SLOT TO DROP YOUR CUSTOM SWIRL IMAGE
uniform sampler2D swirl_texture : filter_nearest, repeat_enable;

uniform float speed : hint_range(0.0, 10.0) = 1.5;
uniform float stop_motion_fps : hint_range(1.0, 24.0) = 8.0;

// CONTROLS THE OPENING: 0.0 is closed, 1.0 is wide open
uniform float opening_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // 1. Local object coordinates for world-locking
    vec2 center = vec2(0.5, 0.5);
    vec2 pixel_coords = UV - center;
    
    // Correct for aspect ratio of the TextureRect node
    vec2 aspect_coords = pixel_coords;
    aspect_coords.x *= 1.7778; 
	vec2 noise_uv = UV * 3.0 + vec2(TIME * 0.05, 0.0);
	float edge_noise = texture(swirl_texture, noise_uv).r;
	edge_noise = edge_noise * 2.0 - 1.0;
    float fold =
    sin(aspect_coords.y * 8.0 + TIME * 2.0) * 0.02;

	float horizontal_dist =
    abs(aspect_coords.x + fold);
    float vertical_dist = abs(aspect_coords.y);
    
    // Wide-curve top-to-bottom opening shape math
    float shape = (horizontal_dist * 2.5) + (vertical_dist * vertical_dist * 1.2);
    shape += edge_noise * 0.08;
    // 2. Cutout Mask Logic: If outside the curve, hide everything
    if (shape > opening_progress) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent (Reveals moving clouds)
    } 
    // 3. Inside the curve: Rotate your custom texture with a stop-motion frame rate
    else {
        // Step the continuous time into distinct blocks
        float stepped_time = floor(TIME * stop_motion_fps) / stop_motion_fps;
        
        // Calculate the rotation angle based on our choppy time variable
        float rotation_angle = stepped_time * speed;
        
        // Create a standard 2D rotation matrix
        float cos_a = cos(rotation_angle);
        float sin_a = sin(rotation_angle);
        mat2 rotation_matrix = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));
        
        // Rotate the UV coordinates around the center point
        vec2 rotated_uv = (rotation_matrix * pixel_coords) + center;
        
        // Read the colors directly from your custom image file
        vec4 sampled_color = texture(swirl_texture, rotated_uv);
		// Fade in as the portal opens
		float portal_alpha = smoothstep(0.02, 0.10, opening_progress);

		sampled_color.a *= portal_alpha;

		COLOR = sampled_color;
        float edge =
    	smoothstep(opening_progress - 0.03,
               opening_progress,
               shape);

		vec3 shadow =
   	 	mix(vec3(0.0),
        sampled_color.rgb,
        edge);

		COLOR.rgb = shadow;
        COLOR = sampled_color;
		
    }
}
