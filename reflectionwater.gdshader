shader_type canvas_item;

uniform sampler2D reflection_texture : hint_default_transparent;
uniform float ripple_strength : hint_range(0.0, 0.02) = 0.005;
uniform float ripple_speed = 1.5;
uniform float reflection_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;
uniform float overall_opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	vec2 ref_uv = UV;
	ref_uv.x += sin(UV.y * 30.0 + TIME * ripple_speed) * ripple_strength;

	vec4 reflection = texture(reflection_texture, ref_uv);

	vec3 result = mix(base.rgb, reflection.rgb, reflection.a * reflection_opacity);
	result = mix(result, result * tint_color.rgb, tint_strength);

	COLOR = vec4(result, base.a * overall_opacity);
}