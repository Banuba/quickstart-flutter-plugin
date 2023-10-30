#include <bnb/glsl.vert>
#include <bnb/decode_int1010102.glsl>
#include<bnb/matrix_operations.glsl>
#define bnb_IDX_OFFSET 0
#ifdef BNB_VK_1
#define gl_VertexID gl_VertexIndex
#define gl_InstanceID gl_InstanceIndex
#endif

BNB_LAYOUT_LOCATION(0) BNB_IN vec2 attrib_pos;


BNB_OUT(0) vec4 var_uv;

void main()
{
    vec2 uv = attrib_pos * 0.5 + 0.5;

    uv.y = 1. - uv.y;

    var_uv.zw = uv;

    mat3 nn_mat = mat3(lips_nn_transform[0].xyz, lips_nn_transform[1].xyz, lips_nn_transform[2].xyz);
    gl_Position = vec4((vec3(uv, 1.) * bnb_inverse_trs2d(nn_mat)).xy, 0., 1.);
    var_uv.xy = gl_Position.xy * 0.5 + 0.5;

    #ifdef BNB_VK_1
    var_uv.y = 1. - var_uv.y;
#endif
}