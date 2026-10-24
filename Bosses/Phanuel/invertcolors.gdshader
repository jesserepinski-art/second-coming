shader_type canvas_item;

uniform float invert_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 inverted = vec3(1.0) - tex.rgb;
	vec3 result = mix(tex.rgb, inverted, invert_amount);
	COLOR = vec4(result, tex.a);
}