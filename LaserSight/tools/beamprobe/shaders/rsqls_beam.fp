// RSQ Laser Sight -- Beam Look: PCVR (owner 2026-11-06, BUGS_1.0 #42). A material shader on the PCVR beam's skin
// (GLDEFS HardwareShader): Unreal 1's living water on the beam. The skin is the grey liquid sheet
// (tools/gen_pcvr_beam.py a), already in the laser's colour (the actor's translation is applied before sampling).
// u runs across the beam, v along it.
//   1. the sheet, its coordinates pushed by crossing sines (UE1's ripple), flowing down the beam;
//   2. a second copy of the sheet at another scale, flowing faster, sharpened to a bright caustic net;
//   3. the bright core across the beam (today's skin's profile), so the edges stay soft.
// The actor's alpha (the beam's brightness and daylight rules) still applies: the engine multiplies after this.

vec4 RsqlsBeam()
{
	const float TAU = 6.28318530718;
	vec2 uv = vTexCoord.st;
	float t = timer;

	vec2 w = uv;
	w.x += 0.05 * sin(TAU * (uv.y * 2.0 + t * 0.45)) + 0.03 * sin(TAU * (uv.y * 5.0 - t * 0.8));
	w.y += 0.06 * sin(TAU * (uv.x + t * 0.3)) - t * 0.35;
	vec4 liquid = getTexel(w);

	vec2 c = vec2(uv.x * 0.8 + 0.04 * sin(TAU * (uv.y * 3.0 + t * 0.6)) + 0.5, uv.y * 0.6 - t * 0.9);
	vec4 caus = getTexel(c);
	float cl = max(caus.r, max(caus.g, caus.b));
	float sharp = cl * cl * cl;

	float r = (uv.x - 0.5) / 0.5;
	float core = exp(-(r * r) / (0.45 * 0.45));

	vec3 col = liquid.rgb * 0.85 + caus.rgb * sharp * 1.6;
	return vec4(col * core, core);
}

void SetupMaterial(inout Material material)
{
	material.Base = RsqlsBeam();
	material.Normal = ApplyNormalMap(vTexCoord.st);
	material.Bright = texture(brighttexture, vTexCoord.st);
}
