shader_type canvas_item;

uniform float strength : hint_range(0.0, 3.0) = 1.0;
uniform float sample_radius : hint_range(0.5, 4.0) = 1.5;

void fragment() {
	vec2 texel = TEXTURE_PIXEL_SIZE * sample_radius;
	vec4 original = texture(TEXTURE, UV);

	vec4 sum = vec4(0.0);
	sum += texture(TEXTURE, UV + vec2(-texel.x, -texel.y));
	sum += texture(TEXTURE, UV + vec2(0.0, -texel.y));
	sum += texture(TEXTURE, UV + vec2(texel.x, -texel.y));
	sum += texture(TEXTURE, UV + vec2(-texel.x, 0.0));
	sum += texture(TEXTURE, UV + vec2(texel.x, 0.0));
	sum += texture(TEXTURE, UV + vec2(-texel.x, texel.y));
	sum += texture(TEXTURE, UV + vec2(0.0, texel.y));
	sum += texture(TEXTURE, UV + vec2(texel.x, texel.y));
	vec4 mean = sum / 8.0;

	vec3 result = original.rgb + (original.rgb - mean.rgb) * strength;
	COLOR = vec4(clamp(result, 0.0, 1.0), original.a);
}