shader_type canvas_item;

uniform float sway_speed = 0.6;
uniform float sway_strength = 3.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.45;
uniform float ripple_speed = 1.2;
uniform float ripple_strength : hint_range(0.0, 0.05) = 0.01;
uniform vec4 lavender_color : source_color = vec4(0.71, 0.65, 0.85, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.6;
void vertex() {
	// Assumes local origin (0,0) is at the tower's point (the tip touching the water),
	// with the structure extending upward in negative-Y screen space.
	float height_factor = clamp(-VERTEX.y / 500.0, 0.0, 1.0); // tune 500.0 to your tower's pixel height

	float primary_sway = sin(TIME * sway_speed) * sway_strength * height_factor;
	float secondary_sway = sin(TIME * sway_speed * 1.7 + 2.0) * sway_strength * 0.3 * height_factor;

	VERTEX.x += primary_sway + secondary_sway;
}

void fragment() {
	// Subtle horizontal ripple distortion, like light refracting through water
	vec2 uv = UV;
	uv.x += sin(UV.y * 20.0 + TIME * ripple_speed) * ripple_strength;

	vec4 tex = texture(TEXTURE, uv);
	COLOR = vec4(tex.rgb, tex.a * opacity);
	float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	vec3 tinted = lavender_color.rgb * luminance;
	vec3 result = mix(tex.rgb, tinted, tint_strength);

	COLOR = vec4(result, tex.a * opacity);
}