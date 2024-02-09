#include <bnb/glsl.vert>

BNB_LAYOUT_LOCATION(0)
BNB_IN vec3 attrib_pos;

BNB_DECLARE_SAMPLER_2D(0, 1, tex_morphs);

BNB_OUT(0)
vec2 var_c;


const int EXPAND_PASSES = 8;
const float NPUSH = 75.;

void main()
{
    int i = int(gl_InstanceID);

    vec3 vpos = attrib_pos;

    ivec2 ij = ivec2(gl_VertexID % (3308 / 2), gl_VertexID / (3308 / 2));
    vec2 delta = vec2(0.);
    float[28] weights = float[](
        morphs_00[0], morphs_00[1], morphs_00[2], morphs_00[3], morphs_04[0], morphs_04[1], morphs_04[2], morphs_04[3], morphs_08[0], morphs_08[1], morphs_08[2], morphs_08[3], morphs_12[0], morphs_12[1], morphs_12[2], morphs_12[3], morphs_16[0], morphs_16[1], morphs_16[2], morphs_16[3], morphs_20[0], morphs_20[1], morphs_20[2], morphs_20[3], morphs_24[0], morphs_24[1], morphs_24[2], morphs_24[3]
    );
    for (int bsi = 0; bsi < weights.length(); ++bsi)
        delta += texelFetch(BNB_SAMPLER_2D(tex_morphs), ivec2(ij.x, ij.y + bsi * 2), 0).xy * weights[bsi];

    vpos.xy += delta;

    float scale = 1. - float(i) / float(EXPAND_PASSES + 1);
    scale = scale * scale * (3. - 2. * scale); // smoothstep fall-off
    float d0 = float(i) / float(EXPAND_PASSES + 1);
    float d1 = float(i + 1) / float(EXPAND_PASSES + 1);
#ifndef BNB_VK_1
    vec4 npush_scale = vec4(NPUSH * float(i) / float(EXPAND_PASSES), scale * 0.5, d1 - d0, d0 + d1 - 1.);
#else
    vec4 npush_scale = vec4(NPUSH * float(i) / float(EXPAND_PASSES), scale * 0.5, (d1 - d0) * 0.5, (d0 + d1) * 0.5);
#endif

    gl_Position = bnb_MVP * vec4(vpos * (1. + npush_scale.x / length(vpos)), 1.);
    gl_Position.z = gl_Position.z * npush_scale.z + gl_Position.w * npush_scale.w;

    vec4 pos_no_push = bnb_MVP * vec4(vpos, 1.);
    vec4 original_pos = bnb_MVP * vec4(attrib_pos, 1.);
    var_c = npush_scale.y * (original_pos.xy / original_pos.w - pos_no_push.xy / pos_no_push.w);
}
