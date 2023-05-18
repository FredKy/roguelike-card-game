shader_type canvas_item;
render_mode unshaded;

uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 dir = UV - center;
	float radius = length(dir)*2.0;
	float angle = atan(dir.x, dir.y)/TAU;
	COLOR = vec4(angle, 0.0, 0.0, 1.0);
}
