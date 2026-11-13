// THE CLAW AND ITS CHAIN. The claw is drawn; RSQGR_Core decides everything in WorldTick -- including the claw's FLIGHT
// (owner 2026-11-13 01:xx: "the claw flies, like the OG mod"): while it flies the core moves it jpalomo's 40 units a tic
// along the line it was fired on and decides the bite where it arrives (RSQGR_Core.StepFlight). The claw's own Tick only
// lays the chain from the off hand to it -- and that is why it is an actor: thinkers run in statnum order (players before
// STAT_DEFAULT) after WorldTick, so by the time this Tick runs the player has moved this tic and the chain's hand end is
// where the hand is now, not a tic behind.
//
// The look is jpalomo's (jp_original/): the claw RSGH (open: in flight and coming back) / RSGK (shut: bitten), the chain
// his tenda0 links (RSGL) at his spacing, 5 units apart from 15 units off the hand. Its class name starts "rsq", so RSQ
// SlowMo runs it in real time.
//
// TEST ONLY: rsqgr_chain_look (coordinator 2026-11-13, for the owner to pick a chain look from rig GIFs; no menu row,
// 0 = the look above). Every variant is jpalomo's own art, no new art: 1 = the links a third the size, 3x as many (a
// third the spacing), tinted dark gunmetal (TRNSLATE RSQGR_Gunmetal); 2 = as 1, plus life while the claw flies: a small
// damped sideways ripple along the chain and one bright untinted link running from the hand out to the claw; 3 = as 2,
// the links near-black (RSQGR_ChainBlack) and the running link warm orange (RSQGR_ChainHot). Read when the claw is fired.
class RSQGR_Claw : Actor
{
	enum EPhase
	{
		PH_OUT,       // bitten: the chain is taut from the hand to here
		PH_BACK,      // coming back to the hand
		PH_FLY        // flying out on its chain (the core moves it)
	}

	PlayerPawn owner;
	int phase;
	int age;
	Actor victim;          // what it bit, followed while bitten (null: geometry or nothing)
	Vector3 victimOfs;
	int holdTics;          // PH_OUT: come back by itself after this many tics (0: the core says when)
	Array<RSQGR_Link> links;
	// the flight (RSQGR_Core.StepFlight)
	int pn;
	Vector3 flyDir;
	double flown, flyMax;
	int flyTics;
	int clawId;
	// the test-only chain look
	int chainLook;
	int liveAge;           // tics of flight, for the ripple and the running link
	TranslationID tLink, tHot;

	const CHAIN_START = 15.0;   // jp_grapple, measured: the nearest link to the hand
	const CHAIN_STEP = 5.0;     // and the spacing
	const CHAIN_CAP = 160;      // links at most (jp_grapple peaks at 152); past it they spread
	const BACK_SPEED = 64.0;    // coming back, units a tic
	const LINK_SCALE = 0.125;   // tenda0's 40 px drawn at jp's 5 units
	// the test-only looks 2 and 3
	const RIPPLE_AMP = 2.5;     // units sideways at most
	const RIPPLE_WAVE = 48.0;   // units along the chain per wave
	const RIPPLE_SPIN = 50.0;   // degrees a tic the wave runs out
	const RIPPLE_DAMP = 8.0;    // tics: the ripple dies away over the flight
	const HOT_SPEED = 90.0;     // the running link, units a tic from the hand out

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
		c.SetLook();
		return c;
	}

	// FIRED: it flies open from the hand along dir, out to range (jp's HookShot: OCLW, "hookshot/loop" as it goes)
	static RSQGR_Claw Launch(PlayerPawn owner, int pn, Vector3 from, Vector3 dir, double range, int newId)
	{
		let c = RSQGR_Claw(Actor.Spawn("RSQGR_Claw", from, NO_REPLACE));
		if (!c) return null;
		c.owner = owner;
		c.pn = pn;
		c.flyDir = dir;
		c.flyMax = range;
		c.clawId = newId;
		c.phase = PH_FLY;
		c.SetLook();
		c.SetStateLabel("Open");
		c.A_StartSound("rsqgr/loop", CHAN_BODY, CHANF_LOOPING);
		return c;
	}

	// it bit here (a monster, or the world when bit is null): shut, and held until the core lets it go
	void Bite(Vector3 at, Actor bit)
	{
		phase = PH_OUT;
		SetOrigin(at, true);
		victim = bit;
		if (bit) victimOfs = at - bit.Pos;
		A_StopSound(CHAN_BODY);
		SetStateLabel("Spawn");
	}

	void SetLook()
	{
		chainLook = clamp(RSQGR_Util.Opt("rsqgr_chain_look", 0), 0, 3);
		if (chainLook == 3) tLink = Translate.GetID('RSQGR_ChainBlack');
		else if (chainLook >= 1) tLink = Translate.GetID('RSQGR_Gunmetal');
		if (chainLook == 3) tHot = Translate.GetID('RSQGR_ChainHot');
	}

	bool Flying() { return phase == PH_FLY; }
	bool Held() { return phase == PH_OUT; }

	// let go: it flies back to the hand and is gone
	void Back()
	{
		if (phase == PH_BACK) return;
		phase = PH_BACK;
		victim = null;
		A_StopSound(CHAN_BODY);
		SetStateLabel("Open");
	}

	override void Tick()
	{
		if (!owner || owner.health <= 0) { Destroy(); return; }
		age++;
		Vector3 hand = RSQGR_Util.HandPos(owner);
		if (phase == PH_FLY) liveAge++;
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
		double step = chainLook >= 1 ? CHAIN_STEP / 3.0 : CHAIN_STEP;
		int cap = chainLook >= 1 ? CHAIN_CAP * 3 : CHAIN_CAP;
		int want = avail > 0 ? int(avail / step) + 1 : 0;
		if (want > cap) { step = avail / (cap - 1); want = cap; }
		while (links.Size() > want) { let l = links[links.Size() - 1]; if (l) l.Destroy(); links.Pop(); }
		if (total < 0.001) return;
		Vector3 u = d / total;
		// looks 2 and 3, while it flies: the damped ripple and the running link
		bool live = chainLook >= 2 && phase == PH_FLY;
		double amp = live ? RIPPLE_AMP * exp(-liveAge / RIPPLE_DAMP) : 0;
		Vector3 side = (-u.y, u.x, 0);
		if (side.Length() < 0.001) side = (1, 0, 0); else side = side.Unit();
		int hot = -1;
		if (live && want > 0 && avail > 0)
		{
			double run = liveAge * HOT_SPEED, lap = avail + step;
			hot = int((run - floor(run / lap) * lap) / step);
		}
		for (int k = 0; k < want; k++)
		{
			double s = k * step;
			Vector3 q = hand + u * (CHAIN_START + s);
			if (amp > 0.01 && avail > 0) q += side * (amp * sin(180.0 * s / avail) * sin(s * 360.0 / RIPPLE_WAVE - liveAge * RIPPLE_SPIN));
			if (k >= links.Size()) links.Push(null);
			let l = links[k];
			if (!l)
			{
				l = RSQGR_Link(Spawn("RSQGR_Link", q, NO_REPLACE));
				links[k] = l;
				if (l && chainLook >= 1) { double sc = LINK_SCALE / 3.0; l.Scale = (sc, sc); }
			}
			else l.SetOrigin(q, true);
			if (!l || chainLook < 1) continue;
			bool h = k == hot;
			if (h) l.Translation = tHot;               // look 2's running link: untinted (tHot unset); look 3's: warm orange
			else l.Translation = tLink;
			if (h != l.isHot)
			{
				l.isHot = h;
				if (h) l.SetStateLabel("Hot");
				else l.SetStateLabel("Spawn");
			}
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
	bool isHot;            // test-only looks 2 and 3: the running link, drawn fullbright
	States
	{
	Spawn:
		RSGL A -1;
		Stop;
	Hot:
		RSGL A -1 Bright;
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
