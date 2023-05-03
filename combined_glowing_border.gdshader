shader_type canvas_item;

uniform float max_line_width = 15.0;
uniform float min_line_width = 8.0;
uniform float freq = 60.0;
uniform float block_size = 20.0;
uniform float line_width = 10.0;
uniform vec4 starting_color = vec4(1,1,1,1);
uniform vec4 ending_color = vec4(1,0,0,0);
const float MY_PI = PI;
const int ANG_RES = 16;
const int GRAD_RES = 16;

float hash(vec2 p, float s) {
	return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

float noise(vec2 p, float s) {
	vec2 d = vec2(0, 1);
	vec2 b = floor(p);
	vec2 f = fract(p);
	return mix(
		mix(hash(b + d.xx, s), hash(b + d.yx, s), f.x),
		mix(hash(b + d.xy, s), hash(b + d.yy, s), f.x),
		f.y);
}

float get_line_width(vec2 p, float s) {
	p /= block_size;
	float w = noise(p, s);
	float intensity = 1.0;
	for (int i = 0; i < 3; i++) {
		w = mix(w, noise(p, s), intensity);
		p /= 2.0;
		intensity /= 2.0;
	}
	return mix(max_line_width, min_line_width, w);
}

bool pixel_in_range(sampler2D text, vec2 uv, vec2 dist) {
	float alpha = 0.0;
	for (int i = 0; i < ANG_RES; i++) {
		float angle = 2.0*PI * float(i) / float(ANG_RES);
		vec2 displacement = dist * vec2(cos(angle), sin(angle));
		if (texture(text, uv + displacement).a > 0.0) return true;
	}
	return false;
}

float get_closest_distance(sampler2D text, vec2 uv, vec2 max_dist) {
	// Binary search
	if (!pixel_in_range(text, uv, max_dist)) return -1.0;
	
	float high = 1.0; float low = 0.0;
	
	for (int i = 1; i <= GRAD_RES; i++) {
		float curr = (high + low) / 2.0;
		if (pixel_in_range(text, uv, curr * max_dist)) {
			high = curr;
		}
		else {
			low = curr;
		}
	}
	
	for (int i = 1; i <= GRAD_RES; i++) {
		vec2 dist = float(i) / float(GRAD_RES) * max_dist;
		if (pixel_in_range(text, uv, dist)) {
			return float(i) / float(GRAD_RES);
		}
	}
	return -1.0;
}

void fragment() {
	float time_step = floor(TIME * freq);
	vec2 scaled_dist = TEXTURE_PIXEL_SIZE;
	scaled_dist *= get_line_width(UV / TEXTURE_PIXEL_SIZE, time_step);
	float w = get_closest_distance(TEXTURE, UV, scaled_dist);
	
	if (w > 0.0 && texture(TEXTURE, UV).a < 0.2) {
		//COLOR = mix(starting_color, ending_color, w);
		//COLOR = mix(starting_color, ending_color, w*w);
		//COLOR = mix(starting_color, ending_color, fract(w-TIME));
		COLOR = mix(starting_color, ending_color, tanh(w));
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
	
}

