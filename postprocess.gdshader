shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

//----------------------------------------------------
// Controls
//----------------------------------------------------

uniform float grain_strength : hint_range(0.0,0.02) = 0.0015;
uniform float chromatic_amount : hint_range(0.0,0.002) = 0.00018;
uniform float vignette_strength : hint_range(0.0,1.0) = 0.05;
uniform float saturation : hint_range(0.0,2.0) = 0.96;
uniform float contrast : hint_range(0.5,2.0) = 1.03;

uniform vec3 tint = vec3(
	1.01,
	1.00,
	0.99
);

uniform float color_steps : hint_range(4.0,64.0) = 18.0;
uniform float dither_strength : hint_range(0.0,1.0) = 0.45;

//----------------------------------------------------

float rand(vec2 p){
	return fract(
		sin(dot(p, vec2(12.9898,78.233)))
		*43758.5453123
	);
}

// 4x4 Bayer matrix
float bayer(vec2 p){

	int x = int(mod(p.x,4.0));
	int y = int(mod(p.y,4.0));

	if(y==0){
		if(x==0) return 0.0/16.0;
		if(x==1) return 8.0/16.0;
		if(x==2) return 2.0/16.0;
		return 10.0/16.0;
	}

	if(y==1){
		if(x==0) return 12.0/16.0;
		if(x==1) return 4.0/16.0;
		if(x==2) return 14.0/16.0;
		return 6.0/16.0;
	}

	if(y==2){
		if(x==0) return 3.0/16.0;
		if(x==1) return 11.0/16.0;
		if(x==2) return 1.0/16.0;
		return 9.0/16.0;
	}

	if(x==0) return 15.0/16.0;
	if(x==1) return 7.0/16.0;
	if(x==2) return 13.0/16.0;
	return 5.0/16.0;
}

//----------------------------------------------------

void fragment(){

	vec2 uv = SCREEN_UV;

	vec2 center = uv - vec2(0.5);

	float edge =
		smoothstep(
			0.15,
			0.75,
			length(center)
		);

	vec2 offset =
		normalize(center + vec2(0.0001))
		* chromatic_amount
		* edge;

	float r = texture(screen_texture, uv + offset).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - offset).b;

	vec3 color = vec3(r,g,b);

	//------------------------------------------------
	// Saturation
	//------------------------------------------------

	float gray =
		dot(color, vec3(0.299,0.587,0.114));

	color =
		mix(vec3(gray), color, saturation);

	//------------------------------------------------
	// Contrast
	//------------------------------------------------

	color =
		(color - 0.5)
		* contrast
		+ 0.5;

	//------------------------------------------------
	// Warm tint
	//------------------------------------------------

	color *= tint;

	//------------------------------------------------
	// Ordered dithering
	//------------------------------------------------

	float threshold =
		(bayer(FRAGCOORD.xy)-0.5)
		/ color_steps;

	color += threshold * dither_strength;

	//------------------------------------------------
	// Posterization
	//------------------------------------------------

	color =
		floor(color * color_steps)
		/ color_steps;

	//------------------------------------------------
	// Film grain
	//------------------------------------------------

	float grain =
		rand(uv * 1400.0 + TIME * 2.0)
		- 0.5;

	color += grain * grain_strength;

	//------------------------------------------------
	// Vignette
	//------------------------------------------------

	float vignette =
		smoothstep(
			0.9,
			0.35,
			length(center)
		);

	color *=
		mix(
			1.0,
			vignette,
			vignette_strength
		);

	COLOR = vec4(clamp(color,0.0,1.0),1.0);
}