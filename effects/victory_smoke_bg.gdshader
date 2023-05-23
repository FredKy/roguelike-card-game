shader_type canvas_item;

/*

Noise value. https://www.youtube.com/watch?v=zXsWftRdsvU&t=285s

all credits to: https://www.youtube.com/channel/UCcAlTqd9zID6aNX3TzwxJXg

*/

uniform float fade : hint_range(0., 1.);

float R21 (vec2 p) {
    return fract(sin(dot(p.xy, vec2(2.3245,5.234)))*3.5632145);
}

float NoiseValue (vec2 uv) {
    vec2 gv = fract(uv);
    vec2 id = floor(uv);
    
    gv = gv * gv * (3. - 2. * gv);

    float a = R21(id);
    float b = R21(id + vec2(1., 0.));
    float c = R21(id + vec2(0., 1.));
    float d = R21(id + vec2(1., 1.));

    return mix(a, b, gv.x) + (c - a)* gv.y * (1. - gv.x) + (d - b) * gv.x * gv.y;
}

float SmoothNoise (vec2 uv) {

    float value = 0.;
    float amplitude = .5;

    for (int i = 0; i < 8; i++) {
        value += NoiseValue(uv) * amplitude;
        uv *= 2.;
        amplitude *= .5;
    }
    
    return value;
}

void fragment() {
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
//	vec4 iRes = vec4(iResolution.x, iResolution.y, FRAGCOORD.z, FRAGCOORD.w);
//	vec4 fraggel = (FRAGCOORD -1.*iRes)/iResolution.y;
    vec2 uv = (FRAGCOORD.xy- 1.*iResolution.xy)/iResolution.y;
//	vec2 uv = fraggel.xy;

    vec3 col = vec3(0.);
    
    vec2 rn = vec2(0.);
    rn.x = SmoothNoise(uv + 1.984 * vec2(1.7,9.2)+ 0.158*TIME );
    rn.y = SmoothNoise(uv + 1. * vec2(8.3,2.8)+ 0.126*TIME);
    
    col += SmoothNoise(uv+rn*2.5);

    COLOR = vec4(col,fade) + vec4(0.4,0.3,0.00,0);
}



//void fragment() {
//	// Place fragment code here.
//}
