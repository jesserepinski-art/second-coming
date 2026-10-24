shader_type canvas_item;

// The texture wrapped around the 3D sphere
uniform sampler2D sphere_texture : repeat_enable;
// Controls how big the sphere mapping calculation is inside the sprite boundaries
uniform float sphere_scale : hint_range(0.1, 2.0) = 1.0;
// Moves the sphere center offset: X moves left/right, Y moves up/down (-1.0 to 1.0)
uniform vec2 sphere_position = vec2(0.0, 0.0);
uniform float rotation_speed : hint_range(-5.0, 5.0) = 0.5;
uniform vec3 light_direction = vec3(0.5, 0.5, 1.0);

// Global toggle for the shader effect. 1.0 = full 3D sphere, 0.0 = original sprite only.
uniform float shader_mix : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // 1. Sample the sprite's original texture and alpha transparency
    vec4 base_sprite = texture(TEXTURE, UV);
    
    // 2. Center the UV coordinates around (0,0) and apply the position offset
    vec2 p = ((UV - 0.5) * 2.0) - sphere_position;
    
    // Apply the custom scale factor to the coordinates
    p /= sphere_scale;
    
    // Calculate distance from center to form the sphere projection boundary
    float radius_squared = dot(p, p);
    
    // 3. Fallback to normal sprite pixels if we go outside the mathematical sphere boundary
    if (radius_squared > 1.0) {
        COLOR = base_sprite;
    } else {
        // 4. Reconstruct the 3D surface Normal (Z axis points toward the camera)
        float z = sqrt(1.0 - radius_squared);
        vec3 normal = vec3(p.x, p.y, z);
        
        // 5. Transform 3D surface normals into spherical mapping coordinates
        float u = atan(normal.x, normal.z) / (2.0 * 3.14159265) + 0.5;
        float v = asin(normal.y) / 3.14159265 + 0.5;
        
        // 6. Spin the texture over time along the horizontal axis
        u += TIME * rotation_speed;
        
        // 7. Sample the sphere texture
        vec4 tex_color = texture(sphere_texture, vec2(u, v));
        
        // 8. Add simple 3D diffuse shading
        vec3 light_dir_norm = normalize(light_direction);
        float diffuse = max(dot(normal, light_dir_norm), 0.1);
        
        // 9. Mask the final sphere color using the original sprite's transparency
        vec4 sphere_color = vec4(tex_color.rgb * diffuse, tex_color.a * base_sprite.a);
        
        // 10. Smoothly mix between the original sprite texture and the 3D sphere texture based on shader_mix
        COLOR = mix(base_sprite, sphere_color, shader_mix);
    }
}
