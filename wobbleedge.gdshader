shader_type canvas_item;

uniform float amplitude = 3.0;
uniform float speed = 0.4;
uniform float frequency = 10.0;

float hash(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0,0.0));
	float c = hash(i + vec2(0.0,1.0));
	float d = hash(i + vec2(1.0,1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a,b,u.x)
		+ (c-a)*u.y*(1.0-u.x)
		+ (d-b)*u.x*u.y;
}

void fragment()
{
	vec2 uv = UV;

	float border =
		min(
			min(uv.x, 1.0 - uv.x),
			min(uv.y, 1.0 - uv.y)
		);

	// 0 at edge, 1 toward center
	float edge = 1.0 - smoothstep(0.0, 0.15, border);

	float t = TIME * speed;

	vec2 offset =
		(vec2(
			noise(uv * frequency + t),
			noise(uv * frequency - t)
		) - 0.5)
		* amplitude
		* TEXTURE_PIXEL_SIZE
		* edge;

	COLOR = texture(TEXTURE, uv + offset) * COLOR;
}