shader_type canvas_item;

uniform float sway_speed = 0.4;
uniform float sway_strength = 1.5;
uniform float noise_influence = 0.3;
uniform vec4 lavender_color : source_color = vec4(0.71, 0.65, 0.85, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	vec3 tinted = lavender_color.rgb * luminance;
	vec3 result = mix(tex.rgb, tinted, tint_strength);

	COLOR = vec4(result, tex.a);
}
void vertex() {
	// Assumes the sprite's local origin (0,0) sits at the building's base.
	// VERTEX.y is negative going up in most sprite setups — adjust sign if needed.
	float height_factor = clamp(-VERTEX.y / 400.0, 0.0, 1.0); // tune 400.0 to your building's pixel height

	float primary_sway = sin(TIME * sway_speed) * sway_strength * height_factor;
	float secondary_wobble = sin(TIME * sway_speed * 2.3 + 1.0) * sway_strength * 0.2 * height_factor;

	VERTEX.x += primary_sway + secondary_wobble * noise_influence;
}