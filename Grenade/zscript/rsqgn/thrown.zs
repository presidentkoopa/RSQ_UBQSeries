// RSQ Grenade -- WHAT LEAVES THE HAND. A projectile with the velocity the throw gave it; Doom does the falling, the
// floors and the walls. The flight numbers are RS_Grenade's (the owner's): gravity 0.27 (Doom's gravity is about 2.7x
// a real one, and a throw leaves at what the arm did), floor bounce 0.5, wall bounce 0.25, ground drag 0.82, a lazy
// tumble that settles flat on the floor. Unlike RS_Grenade it also bounces off monsters (the UAC Survival Pack's
// J_ThrownGrenade does, +ALLOWBOUNCEONACTORS), so only the fuse sets it off.
//
// The damage is ITS OWN A_Explode (RS_Grenade's / the pack's numbers: 85 over 200, then 75 over 255), so the kill,
// the obituary and any score go to the player who threw it (target). The look is RSQGN_Blast (blast.zs).
class RSQGN_Thrown : Actor
{
	int fuse;			// tics left (a cooked grenade arrives with less)
	int fuseTotal;
	int flashNext, redUntil;
	bool boomed;
	bool hot;
	bool hotAmber;		// COOK SENSE 2: this flash is amber
	double dmgMult;		// the blast's share (1 unless a node raises it: Teeth, Skeet)
	int sticky;			// STICKY (Gun Bonsai VR patch): its level at the throw
	Actor stuckTo;		// the monster it is stuck to
	Vector3 stuckOfs;
	bool stuckWall;
	int skeetWin;		// SKEET WINDOW (Gun Bonsai VR patch): its level at the throw
	int age, brightUntil;
	int cooked;			// tics it cooked in the hand before the throw (SLOW BURN reads it)
	bool teeth;			// its pin came out by the teeth (RSQGN_Service "teeth", for a scorer)
	bool skeet;			// it was shot out of the air (Skeet; "skeet")
	bool impactHit;		// an Impact grenade that burst on what it touched ("impact")
	int kind;			// THE KINDS (Gun Bonsai VR patch, kinds.zs)
	Vector3 prevVel;
	// SLOW MOTION (11-03): RSQ SlowMo leaves the series' own actors in real time, so the grenade slows itself: its
	// speed, its fall and its fuse run at slowF (RSQGN_Slow.GrenadeFactor: the world's speed, or more with "Faster
	// Grenades in Slow Motion").
	double slowF, baseGrav, fuseAcc;
	// SHOOT THROWN GRENADES (owner 11-03 19:43): a player's shot or projectile within SHOT_R of it sets it off on the
	// spot, once it is SHOT_GRACE tics out of the hand. SHOT_R 12 map units = 0.35 m round its centre at 34 units a
	// metre: the grenade itself is 3 units (9 cm), so a near miss in VR still counts. SHOT_GRACE 6 tics = 0.17 s: at the
	// slowest throw (2.5 m/s) it is 0.43 m out of the hand by then, so a gun fired from the other hand beside it, or the
	// throwing hand's own swing, cannot set it off as it leaves.
	const SHOT_R = 12.0;
	const SHOT_GRACE = 6;

	Default
	{
		Projectile;
		-NOGRAVITY;
		-BLOODSPLATTER;
		Radius 3;
		Height 3;
		Mass 5;
		Speed 20;
		Damage 0;			// the blast does the damage, not the hit
		Gravity 0.27;
		Scale 0.3;			// the pack's sprite size, for the sprite drawn when models are off
		+MOVEWITHSECTOR;
		+FORCEXYBILLBOARD;
		BounceType "Doom";
		BounceFactor 0.5;
		WallBounceFactor 0.25;
		+BOUNCEONACTORS;
		+ALLOWBOUNCEONACTORS;
		+CANBOUNCEWATER;
		BounceSound "rsqgn/bounce";
		DamageType "Explosive";
		Obituary "%o was popped by %k's grenade";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (fuse <= 0) fuse = RSQGN_Handler.FuseTics();
		if (fuseTotal <= 0) fuseTotal = fuse;
		roll = random[RSQGN_Spin](0, 359);
		pitch = random[RSQGN_Spin](0, 359);
	}

	override void Tick()
	{
		if (slowF <= 0) { slowF = 1; baseGrav = Gravity; }	// the throw set its gravity after the spawn
		Slow();
		prevVel = vel;
		Super.Tick();
		if (bDestroyed || boomed || IsFrozen()) return;
		if (age >= SHOT_GRACE && RSQGN_Slow.CanShoot() && ShotByMissile()) return;
		if (sticky > 0) Stick();
		// IMPACT (Gun Bonsai VR patch): it bursts on the first thing it touches -- a bounce (its velocity turned by more
		// than its fall explains) or the floor -- once it is clear of the hand
		if (kind == RSQGN_Kind.IMPACT && age >= 2 && (pos.z <= floorz + 0.5 || (vel - prevVel - (0, 0, -GetGravity())).Length() > 1.0))
		{
			impactHit = true;   // for a scorer (RSQGN_Service "impact"); the old touch on the pawn went nowhere
			Detonate();
			return;
		}
		// the kind's own skin while it is not flashing
		if (kind > 0 && !hot) { sprite = GetSpriteIndex(RSQGN_Kind.ThrownSprite(kind)); frame = 0; }
		age++;
		if (skeetWin > 0 && age == 8) SkeetWindow();
		if (brightUntil > 0 && age >= brightUntil) { bBright = false; brightUntil = 0; }

		bool grounded = pos.z <= floorz + 0.25 || bOnMobj;		// on the floor, or come to rest on top of a monster
		// AT REST IT IS NO LONGER A MISSILE. Doom's bounce switches itself off once a floor bounce comes back under
		// 3 units a tic (BOUNCE_AutoOff clears every bounce flag), and a missile with no bounce that rolls into a wall
		// or a monster explodes on it -- a grenade going off early because it rolled. So once its bouncing is over it
		// becomes a plain thing that slides and stops; only the fuse sets it off.
		if (bMissile && (!bBOUNCEONWALLS || (grounded && abs(vel.z) < 0.6)))
			bMissile = false;

		if (!grounded)
		{
			roll += 3.5;			// RS_Grenade: about one lazy turn per two seconds, not a neat ratio
			pitch += 3.5 * 0.43;
		}
		else
		{
			// lie down: eased onto its side (pitch 90), the short way round
			roll = Normalize180(roll - Normalize180(roll) * 0.25);
			pitch = Normalize180(pitch - Normalize180(pitch - 90) * 0.25);
			double f = clamp(RSQGN_Handler.SNum("rsqgn_friction", 0.82), 0.1, 1.0);
			vel.x *= f;
			vel.y *= f;
			if (vel.xy.Length() < 0.12) { vel.x = 0; vel.y = 0; }
		}

		if (fuse > 0)
		{
			fuseAcc += slowF;			// slow motion: the fuse burns at the grenade's own speed
			int burn = int(fuseAcc);
			fuseAcc -= burn;
			fuse = max(fuse - burn, 0);
			if (level.maptime >= flashNext)
			{
				int per = RSQGN_Handler.FlashPeriod(fuse, fuseTotal);
				redUntil = level.maptime + max(1, per / 2);
				flashNext = level.maptime + per;
				A_StartSound("rsqgn/tick", CHAN_5, CHANF_OVERLAP, fuse < TICRATE ? 0.85 : 0.5);
				if (target && target.player && RSQGN_Handler.Debug(target.player))
					Console.Printf("RSQGN flash thrown t%d period %d left %d at (%.0f %.0f %.0f)%s", level.maptime, per, fuse, pos.x, pos.y, pos.z, bMissile ? "" : " resting");
			}
			bool red = level.maptime < redUntil;
			bool amb = red && RSQGN_Handler.AmberAt(target, fuse, fuseTotal);
			if (red != hot || amb != hotAmber)
			{
				hot = red;
				hotAmber = amb;
				if (amb) SetStateLabel("HotAmber"); else if (red) SetStateLabel("Hot"); else SetStateLabel("Spawn");
			}
		}
		else Detonate();
	}

	// STICKY (Gun Bonsai VR patch, GBOVR_TREES.md 4.5 Blast): the first monster it touches holds it (2: or a wall), and it
	// rides there until the fuse. A stuck-to monster that dies lets it fall.
	void Stick()
	{
		if (stuckTo)
		{
			if (stuckTo.health <= 0 || stuckTo.bDestroyed) { stuckTo = null; bNoGravity = false; return; }
			SetOrigin(stuckTo.pos + stuckOfs, true);
			vel = (0, 0, 0);
			return;
		}
		if (stuckWall) { vel = (0, 0, 0); return; }
		double reach = radius + vel.Length() + 4;
		let it = BlockThingsIterator.Create(self, reach + 64);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || t == self || t == target || !t.bShootable || !t.bIsMonster || t.health <= 0) continue;
			if (abs(t.pos.x - pos.x) > t.radius + reach || abs(t.pos.y - pos.y) > t.radius + reach) continue;
			if (pos.z < t.pos.z - reach || pos.z > t.pos.z + t.height + reach) continue;
			stuckTo = t;
			// on its skin, not inside it: the side it came from, at the height it struck
			Vector3 c = (t.pos.x, t.pos.y, clamp(pos.z, t.pos.z + 4, t.pos.z + t.height - 4));
			Vector2 away = pos.xy - t.pos.xy;
			if (away.Length() < 0.1) away = -vel.xy;
			if (away.Length() < 0.1) away = (1, 0);
			away = away.Unit() * (t.radius + 1);
			stuckOfs = (c.x + away.x, c.y + away.y, c.z) - t.pos;
			bMissile = false; bNoGravity = true; vel = (0, 0, 0);
			A_StartSound("rsqgn/bounce", CHAN_6);
			RSQGN_Upg.Touch("sticky", target, t);
			return;
		}
		if (sticky >= 2 && BlockingLine) { stuckWall = true; bMissile = false; bNoGravity = true; vel = (0, 0, 0); A_StartSound("rsqgn/bounce", CHAN_6); }
	}

	// SKEET WINDOW (Gun Bonsai VR patch): eight tics after the throw slow motion kicks in for 10 + 5 tics a level (through
	// RSQ SlowMo, from the thrower's own machine; the Skeet Window row turns it off) and the grenade draws full bright for
	// that long: a window to line up the shot.
	void SkeetWindow()
	{
		int tics = int(RSQGN_Upg.Num("SkeetWindow.tics", skeetWin, 0));
		if (tics <= 0) return;
		bBright = true;
		brightUntil = age + tics;
		if (target && target.player && target.PlayerNumber() == consoleplayer && RSQGN_Handler.PFlag(target.player, "rsqgn_skeet_window", true))
		{
			let d = CVar.FindCVar("rsm_depth");
			EventHandler.SendNetworkEvent("rsm_pulse", tics * 1000 / TICRATE, int(clamp(d ? d.GetFloat() : 0.25, 0.05, 0.95) * 100));
		}
	}

	// SLOW MOTION: to the factor it should run at now, from the one it ran at (velocity scaled by the ratio, gravity
	// by its square, as RSQ SlowMo does to everything it slows)
	void Slow()
	{
		double want = RSQGN_Slow.GrenadeFactor();
		if (abs(want - slowF) < 0.0005) return;
		vel *= want / slowF;
		Gravity = baseGrav * want * want;
		if (target && target.player && RSQGN_Handler.Debug(target.player))
			Console.Printf("RSQGN slow t%d: world x%.2f, grenade x%.2f (was x%.2f)", level.maptime, RSQGN_Slow.WorldScale(), want, slowF);
		slowF = want;
	}

	// a player's projectile within SHOT_R of it (the rockets, plasma, a thrown thing; not this mod's own grenades).
	// Projectiles are not in the blockmap, so the handler keeps the list of live missiles (RSQGN_Handler.missiles).
	bool ShotByMissile()
	{
		let h = RSQGN_Handler.Get();
		if (!h) return false;
		for (int i = 0; i < h.missiles.Size(); i++)
		{
			let t = h.missiles[i];
			if (!t || t.bDestroyed || !t.bMissile || t.bNoInteraction || !t.target || !t.target.player) continue;
			if (t.GetMissileDamage(0, 1) <= 0) continue;	// a trail, a tracer, smoke: decoration that hurts nothing
			Vector3 c = t.pos + (0, 0, t.height * 0.5) - (pos + (0, 0, height * 0.5));
			if (c.Length() > SHOT_R + t.radius) continue;
			Shot(String.Format("projectile %s", t.GetClassName()), t.target);
			return true;
		}
		return false;
	}

	// SHOT: it goes off where it is. In the air it is a skeet (RSQ Score's Trap Shot reads "skeet"; the Gun Bonsai VR
	// patch's Skeet node adds its multiplier there).
	void Shot(String how, Actor by)
	{
		if (boomed) return;
		bool air = pos.z > floorz + 2 && !bOnMobj;
		if (air)
		{
			skeet = true;
			int lv = RSQGN_Upg.Lv(target, "Skeet");
			if (lv > 0) dmgMult *= RSQGN_Upg.Num("Skeet.mult", lv, 1.0);
		}
		if (target && target.player && RSQGN_Handler.Debug(target.player))
			Console.Printf("RSQGN shot t%d: %s by %s, %s, %d tics out of the hand, x%.2f", level.maptime, how, by ? by.GetClassName() : 'nobody',
				air ? "in the air (skeet)" : "on the ground", age, dmgMult);
		Detonate();
	}

	void Detonate()
	{
		if (boomed) return;
		boomed = true;		// latched first: Tick keeps running after the state change
		bMissile = false;
		vel = (0, 0, 0);
		if (target && target.player && RSQGN_Handler.Debug(target.player))
			Console.Printf("RSQGN boom thrown t%d at (%.0f %.0f %.0f)", level.maptime, pos.x, pos.y, pos.z);
		SetStateLabel("Boom");
	}

	States
	{
	Spawn:
		QGNT A -1;
		Stop;
	// never entered: names the kinds' thrown sprites for MODELDEF.kinds.txt (Tick sets them)
	KindSprites:
		QGT1 A 0; QGT2 A 0; QGT3 A 0; QGT4 A 0; QGT5 A 0; QGT6 A 0; QGT7 A 0; QGT8 A 0;
		Stop;
	Hot:
		QGNT B -1 Bright;
		Stop;
	HotAmber:
		QGNT C -1 Bright;
		Stop;
	// the engine sends a missile here when it cannot bounce (a damaging floor, its bounce count): it goes off
	Death:
		TNT1 A 0 { boomed = true; }
		Goto Boom;
	Boom:
		TNT1 A 0 A_NoBlocking;
		TNT1 A 0 { RSQGN_Kind.Look(self, kind, target); }
		TNT1 A 1 { RSQGN_Thrown.Blast(self, target, 0, dmgMult > 0 ? dmgMult : 1.0); }
		TNT1 A 1 { RSQGN_Thrown.Blast(self, target, 1, dmgMult > 0 ? dmgMult : 1.0); }
		Stop;
	}

	// THE BLAST'S DAMAGE, for the thrown grenade and the one that goes off in the hand: the pack's two A_Explodes (85 over
	// 200, then 75 over 255), called on `at` so the kill is `at`'s target's (the thrower). BIG BANG raises both radii
	// +15% a level, FRAG both damages +15% a level (Gun Bonsai VR patch, read off `by`'s grenade); `mult` is the throw's
	// own share. The second part throws CLUSTER's bomblets.
	static void Blast(Actor at, Actor by, int part, double mult)
	{
		if (!at) return;
		int k = RSQGN_Thrown(at) ? RSQGN_Thrown(at).kind : RSQGN_HandBlast(at) ? RSQGN_HandBlast(at).kind : 0;
		int bb = RSQGN_Upg.Lv(by, "BigBang"), fr = RSQGN_Upg.Lv(by, "Frag");
		// THE KINDS: each does its share of the frag's damage (stun half, freeze and the rest none) and its own thing
		double dk = (fr > 0 ? RSQGN_Upg.Num("Frag.mult", fr, 1.0) : 1.0) * mult * RSQGN_Kind.DamageShare(by, k);
		double rk = bb > 0 ? RSQGN_Upg.Num("BigBang.mult", bb, 1.0) : 1.0;
		if (dk > 0)
		{
			if (part == 0) at.A_Explode(int(85 * dk + 0.5), int(200 * rk + 0.5), XF_HURTSOURCE);
			else at.A_Explode(int(75 * dk + 0.5), int(255 * rk + 0.5), XF_HURTSOURCE);
		}
		if (part == 0) RSQGN_Kind.Effect(at, by, k, 200 * rk);
		if (part == 1 && dk > 0) Cluster(at, by);	// after both parts, so the blast does not shove its own bomblets
	}

	// CLUSTER (Gun Bonsai VR patch): 2 + a level small bomblets thrown 2-4 m out round the blast, each fused a second
	static void Cluster(Actor at, Actor by)
	{
		int lv = RSQGN_Upg.Lv(by, "Cluster");
		if (lv <= 0) return;
		int n = int(RSQGN_Upg.Num("Cluster.count", lv, 0));
		double m = RSQGN_Geo.Vu();
		let gw = by ? Weapon(by.FindInventory("RSQGN_Grenade")) : null;
		for (int i = 0; i < n; i++)
		{
			let b = RSQGN_Bomblet(Actor.Spawn("RSQGN_Bomblet", at.pos + (0, 0, 8), ALLOW_REPLACE));
			if (!b) continue;
			b.target = by;
			if (gw)
			{
				b.master = gw;
				let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
				Service gb = it.Next();
				if (gb) gb.GetInt("claim", "", 0, 0, b);
			}
			// evenly round, a little jitter (the grenade's own synced table, so every machine throws the same)
			double a = i * 360.0 / n + random[RSQGN_Cluster](-20, 20);
			double d = m * frandom[RSQGN_Cluster](2.0, 4.0);
			double up = 4.0;
			double g = b.GetGravity();	// its pull here, units a tic a tic
			double h0 = max(b.pos.z - b.floorz, 0);
			double t = (up + sqrt(up * up + 2 * g * h0)) / max(g, 0.01);	// tics until it reaches the floor
			b.vel = (cos(a) * d / t, sin(a) * d / t, up);
		}
	}
}

// CLUSTER's bomblet (Gun Bonsai VR patch): a small bomb that lands and goes off a second after the blast, 30 over 96, its
// kill the thrower's (target). The look is the pack's own secondary burst (RSQGN_BlastKaboom) and a flare.
class RSQGN_Bomblet : Actor
{
	int fuse;
	Default
	{
		Projectile;
		-NOGRAVITY;
		-BLOODSPLATTER;
		Radius 2;
		Height 2;
		Gravity 0.5;
		Damage 0;
		Scale 0.15;
		BounceType "Doom";
		BounceFactor 0.15;
		WallBounceFactor 0.2;
		+BOUNCEONACTORS;
		+ALLOWBOUNCEONACTORS;
		BounceSound "rsqgn/bounce";
		DamageType "Explosive";
		Obituary "%o was popped by %k's grenade";
	}
	override void PostBeginPlay() { Super.PostBeginPlay(); fuse = TICRATE; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || IsFrozen()) return;
		if (bMissile && (!bBOUNCEONWALLS || (pos.z <= floorz + 0.25 && abs(vel.z) < 0.6))) bMissile = false;
		if (pos.z <= floorz + 0.25) { vel.x *= 0.45; vel.y *= 0.45; }	// it lands and stays near where it fell
		if (fuse > 0 && --fuse == 0) SetStateLabel("Boom");
	}
	States
	{
	Spawn:
		QGNT A -1;
		Stop;
	Death:
		TNT1 A 0 { fuse = 0; }
		Goto Boom;
	Boom:
		TNT1 A 0 A_NoBlocking;
		TNT1 A 0 { bMissile = false; vel = (0, 0, 0); }
		// RS Ballistics' small blasts and RS Combat FX's RSE1 (tools/fxpull.py)
		TNT1 A 0 A_StartSound(String.Format("rsqgn/fx/bomblet%d", random[RSQGN_Fx](1, 3)), CHAN_AUTO, 0, 0.9);
		TNT1 A 0 A_SpawnItemEx("RSQGN_SmallBlast", 0, 0, 8, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Explode(30, 96, XF_HURTSOURCE);
		Stop;
	}
}
