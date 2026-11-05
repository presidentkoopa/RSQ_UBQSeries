// GUARD, the move (the owner's pick 55; Quest teardown surveys/01_MELEE.md 4.4, apply/02_MELEE_BUILD.md 2.2 and 5).
// Moved from RSQ Gun Bonsai VR on 2026-11-01: the pose was RSQ_MeleeHandler.Guard (up_melee.zs), the soak
// RSQ_Upgrade_Guard.ModifyDamageReceived (up_suite.zs). The upgrade (Gun Bonsai offering it when the player levels,
// its level, its numbers) stays in Gun Bonsai VR as RSQ_Upgrade_Guard; without Gun Bonsai VR the Guard row
// (rsqml_guard, off) plays it at level 1.
//
// Both hands up at your face for HOLD tics, no gun in either hand (empty hands, fists, the gloves, a melee weapon:
// RSQML.IsSlapperClass), and a blow from in front (within ARC degrees of where you face) is soaked -- you take 60% at
// level 1 (Gun Bonsai VR: 10% less a level, down to 30%) -- and pushes you back a step, with a knock in both hands.
// A blow too big for the guard (35 at level 1, +10 a level) breaks it: full damage, and no guard for STUN tics.
class RSQML_Guard : StaticEventHandler
{
	const HOLD = 4;          // tics both hands must be up (the teardown's GUARD_HOLD)
	const ARC = 55.0;        // degrees either side of your facing (GUARD_ARC)
	const STUN = 14;         // tics without a guard after a break (guardStun)
	const PUSH = 2.0;        // the step back (GUARD_PUSH)
	// THE BOX IS TIGHTER THAN THE TEARDOWN'S. Its numbers (20 map units across, 14 below to 9 above the eyes) took the
	// rig's resting pose -- hands 0.3 m below the eyes, 0.25 m out and 0.3 m forward, held at the chest -- for a guard
	// (measured 2026-11-01). So: each hand within 0.35 m of the head across, from 0.25 m below to 0.15 m above the eyes.
	const GUARD_XY_M = 0.35;
	const GUARD_BELOW_M = 0.25;
	const GUARD_ABOVE_M = 0.15;

	int guardTics[MAXPLAYERS], guardBrokenUntil[MAXPLAYERS];

	// THE GUARD'S TREE (GBOVR_TREES.md 4.1 D; Gun Bonsai VR player nodes after Guard, owner 11-02):
	//   START WITH GUARD  row rsqml_guard_start: with Gun Bonsai VR, Guard at level 1 before it is learned
	//   PARRY             hands driven INTO the blow (PARRY_MPS toward where you face, both hands) inside Parry.window tics
	//                     before it lands: no damage, the attacker knocked back and staggered
	//   REFLECT GUARD     a monster's missile about to hit the raised Guard from in front is sent back at its shooter
	//                     (gloves.zs SendBack); at level 3 a bullet is too (its damage, at the shooter)
	//   ABSORB / RELEASE  what the Guard takes charges it (up to AbsorbRelease.cap, draining 5 a second); RSQ Gestures'
	//                     "both hands apart" (rsqg_pair 1, twohand.zs) throws it out round you
	const PARRY_MPS = 1.0;
	const PARRY_KNOCK = 8.0;
	const DRAIN_PER_SEC = 5.0;
	int pushTic[MAXPLAYERS];
	int upTic[MAXPLAYERS];   // the last tic the Guard was up: a parry drives the hands out of the box, so it counts after
	Vector3 pushPrev[MAXPLAYERS * 2];
	bool pushOk[MAXPLAYERS * 2];
	double charge[MAXPLAYERS];

	static RSQML_Guard Get() { return RSQML_Guard(StaticEventHandler.Find("RSQML_Guard")); }

	override void WorldLoaded(WorldEvent e) { for (int i = 0; i < MAXPLAYERS; i++) { guardTics[i] = 0; guardBrokenUntil[i] = 0; pushTic[i] = -1000; charge[i] = 0; pushOk[i * 2] = false; pushOk[i * 2 + 1] = false; } }

	// THE GUARD'S LEVEL: Gun Bonsai VR's (the player's), or the Guard row's level 1 without it; with Gun Bonsai VR and
	// Start With Guard on, level 1 until it is learned
	static int GuardLevel(PlayerPawn pmo)
	{
		int lv = RSQML.MoveLevel(pmo, null, "Guard", "rsqml_guard");
		if (lv <= 0 && RSQML.GB() && RSQML.SVI("rsqml_guard_start", 0) != 0 && RSQML.SVI("rsqml_guard", 1) != 0) lv = 1;   // the Guard row still decides
		return lv;
	}
	// a player node of the Guard's tree (0 without Gun Bonsai VR: these have no row)
	static int Node(PlayerPawn pmo, String short)
	{
		let gb = RSQML.GB();
		return gb ? gb.GetInt("plevel", short, 0, 0, pmo) : 0;
	}

	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo || players[pn].mo.health <= 0) { guardTics[pn] = 0; continue; }
			let pmo = players[pn].mo;
			RSQML_Body.Ensure(pmo);
			if (charge[pn] > 0) charge[pn] = max(0.0, charge[pn] - DRAIN_PER_SEC / TICRATE);
			if (GuardLevel(pmo) <= 0) { guardTics[pn] = 0; continue; }
			Pose(pn, pmo);
			if (guardTics[pn] >= HOLD)
			{
				int rfLv = Node(pmo, "ReflectGuard");
				if (rfLv > 0) Reflect(pn, pmo, rfLv);
			}
		}
	}

	// THE GUARD POSE. The pawn's position IS the head across: both hand poses are the pawn's position minus the hand's
	// offset from the headset (01_MELEE 3.3), and viewz follows the headset's height.
	void Pose(int pn, PlayerPawn pmo)
	{
		bool up = level.maptime >= guardBrokenUntil[pn] && GuardHands(pmo);
		if (up)
		{
			double upm = RSQML.UnitsPerMetre();
			double zpm = upm / RSQML.Stretch();   // map units a metre, upward
			double eye = pmo.player.viewz;
			// SEATED (RSQ Accessibility's Seated Play, RSQML_A11y.Seated / SeatDrop, asked by name). With QuestZDoom's
			// vr_crouch_use_button on (its default) viewz is the PAWN's eye and stays put when you sit, while your eyes
			// and hands drop (measured on the rig 2026-11-01: headset 1.6 -> 1.2 m, viewz 97 both times, hands 98.5 ->
			// 87.2): seated hands at the face sat 0.35 m under viewz, below the box. So the box goes down with your eyes
			// by Accessibility's measured drop. Standing, or without RSQ Accessibility, the drop is 0.
			let cb = CVar.FindCVar("vr_crouch_use_button");
			if ((!cb || cb.GetBool()) && RSQML_A11y.Seated(pmo)) eye -= max(0.0, RSQML_A11y.SeatDrop(pmo)) * zpm;
			for (int h = 0; h < 2 && up; h++)
			{
				Vector3 hp; bool ok;
				[hp, ok] = RSQML_Hands.Pos(pmo, h);
				if (!ok) { up = false; break; }
				double dz = hp.z - eye;
				if ((hp.xy - pmo.pos.xy).Length() > GUARD_XY_M * upm || dz < -GUARD_BELOW_M * zpm || dz > GUARD_ABOVE_M * zpm) up = false;
			}
		}
		// PARRY's push: both hands driven forward (where you face) at PARRY_MPS or more this tic
		double upm = RSQML.UnitsPerMetre();
		Vector2 fwd = (cos(pmo.angle), sin(pmo.angle));
		int pushing = 0;
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp; bool ok;
			[hp, ok] = RSQML_Hands.Pos(pmo, h);
			int i = pn * 2 + h;
			if (ok && pushOk[i])
			{
				// 2026-11-03: the hand against the BODY (RSQML_HandSync.Body). This read (hp - pos) - (pushPrev - Prev),
				// but Prev is already this tic's position when WorldTick runs (P_Ticker clears interpolation first), so it
				// was the hand's WORLD step: walking forward with the guard up read as a 4.9 m/s push, over PARRY_MPS.
				Vector3 v = (hp - RSQML_HandSync.Body(pmo)) - pushPrev[i];
				if ((v.xy dot fwd) * TICRATE / upm >= PARRY_MPS) pushing++;
			}
			pushPrev[i] = hp - RSQML_HandSync.Body(pmo);
			pushOk[i] = ok;
		}
		if (pushing == 2) pushTic[pn] = level.maptime;
		int was = guardTics[pn];
		guardTics[pn] = up ? min(was + 1, 1000) : 0;
		if (guardTics[pn] >= HOLD) upTic[pn] = level.maptime;
		if (RSQML.Debug() > 0 && (guardTics[pn] == HOLD || (was >= HOLD && !up)))
			Console.Printf("RSQML guard: %s at t%d", up ? "UP" : "down", level.maptime);
	}

	static bool GuardHands(PlayerPawn pmo)
	{
		let p = pmo.player;
		if (!p) return false;
		if (p.ReadyWeapon && !RSQML.IsSlapperClass(p.ReadyWeapon.GetClass(), pmo)) return false;
		if (p.OffhandWeapon && !RSQML.IsSlapperClass(p.OffhandWeapon.GetClass(), pmo)) return false;
		return true;
	}

	// THE GUARD FLASH (the owner's pick, 2026-11-02): where the blow is stopped -- between it and your face, 12 map
	// units (35 cm) from your eyes toward whatever struck (a missile from where it is) -- the Guard spark (sparks.zs
	// MLGD) and stock Doom 2's tick (DSTINK, as rsqml/guard).
	static void Flash(PlayerPawn pawn, Actor from)
	{
		Vector3 eye = RSQML_Hands.EyePos(pawn);
		Vector3 to = from ? from.pos + (0, 0, from.bMissile ? 0.0 : from.height * 0.5) : eye + (cos(pawn.angle), sin(pawn.angle), 0);
		Vector3 d = level.Vec3Diff(eye, to);
		if (d.Length() < 0.01) d = (cos(pawn.angle), sin(pawn.angle), 0);
		d = d.Unit();
		RSQML_Spark.Guard(eye + d * 12.0);
		pawn.A_StartSound("rsqml/guard", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		if (RSQML.Debug() > 0) Console.Printf("RSQML guard flash: %.1f %.1f %.1f from the eyes", d.x * 12, d.y * 12, d.z * 12);
	}

	// A PERFECT (Parry, Reflect Guard): kiddolink's white burst where the Guard flash is, frames by the node's level
	static void Perfect(PlayerPawn pawn, Actor from, double size, int frames)
	{
		Vector3 eye = RSQML_Hands.EyePos(pawn);
		Vector3 to = from ? from.pos + (0, 0, from.bMissile ? 0.0 : from.height * 0.5) : eye + (cos(pawn.angle), sin(pawn.angle), 0);
		Vector3 d = level.Vec3Diff(eye, to);
		if (d.Length() < 0.01) d = (cos(pawn.angle), sin(pawn.angle), 0);
		RSQML_Burst.At("RSQML_Burst4", eye + d.Unit() * 14.0, size, frames);
		pawn.A_StartSound("rsqml/fx/clang", CHAN_AUTO, CHANF_OVERLAP, 1.0);
	}

	// a blow on its way in: what is left of it (called from RSQML_Body's ModifyDamage, the player's own side)
	int Soak(PlayerPawn pawn, int damage, Actor inflictor, Actor source, Name dtype = 'None')
	{
		int pn = pawn.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS || damage <= 0) return damage;
		// PARRY's reach: driving the hands into the blow carries them out of the Guard's box, so a parry counts while the
		// Guard was up within the parry window (both the push and the Guard), not only while it is up now
		int paLv = Node(pawn, "Parry");
		int paWin = paLv > 0 ? int(RSQML.Num("Parry.window", paLv, 0, 4)) : -1;
		bool parry = paLv > 0 && level.maptime - pushTic[pn] <= paWin && level.maptime - upTic[pn] <= paWin;
		if (guardTics[pn] < HOLD && !parry) return damage;
		int lv = GuardLevel(pawn);
		if (lv <= 0) return damage;
		// where the blow came from: a missile from where it is, anything else from who struck (a hazard with no
		// attacker -- slime, a crusher -- is not guarded)
		Actor from = (inflictor && inflictor != source && inflictor.bMissile) ? inflictor : source;
		if (!from || from == pawn) return damage;
		if (Actor.absangle(pawn.AngleTo(from), pawn.angle) > ARC) return damage;
		bool dbg = RSQML.Debug() > 0;
		int absLv = Node(pawn, "AbsorbRelease");
		// PARRY: the hands went into the blow just before it landed: nothing gets through, the attacker reels
		if (parry)
		{
			if (source && source != pawn && source.health > 0 && !source.player)
			{
				if (!source.bDontThrust)
				{
					double a = pawn.AngleTo(source);
					double k = clamp(100.0 / max(source.mass, 1.0), 0.1, 1.5) * (source.bBoss ? 0.3 : 1.0);
					source.vel.xy += (cos(a), sin(a)) * PARRY_KNOCK * k;
				}
				RSQML.Stagger(source, int(RSQML.Num("Parry.stagger", paLv, 0, 26)));
				RSQML.Touch("parry", pawn, source);
			}
			Flash(pawn, from);
			Perfect(pawn, from, 1.0, RSQML_Burst.ByLevel(paLv, 3));
			RSQ_Buzz.Start(pawn, 0, 1.0, 8);
			RSQ_Buzz.Start(pawn, 1, 1.0, 8);
			if (absLv > 0) AddCharge(pn, absLv, damage);
			if (dbg) Console.Printf("RSQML guard: PARRY of %d from %s (pushed %d tics before)", damage, from.GetClassName(), level.maptime - pushTic[pn]);
			return 0;
		}
		// REFLECT GUARD 3: a bullet (no missile) is sent back at whoever fired it
		int rfLv = Node(pawn, "ReflectGuard");
		if (rfLv >= 3 && from == source && source && source.health > 0 && !source.player && dtype != 'Melee' && pawn.Distance2D(source) > 96 && damage < RSQML.Num("Guard.break", lv, 0, 35))
		{
			int back = int(round(damage * RSQML.Num("ReflectGuard.mult", rfLv, 0, 1.75)));
			Flash(pawn, from);
			Perfect(pawn, from, 0.6, 0);
			RSQML.Touch("guard.reflect", pawn, source);
			if (absLv > 0) AddCharge(pn, absLv, damage);
			if (dbg) Console.Printf("RSQML guard: bullet of %d sent back at %s for %d", damage, source.GetClassName(), back);
			source.DamageMobj(pawn, pawn, back, 'Hitscan', DMG_THRUSTLESS);
			return 0;
		}
		// the upgrade's numbers (Gun Bonsai VR's RSQ_Upgrade_Guard.BreakAt / Soak); level 1's without it
		double brk = RSQML.Num("Guard.break", lv, 0, 35);
		if (damage >= brk)
		{
			guardTics[pn] = 0;
			guardBrokenUntil[pn] = level.maptime + STUN;
			pawn.A_StartSound("rsqml/smash", CHAN_AUTO, 0, 1.0);
			RSQ_Buzz.Start(pawn, 0, 1.0, 10);
			RSQ_Buzz.Start(pawn, 1, 1.0, 10);
			if (dbg) Console.Printf("RSQML guard: BROKEN by %d from %s", damage, from.GetClassName());
			return damage;
		}
		double away = pawn.AngleTo(from) + 180;
		pawn.vel.xy += (cos(away), sin(away)) * PUSH;
		if (pawn.player) pawn.player.keepmomentum = true;   // a bare Vel write is erased next tic (player.zs)
		Flash(pawn, from);
		pawn.A_StartSound("rsqml/punch", CHAN_AUTO, 0, 0.5);
		RSQ_Buzz.Start(pawn, 0, 0.6, 6);
		RSQ_Buzz.Start(pawn, 1, 0.6, 6);
		double k = RSQML.Num("Guard.soak", lv, 0, 0.6);
		int left = int(round(damage * k));
		if (absLv > 0) AddCharge(pn, absLv, damage - left);
		if (dbg) Console.Printf("RSQML guard: soaked %d -> %d from %s", damage, left, from.GetClassName());
		RSQML.Touch("guard", pawn, source);
		return left;
	}

	// ABSORB: what the Guard took goes into the charge, up to the cap
	void AddCharge(int pn, int lv, double amount)
	{
		if (amount <= 0) return;
		charge[pn] = min(charge[pn] + amount, RSQML.Num("AbsorbRelease.cap", lv, 0, 150));
		if (RSQML.Debug() > 0) Console.Printf("RSQML guard: charge %.0f", charge[pn]);
	}

	// RELEASE (RSQ Gestures' "both hands apart", twohand.zs): the charge goes out round you, each monster in reach takes
	// it and is thrown back. 1 when there was a charge to throw.
	int Release(PlayerPawn pmo)
	{
		int pn = pmo.PlayerNumber();
		int lv = Node(pmo, "AbsorbRelease");
		if (lv <= 0 || charge[pn] < 1) return 0;
		int dmg = int(charge[pn]);
		charge[pn] = 0;
		double r = RSQML.Num("AbsorbRelease.radius", lv, 0, 4.0) * RSQML.UnitsPerMetre();
		int n = 0;
		let it = BlockThingsIterator.Create(pmo, r);
		while (it.Next())
		{
			let o = it.thing;
			if (!RSQML.IsFoe(pmo, o) || pmo.Distance2D(o) > r + o.radius) continue;
			if (o.pos.z > pmo.pos.z + pmo.height + 32 || o.pos.z + o.height < pmo.pos.z - 32) continue;
			n++;
			RSQML.Touch("guard.release", pmo, o);
			o.DamageMobj(pmo, pmo, dmg, 'Melee', DMG_THRUSTLESS);
			if (!o || o.health <= 0 || o.bDontThrust) continue;
			double a = pmo.AngleTo(o);
			double k = clamp(100.0 / max(o.mass, 1.0), 0.1, 1.5) * (o.bBoss ? 0.3 : 1.0);
			o.vel.xy += (cos(a), sin(a)) * 12.0 * k;
			o.vel.z += 4.0 * k;
		}
		pmo.A_StartSound("rsqml/fx/release", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		RSQML_Spark.Guard(RSQML_Hands.EyePos(pmo) + (cos(pmo.angle), sin(pmo.angle), 0) * 12.0);
		RSQML_Burst.At("RSQML_BurstE", pmo.pos + (0, 0, pmo.height * 0.5), 2.0, 0);
		RSQ_Buzz.Start(pmo, 0, 1.0, 12);
		RSQ_Buzz.Start(pmo, 1, 1.0, 12);
		if (RSQML.Debug() > 0) Console.Printf("RSQML guard: RELEASE %d round you (%.0f units), %d hit", dmg, r, n);
		return 1;
	}

	// REFLECT GUARD: a monster's missile about to hit you from in front, while the Guard is up, goes back at its shooter
	void Reflect(int pn, PlayerPawn pmo, int lv)
	{
		let gl = RSQML_Gloves.Get();
		if (!gl) return;
		Vector3 eye = RSQML_Hands.EyePos(pmo);
		for (int i = gl.missiles.Size() - 1; i >= 0; i--)
		{
			let m = gl.missiles[i];
			if (!m || !m.bMissile || m.bDestroyed) continue;
			let from = m.target;
			if (!from || from.player || !from.bIsMonster || from.bFriendly) continue;
			double reach = pmo.radius + m.radius + m.vel.Length() + 4;
			if (pmo.Distance2D(m) > reach) continue;
			if (m.pos.z + m.height < pmo.pos.z || m.pos.z > pmo.pos.z + pmo.height + 8) continue;
			if (Actor.absangle(pmo.AngleTo(m), pmo.angle) > ARC) continue;
			int dmg = m.GetMissileDamage(7, 1);   // the roll it would have hit you for (Doom's own: damage x 1-8)
			Vector3 d = level.Vec3Diff(eye, m.pos);
			Vector3 at = eye + (d.Length() > 0.01 ? d.Unit() : (cos(pmo.angle), sin(pmo.angle), 0)) * 12.0;
			gl.SendBack(pmo, m, from, at, 1.0, RSQML.Num("ReflectGuard.mult", lv, 0, 1.25), null, (cos(pmo.angle), sin(pmo.angle), 0), 2);
			Flash(pmo, m);
			Perfect(pmo, m, 0.6, RSQML_Burst.ByLevel(lv, 3));
			RSQML.Touch("guard.reflect", pmo, from);
			int absLv = Node(pmo, "AbsorbRelease");
			if (absLv > 0) AddCharge(pn, absLv, dmg);
			if (RSQML.Debug() > 0) { String fn = from.GetClassName(); Console.Printf("RSQML guard: REFLECT %s back at %s", m.GetClassName(), fn); }
		}
	}
}

// WHAT THE PLAYER CARRIES FOR MELEE'S DAMAGE: the Guard's soak (a blow on its way in) and Hadouken's harder hit (a
// missile a glove sent back, on its way out). An item, because an item's ModifyDamage is the engine's own place to
// change a blow on either side (Actor.GetModifiedDamage: passive = received). Given to every player while Melee is
// loaded; it does nothing on its own.
class RSQML_Body : Inventory
{
	const SHIELD_ARC = 60.0;   // Human Shield: degrees either side of the held monster that it covers
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE +INVENTORY.QUIET }

	static void Ensure(PlayerPawn pmo)
	{
		if (pmo && !pmo.FindInventory("RSQML_Body")) pmo.GiveInventoryType("RSQML_Body");
	}

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		let pawn = PlayerPawn(owner);
		if (!pawn || damage <= 0) return;
		if (passive)
		{
			// HUMAN SHIELD 2-3 (Gun Bonsai VR, the off glove): the monster you hold takes the blows meant for you from its
			// side (within SHIELD_ARC of it), x1.5 at level 3
			let hl = RSQML_Headlock.Get();
			int pn = pawn.PlayerNumber();
			Actor held = (hl && pn >= 0 && pn < MAXPLAYERS) ? hl.collar[pn] : null;
			if (held && held.health > 0 && inflictor != held && source != held)
			{
				int hsLv = RSQML.GrappleLevel(pawn, "HumanShield");
				Actor from = (inflictor && inflictor != source) ? inflictor : source;
				if (hsLv >= 2 && from && Actor.absangle(pawn.AngleTo(from), pawn.AngleTo(held)) <= SHIELD_ARC)
				{
					int onIt = int(round(damage * RSQML.Num("HumanShield.mult", hsLv, 0, 1.0)));
					if (RSQML.Debug() > 0) Console.Printf("RSQML human shield: %s took %d meant for you", held.GetClassName(), onIt);
					RSQML.Touch("shield.human", pawn, held);
					held.DamageMobj(inflictor, source, onIt, damageType, DMG_THRUSTLESS);
					newdamage = 0;
					return;
				}
			}
			let g = RSQML_Guard.Get();
			if (g) newdamage = g.Soak(pawn, damage, inflictor, source, damageType);
			return;
		}
		// THROW INTO: a monster you threw out of the Headlock hits for its multiplier (headlock.zs RSQML_ThrownInto)
		double ti = RSQML_ThrownInto.MultFor(inflictor, pawn);
		if (ti > 0)
		{
			newdamage = int(round(damage * ti));
			if (RSQML.Debug() > 0) Console.Printf("RSQML throw into: %d -> %d", damage, newdamage);
			return;
		}
		// A MISSILE SENT BACK (Hadouken, Swat Back, Reflect Guard) hits for its multiplier (gloves.zs SendBack)
		let gl = RSQML_Gloves.Get();
		double mult = gl ? gl.MultOfReturned(inflictor) : 0;
		if (mult <= 0) return;
		newdamage = int(round(damage * mult));
		if (RSQML.Debug() > 0) Console.Printf("RSQML returned missile hit: %d -> %d (x%.2f)", damage, newdamage, mult);
	}
}
