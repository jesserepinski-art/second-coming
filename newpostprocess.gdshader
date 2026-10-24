shader_type canvas_item;

uniform sampler2D grain_texture;
uniform float grain_strength : hint_range(0.0, 1.0) = 0.08;
uniform vec2 grain_scale = vec2(1.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 grain = texture(grain_texture, UV * grain_scale);
	vec3 result = tex.rgb * (1.0 - grain_strength) + tex.rgb * grain.rgb * grain_strength;
	COLOR = vec4(result, tex.a);
}