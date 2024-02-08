#include <bnb/glsl.frag>

#define SOFTSKIN_RADIUS 0.1000
#define RETOUCH_EPSILON 0.000001

vec4 getLuminance4(mat4 color){
    const vec4 rgb2y=vec4(0.333,0.334,0.333,0.0);
    return rgb2y*color;
}
float getLuminance(vec4 color){
    const vec4 rgb2y=vec4(0.333,0.334,0.333,0.0);
    return dot(color,rgb2y);
}
float rand(vec2 co){
    return fract(sin(dot(co.xy,vec2(12.9898,78.233)))*43758.5453);
}
vec4 getWeight(float intens,vec4 nextIntens){
    vec4 lg=log(nextIntens/(intens+RETOUCH_EPSILON));
    lg*=lg;
    return exp(lg*(-1.0/(2.0*SOFTSKIN_RADIUS*SOFTSKIN_RADIUS)));
}
vec4 soften(BNB_DECLARE_SAMPLER_2D_ARGUMENT(tex_camera), vec2 uv, float factor)
{
    vec4 originalColor = textureLod(BNB_SAMPLER_2D(tex_camera),uv,0.);
    vec4 screenColor=originalColor;
    float intens=getLuminance(screenColor);
    float sum=1.0;
    mat4 nextColor;
    vec2 texCoord0 = uv+vec2(-0.00694444,-0.00390625);
    vec2 texCoord1 = uv+vec2(-0.00694444,0.00546875);
    vec2 texCoord2 = uv+vec2(0.00972222,-0.00390625);
    vec2 texCoord3 = uv+vec2(0.00972222,0.00546875);
    nextColor[0]=textureLod(BNB_SAMPLER_2D(tex_camera),texCoord0,0.);
    nextColor[1]=textureLod(BNB_SAMPLER_2D(tex_camera),texCoord1,0.);
    nextColor[2]=textureLod(BNB_SAMPLER_2D(tex_camera),texCoord2,0.);
    nextColor[3]=textureLod(BNB_SAMPLER_2D(tex_camera),texCoord3,0.);
    vec4 nextIntens=getLuminance4(nextColor);
    vec4 curr=0.36787944*getWeight(intens,nextIntens);
    sum+=dot(curr,vec4(1.0));
    screenColor+=nextColor*curr;
    float noise=(rand(uv) -0.5)/30.0;
    screenColor=screenColor/sum+vec4(noise,noise,noise,1.0);
    screenColor=mix(originalColor,screenColor,factor);
    return screenColor;
}