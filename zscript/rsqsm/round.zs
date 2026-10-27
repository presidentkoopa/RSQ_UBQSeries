// DODGEABLE BULLETS (on by default; rsqsm_rounds).
//
// In slow motion an enemy's hitscan does not land instantly: it becomes a visible
// round leaving the same muzzle along the same line (the spread already rolled in),
// carrying the same damage, damage type and puff. It flies at rsqsm_round_speed
// at the set depth and speeds up as the world comes back. Step out of its way and
// it misses; the ShieldSaw and the saber stop it like any projectile; when it hits
// it hurts exactly as the shot would have, credited to the shooter (so monsters
// still fight each other over it).
//
// The engine lets a script take a hitscan before it is traced: WorldHitscanPreFired
// returning true cancels it (checked in qzd17.3 p_map.cpp, P_LineAttack).
// Melee (LAF_ISMELEEATTACK, or a reach of 128 or less) is never converted, and
// neither are players' shots: yours leave a fading trail instead (rsqsm_trails).
//
// Near misses whiz and crack (RS_Ballistics' recordings), and buzz your hands.

class RSQSM_Shots : EventHandler
{
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let clock = RSQSM_Clock.Get();
		if (!clock || clock.StoodDown() || !clock.Active()) return false;
		Actor t = e.Thing;
		if (!t || t.player) return false;
		if (RSQSM_Clock.Cv("rsqsm_rounds", 1) == 0) return false;
		if ((e.AttackLineFlags & LAF_ISMELEEATTACK) || e.AttackDistance <= 128) return false;
		// A test trace (no damage, or no interaction: A_CustomBulletAttack aiming its
		// tracer, for one) is not a bullet. Absolute positions are left to the engine.
		if (e.Damage <= 0 || (e.AttackLineFlags & (LAF_NOINTERACT | LAF_ABSPOSITION | LAF_ABSOFFSET))) return false;
		// Only a shooter inside the slowed range: far away the world runs at full speed.
		double f = clock.FactorFor(t, t.Speed);
		if (f >= 0.9999) return false;

		double a = e.AttackAngle, p = e.AttackPitch;     // p: Doom's sign, positive down
		Vector3 dir = (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
		// Where the engine would have traced from: P_LineAttack's shootz.
		Vector3 from = t.pos;
		if (e.AttackLineFlags & LAF_OVERRIDEZ) from.z = t.pos.z + e.AttackZ;
		else from.z = t.pos.z + t.height * 0.5 - t.Floorclip + 8 + e.AttackZ;
		from.xy += (cos(a), sin(a)) * e.AttackOffsetForward + (cos(a - 90), sin(a - 90)) * e.AttackOffsetSide;

		let r = RSQSM_Round(Actor.Spawn("RSQSM_Round", from));
		if (!r) return false;
		r.target = t;
		r.angle = a;
		r.pitch = p;
		r.dmg = e.Damage;
		r.puff = e.AttackPuffType;
		r.maxDist = e.AttackDistance;
		// What the puff would have brought to the hit, as P_LineAttack applies it.
		Name dt = e.DamageType;
		if (r.puff)
		{
			let pd = GetDefaultByType(r.puff);
			if (pd.DamageType != 'None') dt = pd.DamageType;
			r.bTHRUGHOST = pd.bTHRUGHOST;
			r.bSPECTRAL = pd.bSPECTRAL;
			r.bFOILINVUL = pd.bFOILINVUL;
			r.bPAINLESS = pd.bPAINLESS;
			r.bFORCEPAIN = pd.bFORCEPAIN;
		}
		r.DamageType = dt;
		// Already slowed when it leaves the muzzle: the clock is told the factor it was
		// made at (the spawn event comes later, just before its first tic).
		r.baseSpeed = clock.RoundBase();
		r.preFactor = f;
		r.Speed = r.baseSpeed * f;
		r.vel = dir * r.Speed;
		r.CheckMissileSpawn(t.radius);
		return true;
	}

	// Your own shots: a fading trail from the muzzle to where it landed.
	override void WorldHitscanFired(WorldEvent e)
	{
		let clock = RSQSM_Clock.Get();
		if (!clock || clock.StoodDown() || !clock.Active()) return;
		if (!e.Thing || !e.Thing.player) return;
		if (RSQSM_Clock.Cv("rsqsm_trails", 1) == 0) return;
		if (e.AttackLineFlags & LAF_ISMELEEATTACK) return;
		Vector3 a = e.AttackPos, b = e.DamagePosition;
		Vector3 d = level.Vec3Diff(a, b);
		double len = d.Length();
		if (len < 32) return;
		int n = clamp(int(len / 24), 2, 48);
		FSpawnParticleParams pp;
		pp.color1 = RSQSM_CB.Pick(RSQSM_CB.CB_HAVE, 0xFFF0C8);
		pp.style = STYLE_Add;
		pp.flags = SPF_FULLBRIGHT;
		pp.lifetime = 24;
		pp.size = 2.5;
		pp.sizestep = -0.06;
		pp.startalpha = 0.55;
		pp.fadestep = -1;
		for (int i = 1; i < n; i++)
		{
			pp.pos = a + d * (i / double(n));
			level.SpawnParticle(pp);
		}
	}
}

class RSQSM_Round : Actor
{
	int dmg;
	double baseSpeed, preFactor;
	class<Actor> puff;
	double maxDist, flown;
	Actor hit;
	double nearD[MAXPLAYERS];
	bool passed[MAXPLAYERS];

	Default
	{
		Projectile;
		Radius 2;
		Height 2;
		Speed 56;
		Damage 0;
		RenderStyle "Add";
		+NOTELEPORT
		+DONTSPLASH
		-ACTIVATEPCROSS
		-ACTIVATEIMPACT
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		CBLook(self);
		for (int i = 0; i < MAXPLAYERS; i++) nearD[i] = 1e9;
	}

	// COLOUR-BLIND PLAY (rsqa_colorblind, cb.zs): the stock orange streak is dim to a protanope,
	// and your own trail is warm white; with the setting on a round is the series' COULD colour
	// (amber / red / yellow) on its own gradient (AddShaded), and a quarter larger -- it is the
	// thing to dodge -- while your trail turns HAVE (azure / cyan / magenta, RSQSM_Shots).
	static void CBLook(Actor r)
	{
		if (!RSQSM_CB.Mode()) return;
		r.A_SetRenderStyle(1.0, STYLE_AddShaded);
		r.SetShade(RSQSM_CB.Rgb(RSQSM_CB.CB_COULD, RSQSM_CB.Mode()));
		r.Scale = (1.25, 1.25);
	}

	// It hurts exactly as the hitscan would have, and like a hitscan (not like a
	// projectile) it hurts the shooter's own kind: a zombieman's round that finds
	// another zombieman wounds him, and he turns on the shooter. So the hit is dealt
	// here and the engine's projectile rules (same species, no infighting) are
	// skipped: 0 = explode now, 1 = pass through.
	override int SpecialMissileHit(Actor victim)
	{
		if (victim == target) return 1;
		// A hitscan passes everything that is not shootable (columns, lamps, trees).
		if (!victim.bSHOOTABLE) return 1;
		if ((victim.bSPECTRAL && !bSPECTRAL) || (victim.bGHOST && bTHRUGHOST)) return 1;
		hit = victim;
		int done = victim.DamageMobj(self, target, dmg, DamageType, DMG_USEANGLE, angle);
		if (done > 0 && !victim.bNOBLOOD && !victim.bINVULNERABLE && !victim.bDORMANT)
		{
			victim.SpawnBlood(pos, angle + 180, done);
			victim.TraceBleed(done, self);
		}
		return 0;
	}

	override void Tick()
	{
		Vector3 was = pos;
		Super.Tick();
		if (bDestroyed) return;
		if (InStateSequence(CurState, FindState("Death"))) return;
		flown += level.Vec3Diff(was, pos).Length();
		if (flown > maxDist) { Destroy(); return; }
		NearMisses();
	}

	// The closest approach to each player's head: a whiz past, a crack close by.
	private void NearMisses()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || passed[i]) continue;
			let mo = players[i].mo;
			if (!mo || mo == target) continue;
			Vector3 head = (mo.pos.xy, players[i].viewz);
			Vector3 d = level.Vec3Diff(pos, head);
			double dist = (d.x, d.y, d.z * 1.2).Length();
			if (dist < nearD[i]) { nearD[i] = dist; continue; }
			if (nearD[i] > 64) continue;
			// It has passed this player's head.
			passed[i] = true;
			let dv = CVar.FindCVar("developer"); if (dv && dv.GetInt() >= 1) Console.Printf("RSQ_SlowMo: round passed player %d at %.0f units", i, nearD[i]);
			int pick = (int(flown) + i) % 4;
			if (nearD[i] < 22) A_StartSound(pick % 2 ? "rsqsm/crack2" : "rsqsm/crack1", CHAN_AUTO, 0, 1.0, ATTN_STATIC);
			else A_StartSound(String.Format("rsqsm/whiz%d", pick + 1), CHAN_AUTO, 0, 1.0, ATTN_STATIC);
			RSQSM_Buzz.Start(mo, 0, 0.30, 4);
			RSQSM_Buzz.Start(mo, 1, 0.30, 4);
			let clock = RSQSM_Clock.Get();
			if (clock) clock.AddAdrenaline(RSQSM_Clock.Cv("rsqsm_adr_near", 4));
		}
	}

	// Where it lands: on a wall, or on a thing that does not bleed, the shot's own
	// puff (Brutal Doom's sparks and all) and a chip in the wall. A bleeding thing
	// bled in SpecialMissileHit, as a hitscan's victim does.
	void Impact()
	{
		if (!hit || hit.bNOBLOOD || hit.bINVULNERABLE || hit.bDORMANT)
		{
			if (puff) SpawnPuff(puff, pos, angle + 180, angle - 90, 2, 0, hit);
			if (!hit) A_SprayDecal("BulletChip", 12);
		}
	}

	States
	{
	Spawn:
		RSQR A -1 Bright;
		Stop;
	Death:
		TNT1 A 1 Impact();
		Stop;
	}
}
