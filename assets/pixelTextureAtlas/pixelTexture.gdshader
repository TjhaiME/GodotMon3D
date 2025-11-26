shader_type spatial;

uniform sampler2D atlas_tex;
uniform vec2 uv_offset;
uniform vec2 uv_scale;

void vertex(){}

void fragment() {
	vec2 tile_uv = UV * uv_scale + uv_offset;
	ALBEDO = texture(atlas_tex, tile_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
