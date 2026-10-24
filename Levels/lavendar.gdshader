shader_type canvas_item;

uniform vec4 lavender_color : source_color = vec4(0.71, 0.65, 0.85, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	vec3 tinted = lavender_color.rgb * luminance;
	vec3 result = mix(tex.rgb, tinted, tint_strength);

	COLOR = vec4(result, tex.a);
}