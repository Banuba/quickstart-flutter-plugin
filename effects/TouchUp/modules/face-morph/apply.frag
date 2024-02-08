#include <bnb/glsl.frag>

BNB_IN(0) vec2 var_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_warp);
BNB_DECLARE_SAMPLER_2D(2, 3, tex_frame);

void main()
{
    vec2 o = textureLod(BNB_SAMPLER_2D(tex_warp), var_uv, 0.).xy;
#if defined(BNB_VK_1)
    o = vec2(o.x, -o.y);
#endif
    bnb_FragColor = textureLod(BNB_SAMPLER_2D(tex_frame), var_uv + o, 0.);
}
