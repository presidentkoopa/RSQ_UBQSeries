// RS_ShieldSawQ -- the world actors: the shield on your back (and in your hand as others
// see it), and the mount's marker. Both are placed by SSQ_Handler every tic; the renderer
// interpolates between tics.

class SSQ_Prop : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTIMEFREEZE
		+INTERPOLATEANGLES
		RenderStyle "Normal";
	}
	States
	{
	Spawn:
		SSQP A -1;
		Stop;
	}
}

class SSQ_MountMarker : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTIMEFREEZE
		+INTERPOLATEANGLES
		RenderStyle "Add";
		Alpha 0.3;
	}
	States
	{
	Spawn:
		SSQM A -1 Bright;
		Stop;
	}
}

// the block: a spark star at the crossing point (RS_CombatFX sparks/RSS1), a short spark
// animation (sparks/RSS0) and, for a blast, the hit bloom (hitflash/RSH0). All additive, all
// short, all cheap on Quest.
class SSQ_BlockFlash : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 1.0;
		Scale 0.35;
	}
	States
	{
	Spawn:
		SSQX A 1 Bright;
		SSQX A 1 Bright A_FadeOut(0.18);
		Wait;
	}
}

class SSQ_SparkPuff : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +FORCEXYBILLBOARD
		RenderStyle "Add";
		Scale 0.9;
	}
	States
	{
	Spawn:
		SSQY ABCDE 2 Bright;
		Stop;
	}
}

class SSQ_BlastBloom : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +FORCEXYBILLBOARD
		RenderStyle "Add";
		Scale 0.6;
	}
	States
	{
	Spawn:
		SSQZ ABCDEFGH 1 Bright;
		Stop;
	}
}
