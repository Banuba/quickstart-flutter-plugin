#include <bnb/glsl.frag>

#define PI 6.28318530718
#define DIRECTIONS 3.0 // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
#define QUALITY 4.0     // BLUR QUALITY (Default 4.0 - More is better but slower)
#define SIZE 35.0 


BNB_IN(0) vec4 var_uv;


BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);

BNB_DECLARE_SAMPLER_2D(2, 3, tex_scene);

BNB_DECLARE_SAMPLER_2D(4, 5, tex_lips_mask);


const float eps = 0.0000001;

vec3 hsv2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs( mod( c.x * 6.0 + vec3(0.0,4.0,2.0), 6.0 ) - 3.0 ) - 1.0, 0.0, 1.0 );
	return c.z * mix( vec3(1.0), rgb, c.y );
}

vec3 rgb2hsv( in vec3 c )
{
    vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix( vec4(c.zy, k.wz), vec4(c.yz, k.xy), (c.z < c.y) ? 1.0 : 0.0 );
    vec4 q = mix( vec4(p.xyw, c.x), vec4(c.x, p.yzx), (p.x < c.x) ? 1.0 : 0.0 );
    float d = q.x - min( q.w, q.y );
    return vec3(abs( q.z + (q.w - q.y) / (6.0 * d + eps) ), d / (q.x+eps), q.x );
}

vec2 scale_uv (vec2 uv, float scale){
    return (uv - 0.5) * scale + 0.5;
}

void main()
{
    vec2 uv = scale_uv(var_uv.zw, 0.9);

	vec4 maskColor = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_lips_mask), uv );

	vec3 bg = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_scene), var_uv.xy ).xyz;
	vec3 cam = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_uv.xy ).xyz;

        vec2 radius = SIZE / bnb_SCREEN.xy;

    for (float d = 0.0; d < PI; d += PI / DIRECTIONS) {
        for (float i = 1.0 / QUALITY; i <= 1.0; i += 1.0 / QUALITY) {
            maskColor += BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_lips_mask), uv + vec2(cos(d), sin(d)) * radius * i);
        }
    }
    maskColor /= QUALITY * DIRECTIONS;

	float maskAlpha = maskColor.x;

	bnb_FragColor = vec4(mix(bg, cam, maskAlpha), 1.);
}
