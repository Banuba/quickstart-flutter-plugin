#include <bnb/glsl.frag>

BNB_IN(0) vec2 var_uv;
BNB_IN(1) vec2 var_mask_uv;

BNB_DECLARE_SAMPLER_2D(0, 1, tex);
BNB_DECLARE_SAMPLER_2D(2, 3, blur_tex);

#define UnsharpAmount 0.05
#define UnsharpThreshold 0.1
#define ALPHA_MULTIPLIER 0.4

void main()
{
	vec3 original = textureLod( BNB_SAMPLER_2D(tex), var_uv, 0. ).rgb;
	vec3 gauss = textureLod( BNB_SAMPLER_2D(blur_tex), var_uv, 0. ).rgb;

	float alpha = ALPHA_MULTIPLIER;

	vec3 difference = gauss - original;
	vec3 curve = clamp(original, 0.0, 1.0);
	float val2 = clamp(length(original.gb) - length(gauss.gb) + 0.5, 0.0, 1.0);
	vec2 case1 = vec2(val2, 1.0 - val2);
	case1 *= case1;
	case1 *= case1;
	case1 = case1 * case1 * 128.0;
	float val2mixAmount = step(val2, 0.5);
	val2 = mix(1.0 - case1.y, case1.x, val2mixAmount);
	vec3 origCurve = mix(curve, original, val2);
	float mixAmount =
		step(UnsharpThreshold * UnsharpThreshold, dot(difference, difference));
	vec3 smoothCol = origCurve + (mixAmount * UnsharpAmount) * difference;
	bnb_FragColor = vec4(mix(original, smoothCol, alpha), 1.0);
}
