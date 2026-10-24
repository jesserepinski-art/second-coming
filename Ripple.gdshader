shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float ring_thickness : hint_range(0.0, 0.5) = 0.15;
uniform vec4 ring_color : source_color = vec4(1.0, 1.0, 1.0, 0.6);

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center) * 2.0; // 0 at center, 1 at edge

	float ring_pos = progress;
	float ring_alpha = 1.0 - smoothstep(0.0, ring_thickness, abs(dist - ring_pos));

	float fade_out = 1.0 - progress;

	COLOR = vec4(ring_color.rgb, ring_color.a * ring_alpha * fade_out);
}