// RSQ_SlowMo colour drain: mixes the scene toward its own luminance (Rec. 709 weights).
// rsqsmDrain: 0 untouched .. 1 grey. Desaturation only: 10_TIME §4.5's VR caution (no vignette,
// no aberration, no warp, which break stereo fusion).
void main()
{
	vec4 c = texture(InputTexture, TexCoord);
	float l = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
	FragColor = vec4(mix(c.rgb, vec3(l), rsqsmDrain), c.a);
}
