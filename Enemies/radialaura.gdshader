shader_type canvas_item;

uniform float pulse_speed = 1.2;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.25;
uniform float flicker_speed = 15.0;
uniform float flicker_strength : hint_range(0.0, 1.0) = 0.1;
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float rand(float seed) {
	return fract(sin(seed * 12.9898) * 43758.5453);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Slow, smooth breathing pulse
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;

	// Fast, irregular flicker layered on top for instability
	float flicker_step = floor(TIME * flicker_speed);
	float flicker = 1.0 - rand(flicker_step) * flicker_strength;

	float brightness = pulse * flicker;

	COLOR = vec4(light_color.rgb * tex.rgb, tex.a * brightness);
}