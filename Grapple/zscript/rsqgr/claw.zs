// THE CLAW AND ITS CHAIN. The claw is drawn; RSQGR_Core decides everything in WorldTick. The claw's own Tick only places
// itself and lays the chain from the off hand to it -- and that is why it is an actor: thinkers run in statnum order
// (players before STAT_DEFAULT) after WorldTick, so by the time this Tick runs the player has moved this tic and the
// chain's hand end is where the hand is now, not a tic behind.
//
// The look is jpalomo's (jp_original/): the claw RSGH (open) / RSGK (shut), the chain his tenda0 links (RSGL) at his
// spacing, 5 units apart from 15 units off the hand. Its class name starts "rsq", so RSQ SlowMo runs it in real time.
class RSQGR_Claw : Actor
{
	enum EPhase
	{
		PH_OUT,       // bitten (or reaching): the chain is taut from the hand to here
		PH_BACK       // coming back to the hand
	}

	PlayerPawn owner;
	int phase;
	int age;
	Actor victim;          // what it bit, followed while bitten (null: geometry or nothing)
	Vector3 victimOfs;
	int holdTics;          // PH_OUT: come back by itself after this many tics (0: the core says when)
	Array<RSQGR_Link> links;

	const CHAIN_START = 15.0;   // jp_grapple, measured: the nearest link to the hand
	const CHAIN_STEP = 5.0;     // and the spacing
	const CHAIN_CAP = 160;      // links at most (jp_grapple peaks at 152); past it they spread
	const BACK_SPEED = 64.0;    // coming back, units a tic

	Default
	{
		Radius 4;
		Height 4;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTELEPORT
		+FORCEXYBILLBOARD
		RenderStyle "Normal";
	}

	States
	{
	Spawn:
		RSGK A -1;
		Stop;
	Open:
		RSGH A -1;
		Stop;
	}

	static RSQGR_Claw Make(PlayerPawn owner, Vector3 at, Actor victim)
	{
		let c = RSQGR_Claw(Actor.Spawn("RSQGR_Claw", at, NO_REPLACE));
		if (!c) return null;
		c.owner = owner;
		c.victim = victim;
		if (victim) c.victimOfs = at - victim.Pos;
		c.phase = PH_OUT;
		return c;
	}

	// let go: it flies back to the hand and is gone
	void Back()
	{
		if (phase == PH_BACK) return;
		phase = PH_BACK;
		victim = null;
		SetStateLabel("Open");
	}

	override void Tick()
	{
		if (!owner || owner.health <= 0) { Destroy(); return; }
		age++;
		Vector3 hand = RSQGR_Util.HandPos(owner);
		if (phase == PH_OUT)
		{
			if (victim && !victim.bDestroyed) SetOrigin(victim.Pos + victimOfs, true);
			if (holdTics > 0 && age >= holdTics) Back();
		}
		if (phase == PH_BACK)
		{
			Vector3 d = hand - Pos;
			double l = d.Length();
			if (l <= BACK_SPEED || l < CHAIN_START) { Destroy(); return; }
			SetOrigin(Pos + d / l * BACK_SPEED, true);
		}
		LayChain(hand);
	}

	void LayChain(Vector3 hand)
	{
		Vector3 d = Pos - hand;
		double total = d.Length();
		double avail = total - CHAIN_START;
		int want = avail > 0 ? int(avail / CHAIN_STEP) + 1 : 0;
		double step = CHAIN_STEP;
		if (want > CHAIN_CAP) { step = avail / (CHAIN_CAP - 1); want = CHAIN_CAP; }
		while (links.Size() > want) { let l = links[links.Size() - 1]; if (l) l.Destroy(); links.Pop(); }
		if (total < 0.001) return;
		Vector3 u = d / total;
		for (int k = 0; k < want; k++)
		{
			Vector3 q = hand + u * (CHAIN_START + k * step);
			if (k >= links.Size()) links.Push(null);
			let l = links[k];
			if (!l) { l = RSQGR_Link(Spawn("RSQGR_Link", q, NO_REPLACE)); links[k] = l; }
			else l.SetOrigin(q, true);
		}
	}

	override void OnDestroy()
	{
		for (int k = 0; k < links.Size(); k++) if (links[k]) links[k].Destroy();
		links.Clear();
		Super.OnDestroy();
	}
}

// One link: jpalomo's tenda0 (40 px, drawn at 0.125 = his 5 units). Placed by its claw every tic.
class RSQGR_Link : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTELEPORT
		+FORCEXYBILLBOARD
		RenderStyle "Normal";
		Scale 0.125;
	}
	States
	{
	Spawn:
		RSGL A -1;
		Stop;
	}
	override void Tick() {}
}

// The hook's eyes: walls by their blocking flags, things by whether a claw could bite them.
class RSQGR_Tracer : LineTracer
{
	Actor shooter;
	const WALLMASK = Line.ML_BLOCKEVERYTHING | Line.ML_BLOCKPROJECTILE | Line.ML_BLOCKHITSCAN;

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor)
			return RSQGR_Util.Biteable(Results.HitActor, shooter) ? TRACE_Stop : TRACE_Skip;
		return TRACE_Stop;
	}
}

// THE SPOT the air spike lands on: RSQ Grenade's Neon Crescent goes off where it stands ("g2.neon"). Nothing else.
class RSQGR_Spot : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 70;
		Stop;
	}
}

// THE AIR SPIKE's fire: the IWAD's own flame (Doom II's FIRE, the Arch-vile's; read from the IWAD, not shipped).
class RSQGR_Fire : Actor
{
	Default
	{
		Radius 2;
		Height 2;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 0.9;
	}
	States
	{
	Spawn:
		FIRE ABCDEFGH 3 Bright;
		Stop;
	}
}

// Particles where no art is shipped: the kick's puff without RSQ Melee, the time markers without RSQ VisualRewards, the
// air spike's shockwave ring. Drawn from an invisible helper that lives one tic.
class RSQGR_Fx : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}

	static RSQGR_Fx At(Vector3 p) { return RSQGR_Fx(Actor.Spawn("RSQGR_Fx", p, NO_REPLACE)); }

	// a yellow star puff (the kick without RSQ Melee's MLK4)
	static void Puff(Vector3 p)
	{
		let f = At(p);
		if (!f) return;
		for (int i = 0; i < 24; i++)
		{
			double a = i * 15.0, s = (i & 1) ? 6.0 : 3.0;
			f.A_SpawnParticle(0xFFC83C, SPF_FULLBRIGHT, 14, 5, 0, 0, 0, 0, cos(a) * s, 0, sin(a) * s, 0, 0, 0, 1.0, -1, -0.2);
		}
	}

	// a ring of particles rolling out along the floor
	static void Ring(Vector3 p, double radius, int rgb)
	{
		let f = At(p + (0, 0, 2));
		if (!f) return;
		double sp = radius / 14.0;
		for (int i = 0; i < 48; i++)
		{
			double a = i * 7.5;
			f.A_SpawnParticle(rgb, SPF_FULLBRIGHT, 14, 8, 0, 0, 0, 0, cos(a) * sp, sin(a) * sp, 0.4, 0, 0, 0, 1.0, -1, 0);
		}
	}

	// a small marker over a monster: four motes turning over its head (a time marker without RSQ VisualRewards)
	static void Marker(Actor a, int rgb)
	{
		let f = At(a.Pos + (0, 0, a.Height + 12));
		if (!f) return;
		double t = level.maptime * 12.0;
		for (int i = 0; i < 4; i++)
		{
			double ang = t + i * 90;
			f.A_SpawnParticle(rgb, SPF_FULLBRIGHT, 2, 5, 0, cos(ang) * 8, sin(ang) * 8, 0);
		}
	}
}
