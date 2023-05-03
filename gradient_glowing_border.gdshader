shader_type canvas_item;

uniform float line_width = 10.0;
uniform vec4 starting_color = vec4(1,1,1,1);
uniform vec4 ending_color = vec4(1,0,0,0);
const float MY_PI = PI;
const int ANG_RES = 16;
const int GRAD_RES = 16;

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
	vec2 scaled_dist = TEXTURE_PIXEL_SIZE * line_width;
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

