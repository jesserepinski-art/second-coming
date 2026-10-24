shader_type spatial;
render_mode unshaded;

//uniforsm
uniform sampler2D noise_tex;
uniform int seed;
uniform vec4 star_color : source_color = vec4(1.0, 0.6, 0.2, 1.0);
uniform int spike_count : hint_range(1, 8) = 4;
uniform float rotation_offset : hint_range(0.0, 6.28) = 0.0;
uniform float flare_intensity : hint_range(0.0, 5.0) = 1.0;

uniform float spike_length : hint_range(0.1, 10.0) = 3.0;
uniform float central_glow_effect : hint_range(0.0, 1.0) = 1.0;
uniform float glow_size : hint_range(0.01, 0.04) = 0.01;
uniform float glow_intensity : hint_range(0.0, 10.0) = 10.0; 
uniform float master_brightness : hint_range(0.0, 5.0) = 1.0;

//alpha controls
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float edge_smoothing : hint_range(0.1, 0.5) = 0.3; //smoothed a little

uniform float inner_thickness : hint_range(0.0, 0.1) = 0.01;
uniform float outer_thickness : hint_range(0.0, 0.1) = 0.01;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 rel = UV - center;
	float dist = length(rel);
	
	//coreglow
	float glow = exp(-dist / glow_size) * glow_intensity;

	float angle = atan(rel.y, rel.x) / (2.0 * PI) + 0.5;
	float radial_noise = texture(noise_tex, vec2(angle + float(seed), float(seed))).r;
	radial_noise = radial_noise * central_glow_effect;
	float burst = (radial_noise / (dist + 0.1)) * 0.5;
	
	//main spikes
	float spikes = 0.0;
	float current_thickness = mix(inner_thickness, outer_thickness, clamp(dist * 2.0, 0.0, 1.0));

	for (int i = 0; i < spike_count; i++) {
		float spike_angle = (float(i) * 6.28318 / float(spike_count)) + rotation_offset;
		vec2 dir = vec2(cos(spike_angle), sin(spike_angle));
		float projection = abs(rel.x * dir.y - rel.y * dir.x);
		float side_mask = step(0.0, dot(rel, dir));
		float line = smoothstep(current_thickness, 0.0, projection) * side_mask;
		spikes = max(spikes, line);
	}
	spikes *= exp(-dist * spike_length);

	//final color
	float combined = (glow + (burst * 0.5) + (spikes * flare_intensity)) * master_brightness;
	
	//alpha sharpness
	float sticker_alpha = smoothstep(alpha_threshold, alpha_threshold + edge_smoothing, combined);

	vec3 final_color = mix(vec3(0.0), star_color.rgb, combined);
	final_color += pow(combined, 4.0);

	//final output
    ALBEDO = final_color;
    ALPHA = sticker_alpha;
}
