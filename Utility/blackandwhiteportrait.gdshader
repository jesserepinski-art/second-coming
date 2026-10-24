shader_type canvas_item;

uniform float grayscale_amount : hint_range(0.0, 1.0) = 1.0;

uniform float wobble_speed = 1.5;
uniform float wobble_strength = 2.0;

void vertex() {
	float wobble_x = sin(TIME * wobble_speed + VERTEX.y * 0.05) * wobble_strength;
	float wobble_y = cos(TIME * wobble_speed * 1.3 + VERTEX.x * 0.05) * wobble_strength * 0.5;
	VERTEX += vec2(wobble_x, wobble_y);
}
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 result = mix(tex.rgb, vec3(gray), grayscale_amount);
	COLOR = vec4(result, tex.a);
}