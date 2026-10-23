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

	// ---- the plate --------------------------------------------------------------------
	// Held: centre = hand + F*f + L*l*side + U*u (cm in the controller's frame), face = +L*side,
	// where side is +1 for the off hand being the LEFT controller (right-handed scheme) and
	// -1 for the right. Stowed: at the mount, facing backward.
	static clearscope double Side(PlayerInfo p) { return SSQ_Handler.LeftHanded(p) ? -1.0 : 1.0; }

	static clearscope Vector3 PlateCentre(PlayerPawn mo, SSQ_Pose pose, bool stowed)
	{
		let p = mo.player;
		if (stowed)
			return SSQ_Handler.MountPos(mo) - (0, 0, SSQ_Handler.CM(SSQ_Handler.UV(p, 'ssq_mount_drop', 11.0)));
		double s = Side(p);
		return pose.pos[0]
			+ pose.F * SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_f', -15.4))
			+ pose.L * (SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_l', 8.4)) * s)
			+ pose.U * SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_u', -5.0));
	}

	static clearscope Vector3 PlateNormal(PlayerPawn mo, SSQ_Pose pose, bool stowed)
	{
		if (stowed)
		{
			double a = mo.angle;
			return (-cos(a), -sin(a), 0);
		}
		double s = Side(mo.player);
		double yaw = SSQ_Handler.SV('ssq_plate_yaw', 0);
		double pitch = SSQ_Handler.SV('ssq_plate_pitch', 0);
		// the face is +L; a yaw tilts it toward F, a pitch toward U
		Vector3 n = pose.L * (s * cos(yaw) * cos(pitch)) + pose.F * (sin(yaw) * cos(pitch)) + pose.U * sin(pitch);
		return n.Unit();
	}

	static clearscope double PlateRadius(bool blades)
	{
		return SSQ_Handler.CM(SSQ_Handler.SV('ssq_plate_radius', 28.5) + (blades ? SSQ_Handler.SV('ssq_plate_blades', 2.5) : 0));
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
		// the reported point: on the face
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
		if (st == SSQ_Handler.SS_STOWED && SSQ_Handler.SVI('ssq_guard_stowed', 1) != 0 && saw)
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
