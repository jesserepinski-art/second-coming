shader_type canvas_item;

uniform sampler2D noise_texture;
uniform vec2 scroll_speed_1 = vec2(0.015, 0.0);
uniform vec2 scroll_speed_2 = vec2(-0.008, 0.004);
uniform float noise_scale_1 = 2.0;
uniform float noise_scale_2 = 4.0;
uniform float fog_strength = 0.35;
uniform vec4 fog_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	// Two noise samples at different scales/speeds/directions for a layered, drifting fog look
	vec2 uv1 = UV * noise_scale_1 + TIME * scroll_speed_1;
	vec2 uv2 = UV * noise_scale_2 + TIME * scroll_speed_2;

	float noise1 = texture(noise_texture, uv1).r;
	float noise2 = texture(noise_texture, uv2).r;
	float combined_noise = (noise1 * 0.6 + noise2 * 0.4);

	vec3 fogged = mix(base.rgb, fog_color.rgb, combined_noise * fog_strength);
	COLOR = vec4(fogged, base.a);
}