#include <bnb/glsl.frag>

BNB_IN(0)
vec2 var_c;

void main()
{
    bnb_FragColor = vec4(var_c, 0., 0.);
}
