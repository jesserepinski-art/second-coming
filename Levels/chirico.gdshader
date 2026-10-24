shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	vec3 color;

	if (lum < 0.2)
		color = vec3(0.25,0.20,0.55);      // lavender shadows
	else if (lum < 0.4)
		color = vec3(0.55,0.55,0.90);      // blue-purple
	else if (lum < 0.6)
		color = vec3(0.65,0.90,0.75);      // mint
	else if (lum < 0.8)
		color = vec3(0.95,0.80,0.70);      // peach
	else
		color = vec3(1.00,0.95,0.85);      // cream

	// Preserve shading
	color *= lum * 1.4;

	COLOR = vec4(color, tex.a);
}