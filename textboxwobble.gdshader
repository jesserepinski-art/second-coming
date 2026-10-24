shader_type canvas_item;

uniform float wobble_speed = 1.5;
uniform float wobble_strength = 2.0;

void vertex() {
	float wobble_x = sin(TIME * wobble_speed + VERTEX.y * 0.05) * wobble_strength;
	float wobble_y = cos(TIME * wobble_speed * 1.3 + VERTEX.x * 0.05) * wobble_strength * 0.5;
	VERTEX += vec2(wobble_x, wobble_y);
}