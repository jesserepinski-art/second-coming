shader_type canvas_item;

uniform float tile_size = 16.0;

uniform float strength = 0.8;
uniform float speed = 0.4;

void fragment()
{
    vec2 pixel = UV * TEXTURE_PIXEL_SIZE;
}