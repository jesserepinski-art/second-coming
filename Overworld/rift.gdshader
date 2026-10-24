shader_type canvas_item;

uniform sampler2D swirl_texture : filter_nearest, repeat_enable;
uniform float speed : hint_range(0.0, 10.0) = 1.5;
uniform float stop_motion_fps : hint_range(1.0, 24.0) = 8.0;

uniform vec4 key_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float key_threshold : hint_range(0.0, 0.5) = 0.08;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float color_distance = distance(tex.rgb, key_color.rgb);

	if (color_distance < key_threshold) {
		// --- swirl logic, applied only within the keyed core area ---
		vec2 center = vec2(0.5, 0.5);
		vec2 pixel_coords = UV - center;

		float stepped_time = floor(TIME * stop_motion_fps) / stop_motion_fps;
		float rotation_angle = stepped_time * speed;

		float cos_a = cos(rotation_angle);
		float sin_a = sin(rotation_angle);
		mat2 rotation_matrix = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));

		vec2 rotated_uv = (rotation_matrix * pixel_coords) + center;
		vec4 sampled_color = texture(swirl_texture, rotated_uv);

		COLOR = vec4(sampled_color.rgb, sampled_color.a * tex.a);
	} else {
		COLOR = tex;
	}
}