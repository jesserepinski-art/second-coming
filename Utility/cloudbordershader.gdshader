shader_type canvas_item;

// The primary color you want to remove (defaults to pure green)
uniform vec4 chroma_key_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
// How close the color needs to be to the chroma_key_color to be removed
uniform float similarity : hint_range(0.0, 1.0) = 0.4;
// Smoothness of the blending edge for the primary color
uniform float smoothness : hint_range(0.0, 1.0) = 0.08;

// --- BLACK REMOVAL ---
uniform float black_similarity : hint_range(0.0, 1.0) = 0.05;
uniform float black_smoothness : hint_range(0.0, 1.0) = 0.02;

// --- MAGENTA REMOVAL ---
uniform vec4 magenta_key_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float magenta_similarity : hint_range(0.0, 1.0) = 0.25;
uniform float magenta_smoothness : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 video_color = texture(TEXTURE, UV);

    // Green (or primary chroma color)
    float diff_chroma = distance(video_color.rgb, chroma_key_color.rgb);
    float mask_chroma = smoothstep(similarity, similarity + smoothness, diff_chroma);

    // Black
    float diff_black = distance(video_color.rgb, vec3(0.0, 0.0, 0.0));
    float mask_black = smoothstep(
        black_similarity,
        black_similarity + black_smoothness,
        diff_black
    );

    // Magenta
    float diff_magenta = distance(video_color.rgb, magenta_key_color.rgb);
    float mask_magenta = smoothstep(
        magenta_similarity,
        magenta_similarity + magenta_smoothness,
        diff_magenta
    );

    // Remove if it matches ANY of the three colors
    float final_mask = mask_chroma * mask_black * mask_magenta;

    // ---- IVORY MARBLE RECOLOR ----

// Convert the remaining hand into grayscale so its shading is preserved
float brightness = dot(video_color.rgb, vec3(0.299, 0.587, 0.114));

// Marble palette
vec3 shadow = vec3(0.42, 0.46, 0.54);
vec3 mid    = vec3(0.78, 0.82, 0.90);
vec3 light  = vec3(0.95, 0.97, 1.00);

// Preserve the original lighting
vec3 hand_color;

if (brightness < 0.5) {
    hand_color = mix(shadow, mid, brightness * 2.0);
} else {
    hand_color = mix(mid, light, (brightness - 0.5) * 2.0);
}

COLOR = vec4(hand_color, video_color.a * final_mask);
}