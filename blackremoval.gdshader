shader_type canvas_item;

// The color to remove (pure magenta by default)
uniform vec4 key_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);

// How close a pixel must be to the key color before becoming transparent.
uniform float tolerance : hint_range(0.0, 1.0) = 0.15;

// Softens the edges of the chroma key.
uniform float softness : hint_range(0.001, 0.5) = 0.05;

// Horizontal alignment adjustment.
uniform float horizontal_offset : hint_range(-0.5, 0.5) = 0.05;

void fragment() {
	vec2 shifted_uv = UV;
	shifted_uv.x -= horizontal_offset;

	if (shifted_uv.x < 0.0 || shifted_uv.x > 1.0) {
		discard;
	}

	vec4 video_color = texture(TEXTURE, shifted_uv);

	// Distance from the key color (magenta)
	float dist = distance(video_color.rgb, key_color.rgb);

	// Smooth alpha transition
	float alpha = smoothstep(tolerance, tolerance + softness, dist);

	COLOR = vec4(video_color.rgb, video_color.a * alpha);
}