shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float danger : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_speed = 5;
uniform float slice_count : hint_range(1.0, 40.0) = 32;

uniform float slice_jump_chance_max : hint_range(0.0, 1.0) = 0.3;
uniform float slice_jump_amount_max : hint_range(0.0, 0.1) = 0.02;
uniform float rgb_shift_max : hint_range(0.0, 0.05) = 0.006;
uniform float desaturation_max : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_max : hint_range(0.0, 1.0) = 0.5;

float rand(float seed) {
	return fract(sin(seed * 12.9898) * 43758.5453);
}

void fragment() {
	vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);

	if (danger <= 0.001) {
		COLOR = tex;
	} else {
		vec2 uv = SCREEN_UV;
		float slice_id = floor(uv.y * slice_count);
		float time_step = floor(TIME * glitch_speed);
		float slice_seed = slice_id + time_step * 17.0;
		float jump_chance = rand(slice_seed);

		if (jump_chance > (1.0 - danger * slice_jump_chance_max)) {
			uv.x += (rand(slice_seed + 0.5) - 0.5) * danger * slice_jump_amount_max;
		}

		vec4 shifted = texture(SCREEN_TEXTURE, uv);

		float shift = danger * rgb_shift_max;
		float r = texture(SCREEN_TEXTURE, uv + vec2(shift, 0.0)).r;
		float g = shifted.g;
		float b = texture(SCREEN_TEXTURE, uv - vec2(shift, 0.0)).b;
		vec3 rgb_split = vec3(r, g, b);

		float gray = dot(rgb_split, vec3(0.299, 0.587, 0.114));
		vec3 desaturated = mix(rgb_split, vec3(gray), danger * desaturation_max);

		float dist = distance(SCREEN_UV, vec2(0.5));
		float vignette = smoothstep(0.4, 0.9, dist) * danger * vignette_max;

		vec3 result = desaturated * (1.0 - vignette);
		COLOR = vec4(result, 1.0);
	}
}