shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_speed = 8.0;
uniform float slice_count : hint_range(1.0, 40.0) = 12.0;
uniform float rgb_shift_amount : hint_range(0.0, 0.05) = 0.0;

uniform float sway_speed = 1.0;
uniform float sway_angle_degrees : hint_range(0.0, 45.0) = 8.0;

void vertex() {
	float angle = radians(sin(TIME * sway_speed) * sway_angle_degrees);
	float c = cos(angle);
	float s = sin(angle);
	mat2 rot = mat2(vec2(c, -s), vec2(s, c));
	VERTEX = rot * VERTEX;
}

float rand(float seed) {
	return fract(sin(seed * 12.9898) * 43758.5453);
}

void fragment() {
	vec4 base_tex = texture(TEXTURE, UV);

	if (glitch_intensity <= 0.001) {
		COLOR = base_tex;
	} else {
		vec2 uv = UV;

		float slice_id = floor(uv.y * slice_count);
		float time_step = floor(TIME * glitch_speed);
		float slice_seed = slice_id + time_step * 17.0;

		float jump_chance = rand(slice_seed);
		float offset = 0.0;

		if (jump_chance > (1.0 - glitch_intensity * 0.5)) {
			offset = (rand(slice_seed + 0.5) - 0.5) * glitch_intensity * 0.15;
		}

		uv.x += offset;

		float shift = rgb_shift_amount * glitch_intensity;
		float r = texture(TEXTURE, uv + vec2(shift, 0.0)).r;
		float g = texture(TEXTURE, uv).g;
		float b = texture(TEXTURE, uv - vec2(shift, 0.0)).b;
		float a = texture(TEXTURE, uv).a;

		vec3 result = vec3(r, g, b);

		if (jump_chance > (1.0 - glitch_intensity * 0.15)) {
			a *= (1.0 - glitch_intensity * 0.6);
		}

		COLOR = vec4(result, a);
	}
}