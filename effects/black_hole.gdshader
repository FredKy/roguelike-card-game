shader_type canvas_item;
render_mode unshaded;

uniform sampler2D image_texture;
uniform sampler2D image_multiplier;

uniform float effect_scale = 1.0;
uniform float effect_repeat = 1.0;
uniform vec2 effect_center = vec2(0.5, 0.5);
uniform vec2 uv_mod = vec2(1.0);
uniform vec2 scroll_speed = vec2(0.0);

vec2 coordinates(vec2 uv, vec2 center, float scale, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir)*2.0;
	float angle = atan(dir.x, dir.y)/TAU + 0.5;
	return (vec2(angle*repeat, radius/scale));
}

void fragment() {
//	COLOR = vec4(angle, radius, 0.0, 1.0);
	vec2 uv = uv_mod*coordinates(UV, effect_center, effect_scale, effect_repeat);
	vec4 image_tex = texture(image_texture, uv+(TIME*scroll_speed));
	image_tex *= texture(image_multiplier, UV);
	COLOR = image_tex;
}
