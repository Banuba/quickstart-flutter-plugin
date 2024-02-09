#include <bnb/glsl.frag>
#include <bnb/lut.glsl>

BNB_IN(0)
vec2 var_uv;
BNB_IN(1)
vec3 var_red_mask;
BNB_IN(2)
vec2 var_bg_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_camera);

BNB_DECLARE_SAMPLER_LUT(2, 3, tex_whitening);
BNB_DECLARE_SAMPLER_2D(4, 5, tex_redmask);


void main()
{
    vec4 camera = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_camera), var_bg_uv);

    float alpha = BNB_TEXTURE_2D(BNB_SAMPLER_2D(tex_redmask), var_uv).g;

    vec3 whitening = BNB_TEXTURE_LUT(camera.rgb, BNB_PASS_SAMPLER_ARGUMENT(tex_whitening));

    float whitening_mask = alpha * var_teeth_whitening_strength.x;

    if(var_teeth_whitening_strength.x >= 1.0)
        whitening_mask = alpha;

    bnb_FragColor = vec4(whitening, whitening_mask);
}
