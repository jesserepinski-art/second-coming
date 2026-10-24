shader_type canvas_item;

uniform sampler2D fixed_pattern : repeat_enable;
uniform vec2 pattern_scale = vec2(0.01, 0.01);
uniform vec2 node_global_position = vec2(0.0, 0.0);

void fragment() {
	vec4 mask = texture(TEXTURE, UV);

	vec2 sprite_size = vec2(textureSize(TEXTURE, 0));
	vec2 local_offset = (UV - 0.5) * sprite_size;
	vec2 world_pos = node_global_position + local_offset;

	vec2 world_uv = world_pos * pattern_scale;
	vec4 pattern_color = texture(fixed_pattern, world_uv);
	COLOR = vec4(pattern_color.rgb, mask.a);
}