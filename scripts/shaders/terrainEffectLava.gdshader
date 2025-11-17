

shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, unshaded, blend_add;//cull_back;

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


uniform vec4 light_color = vec4( 0.32, 0.5, 0.82, 0.5 );
uniform vec4 arc_color = vec4( 0.46, 0.68, 1.0, 1.0 );

uniform vec2 seed = vec2( 0.0, 0.0 );
uniform float speed = 5.1;
uniform float random_scale = 4.6;
uniform float electro_scale = 11.459;

vec2 random( vec2 pos )
{ 
	return fract(
		sin(
			vec2(
				dot(pos, vec2(12.9898,78.233))
			,	dot(pos, vec2(-148.998,-65.233))
			)
		) * 43758.5453
	);
}

float value_noise( vec2 pos )
{
	vec2 p = floor( pos );
	vec2 f = fract( pos );

	float v00 = random( p + vec2( 0.0, 0.0 ) ).x;
	float v10 = random( p + vec2( 1.0, 0.0 ) ).x;
	float v01 = random( p + vec2( 0.0, 1.0 ) ).x;
	float v11 = random( p + vec2( 1.0, 1.0 ) ).x;

	vec2 u = f * f * ( 3.0 - 2.0 * f );

	return mix( mix( v00, v10, u.x ), mix( v01, v11, u.x ), u.y );
}

float noise_tex( vec2 p )
{
	return (
		value_noise( p * 0.984864 ) * 0.5
	+	value_noise( p * 2.543 ) * 0.25
	+	value_noise( p * 9.543543 ) * 0.125
	+	value_noise( p * 21.65436 ) * 0.0625
	+	value_noise( p * 42.0 ) * 0.03125
	+	value_noise( p * 87.135148 ) * 0.015625
	+	value_noise( p * 340.66534654 ) * 0.0078125
	);
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
	vec2 effect_uv = seed + vec2( UV.x + cos( TIME * 1321.21 + UV.y * 348.513 ) * 0.004, UV.y + sin( TIME * 421.21 + UV.x * 314.513 ) * 0.0016 );
	float f = abs( cos( TIME * speed + noise_tex( effect_uv * random_scale ) * electro_scale ) );

	ALBEDO = mix( light_color, arc_color, 1.0 - clamp( ( f - 0.08 ) * 20.0, 0.0, 1.0 ) ).rgb;
	//terrain_color;//not really needed since if set to vec3(1.0) it works
    NORMAL = normal; //give it the weird squares of different colours due to lighting
    ALPHA = 1.0 - clamp( ( f - 0.3 ) * 3.0, 0.0, 1.0 );
	ALPHA *= opacity * fade;//if albedo is 1.0 its still a circle?
}
//
//void fragment( )
//{
	//vec2 uv = seed + vec2( UV.x + cos( TIME * 1321.21 + UV.y * 348.513 ) * 0.004, UV.y + sin( TIME * 421.21 + UV.x * 314.513 ) * 0.0016 );
	//float f = abs( cos( TIME * speed + noise_tex( uv * random_scale ) * electro_scale ) );
//
	//ALBEDO = mix( light_color, arc_color, 1.0 - clamp( ( f - 0.08 ) * 20.0, 0.0, 1.0 ) ).rgb;
	//ALPHA = 1.0 - clamp( ( f - 0.3 ) * 3.0, 0.0, 1.0 );
//}