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

	static RSQML_Guard Get() { return RSQML_Guard(StaticEventHandler.Find("RSQML_Guard")); }

	override void WorldLoaded(WorldEvent e) { for (int i = 0; i < MAXPLAYERS; i++) { guardTics[i] = 0; guardBrokenUntil[i] = 0; } }

	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo || players[pn].mo.health <= 0) { guardTics[pn] = 0; continue; }
			let pmo = players[pn].mo;
			RSQML_Body.Ensure(pmo);
			if (RSQML.MoveLevel(pmo, null, "Guard", "rsqml_guard") <= 0) { guardTics[pn] = 0; continue; }
			Pose(pn, pmo);
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
		int was = guardTics[pn];
		guardTics[pn] = up ? min(was + 1, 1000) : 0;
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

	// a blow on its way in: what is left of it (called from RSQML_Body's ModifyDamage, the player's own side)
	int Soak(PlayerPawn pawn, int damage, Actor inflictor, Actor source)
	{
		int pn = pawn.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS || guardTics[pn] < HOLD || damage <= 0) return damage;
		int lv = RSQML.MoveLevel(pawn, null, "Guard", "rsqml_guard");
		if (lv <= 0) return damage;
		// where the blow came from: a missile from where it is, anything else from who struck (a hazard with no
		// attacker -- slime, a crusher -- is not guarded)
		Actor from = (inflictor && inflictor != source && inflictor.bMissile) ? inflictor : source;
		if (!from || from == pawn) return damage;
		if (Actor.absangle(pawn.AngleTo(from), pawn.angle) > ARC) return damage;
		bool dbg = RSQML.Debug() > 0;
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
		if (dbg) Console.Printf("RSQML guard: soaked %d -> %d from %s", damage, left, from.GetClassName());
		return left;
	}
}

// WHAT THE PLAYER CARRIES FOR MELEE'S DAMAGE: the Guard's soak (a blow on its way in) and Hadouken's harder hit (a
// missile a glove sent back, on its way out). An item, because an item's ModifyDamage is the engine's own place to
// change a blow on either side (Actor.GetModifiedDamage: passive = received). Given to every player while Melee is
// loaded; it does nothing on its own.
class RSQML_Body : Inventory
{
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
			let g = RSQML_Guard.Get();
			if (g) newdamage = g.Soak(pawn, damage, inflictor, source);
			return;
		}
		// HADOUKEN: the returned missile hits for the upgrade's share (Gun Bonsai VR's RSQ_Upgrade_ReturnFire.Mult;
		// level 1's 150% without it)
		let gl = RSQML_Gloves.Get();
		int lv = gl ? gl.ReturnedLevel(inflictor) : 0;
		if (lv <= 0) return;
		newdamage = int(round(damage * RSQML.Num("Hadouken.mult", lv, 0, 1.5)));
		if (RSQML.Debug() > 0) Console.Printf("RSQML hadouken hit: %d -> %d (level %d)", damage, newdamage, lv);
	}
}
