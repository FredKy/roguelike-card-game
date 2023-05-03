shader_type canvas_item;
uniform sampler2D emission_texture;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	vec4 emission_color = texture(emission_texture, UV);
	
	if (emission_color.r > 0.f)
	{
		COLOR = (emission_color + vec4(0.f, 1.f,0.f,0.f));
	}
	else
	{
		COLOR = current_color; // We aren't over an emission pixle, so leave alone
	}
}
