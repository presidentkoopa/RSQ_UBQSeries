// RSQ_Accessibility comfort vignette: darkens toward the edge of each eye's view.
// rsqaStrength: how dark the very edge gets (0..1). rsqaInner: where the darkening starts, as a
// fraction of the distance from the middle of the eye to its corner (0..1).
void main()
{
	vec4 c = texture(InputTexture, TexCoord);
	vec2 d = (TexCoord - vec2(0.5)) * 1.41421356;
	float r = length(d);
	float k = smoothstep(rsqaInner, 1.0, r);
	FragColor = vec4(c.rgb * (1.0 - rsqaStrength * k), c.a);
}
