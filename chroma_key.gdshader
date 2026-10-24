shader_type canvas_item;

//======================
// DISTORTION
//======================

uniform float rift_strength : hint_range(0.0,1.0)=0.0;

uniform float wobble_speed = 7.0;
uniform float wobble_amount = 0.035;

uniform float tear_amount = 0.20;
uniform float suck_strength = 0.18;


//======================
// CHROMA
//======================

uniform vec4 chroma_key_color : source_color = vec4(0.0,1.0,0.0,1.0);
uniform float similarity = 0.4;
uniform float smoothness = 0.08;

uniform float black_similarity = 0.05;
uniform float black_smoothness = 0.02;

uniform vec4 magenta_key_color : source_color = vec4(1.0,0.0,1.0,1.0);
uniform float magenta_similarity = 0.25;
uniform float magenta_smoothness = 0.05;


void fragment()
{
    vec2 uv = UV;

    vec2 center = vec2(0.5);

    vec2 p = uv-center;

    float r = length(p);

    //-------------------------------------
    // organic wobble
    //-------------------------------------

    float wobble =
        sin((p.x+p.y)*20.0 + TIME*wobble_speed)
        * wobble_amount;

    wobble *= rift_strength;

    p += normalize(p+0.0001)*wobble;

    //-------------------------------------
    // horizontal tearing
    //-------------------------------------

    p.x +=
        sin(p.y*35.0 + TIME*4.0)
        * tear_amount
        * (1.0-r)
        * rift_strength;

    //-------------------------------------
    // vertical tearing
    //-------------------------------------

    p.y +=
        cos(p.x*28.0 - TIME*3.0)
        * tear_amount
        * 0.6
        * (1.0-r)
        * rift_strength;

    //-------------------------------------
    // suck toward center
    //-------------------------------------

    p *= mix(
        1.0,
        1.0-suck_strength,
        rift_strength
    );

    //-------------------------------------
    // slight rotation
    //-------------------------------------

    float angle =
        rift_strength
        *0.45
        *(1.0-r);

    float c = cos(angle);
    float s = sin(angle);

    vec2 rotated;

    rotated.x = p.x*c-p.y*s;
    rotated.y = p.x*s+p.y*c;

    uv = rotated+center;

    //-------------------------------------
    // sample video
    //-------------------------------------

    vec4 video_color = texture(TEXTURE,uv);

    //-------------------------------------
    // chroma key
    //-------------------------------------

    float diff_chroma =
        distance(video_color.rgb,chroma_key_color.rgb);

    float mask_chroma =
        smoothstep(
            similarity,
            similarity+smoothness,
            diff_chroma
        );

    float diff_black =
        distance(video_color.rgb,vec3(0.0));

    float mask_black =
        smoothstep(
            black_similarity,
            black_similarity+black_smoothness,
            diff_black
        );

    float diff_magenta =
        distance(video_color.rgb,magenta_key_color.rgb);

    float mask_magenta =
        smoothstep(
            magenta_similarity,
            magenta_similarity+magenta_smoothness,
            diff_magenta
        );

    float alpha =
        mask_chroma
        *mask_black
        *mask_magenta;

    COLOR=vec4(
        video_color.rgb,
        video_color.a*alpha
    );
}