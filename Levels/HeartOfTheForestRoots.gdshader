shader_type canvas_item;

uniform sampler2D noise_texture : hint_default_black;
uniform vec4 color_1 : source_color = vec4(0.2, 0.0, 0.4, 1.0);  // Dark Purple
uniform vec4 color_2 : source_color = vec4(0.0, 0.8, 0.6, 1.0);  // Neon Turquoise
uniform vec4 color_3 : source_color = vec4(1.0, 0.3, 0.7, 1.0);  // Hot Pink

uniform float swirl_speed : hint_range(0.0, 5.0) = 0.6;
uniform float wave_intensity : hint_range(0.1, 10.0) = 3.5;
uniform float scale : hint_range(0.1, 10.0) = 2.0;
uniform float wobble_speed = 1.5;
uniform float wobble_strength = 2.0;

void vertex() {
	float wobble_x = sin(TIME * wobble_speed + VERTEX.y * 0.05) * wobble_strength;
	float wobble_y = cos(TIME * wobble_speed * 1.3 + VERTEX.x * 0.05) * wobble_strength * 0.5;
	VERTEX += vec2(wobble_x, wobble_y);
}

void fragment() {
    // 1. Fetch only the ALPHA transparency from your original root sprite texture
    // This defines the shape of the path so players know exactly where they can step.
    float path_mask = texture(TEXTURE, UV).a;
    
    // 2. Center the UVs for circular/vortex coordinate math
    vec2 uv_centered = (UV - vec2(0.5)) * scale;
    float dist = length(uv_centered);
    float angle = atan(uv_centered.y, uv_centered.x);
    
    // 3. Create time-based shifting ripples (Liquid Distortion)
    float time_factor = TIME * swirl_speed;
    
    // Distort the coordinates using concentric sine waves layered with an active vortex twist
    float movement = sin(dist * wave_intensity - time_factor) + cos(angle * 3.0 + time_factor * 0.5);
    
    // 4. Sample a noise texture using our distorted acid-coordinates
    vec2 distorted_uv = vec2(dist + movement * 0.15, angle / TAU + movement * 0.1);
    vec4 noise_sample = texture(noise_texture, distorted_uv);
    
    // 5. Psychotropic Color Psychedelia (Tri-color mixing based on the shifting waves)
    float blend_weight = clamp(noise_sample.r + (movement * 0.25) + 0.3, 0.0, 1.0);
    
    vec3 acid_pool;
    if (blend_weight < 0.5) {
        acid_pool = mix(color_1.rgb, color_2.rgb, blend_weight * 2.0);
    } else {
        acid_pool = mix(color_2.rgb, color_3.rgb, (blend_weight - 0.5) * 2.0);
    }
    
    // 6. Output ONLY the acid pattern, restricted perfectly inside the root's shapes
    COLOR = vec4(acid_pool, path_mask);
}