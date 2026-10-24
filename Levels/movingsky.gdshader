shader_type canvas_item;

uniform float speed = 0.25;
uniform float amplitude = 0.012;
uniform float frequency = 3.0;

void fragment()
{
    vec2 uv = UV;

    // Horizontal wave
    uv.x += sin((uv.y * frequency + TIME * speed) * TAU) * amplitude;

    COLOR = texture(TEXTURE, uv);
}