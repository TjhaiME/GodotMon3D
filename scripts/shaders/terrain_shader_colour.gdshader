shader_type spatial;

uniform sampler2D heightmap;
uniform float height_scale = 5.0;
uniform float normal_strength = 1.0;

uniform sampler2D detail_tex;
uniform float detail_scale = 10.0;
uniform float detail_strength = 0.75;

// Height-based gradient
uniform vec3 color_bottom = vec3(0.4, 0.4, 0.5);
uniform vec3 color_mid    = vec3(0.5, 0.35, 0.2);
uniform vec3 color_top    = vec3(0.3, 0.7, 0.3);

// Slope-based darkening/blending
uniform vec3 slope_color = vec3(0.3, 0.3, 0.3); // rock tint
uniform float slope_influence = 0.8; // how strong the slope effect is (0–1)

vec2 pixel_uv(vec2 uv) {
    ivec2 res = textureSize(heightmap, 0);
    vec2 tex = uv * vec2(res);
    tex = floor(tex) + vec2(0.5);
    return tex / vec2(res);
}

void vertex() {
    float h = texture(heightmap, pixel_uv(UV)).r;
    VERTEX.y = (h - 0.5) * height_scale;
}

void fragment() {
    vec2 tex_size = vec2(textureSize(heightmap, 0));
    vec2 texel = 1.0 / tex_size;

    vec2 uvC = pixel_uv(UV);
    vec2 uvL = pixel_uv(UV - vec2(texel.x, 0.0));
    vec2 uvR = pixel_uv(UV + vec2(texel.x, 0.0));
    vec2 uvD = pixel_uv(UV - vec2(0.0, texel.y));
    vec2 uvU = pixel_uv(UV + vec2(0.0, texel.y));

    float hL = texture(heightmap, uvL).r;
    float hR = texture(heightmap, uvR).r;
    float hD = texture(heightmap, uvD).r;
    float hU = texture(heightmap, uvU).r;

    vec3 normal = normalize(vec3((hL - hR) * height_scale, 2.0 / normal_strength, (hD - hU) * height_scale));
	//vec3 normal = normalize(vec3((hL - hR), 2.0 / normal_strength, (hD - hU)));

    //float h = texture(heightmap, uvC).r;
	
	// Bilinear interpolation of heightmap color
	ivec2 tex_size2 = textureSize(heightmap, 0);
	vec2 texel2 = 1.0 / vec2(tex_size2);

	// Get the four surrounding texels
	vec2 coord = UV * vec2(tex_size2) - 0.5;
	vec2 frac = fract(coord);
	vec2 base = (floor(coord) + 0.5) / vec2(tex_size2);

	float h00 = texture(heightmap, base).r;
	float h10 = texture(heightmap, base + vec2(texel2.x, 0.0)).r;
	float h01 = texture(heightmap, base + vec2(0.0, texel2.y)).r;
	float h11 = texture(heightmap, base + texel2).r;

	// Bilinear blend
	float h = mix(mix(h00, h10, frac.x), mix(h01, h11, frac.x), frac.y);

	
	
	
	// Small UV-scaled noise pattern (value noise)
	//float n = fract(sin(dot(UV * 456.7, vec2(12.9898, 78.233))) * 43758.5453);
	//h += (n - 0.5) * 0.03; // Add ±3% variation

    // Height-based gradient
    vec3 terrain_color;
    //if (h < 0.4)
        //terrain_color = mix(color_bottom, color_mid, smoothstep(0.2, 0.4, h));
    //else
        //terrain_color = mix(color_mid, color_top, smoothstep(0.4, 0.8, h));

	float height_blend_width = 0.15; // Try 0.1–0.2 for softer look
	if (h < 0.4)
	    terrain_color = mix(color_bottom, color_mid, smoothstep(0.2 - height_blend_width, 0.4 + height_blend_width, h));
	else
	    terrain_color = mix(color_mid, color_top, smoothstep(0.4 - height_blend_width, 0.8 + height_blend_width, h));


    // --- Slope-based darkening ---
    float slope_factor = 1.0 - clamp(normal.y, 0.0, 1.0);
    // Blend towards slope_color based on slope steepness
    terrain_color = mix(terrain_color, slope_color, slope_factor * slope_influence);

	//new bit
    //vec3 terrain_color = ...; // height/slope-based color
    vec3 detail = texture(detail_tex, UV * detail_scale).rgb;
    terrain_color = mix(terrain_color, terrain_color * detail, detail_strength);

    ALBEDO = terrain_color;
    NORMAL = normal;
}
