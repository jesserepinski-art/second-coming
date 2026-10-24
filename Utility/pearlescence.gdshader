shader_type canvas_item;

uniform float shimmer_speed = 0.12;
uniform float shimmer_width = 0.12;
uniform float shimmer_strength = 0.55;

// Approximate "white border" threshold
uniform float border_threshold = 0.8;

void fragment()
{
    vec4 tex = texture(TEXTURE, UV);

    // Only affect bright pixels (your white border)
    float brightness = max(tex.r, max(tex.g, tex.b));

    if (brightness < border_threshold)
    {
        COLOR = tex;
        return;
    }

    // Rotating pearlescent wave
    float angle = atan(UV.y - 0.5, UV.x - 0.5);

    float wave =
        sin(angle * 2.0 - TIME * shimmer_speed * 6.28318) * 0.5 + 0.5;

    // Soft rainbow
    vec3 pearl =
        0.5 +
        0.5 *
        cos(
            vec3(0.0, 2.094, 4.188)
            + wave * 6.28318
        );

    // Pastelize
    pearl = mix(vec3(1.0), pearl, 0.35);

    float mask =
        smoothstep(
            1.0 - shimmer_width,
            1.0,
            wave
        );

    vec3 final =
        mix(
            tex.rgb,
            pearl,
            mask * shimmer_strength
        );

    COLOR = vec4(final, tex.a);
}