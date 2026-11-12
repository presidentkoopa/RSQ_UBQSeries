// shotfx.zs (BD 2.0, owner 2026-10-27 20:02): the Dakka look of "True Bullets: On" (2.0.2: was its own
// option "Shot Tracers: Off / Dakka"; owner r3 item 39: True Bullets On = our rounds with the Dakka look, Off = stock BD22).
//
// The shot look of Dakka by ijon (github.com/0dot0repeating/dakka, WTFPL), ported from its DECORATE
// and ACS to ZScript, with its own sprites (DPUF A-E, renamed RSDP here so the two packs can load
// together). Nothing of BD22 is replaced: its puffs, blood, decals, DecorativeTracers stay; this adds.
//
//   THE TRACER   acs/dakka_tracers.h "Dakka_Tracer_Client": additive dots every 12 units from the gun
//                to the puff (density 0 = 12.0), revealed at 256 units a tic (dakka_cl_tracerspeed 256),
//                each dot's alpha the fraction of that tic's 256 units it sits at. A dot is
//                decorate/main/puffs.dec DakkaTracer: scale 0.4 + a*0.1, alpha 0.4 + a*0.1 additive,
//                then every tic 0.1 smaller and 0.1 fainter until gone.
//                Dakka starts it 12 units ahead of the eye; here it starts at the DRAWN MUZZLE
//                (RSQ_Muzzle.Where), so in VR it leaves the barrel you are holding.
//   THE IMPACT   puffs.dec DakkaPuff: by surface (FloorHit: within 8 of the floor, CeilingHit: within 8
//                of the ceiling, else WallHit), one DakkaBulletSpark and three DakkaBulletSpark2 with
//                Dakka's velocity ranges, thrown back toward the shooter (the puff's angle), plus the
//                DPUF A B C D puff (BulletPuff style: translucent 0.5).
//
// HITSCAN mode: on WorldHitscanFired, the tracer runs muzzle -> where the shot landed.
// BULLET mode (playerrounds.zs): the round IS a Dakka shotgun tracer (owner 20:09): its head is the DPUF A
// dot and it lays Dakka's dots behind itself each tic, at its own speed, whatever this option says. With the
// option on, its delivered hitscan also draws the last stretch and the impact. Rails are not traced (the
// Railgun is a railgun); the Ruger is a rifle and always gets one tracer, see IsRuger.
//
// QUEST BUDGET (not in Dakka, which is a PC mod): live dots and sparks are capped. Past the cap a dot
// or spark is simply not spawned. Melee hitscans (LAF_ISMELEEATTACK, a melee weapon held) draw nothing.
//
// sv_rsq_true_bullets (default On) is a server cvar: the sparks are real (bouncing) actors and use playsim random
// numbers (stream rsqdk), so every machine must make the same choice.

class RSQ_DakkaDot : Actor
{
	Default
	{
		+NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +DONTSPLASH; +NOTRIGGER; +FORCEXYBILLBOARD; +NOTELEPORT;
		Radius 0; Height 0;
		RenderStyle "Add";
		Alpha 0.5;
		Scale 0.5;
	}

	double a0;	// Dakka's alphaScalar, 0..1

	override void OnDestroy()
	{
		RSQ_ShotFX.Count(-1, 0);
		Super.OnDestroy();
	}

	States
	{
	Spawn:
		RSDP A 1 Bright { A_SetScale(0.4 + a0 * 0.1); A_SetRenderStyle(0.4 + a0 * 0.1, STYLE_Add); }
	Fade:
		RSDP A 1 Bright { A_SetScale(scale.x - 0.1); A_FadeOut(0.1); if (scale.x <= 0) Destroy(); }
		Loop;
	}
}

class RSQ_DakkaSpark : Actor
{
	Default
	{
		Radius 1; Height 1;
		Projectile;
		-NOGRAVITY;
		+THRUACTORS;
		BounceType "Doom"; +FORCEXYBILLBOARD; +DONTSPLASH; +NOTRIGGER; +NOTELEPORT;
		Gravity 0.5;
		BounceFactor 0.1;
		Damage 0;
		RenderStyle "Add";
		Scale 0.25;
	}

	override void OnDestroy()
	{
		RSQ_ShotFX.Count(0, -1);
		Super.OnDestroy();
	}

	States
	{
	Spawn:
		RSDP A 105 Bright;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RSQ_DakkaSpark2 : RSQ_DakkaSpark
{
	Default { Scale 0.5; }
}

// DakkaPuff's own sprite run (BulletPuff style), after the impact: DPUF AB 4 bright, CD 2
class RSQ_DakkaPuff : Actor
{
	Default
	{
		+NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +DONTSPLASH; +NOTRIGGER; +FORCEXYBILLBOARD; +NOTELEPORT;
		Radius 0; Height 0;
		RenderStyle "Translucent";
		Alpha 0.5;
	}
	States
	{
	Spawn:
		RSDP AB 4 Bright;
		RSDP CD 2;
		Stop;
	}
}

// One tracer being revealed, muzzle to hit, at Dakka's 256 units a tic.
class RSQ_DakkaLine : Thinker
{
	Vector3 from, dir;
	double dist, step, tic;

	const DENSITY = 12.0;	// dakka_cl_tracerdensity 0
	const SPEED = 256.0;	// dakka_cl_tracerspeed default

	static void Draw(Vector3 a, Vector3 b)
	{
		Vector3 d = b - a;
		double len = d.Length();
		if (len < 1)
			return;
		let l = new('RSQ_DakkaLine');
		l.ChangeStatNum(STAT_USER + 7);
		l.from = a;
		l.dir = d / len;
		l.dist = len;
		l.step = (len % DENSITY) / 2;	// Dakka: startPoint = mod(dist, density) / 2
		l.tic = l.step;
		l.Tick();	// the first tic's stretch now, as Dakka's script runs inside the shot
	}

	override void Tick()
	{
		while (step < dist)
		{
			RSQ_ShotFX.PutDot(from + dir * step, tic / SPEED);
			step += DENSITY;
			tic += DENSITY;
			if (tic >= SPEED)
			{
				tic -= SPEED * int(tic / SPEED);
				return;	// the rest next tic
			}
		}
		Destroy();
	}
}

class RSQ_ShotFX : EventHandler
{
	const MAX_DOTS = 600;
	const MAX_SPARKS = 96;

	int dots, sparks;

	static bool On()
	{
		let cv = CVar.FindCVar('sv_rsq_true_bullets');	// "True Bullets: On / Off": one switch for the rounds and their look
		return cv && cv.GetBool() && RSQWS_FX.Enhanced();	// this pack: and Weapon Effects = Enhanced
	}

	static RSQ_ShotFX Get()
	{
		return RSQ_ShotFX(EventHandler.Find('RSQ_ShotFX'));
	}

	static void Count(int d, int s)
	{
		let h = Get();
		if (!h)
			return;
		h.dots = max(0, h.dots + d);
		h.sparks = max(0, h.sparks + s);
	}

	static void PutDot(Vector3 at, double a)
	{
		let h = Get();
		if (!h || h.dots >= MAX_DOTS)
			return;
		let d = RSQ_DakkaDot(Actor.Spawn('RSQ_DakkaDot', at));
		if (!d)
			return;
		d.a0 = clamp(a, 0.0, 1.0);
		h.dots++;
	}

	// The round's own stretch this tic (playerrounds.zs, Bullet mode): Dakka's dots at the round's speed.
	// The round only exists with True Bullets On, and this IS how it looks (owner, 20:09:
	// "dakka has shotgun visuals that [I] want as our bullets").
	static void RoundStep(Vector3 a, Vector3 b, double speed, out double carry)
	{
		Vector3 d = b - a;
		double len = d.Length();
		if (len < 0.01)
			return;
		Vector3 u = d / len;
		double s = carry;
		while (s < len)
		{
			PutDot(a + u * s, s / max(speed, 1.0));
			s += RSQ_DakkaLine.DENSITY;
		}
		carry = s - len;
	}

	static bool Melee(Actor who, int flags)
	{
		return (flags & LAF_ISMELEEATTACK) || RSQ_Ballistics.MeleeHeld(who);
	}

	// where the player's shot visibly starts: the drawn muzzle, else where the engine started it
	static Vector3 Start(PlayerPawn mo, Vector3 engine)
	{
		Vector3 at; bool ok;
		[at, ok] = RSQ_Muzzle.Where(mo);
		return ok ? at : engine;
	}

	int rugerTic, rugerPlayer;

	// THE RUGER (owner 20:05: our mesh is a sniper rifle, and the mesh wins). BD22's Sniper fires three
	// hitscans and two rails on one tic (actors/Weapons/Sniper.dec:261-266): a 50 point-blank ShotgunPuff
	// (range 500), two 50 SniperPuff "penetration" shots (range 15000), a damage-0 Gray "trail effect only"
	// rail (now commented out: no beam) and the 30-damage piercing rail (range 500, colour None: invisible).
	// It is drawn as ONE bullet: the Dakka tracer of the first SniperPuff shot each tic (True Bullets On).
	// With True Bullets Off, Sniper.dec fires BD22's own gray trail rail instead.
	static bool IsRuger(Actor who)
	{
		return who && who.player && who.player.ReadyWeapon && RSQ_Alias.Exact(who.player.ReadyWeapon) == 'Sniper';
	}

	override void WorldHitscanFired(WorldEvent e)
	{
		if (!e.Thing || !On())
			return;	// True Bullets Off: BD22's own hitscan look, no Dakka effect at all (the Ruger included)
		let rnd = RSQ_PlayerRound(e.Thing);
		Actor shooter = rnd ? rnd.target : e.Thing;
		if (!shooter || !shooter.player || Melee(shooter, e.AttackLineFlags))
			return;
		if (IsRuger(shooter))
		{
			Name pn = e.Inflictor ? e.Inflictor.GetClassName() : (rnd && rnd.puffType ? rnd.puffType.GetClassName() : 'None');
			if (pn != 'SniperPuff' && pn != 'SniperPuffDM')
				return;
			if (rnd)
			{	// Bullet mode: the round already drew its flight; the impact only, once
				if (rugerTic == level.maptime && rugerPlayer == shooter.PlayerNumber())
					return;
			}
			else if (rugerTic == level.maptime && rugerPlayer == shooter.PlayerNumber())
				return;
			rugerTic = level.maptime;
			rugerPlayer = shooter.PlayerNumber();
			RSQ_DakkaLine.Draw(e.AttackPos, e.DamagePosition);
			Impact(e.DamagePosition, e.AttackPos);
			return;
		}
		// a hitscan starts at the muzzle already (muzzle.zs re-fires it from there) or, off the muzzle
		// table, at the controller; the round's delivery starts at the round
		RSQ_DakkaLine.Draw(e.AttackPos, e.DamagePosition);
		Impact(e.DamagePosition, e.AttackPos);
	}

	// DakkaPuff's spawn states: which surface, then one Spark and three Spark2 at Dakka's speeds,
	// thrown along the puff's angle (back toward the shooter), and the DPUF puff itself.
	void Impact(Vector3 at, Vector3 from)
	{
		let sec = level.PointInSector(at.xy);
		double fz = sec ? sec.floorplane.ZatPoint(at.xy) : at.z - 100;
		double cz = sec ? sec.ceilingplane.ZatPoint(at.xy) : at.z + 100;
		if (sec && sec.GetTexture(Sector.ceiling) == skyflatnum && cz - at.z < 8)
			return;	// into the sky: nothing to spark off
		Vector3 back = from - at;
		double ang = VectorAngle(back.x, back.y);
		Actor.Spawn('RSQ_DakkaPuff', at);
		if (at.z - fz < 8)
		{	// FloorHit
			Spark('RSQ_DakkaSpark', at, ang, 0, frandom[rsqdk](10.0, 16.0), frandom[rsqdk](-5.0, 5.0), frandom[rsqdk](2.5, 10.0));
			for (int i = 0; i < 3; i++)
				Spark('RSQ_DakkaSpark2', at, ang, 0, frandom[rsqdk](4.0, 14.0), frandom[rsqdk](-3.0, 3.0), frandom[rsqdk](0.5, 4.0));
		}
		else if (cz - at.z < 8)
		{	// CeilingHit
			Spark('RSQ_DakkaSpark', at, ang, -4, frandom[rsqdk](10.0, 32.0), frandom[rsqdk](-5.0, 5.0), -frandom[rsqdk](1.5, 12.0));
			for (int i = 0; i < 3; i++)
				Spark('RSQ_DakkaSpark2', at, ang, -4, frandom[rsqdk](4.0, 24.0), frandom[rsqdk](-3.0, 3.0), -frandom[rsqdk](0.5, 8.0));
		}
		else
		{	// WallHit
			Spark('RSQ_DakkaSpark', at, ang, -4, frandom[rsqdk](3.0, 8.0), frandom[rsqdk](-3.0, 3.0), -frandom[rsqdk](-6.0, 6.0));
			for (int i = 0; i < 3; i++)
				Spark('RSQ_DakkaSpark2', at, ang, -4, frandom[rsqdk](2.0, 6.0), frandom[rsqdk](-2.0, 2.0), -frandom[rsqdk](-4.0, 4.0));
		}
	}

	// A_SpawnItemEx's frame: x forward along the angle, y to the side
	void Spark(class<Actor> cls, Vector3 at, double ang, double zofs, double vx, double vy, double vz)
	{
		if (sparks >= MAX_SPARKS)
			return;
		let s = Actor.Spawn(cls, at + (0, 0, zofs));
		if (!s)
			return;
		double c = cos(ang), n = sin(ang);
		s.vel = (vx * c + vy * n, vx * n - vy * c, vz);
		sparks++;
	}
}
