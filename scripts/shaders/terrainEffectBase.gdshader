shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;//cull_back;

// --- Terrain mapping ---
uniform sampler2D heightmap;
uniform float height_scale = 5.0;
uniform float normal_strength = 1.0;
uniform sampler2D detail_tex;
uniform float detail_scale = 10.0;
uniform float detail_strength = 0.75;

// Terrain colors
uniform vec3 color_bottom = vec3(0.4, 0.4, 0.5);
uniform vec3 color_mid    = vec3(0.5, 0.35, 0.2);
uniform vec3 color_top    = vec3(0.3, 0.7, 0.3);
uniform vec3 slope_color = vec3(0.3, 0.3, 0.3);
uniform float slope_influence = 0.8;

// Effect settings
uniform vec3 effect_color : source_color = vec3(0.2, 0.6, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec2 effect_center_world = vec2(0.0,0.0);
uniform float world_radius = 5.0;

// Heightmap world mapping
uniform vec2 heightmap_origin_world;
uniform vec2 heightmap_world_size;

// --- Varying ---
varying vec3 world_pos;

// --- Helpers ---
vec2 world_to_height_uv(vec2 world_pos_xz) {
    vec2 uv = (world_pos_xz - heightmap_origin_world) / heightmap_world_size;
    return clamp(uv, vec2(0.0), vec2(1.0));
}

vec2 pixel_uv(vec2 uv) {
    ivec2 res = textureSize(heightmap, 0);
    vec2 tex = uv * vec2(res);
    tex = floor(tex) + vec2(0.5);
    return tex / vec2(res);
}

float sample_height(vec2 uv) {
    vec2 puv = pixel_uv(uv);
    return texture(heightmap, puv).r;
}

vec3 compute_normal(vec2 uv) {
    vec2 tex_size = vec2(textureSize(heightmap, 0));
    vec2 texel = 1.0 / tex_size;

    float hC = sample_height(uv);
    float hL = sample_height(uv - vec2(texel.x, 0.0));
    float hR = sample_height(uv + vec2(texel.x, 0.0));
    float hD = sample_height(uv - vec2(0.0, texel.y));
    float hU = sample_height(uv + vec2(0.0, texel.y));

    return normalize(vec3((hL - hR) * height_scale, 2.0 / normal_strength, (hD - hU) * height_scale));
}

//// --- Vertex ---
//void vertex() {
    //world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
//}

varying vec2 world_xz;

void vertex() {
    // Compute world XZ
    vec3 wp = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
    world_xz = wp.xz;
	/////METHOD 1
    // Sample heightmap
    vec2 uv = world_to_height_uv(world_xz);
    vec2 puv = pixel_uv(uv);
    float h = texture(heightmap, puv).r;
    float terrain_height = (h - 0.5) * height_scale;

    // Offset vertex Y to terrain height
    //VERTEX.y += terrain_height;
	VERTEX.y = terrain_height;
	////METHOD 2
	//vec2 uv = (world_pos.xz - heightmap_origin_world) / heightmap_world_size;
//
	//float h = texture(heightmap, uv).r * height_scale;
	//VERTEX.y = h;

    // Optional small offset so it’s slightly above terrain
    VERTEX.y += 0.02;
}

void fragment() {//minimal version
    //vec2 world_xz = world_pos.xz;
    vec2 uv = world_to_height_uv(world_xz);

    // Fade based on distance from effect center
    float dist = distance(world_xz, effect_center_world);
    float fade = clamp(1.0 - smoothstep(world_radius * 0.8, world_radius, dist), 0.0, 1.0);
    if (fade < 0.01) discard;
    // --- Compute slope normal ---
    vec3 normal = compute_normal(uv);
    ALBEDO = vec3(1.0);//terrain_color;//not really needed since if set to vec3(1.0) it works
    NORMAL = normal; //give it the weird squares of different colours due to lighting
    ALPHA = opacity * fade;//if albedo is 1.0 its still a circle?
}