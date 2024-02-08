#include <bnb/glsl.vert>

BNB_LAYOUT_LOCATION(0)
BNB_IN vec3 attrib_pos;

BNB_OUT(0) vec3 var_uv;

void main()
{
	vec2 v = attrib_pos.xy;
	gl_Position = vec4( v, 0., 1. );
	var_uv = vec3( v*0.5 + 0.5, 0. );

#if defined(BNB_VK_1)
	var_uv.y = 1. - var_uv.y;
#endif
}
