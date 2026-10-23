// RS_ShieldSawQ -- the block, the grind and the bash.
//
// WHAT CROSSES THE FACE IS STOPPED. Not by sweeping the missile list: the plate sits inside
// the player's own collision box, and the engine kills a missile at the box edge before any
// sweep sees it reach the plate (the 2026-10-17 audit). So the block is decided in the one
// place every hit passes through anyway: Inventory.AbsorbDamage, which the engine calls on
// every machine, in the sim, for every damage the player takes, with the inflictor and the
// source. The attack's line is tested against the plate disc; blocked means the damage is
// zero, a spark where it crossed the face, the striker reels, and a blocked missile is sent
// back. A fireball you can see fly under the rim hits you.
//
// The plate comes from the SYNCED pose (pose.zs) when the shield is in the hand, and from
// the mount (body-relative, so already the same everywhere) when it is on the back.

class SSQ_Guard : Inventory
{
	int bashCool;
	int lastBlockTic;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		+INVENTORY.PERSISTENTPOWER
	}

	// ---- the plate: MEASURED OFF THE MESH, not guessed ----------------------------------
	//
	// Where shield.md3 actually ends up when the held block of MODELDEF draws it
	// (Scale -1 1 1, Offset 0 -24 -10), followed through stock QZD 17.3 (qzd173-pinned):
	//
	//   models_md3.cpp BuildVertexBuffer  render vertex = (mx, mz, my)
	//   models.cpp RenderHUDModel         M = Hand . S(0.01) . T(0,5,30) . S(xs,zs,ys)
	//                                         . T(xo/xs, zo/zs, yo/ys) . R(90,Y)
	//   hw_vrmodes.cpp MapWeaponDir       F = -Zlocal, L = -Xlocal, U = +Ylocal
	//
	// which reduces, in the off controller's own frame and in cm, to
	//
	//   F = mx - 6        L = my (right-handed scheme) / -my (left)       U = mz - 5
	//
	// and the meshes measure (frame 0 closed / frame 3 open):
	//
	//   shield_rim     centre F -15.36  L -8.37  U -4.93   radius 28.46 / 29.27
	//   shield_back    centre F -15.40  L -6.60  U -5.00   radius 29.04
	//   shield_front   the saw housing, L -16.03 .. -8.86, in-plane radius 29.16
	//   saw blades     L -8.70 .. -8.02, tip radius 29.2 retracted, 35.2 deployed
	//   shield_handle  a bar at F -1.3, L -4.5, spanning U -13.8 .. +4.4: the grip
	//   hand_ssq       straddles the origin, F -13.3..9.1  L -3.9..8.5  U -11.7..3.0
	//
	// So the disc sits 15.4 cm back along the forearm (the handle is at the hand, the
	// disc covers the arm toward the elbow), 7.5 cm to the controller's RIGHT -- the
	// arm is on the plate's +L side -- and 5 cm down. Its face normal is -L to within
	// 0.001, and the whole assembly spans L -3.7 (holder) to -16.0 (housing).
	//
	// v0.6 had the sign of L inverted and the normal pointing into the forearm; that is
	// "the ring is on the wrong side of the shield" and "the plate is not aligned with
	// the geometry". The numbers below are the measurement; ssq_debug_ring draws them.
	//
	// side is +1 when the off hand is the LEFT controller (right-handed scheme) and -1
	// when it is the right: MODELDEF mirrors the mesh for the other hand (SSQJ, Scale 1),
	// so the lateral axis flips with it.
	static clearscope double Side(PlayerInfo p) { return SSQ_Handler.LeftHanded(p) ? -1.0 : 1.0; }

	// ONE SCALE FOR THE WHOLE SHIELD. A model scaled about its own origin moves its disc
	// further from the grip by the same factor it grows, so the offsets scale with the
	// radius -- otherwise a bigger shield would sit in the same place and hang off the hand
	// wrongly. 1.0 is the mesh as it is; 1.5 is half again, which is as far as it goes.
	static clearscope double Scale()
	{
		return clamp(SSQ_Handler.SV('ssq_shield_scale', 1.0), 1.0, 1.5);
	}

	static clearscope Vector3 PlateCentre(PlayerPawn mo, SSQ_Pose pose, bool stowed)
	{
		let p = mo.player;
		if (stowed) return SSQ_Handler.MountPlateCentre(mo);
		double s = Side(p);
		double k = Scale();
		return pose.pos[0]
			+ pose.F * (SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_f', -15.4)) * k)
			+ pose.L * (SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_l', -7.5)) * s * k)
			+ pose.U * (SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_u', -5.0)) * k);
	}

	// OUTWARD: away from the forearm, which the mesh puts on the plate's +L side.
	static clearscope Vector3 PlateNormal(PlayerPawn mo, SSQ_Pose pose, bool stowed)
	{
		if (stowed) return SSQ_Handler.MountPlateNormal(mo);
		return pose.L * (-Side(mo.player));
	}

	static clearscope double PlateRadius(bool blades)
	{
		return SSQ_Handler.CM((SSQ_Handler.SV('ssq_plate_radius', 29.2) + (blades ? SSQ_Handler.SV('ssq_plate_blades', 6.0) : 0)) * Scale());
	}

	// does the segment A->B pass through the THICK disc (centre C, face n, radius R, half
	// thickness T)? P is where. A thick disc, not a plane: the plane test misses a shot that
	// skims the face edge-on, and it needs the face's sign to be right; the thick disc blocks
	// anything whose path comes within the rim and within T of the face.
	Vector3 hitP;		// where the last Crosses() hit the face (no Vector3 returns: the VM drops them)

	bool Crosses(Vector3 A, Vector3 B, Vector3 C, Vector3 n, double R)
	{
		double thick = SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_thick', 25.0));
		Vector3 d = B - A;
		double dd = d dot d;
		if (dd <= 0 || dd != dd) return false;
		// the closest point on the segment to the centre
		double frac = ((C - A) dot d) / dd;
		if (frac < 0) frac = 0; else if (frac > 1) frac = 1;
		Vector3 q = A + d * frac;
		Vector3 rel = q - C;
		double along = rel dot n;
		if (along != along) return false;
		Vector3 inplane = rel - n * along;
		if (inplane.Length() > R) return false;
		if (along > thick || along < -thick) return false;
		// THE REPORTED POINT GOES ON THE FACE. Where the segment actually pierces the
		// face plane if it does -- the slab is thick, so the closest point can be 10 cm
		// off the face and the spark lands in mid air. Otherwise the closest point,
		// flattened onto the plane.
		double da = (A - C) dot n, db = (B - C) dot n;
		if ((da > 0) != (db > 0))
		{
			double den = da - db;
			if (den != 0 && den == den)
			{
				Vector3 x = A + d * (da / den);
				Vector3 xr = x - C;
				Vector3 xp = xr - n * (xr dot n);
				if (xp.Length() <= R) { hitP = C + xp; return true; }
			}
		}
		hitP = C + inplane;
		return true;
	}

	// which plate is up for this player right now, if any
	Vector3 plateC, plateN; double plateR; int plateHeld;

	bool Plate()
	{
		plateC = (0, 0, 0); plateN = (0, 0, 1); plateR = 0; plateHeld = 0;
		let mo = PlayerPawn(Owner);
		if (!mo || !mo.player) return false;
		let h = SSQ_Handler.Get();
		if (!h) return false;
		int pnum = mo.PlayerNumber();
		int st = h.StateOf(pnum);
		let pose = h.PoseOf(pnum);
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		if (st == SSQ_Handler.SS_DRAWN && pose.Fresh(Level.maptime))
		{
			plateHeld = 1;
			plateC = PlateCentre(mo, pose, false);
			plateN = PlateNormal(mo, pose, false);
			plateR = PlateRadius(saw && saw.Revved());
			return true;
		}
		if (st == SSQ_Handler.SS_STOWED && SSQ_Handler.SVI('ssq_guard_stowed', 0) != 0 && saw)
		{
			plateHeld = 0;
			plateC = PlateCentre(mo, pose, true);
			plateN = PlateNormal(mo, pose, true);
			plateR = PlateRadius(false);
			return true;
		}
		return false;
	}

	// ---- the block ----------------------------------------------------------------------
	override void AbsorbDamage(int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags)
	{
		if (damage <= 0 || SSQ_Handler.SVI('ssq_guard', 1) == 0) return;
		let mo = PlayerPawn(Owner);
		if (!mo) return;
		if (!Plate()) return;
		Vector3 C = plateC, n = plateN; double R = plateR; int held = plateHeld;

		Vector3 centre = mo.pos + (0, 0, mo.height * 0.5);
		Vector3 A, B;
		int kind;	// 0 missile, 1 hitscan, 2 melee, 3 blast
		if (inflictor && inflictor.bMissile && !(flags & DMG_EXPLOSION))
		{
			kind = 0;
			Vector3 v = inflictor.vel;
			double sp = v.Length();
			Vector3 u = sp > 0 ? v / sp : (centre - inflictor.pos).Unit();
			A = inflictor.pos - u * (sp * 2 + 8);
			B = inflictor.pos + u * (mo.radius * 2 + 24);
		}
		else if (flags & DMG_EXPLOSION)
		{
			kind = 3;
			if (!inflictor) return;
			A = inflictor.pos;
			B = centre;
		}
		else if (source && inflictor == source && !source.player)
		{
			kind = 2;
			A = source.pos + (0, 0, source.height * 0.6);
			B = centre;
		}
		else
		{
			kind = 1;
			if (!source) return;
			A = (source.player && source.OverrideAttackPosDir) ? source.AttackPos : source.pos + (0, 0, source.height * 0.75);
			B = centre;
		}

		bool hit = Crosses(A, B, C, n, R);
		Vector3 P = hitP;
		if (SSQ_Handler.UVI(mo.player, 'ssq_debug', 0))
		{
			String who = "?";
			if (source) who = source.GetClassName();
			Console.Printf("ssq: guard kind %d %s dmg %d from %s (held %d, plate r %.1f) A(%.0f %.0f %.0f) B(%.0f %.0f %.0f) C(%.0f %.0f %.0f) n(%.2f %.2f %.2f)", kind, hit ? "BLOCKED" : "missed", damage, who, held, R, A.x, A.y, A.z, B.x, B.y, B.z, C.x, C.y, C.z, n.x, n.y, n.z);
		}
		if (!hit) return;

		// blocked
		newdamage = 0;
		// the spark comes off the face on the attacker's side
		Vector3 outward = ((A - C) dot n) >= 0 ? n : -n;

		// PERFECT BLOCK: the plate was moving into the hit (ssq_perfect_speed along the attack)
		bool perfect = false;
		if (held != 0 && SSQ_Handler.SVI('ssq_perfect', 0) != 0)
		{
			let h = SSQ_Handler.Get();
			let pose = h ? h.PoseOf(mo.PlayerNumber()) : null;
			if (pose) perfect = (pose.Vel() * TICRATE) dot outward >= SSQ_Handler.SV('ssq_perfect_speed', 40.0);
		}

		bool fb = SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) != 0;
		int now = Level.maptime;
		if (now != lastBlockTic)
		{
			lastBlockTic = now;
			if (fb)
			{
				mo.A_StartSound("ssq/block", CHAN_5, 0, perfect ? 1.0 : 0.8, ATTN_NORM, perfect ? 1.25 : 1.0);
				if (held != 0) SSQ_FX.Buzz(mo, perfect ? 1.0 : 0.7, perfect ? 9 : 5);
			}
		}
		if (fb) SSQ_FX.Sparks(mo, P, outward, (kind == 3 || perfect) ? 14 : 8);

		int melee = SSQ_Handler.SVI('ssq_melee', 2);
		if (kind == 2 && source && (melee != 0 || perfect))
		{
			source.TriggerPainChance('Melee', true);
			if (melee == 2 || perfect)
			{
				Vector3 away = (source.pos - mo.pos); away.z = 0;
				if (away.Length() > 0) source.Thrust(SSQ_Handler.SV('ssq_stagger_push', 12.0) / 10.0 * (perfect ? 2.0 : 1.0), atan2(away.y, away.x));
			}
		}
		if (kind == 0 && inflictor && (SSQ_Handler.SVI('ssq_deflect', 1) != 0 || perfect))
			Deflect(mo, inflictor, source, P, outward, perfect ? 1.6 : 1.0);
	}

	// a blocked missile comes back: the same class, from the face, at its source or
	// mirrored off the plate
	void Deflect(PlayerPawn mo, Actor missile, Actor source, Vector3 P, Vector3 n, double boost)
	{
		let back = Actor.Spawn(missile.GetClass(), P + n * 6);
		if (!back) return;
		double sp = max(missile.vel.Length(), missile.speed, 8) * boost;
		Vector3 dir;
		if (SSQ_Handler.SVI('ssq_deflect_aim', 1) != 0 && source && source.health > 0 && source != mo)
			dir = (source.pos + (0, 0, source.height * 0.5) - back.pos).Unit();
		else
		{
			Vector3 v = missile.vel;
			double vl = v.Length();
			Vector3 u = vl > 0 ? v / vl : -n;
			dir = (u - n * (2 * (u dot n))).Unit();
		}
		back.vel = dir * sp;
		back.angle = atan2(dir.y, dir.x);
		back.pitch = -asin(clamp(dir.z, -1, 1));
		back.target = mo;	// ours now: it hurts them, never us
		back.bMissile = true;
		missile.vel = (0, 0, 0);	// the original dies on the box as it would have
	}

	// ---- held: the grind, the bash, the debug ring (from SSQ_ShieldSaw's Ready tic) -------
	static void HeldTick(PlayerPawn mo, SSQ_ShieldSaw saw, SSQ_Pose pose)
	{
		if (!mo || !saw || !pose || !pose.Fresh(mo.Level.maptime)) return;
		let g = SSQ_Guard(mo.FindInventory('SSQ_Guard'));
		if (!g) return;
		let p = mo.player;
		Vector3 C = PlateCentre(mo, pose, false);
		Vector3 n = PlateNormal(mo, pose, false);
		double R = PlateRadius(saw.Revved());

		if (SSQ_Handler.UVI(p, 'ssq_debug_ring', 0) != 0) g.Ring(mo, C, n, R, pose);

		if (g.bashCool > 0) g.bashCool--;
		bool grindNow = saw.Revved() && SSQ_Handler.SVI('ssq_grind_damage', 6) > 0 && (mo.Level.maptime % max(1, SSQ_Handler.SVI('ssq_grind_every', 4))) == 0;
		Vector3 v = pose.Vel() * TICRATE;
		double shove = v dot n;
		bool bashNow = SSQ_Handler.SVI('ssq_bash', 1) != 0 && g.bashCool == 0 && shove >= SSQ_Handler.SV('ssq_bash_speed', 70.0);
		if (!grindNow && !bashNow) return;

		let it = BlockThingsIterator.Create(mo, R + 64);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || t == mo || !t.bShootable || t.health <= 0) continue;
			if (t.player && !deathmatch) continue;
			Vector3 tc = t.pos + (0, 0, t.height * 0.5);
			Vector3 d = tc - C;
			double along = d dot n;
			Vector3 inplane = d - n * along;
			if (inplane.Length() > R + t.radius) continue;
			if (abs(along) > t.radius + 10) continue;
			if (grindNow)
			{
				int dmg = SSQ_Handler.SVI('ssq_grind_damage', 6);
				t.DamageMobj(mo, mo, dmg, 'Saw');
				mo.A_StartSound("ssq/grind", CHAN_5, 0, 0.8);
				SSQ_FX.Sparks(mo, C + n * (t.radius * 0.5), n, 4);
				SSQ_FX.Buzz(mo, 0.3, 3);
			}
			if (bashNow && along > 0)
			{
				int dmg = int(clamp(10 + 0.15 * shove, 10, 40) * SSQ_Handler.SV('ssq_bash_damage', 1.0));
				t.DamageMobj(mo, mo, dmg, 'Melee');
				t.Thrust(clamp(shove / 20.0, 4, 16), atan2(n.y, n.x));
				mo.A_StartSound("ssq/bash", CHAN_5);
				SSQ_FX.Buzz(mo, 1.0, 8);
				g.bashCool = 10;
			}
		}
	}

	// the plate as particles: rim, a spoke along the face normal, and the hand
	void Ring(PlayerPawn mo, Vector3 C, Vector3 n, double R, SSQ_Pose pose)
	{
		Vector3 a = pose.F;
		Vector3 b = (n.y * a.z - n.z * a.y, n.z * a.x - n.x * a.z, n.x * a.y - n.y * a.x);
		a = (b.y * n.z - b.z * n.y, b.z * n.x - b.x * n.z, b.x * n.y - b.y * n.x);
		for (int k = 0; k < 36; k++)
		{
			double t = k * 10.0;
			SSQ_FX.Particle(mo, C + a * (R * cos(t)) + b * (R * sin(t)), (0, 0, 0), "ff2020", 4, 6.0);
		}
		SSQ_FX.Particle(mo, C, (0, 0, 0), "ff2020", 4, 8.0);
		for (int k = 1; k <= 6; k++) SSQ_FX.Particle(mo, C + n * (k * 3.0), (0, 0, 0), "20ff20", 4, 5.0);
		SSQ_FX.Particle(mo, pose.pos[0], (0, 0, 0), "3080ff", 4, 7.0);
		for (int k = 1; k <= 4; k++) SSQ_FX.Particle(mo, pose.pos[0] + pose.F * (k * 3.0), (0, 0, 0), "ffffff", 4, 4.0);
	}
}
