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
	// THE PLATE'S PATH ALONG ITS OWN FACE, decaying: see HeldTick. lastPushTic makes the sum
	// self-healing -- any gap (stowed, thrown, dead, a level change) starts it clean, with no
	// second site having to remember to reset it.
	double pushPath;
	int lastPushTic;
	int lastBlockTic;
	// WHO HAS BEEN GROUND, AND WHEN. ssq_grind_every used to be a GLOBAL tic gate in HeldTick --
	// the whole grind fired on one tic in four and did nothing on the other three -- so a body
	// the rim crossed on a skipped tic was never touched at all, however squarely the plate was
	// on it, while a body standing still was ground at the full rate. A per-victim cooldown is
	// the same cap on how fast one thing can be hurt without ever skipping a thing: the grind is
	// evaluated EVERY tic now, and each body takes a hit no oftener than once every
	// ssq_grind_every tics. It is also the only form that is any use with a swept rim below,
	// which is the other half of the same fix. The saber caps its cut exactly this way
	// (ubqs_cut_rate: QuestSaber/zscript.txt:1873, :1892-1893, stamped :1958-1959, pruned
	// :1968-1969) and the disc caps its embed grind the same way for one victim (disc.zs:475).
	Array<Actor> grindWho;
	Array<int> grindWhen;
	Array<int> grindStart;		// the tic the grind on that body began (RSQ Score's Buzzsaw, SSQ_ScoreService "grind.held")

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
	// the whole shield, model and plate. SHIELD SIZE (Gun Bonsai VR patch): the Shield Size row is the floor and the node's
	// levels raise it for that player, Large (1.25) at 1, Largest (1.5) at 2 -- read in play by SSQ_Handler (mSizeK), as
	// this is clearscope. pnum -1: the row alone.
	static clearscope double Scale(int pnum = -1)
	{
		double k = clamp(SSQ_Handler.SV('ssq_shield_scale', 1.0), 1.0, 1.5);
		if (pnum >= 0 && pnum < MAXPLAYERS) { let h = SSQ_Handler.Get(); if (h) k = max(k, h.mSizeK[pnum]); }
		return k;
	}
	static double SizeFor(PlayerPawn mo)
	{
		int lv = SSQ_Upg.Lv(mo ? mo.FindInventory('SSQ_ShieldSaw') : null, "ShieldSize");
		return lv > 0 ? SSQ_Upg.Num("ShieldSize.scale", lv, 1.0) : 1.0;
	}

	static clearscope Vector3 PlateCentre(PlayerPawn mo, SSQ_Pose pose, bool stowed)
	{
		let p = mo.player;
		if (stowed) return SSQ_Handler.MountPlateCentre(mo);
		double s = Side(p);
		double k = Scale(mo.PlayerNumber());
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

	// HOW WIDE THE PLATE IS (the shield you see is unchanged). `grow` is GrowK(): with the Gun
	// Bonsai VR patch loaded the plate GROWS -- its Broadening upgrade, +20% a level up to double
	// at level 5 (the owner, 10-27: "grow the shield over time from its default instead of
	// doubling it in options"). Without the patch, ssq_block_double (Double Block Radius) still
	// doubles it outright.
	static clearscope double PlateRadius(bool blades, double grow = 1.0, int pnum = -1)
	{
		return SSQ_Handler.CM((SSQ_Handler.SV('ssq_plate_radius', 29.2) + (blades ? SSQ_Handler.SV('ssq_plate_blades', 6.0) : 0)) * Scale(pnum) * grow);
	}

	// the plate's width factor for this player, asked once a second (a service call by name)
	double growNow;
	int growTic;
	double GrowK()
	{
		if (growNow <= 0 || Level.maptime >= growTic || Level.maptime < growTic - 35)
		{
			growTic = Level.maptime + 35;
			growNow = GrowFor(PlayerPawn(Owner));
		}
		return growNow;
	}
	static double GrowFor(PlayerPawn mo)
	{
		// THE OPTION ALWAYS WINS (the owner, 10-27: "2x as large doesn't seem to visibly increase the
		// plate"): with Gun Bonsai's VR patch loaded the option used to be ignored in favour of the
		// Broadening upgrade. Double Block Radius on is double, at once; off, Broadening grows it.
		if (SSQ_Handler.SV('ssq_block_double', 0) > 0.5) return 2.0;
		let svc = SSQ_Upg.Svc();
		if (svc && svc.GetInt("loaded") > 0)
			return 1.0 + 0.2 * clamp(SSQ_Upg.Lv(mo ? mo.FindInventory('SSQ_ShieldSaw') : null, "Broadening"), 0, 5);
		return 1.0;
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
	// SHIELD DASH (Gun Bonsai VR patch): units still to go, the way, the bash it lands with, the cooldown
	double dashLeft, dashSent, dashEff;
	Vector2 dashDir;
	Vector3 dashLast;
	int dashTics, dashCool;
	int lastSweepTic;

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
			plateR = PlateRadius(saw && saw.Revved(), GrowK(), pnum) * BraceK(h, pnum);
			return true;
		}
		if (st == SSQ_Handler.SS_STOWED && saw && BackPlate(mo) > 0)
		{
			plateHeld = 0;
			plateC = PlateCentre(mo, pose, true);
			plateN = PlateNormal(mo, pose, true);
			plateR = PlateRadius(false, GrowK(), pnum);
			return true;
		}
		return false;
	}

	// BACK PLATE (Gun Bonsai VR patch, GBOVR_TREES.md 4.3 Block): what a shield you are not holding does. 0 nothing, 1
	// blocks, 2 blocks and turns shots (missiles and bullets) as a held one does. Without the patch Block While Holstered
	// (ssq_guard_stowed) is both or neither, as before; under it the node replaces that row.
	static int BackPlate(PlayerPawn mo)
	{
		if (!SSQ_Upg.On()) return SSQ_Handler.SVI('ssq_guard_stowed', 0) != 0 ? 2 : 0;
		return clamp(SSQ_Upg.Lv(mo ? mo.FindInventory('SSQ_ShieldSaw') : null, "BackPlate"), 0, 2);
	}
	// the plate Plate() just found turns what it stops: always in the hand, on the back only at Back Plate 2
	bool PlateTurns() { return plateHeld != 0 || BackPlate(PlayerPawn(Owner)) >= 2; }

	// SHIELD WALL (Gun Bonsai VR patch): how long a perfect block slows time, ms (0 none). Without the patch the
	// Perfect-Block Slow-Mo row's half second, as before; under it the node's levels (0.75 / 1 / 1.25 s) replace the row.
	static int ShieldWallMs(PlayerPawn mo)
	{
		if (!SSQ_Upg.On()) return SSQ_Handler.SVI('ssq_perfect_slowmo', 0) != 0 ? 500 : 0;
		int lv = SSQ_Upg.Lv(mo ? mo.FindInventory('SSQ_ShieldSaw') : null, "ShieldWall");
		return lv > 0 ? int(SSQ_Upg.Num("ShieldWall.ms", lv, 0)) : 0;
	}

	// SPARTAN (Gun Bonsai VR patch, GBOVR_TREES.md 4.3, the Saber link): its level while the lit saber rests on the shield
	// (Saber Over Shield, mBraced), else 0. 1: a shot the shield turns is PARRIED -- sent straight at whoever fired it,
	// even with the Deflect row off; 2: a bash in that stance cuts as well.
	static clearscope int Spartan(PlayerPawn mo)
	{
		if (!mo) return 0;
		int pn = mo.PlayerNumber();
		let h = SSQ_Handler.Get();
		if (!h || pn < 0 || pn >= MAXPLAYERS || !h.mBraced[pn]) return 0;
		return h.mSpartan[pn];
	}

	// ONE GRIND HIT: the Grind Damage row, and HUNGRY BLADES (Gun Bonsai VR patch) +2 a level (6 -> 8, 10, 12)
	static int GrindDamage(PlayerPawn mo)
	{
		int lv = SSQ_Upg.Lv(mo ? mo.FindInventory('SSQ_ShieldSaw') : null, "HungryBlades");
		return SSQ_Handler.SVI('ssq_grind_damage', 6) + (lv > 0 ? int(SSQ_Upg.Num("HungryBlades.grind", lv, 0)) : 0);
	}
	// REV SHIELD (Gun Bonsai VR patch, GBOVR_TREES.md 4.3 Grind): its level while the shield is held up AND revving, else 0.
	// 1: what claws the plate is ground (ClawGrind); 2: a blocked missile is turned even with the Deflect row off.
	static int RevShield(PlayerPawn mo, int held)
	{
		if (held == 0 || !mo) return 0;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		if (!saw || !saw.Revved()) return 0;
		return SSQ_Upg.Lv(saw, "RevShield");
	}
	// one grind hit on what clawed the plate, paid to the saw like the grind in HeldTick
	static void ClawGrind(PlayerPawn mo, SSQ_ShieldSaw saw, Actor t)
	{
		if (!mo || !t || t.health <= 0) return;
		let upg = SSQ_Upg.Svc();
		SSQ_Upg.Touch("rev.block", mo, t);
		if (upg && saw) upg.GetInt("credit.push", "", 2, 0, saw);
		t.DamageMobj(mo, mo, GrindDamage(mo), 'Saw');
		if (upg && saw) upg.GetInt("credit.pop", "", 0, 0, saw);
		Vector3 at = t.pos + (0, 0, t.height * 0.5);
		SSQ_FX.At(mo, at, "ssq/grind", CHAN_5, 0.9);
		SSQ_FX.Sparks(mo, at, (0, 0, 1), 6);
	}

	// SABER OVER SHIELD (pick 15, surveys/07_SHIELDS_PARRY.md 4.12): while the player's lit saber rests across
	// the plate's front the BLOCK is wider. The stance is decided on the player's own machine from the raw hand
	// fields (SSQ_Handler.SendBrace) and arrives here as a network event, so every machine reads the same flag.
	// The grind and the bash keep the plain plate: the stance is a guard, not a bigger blade.
	static clearscope double BraceK(SSQ_Handler h, int pnum)
	{
		if (!h || pnum < 0 || pnum >= MAXPLAYERS || !h.mBraced[pnum]) return 1.0;
		if (SSQ_Handler.SVI('ssq_brace', 1) == 0) return 1.0;
		return clamp(SSQ_Handler.SV('ssq_brace_widen', 1.3), 1.0, 2.0);
	}

	// HIT-STOP (pick 13, off by default; surveys/01_MELEE.md 3.6): the monster stops dead for a beat --
	// freezetics halts its whole Tick, movement and states. Never a player (their hands keep moving).
	static void HitStop(Actor t, PlayerPawn by = null)
	{
		if (!t || t.player || t.health <= 0) return;
		int tics = HitStopTics(by);
		if (tics > 0) t.freezetics = max(t.freezetics, tics);
	}
	// STRIKE TRUE (Gun Bonsai VR patch; the class is RSQ_Upgrade_BashHitStop, the saber's own Strike True has other
	// numbers): under the patch the node's 4 / 5 / 6 tics replace the Hit-Stop rows; without it the rows as before.
	static int HitStopTics(PlayerPawn by)
	{
		if (!SSQ_Upg.On()) return SSQ_Handler.SVI('ssq_hitstop', 0) != 0 ? clamp(SSQ_Handler.SVI('ssq_hitstop_tics', 4), 1, 10) : 0;
		int lv = SSQ_Upg.Lv(by ? by.FindInventory('SSQ_ShieldSaw') : null, "BashHitStop");
		return lv > 0 ? int(SSQ_Upg.Num("BashHitStop.tics", lv, 0)) : 0;
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
		if (held == 0) SSQ_Upg.Touch("backplate", mo, source);	// Back Plate: the shield on your back took it
		// the spark comes off the face on the attacker's side
		Vector3 outward = ((A - C) dot n) >= 0 ? n : -n;

		// PERFECT BLOCK: you did not hold the shield in the way, you MET the shot with it. The
		// plate has to have been moving into the attack at ssq_perfect_speed (units/sec along
		// the line it came in on) at the moment it landed -- a push, a parry, a swat, not a
		// stance. It pays: the shot goes back 60% faster, a melee attacker is always staggered
		// and shoved whatever ssq_melee says, and you can tell one happened without being told.
		bool perfect = false;
		if (held != 0 && SSQ_Handler.SVI('ssq_perfect', 1) != 0)
		{
			let h = SSQ_Handler.Get();
			let pose = h ? h.PoseOf(mo.PlayerNumber()) : null;
			// BULWARK (Gun Bonsai): a slower plate still counts, 1 / (1 + 0.35 x level) of the speed
			double need = SSQ_Handler.SV('ssq_perfect_speed', 25.0) / (1.0 + 0.35 * SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "Bulwark"));
			// THE FASTEST MOMENT, NOT THE LAST TWO SAMPLES (Quest teardown apply/03 1.4): a hard parry is often past its
			// peak by the tic the shot lands, so the newest pair under-reads it -- the best of the last few 2-tic
			// windows decides, as the throw already does.
			if (pose)
			{
				double into = (pose.Vel() * TICRATE) dot outward;
				for (int k = 0; k < 3; k++) into = max(into, (pose.VelAt(k) * TICRATE) dot outward);
				perfect = into >= need;
			}
		}
		// a scorer may ask about this block, and whether it was perfect (score.zs)
		{ let sh = SSQ_Handler.Get(); if (sh && sh.score) sh.score.Blocked(source, perfect); }
		if (perfect && source && Level.maptime != lastBlockTic)
		{
			HitStop(source, mo);
			// PERFECT-BLOCK SLOW MOTION (pick 14, off by default; apply/05_SLOWMO.md 8): half a second through
			// RSQ SlowMo's own pulse, at the depth RS_Score's big kills use (Score handler.zs PULSE_DEPTH 35).
			// Sent from the blocker's own machine only, so a netgame gets one event; absent SlowMo hears nothing.
			// Under the Gun Bonsai VR patch Shield Wall's levels decide it (ShieldWallMs).
			int swMs = ShieldWallMs(mo);
			if (swMs > 0 && mo.PlayerNumber() == consoleplayer)
				EventHandler.SendNetworkEvent("rsm_pulse", swMs, 35);
			if (SSQ_Handler.UVI(mo.player, 'ssq_debug', 0))
				Console.Printf("ssq: perfect block of %s, hitstop %d slowmo %d", source.GetClassName(), SSQ_Handler.SVI('ssq_hitstop', 0), SSQ_Handler.SVI('ssq_perfect_slowmo', 0));
		}

		bool fb = SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) != 0;
		int now = Level.maptime;
		if (now != lastBlockTic)
		{
			lastBlockTic = now;
			if (fb)
			{
				SSQ_FX.At(mo, P, "ssq/block", CHAN_5, perfect ? 1.0 : 0.8, perfect ? 1.35 : 1.0);
				// a perfect block is a DOUBLE knock in the hand, never just a stronger buzz (a bash is one long one)
				if (held != 0) SSQ_FX.Buzz(mo, perfect ? 1.0 : 0.7, perfect ? 12 : 5, perfect);
				// HOW YOU KNOW IT WAS PERFECT, without reading a message: it rings a tone higher,
				// the hand buzz is twice as long, and the plate blooms white at the contact point.
				// A normal block is a spark and a thud; this is unmistakable.
				if (perfect)
				{
					let fl = SSQ_FX.FlashOk() ? Actor.Spawn('SSQ_BlastBloom', P) : null;   // Photosensitive Mode
					if (fl) { fl.A_SetScale(1.4); fl.alpha = SSQ_A11y.Dim(fl.alpha); }
					SSQ_FX.At(mo, P, "ssq/bash", CHAN_6, 0.7, 1.3);
				}
			}
		}
		if (fb) SSQ_FX.Sparks(mo, P, outward, (kind == 3 || perfect) ? 14 : 8);

		int revLv = RevShield(mo, held);
		if (revLv >= 1 && kind == 2 && source && !source.player)
			ClawGrind(mo, SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw')), source);
		int melee = SSQ_Handler.SVI('ssq_melee', 2);
		if (kind == 2 && source && (melee != 0 || perfect))
		{
			SSQ_FX.Pain(source, 'Melee');
			if (melee == 2 || perfect)
			{
				Vector3 away = (source.pos - mo.pos); away.z = 0;
				if (away.Length() > 0) source.Thrust(SSQ_Handler.SV('ssq_stagger_push', 12.0) / 10.0 * (perfect ? 2.0 : 1.0), atan2(away.y, away.x));
			}
		}
		int spartan = Spartan(mo);
		if (kind == 0 && inflictor && (SSQ_Handler.SVI('ssq_deflect', 1) != 0 || perfect || revLv >= 2 || spartan >= 1) && PlateTurns())
		{
			if (spartan >= 1) SSQ_Upg.Touch("spartan", mo, source);
			Deflect(mo, inflictor, source, P, outward, perfect ? 1.6 : 1.0);
		}
	}

	// HOW FAR THE PLATE ITSELF MOVED THIS TIC. The sweep tests a shot's path across several
	// tics but used to test it against a plate frozen where it was when the tic began -- so a
	// shield being swung was checked at a stale position while the shot was checked at a live
	// one, and the faster you parried the more it missed. This is the plate's own travel over
	// the last tic, from the synced history, so the test can walk the plate along it. The
	// facing is this tic's: the history keeps positions, not past axes, and across one tic the
	// translation is the part that matters.
	//
	// `assumeHeld` is for a caller that already knows the shield is in the hand. plateHeld is
	// written by Plate(), and the two block paths call Plate() a few lines before they ask for
	// the travel; HeldTick never calls it at all (and DoEffect, which does, returns before it
	// when ssq_sweep is off), so for that caller the flag is nobody's answer. HeldTick runs only
	// from SSQ_ShieldSaw's own Ready tic with a fresh pose, which is what "in the hand" means.
	Vector3 PlateTravel(bool assumeHeld = false)
	{
		let mo = PlayerPawn(Owner);
		if (!mo || (!assumeHeld && plateHeld == 0)) return (0, 0, 0);
		let h = SSQ_Handler.Get();
		if (!h) return (0, 0, 0);
		let pose = h.PoseOf(mo.PlayerNumber());
		if (!pose || pose.count < 2) return (0, 0, 0);
		return pose.pos[1] - pose.pos[0];	// where it came FROM, relative to where it is
	}

	// ---- THE MUZZLE: stop a hitscan before it is ever traced -----------------------------
	//
	// The sweep turns missiles because a missile is an actor with a path you can look at. A
	// bullet has neither: P_LineAttack traces, damages and is gone inside one call, and the
	// only mark it leaves on us is AbsorbDamage, which runs after it has already hit. That is
	// the whole reason bullets felt different from fireballs against this shield.
	//
	// Stock QZD fires WorldHitscanPreFired before the trace (p_map.cpp:4718), and returning
	// true cancels the shot outright -- no trace, no puff, no damage, for anybody. So we get
	// the shooter, where it is firing from and the angle it is firing at, test that ray
	// against the plate exactly as the sweep tests a missile's path, and if it would cross the
	// shield the shot never happens. SSQ_Handler calls this; the geometry lives here with the
	// rest of the guard.
	//
	// Returns true if this player's shield eats the shot.
	bool StopsHitscan(Actor shooter, Vector3 A, Vector3 dir, double dist, int damage)
	{
		let mo = PlayerPawn(Owner);
		if (!mo || !mo.player || mo.health <= 0) return false;
		if (!shooter || shooter == mo) return false;
		if (!Plate()) return false;
		double R = plateR + SSQ_Handler.CM(SSQ_Handler.SV('ssq_sweep_pad', 18.0));
		Vector3 B = A + dir * max(dist, 1.0);
		Vector3 travel = PlateTravel();
		bool got = false;
		for (int s = 0; s <= 2 && !got; s++)
		{
			Vector3 Cs = plateC + travel * (1.0 - s * 0.5);
			if (Crosses(A, B, Cs, plateN, R)) got = true;
		}
		if (!got) return false;
		// it has to be coming at US, not merely passing the shield on its way elsewhere: the
		// crossing point must be nearer the shooter than we are, give or take our own width.
		Vector3 centre = mo.pos + (0, 0, mo.height * 0.5);
		if ((hitP - A).Length() > (centre - A).Length() + mo.radius * 2) return false;
		Vector3 P = hitP;
		Vector3 outward = ((A - plateC) dot plateN) >= 0 ? plateN : -plateN;
		bool fb = SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) != 0;
		int now = Level.maptime;
		if (now != lastSweepTic)
		{
			lastSweepTic = now;
			if (fb)
			{
				SSQ_FX.At(mo, P, "ssq/block", CHAN_5, 0.8, 1.15);
				if (plateHeld != 0) SSQ_FX.Buzz(mo, 0.6, 4);
			}
		}
		if (fb) SSQ_FX.Sparks(mo, P, outward, 8);
		// AND IT GOES BACK. A stopped bullet that simply vanishes is a disappointment; one that
		// comes off the plate and finds the thing that fired it is the point of carrying a
		// shield. The return is a trace of our own from the plate, so it uses the same aim rule
		// as every other deflection (ssq_deflect_aim), and because it is ours it cannot be
		// eaten by this same hook -- a player's shots are never tested.
		if (SSQ_Handler.SVI('ssq_hitscan_return', 1) != 0 && damage > 0 && PlateTurns())
		{
			Vector3 back = DeflectDir(mo, P, dir * max(dist, 1.0), outward, shooter, -PlateTravel());
			double ang = atan2(back.y, back.x);
			double pit = -asin(clamp(back.z, -1, 1));
			int dmg = int(max(1, damage * SSQ_Handler.SV('ssq_hitscan_damage', 1.0)));
			// REBOUND (Gun Bonsai): a returned bullet hits harder. (A turned missile gets the same from the
			// patch itself, which can see it; this return is traced by a helper the patch cannot credit.)
			int rb = SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "Rebound");
			if (rb > 0) dmg = int(dmg * (1.1 + 0.15 * rb));
			// REFLECT (Gun Bonsai VR patch): a returned BULLET does x1.5, x2 on top of ssq_hitscan_damage
			int rf = SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "Reflect");
			if (rf > 0) { dmg = int(dmg * SSQ_Upg.Num("Reflect.mult", rf, 1.0)); SSQ_Upg.Touch("reflect.saw", mo, shooter); }
			// With LAF_ABSPOSITION the engine reads the three offsets as LITERAL COORDINATES --
			// tempos = (offsetforward, offsetside, sz), p_map.cpp:4875 -- so the forward and side
			// slots carry X and Y. Passing 0,0 started this trace at the map origin.
			// (angle, distance, pitch, damage, type, puff, flags, victim, Z, X, Y)
			//
			// FIRED BY A HELPER, NOT BY THE PLAYER. A player's LineAttack in VR is re-aimed by the
			// engine: with OverrideAttackPosDir, P_LineAttack replaces the direction with the MAIN
			// CONTROLLER's AttackDir (p_map.cpp:4787-4797), so the return went where the gun
			// pointed, buzzed the gun hand (p_map.cpp:4762-4772), and read the local controller
			// in a netgame. A non-player shooter is traced exactly along `back`. The helper is
			// excluded from our own hitscan hook (state.zs) and owned by the player (target).
			let ric = Actor.Spawn('SSQ_Ricochet', P);
			if (ric)
			{
				ric.target = mo;
				// a MISSILE so a scorer walks from it to the player who turned the shot: a kill by a
				// returned bullet was credited to this helper, and so to nobody
				ric.bMissile = true;
				ric.angle = ang;
				// AND PAID TO THE SHIELDSAW. The engine names the helper as the damage source, so Gun
				// Bonsai saw nobody's damage: FriendPlayer makes the helper count as this player's
				// (Gun Bonsai's GetPlayerDamageSource reads it), and the claim -- its master is the
				// saw, asked of the VR patch by name -- pays the helper and the puff it leaves to the
				// ShieldSaw. Without the patch the claim is nobody's call and nothing changes.
				ric.FriendPlayer = mo.PlayerNumber() + 1;
				ric.master = mo.FindInventory('SSQ_ShieldSaw');
				{ let upg = SSQ_Upg.Svc(); if (upg && ric.master) upg.GetInt("claim", "", 0, 0, ric); }
				FTranslatedLineTarget hitT;
				// FROM OUTSIDE THE PLAYER'S OWN BOX. A shield on the back sits inside the player's box: a trace started
				// there hit the player at once and the player's own guard ate it (measured 11-02 with the back plate:
				// every returned bullet was blocked by the shield that returned it). Step the start out along the return.
				Vector3 S = P;
				if (abs(S.x - mo.pos.x) <= mo.radius && abs(S.y - mo.pos.y) <= mo.radius && S.z >= mo.pos.z && S.z <= mo.pos.z + mo.height)
					S += back * (mo.radius * 2.9 + 2);
				ric.LineAttack(ang, max(dist, 1024.0), pit, dmg, 'Hitscan', 'BulletPuff', LAF_ABSPOSITION, hitT, S.z, S.x, S.y);
				// The helper vanishes in a tic: a monster it hit would chase nothing. Point the
				// victim at the player who turned the shot. (Known limit: the engine credits the
				// damage to the helper, so co-op friendly-fire rules do not see a player source.)
				let v = hitT.linetarget;
				if (v && v.health > 0 && v.target == ric) v.target = mo;
				{ let sh = SSQ_Handler.Get(); if (sh && sh.score) sh.score.ReturnHit(v, shooter); }
			}
		}
		return true;
	}

	// ---- THE SWEEP: turn a shot BEFORE it reaches you ------------------------------------
	//
	// AbsorbDamage only ever runs when something is already damaging you, so the old guard
	// could only block what was going to hit anyway, at the exact instant it hit. That is why
	// the window felt small: a shot is tested against one line, drawn to your centre, on one
	// tic. The owner's lightsaber does the opposite and it is the better idea -- every tic it
	// looks for missiles NEAR THE BLADE and bats them away, testing each shot's own path from
	// a tic behind to ssq_sweep_lead tics ahead, so fast bolts are turned early instead of
	// arriving between two checks.
	//
	// Same thing here, against the plate instead of a blade: anything crossing the disc in the
	// next few tics is turned, including shots that would have missed. It runs from DoEffect,
	// which ticks on every machine for every player, off the same synced pose the block uses,
	// so it stays deterministic. AbsorbDamage stays exactly as it was and still catches
	// hitscans, melee and blasts, which have no flight to intercept.
	override void DoEffect()
	{
		Super.DoEffect();
		{ let dm = PlayerPawn(Owner); if (dm) DashTick(dm); }
		if (SSQ_Handler.SVI('ssq_guard', 1) == 0 || SSQ_Handler.SVI('ssq_sweep', 1) == 0) return;
		let mo = PlayerPawn(Owner);
		if (!mo || !mo.player || mo.health <= 0) return;
		if (!Plate() || !PlateTurns()) return;	// the sweep only TURNS: a Back Plate 1 shield just blocks
		Vector3 C = plateC, n = plateN;
		double R = plateR + SSQ_Handler.CM(SSQ_Handler.SV('ssq_sweep_pad', 18.0));
		double lead = clamp(SSQ_Handler.SV('ssq_sweep_lead', 3.0), 1.0, 6.0);
		Vector3 travel = PlateTravel();
		double reach = R + 320.0 + travel.Length();	// a fast bolt, and a fast arm, cover ground
		// the missiles in flight (SSQ_Handler.mMissiles: a projectile is never in the blockmap)
		let hh = SSQ_Handler.Get();
		if (!hh) return;
		for (int k = hh.mMissiles.Size() - 1; k >= 0; k--)
		{
			Actor sh = hh.mMissiles[k];
			if (!sh || !sh.bMissile || sh == mo) continue;
			if ((sh.pos - C).Length() > reach) continue;
			if (sh.target == mo) continue;		// ours already, or one we just turned
			if (sh is 'SSQ_Disc') continue;		// never our own shield
			Vector3 v = sh.vel;
			if (v.Length() <= 0) continue;
			Vector3 A = sh.pos - v;				// a tic behind
			Vector3 B = sh.pos + v * lead;		// and a few ahead
			// three places the plate was during this tic: where it came from, halfway, here
			bool got = false;
			for (int s = 0; s <= 2 && !got; s++)
			{
				Vector3 Cs = C + travel * (1.0 - s * 0.5);
				if (Crosses(A, B, Cs, n, R + sh.radius)) got = true;
			}
			if (!got) continue;
			Vector3 P = hitP;
			Vector3 outward = ((A - C) dot n) >= 0 ? n : -n;
			BatBack(mo, sh, P, outward);
		}
	}

	// THE ENEMY YOU ARE LOOKING AT: the nearest live one inside `cone` degrees of your gaze
	// that you can see. A deflection that goes where you are LOOKING is the one that feels
	// like skill rather than luck -- you turn your head and the shot follows it.
	static Actor GazeTarget(PlayerPawn mo, double cone)
	{
		if (cone <= 0) return null;
		Vector3 eye = mo.Vec3Offset(0, 0, mo.player ? mo.player.viewheight : 41.0);
		Vector3 look = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
		Actor best = null;
		double bestOff = cone;
		double range = SSQ_Handler.SV('ssq_lock_range', 1200.0);
		let it = BlockThingsIterator.CreateFromPos(eye.x, eye.y, eye.z - range, range * 2.0, range, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == mo || !t.bShootable || t.health <= 0) continue;
			if (!t.bIsMonster && !t.player) continue;
			if (t.bFriendly && !deathmatch) continue;
			if (t.player && !deathmatch) continue;
			Vector3 d = t.pos + (0, 0, t.height * 0.55) - eye;
			double dist = d.Length();
			if (dist < 1 || dist > range) continue;
			double off = acos(clamp((d / dist) dot look, -1, 1));
			if (off >= bestOff) continue;
			if (!mo.CheckSight(t)) continue;
			bestOff = off;
			best = t;
		}
		return best;
	}

	// WHERE A TURNED SHOT GOES, for both the sweep and the block, so they never disagree.
	// ssq_deflect_aim: 0 straight back at whoever fired it, 1 where you are LOOKING (helped
	// onto the nearest enemy within ssq_deflect_assist of your gaze), 2 mirrored off the face.
	// 1 is the default because it is the one that makes a shield feel like a weapon: you catch
	// a fireball on the plate and send it wherever you turn your head.
	// 3, OFF THE PLATE AND YOUR SWING (owner 2026-10-31: "100% of the time it sends the projectile directly back to
	// the attacker, it doesn't seem to make a difference if I block at an angle, or bash"): the shot glances off the
	// face as off a mirror -- an angled plate sends it aside -- and the plate's own motion this tic is added on top, so a
	// bash or a swing throws it the way the shield was moving (ssq_deflect_swing: how much; a full-speed bash at a slow
	// fireball all but sends it along the bash). `swing` is the plate's travel this tic, map units.
	static Vector3 DeflectDir(PlayerPawn mo, Vector3 from, Vector3 vel, Vector3 n, Actor shooter, Vector3 swing = (0, 0, 0))
	{
		int aim = SSQ_Handler.SVI('ssq_deflect_aim', 3);
		if (shooter && shooter.health > 0 && shooter != mo && Spartan(mo) >= 1) aim = 0;	// SPARTAN: parried, at the shooter
		Vector3 d = (0, 0, 0);
		if (aim == 3)
		{
			double vl = vel.Length();
			Vector3 u = vl > 0 ? vel / vl : -n;
			d = u - n * (2 * (u dot n));
			double sl = swing.Length();
			if (sl > 0.3)
			{
				double k = min(2.0, sl / max(vl, 8.0) * SSQ_Handler.SV('ssq_deflect_swing', 3.0));
				d = d.Unit() + swing / sl * k;
			}
		}
		if (aim == 1)
		{
			let pick = GazeTarget(mo, SSQ_Handler.SV('ssq_deflect_assist', 14.0));
			if (pick) d = (pick.pos + (0, 0, pick.height * 0.55)) - from;
			else d = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
		}
		else if (aim == 2)
		{
			double vl = vel.Length();
			Vector3 u = vl > 0 ? vel / vl : -n;
			d = u - n * (2 * (u dot n));
		}
		if (d.Length() < 0.001 && shooter && shooter.health > 0 && shooter != mo)
			d = (shooter.pos + (0, 0, shooter.height * 0.5)) - from;
		if (d.Length() < 0.001) d = -vel;
		if (d.Length() < 0.001) d = n;
		return d.Unit();
	}

	// A SWEPT SHOT IS TURNED, NOT REPLACED. The block path spawns a fresh missile because the
	// original is already mid-impact by then; out here it has not hit anything yet, so it just
	// gets a new heading -- no spawn, no second sound, and a seeker keeps seeking.
	void BatBack(PlayerPawn mo, Actor sh, Vector3 P, Vector3 n)
	{
		Actor shooter = sh.target;
		double sp = max(sh.vel.Length(), sh.speed, 8.0) * SSQ_Handler.SV('ssq_sweep_boost', 1.0);
		Vector3 dir = DeflectDir(mo, sh.pos, sh.vel, n, shooter, -PlateTravel());
		sh.target = mo;						// ours now: it hurts them, never us
		// and the ShieldSaw turned it: Gun Bonsai's VR patch pays a missile to its master weapon
		// (before, a swept shot had no master and its damage went to whichever hand scored best)
		let saw = mo.FindInventory('SSQ_ShieldSaw');
		if (saw) sh.master = saw;
		// and remembered as turned, like the block path's: a scorer's "returned", and the patch's
		// Rebound, read it (the sweep never told them, so a swept shot was never a returned one)
		{ let shh = SSQ_Handler.Get(); if (shh && shh.score) shh.score.Turned(sh, shooter); }
		// a seeker only seeks its shooter when it was sent back AT him (0 / 1); glanced off the plate it flies on as sent
		if (sh.bSeekerMissile) sh.tracer = SSQ_Handler.SVI('ssq_deflect_aim', 3) >= 2 ? null : shooter;
		sh.vel = dir * sp;
		sh.angle = atan2(dir.y, dir.x);
		sh.pitch = -asin(clamp(dir.z, -1, 1));
		if (SSQ_Handler.SVI('ssq_debug', 0) && shooter)
		{
			Vector3 ts = shooter.pos - sh.pos;
			Console.Printf("ssq: turned %s t%d -- %.0f deg off the line back to its shooter (plate swing %.1f)", sh.GetClassName(), Level.maptime,
				acos(clamp((ts.Unit()) dot dir, -1.0, 1.0)), PlateTravel().Length());
		}
		int now = Level.maptime;
		if (now != lastSweepTic)
		{
			lastSweepTic = now;
			if (SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) != 0)
			{
				SSQ_FX.At(mo, P, "ssq/block", CHAN_5, 0.7, 1.1);
				if (plateHeld != 0) SSQ_FX.Buzz(mo, 0.55, 4);
			}
		}
		if (SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) != 0) SSQ_FX.Sparks(mo, P, n, 8);
	}

	// a blocked missile comes back: the same class, from the face, at its source or
	// mirrored off the plate
	void Deflect(PlayerPawn mo, Actor missile, Actor source, Vector3 P, Vector3 n, double boost)
	{
		let back = Actor.Spawn(missile.GetClass(), P + n * 6);
		if (!back) return;
		double sp = max(missile.vel.Length(), missile.speed, 8) * boost;
		Vector3 dir = DeflectDir(mo, back.pos, missile.vel, n, source, -PlateTravel());
		back.vel = dir * sp;
		back.angle = atan2(dir.y, dir.x);
		back.pitch = -asin(clamp(dir.z, -1, 1));
		back.target = mo;	// ours now: it hurts them, never us
		// and the ShieldSaw turned it: Gun Bonsai's VR patch pays a missile to its master weapon
		back.master = mo.FindInventory('SSQ_ShieldSaw');
		back.bMissile = true;
		{ let sh = SSQ_Handler.Get(); if (sh && sh.score) sh.score.Turned(back, source); }
		missile.vel = (0, 0, 0);	// the original dies on the box as it would have
	}

	// ---- held: the grind, the bash, the debug ring (from SSQ_ShieldSaw's Ready tic) -------
	// ONE BASH ON ONE BODY: HeldTick's, and Charge's and Shield Dash's (Gun Bonsai VR patch). `eff` is how hard, units/sec
	// along the face; C and n the plate. What it was before 11-02, lifted out of HeldTick unchanged but for the hit-stop's
	// player (Strike True is read off this player's ShieldSaw).
	static void Bash(PlayerPawn mo, SSQ_ShieldSaw saw, Actor t, Vector3 C, Vector3 n, double eff)
	{
		if (!mo || !t) return;
		let p = mo.player;
		let upg = SSQ_Upg.Svc();
		Vector3 tc = t.pos + (0, 0, t.height * 0.5);
		int dmg = int(clamp(10 + 0.15 * eff, 10, 40) * SSQ_Handler.SV('ssq_bash_damage', 1.0));
		if (upg) upg.GetInt("credit.push", "", 2, 0, saw);
		SSQ_FX.Hit(t, mo, mo, dmg, 'Melee');
		if (upg) upg.GetInt("credit.pop", "", 0, 0, saw);
		if (!t) return;
		// SPARTAN 2 (Gun Bonsai VR patch): the blade resting on the shield cuts what the bash strikes, as hard again,
		// paid to the saber in the main hand (the cut is the blade's)
		if (Spartan(mo) >= 2 && t.health > 0)
		{
			Weapon cutter = p ? p.ReadyWeapon : null;
			String cutName = "";
			if (cutter) cutName = cutter.GetClassName();
			if (cutName.Left(10) != "UBQS_Saber") cutter = saw;
			SSQ_Upg.Touch("spartan", mo, t);
			if (upg && cutter) upg.GetInt("credit.push", "", 2, 0, cutter);
			t.DamageMobj(mo, mo, dmg, 'Melee');
			if (upg && cutter) upg.GetInt("credit.pop", "", 0, 0, cutter);
			if (!t) return;
			SSQ_FX.Sparks(mo, tc, n, 8);
		}
		// CLEAR SOME SPACE. The shove is away from the face, scaled by how hard you drove
		// it, with a small lift under it so a body actually leaves the floor and lands
		// somewhere else instead of sliding a few units and standing back up in your face.
		// Anything too heavy to throw (NOBLOCKMAP, boss-flagged, DONTTHRUST) ignores it
		// on its own, which is the behaviour we want anyway.
		// AND SCALED BY WHAT YOU HIT. Thrust() adds velocity outright and ignores Mass, so a
		// Cyberdemon (1000) left the plate exactly as fast as an imp (100) and the shove read
		// as a scripted launch instead of as weight. The lift takes the same factor, so a
		// heavy thing leans where a light one is thrown.
		// Thrust() itself checks NO flag, so the comment above was a hope: a DONTTHRUST boss
		// (a LegenDoom Lite legendary boss once risen) and a max-mass body (Champions' Bronze,
		// Mass 0x7FFFFFFF, its way of saying "immovable") slid like anything else.
		double mk = clamp(100.0 / max(t.mass, 1.0), 0.08, 2.0);
		double knock = clamp(eff / 20.0, 4, 16) * SSQ_Handler.SV('ssq_bash_knock', 1.35) * mk;
		if (!t.bDontThrust && t.Mass < 0x7FFFFFFF) t.Thrust(knock, atan2(n.y, n.x));
		if (!t.bNoGravity && !t.bDontThrust && t.Mass < 0x7FFFFFFF)
			t.vel.z += SSQ_Handler.SV('ssq_bash_lift', 2.5) * mk * (t.player ? 0.5 : 1.0);
		SSQ_FX.At(mo, C + n * (t.radius * 0.5), "ssq/bash", CHAN_5);
		SSQ_FX.Buzz(mo, 1.0, 8);
		// A BASH THAT LANDS READS (owner 2026-10-31: "a little more visual feedback"). It had a sound and
		// a buzz and nothing to see. At the body's face toward the plate: a burst scaled by how hard you
		// drove it, thrown along the bash, and the flash and bloom the block already uses (dimmed and
		// rate-limited by Photosensitive Mode inside Sparks / BashBurst).
		// ON THE BODY, AT THE PLATE'S HEIGHT, never the floor (owner 2026-10-31: "is your shield bash visual that
		// fire on the ground?" -- it was: the plate's normal tips down in a bash, and the point stepped back along
		// it landed at the monster's feet). The face of the body toward you, across the ground only, at the height
		// the plate struck, kept inside the body; the burst thrown level away from you.
		if (SSQ_Handler.UVI(p, 'ssq_feedback', 1) != 0)
		{
			Vector2 fl = n.xy.Length() > 0.01 ? n.xy.Unit() : (cos(mo.angle), sin(mo.angle));
			Vector3 hit = (tc.x - fl.x * t.radius * 0.8, tc.y - fl.y * t.radius * 0.8,
				clamp(C.z, t.pos.z + t.height * 0.3, t.pos.z + t.height * 0.85));
			SSQ_FX.BashBurst(mo, hit, (fl.x, fl.y, 0.15), eff);
		}
		if (SSQ_Handler.UVI(p, 'ssq_debug', 0))
			Console.Printf("ssq: BASH %s eff %.0f u/s dmg %d knock %.1f", t.GetClassName(), eff, dmg, knock);
		HitStop(t, mo);
		// WALL SLAM (pick 12): watch where the shove takes it
		let sh = SSQ_Handler.Get();
		if (sh) sh.ArmSlam(t, mo.PlayerNumber());
		// BATTERING RAM (Gun Bonsai): what was bashed is thrown into whatever stands behind it
		if (upg && t.health > 0) upg.GetInt("ram", "", mo.PlayerNumber(), eff, t);
	}

	// CHARGE (Gun Bonsai VR patch, GBOVR_TREES.md 4.3 Bash): a bash while you move forward at 2 m/s or more -- the stick,
	// or your body (the patch's own head speed, the one Lunge reads) -- strikes everything in the wedge ahead of the plate,
	// 1 m + 0.5 m a level deep, each bashed as hard.
	static void Charge(PlayerPawn mo, SSQ_ShieldSaw saw, Vector3 C, Vector3 n, double eff, Array<Actor> done)
	{
		int lv = SSQ_Upg.Lv(saw, "Charge");
		if (lv <= 0 || !mo) return;
		double m = SSQ_Handler.CM(100.0);
		Vector2 f = n.xy.Length() > 0.01 ? n.xy.Unit() : (cos(mo.angle), sin(mo.angle));
		double stick = (mo.vel.xy dot f) * TICRATE / m;
		if (max(stick, SSQ_Upg.HeadMps(mo)) < 2.0) return;
		double reach = m * SSQ_Upg.Num("Charge.reach", lv, 1.0);
		// the shockwave and its rolling blast (RS Combat FX, RS Ballistics: tools/fxpull.py)
		Actor.Spawn("SSQ_ChargeWave", C + (f.x, f.y, 0) * reach);	// at the wedge's far end, not in your face
		SSQ_FX.At(mo, C, "ssq/charge", CHAN_AUTO, 0.9);
		Wedge(mo, saw, C, f, reach, eff, done, "charge");
	}

	// everything within `reach` ahead of C, inside 45 degrees of f, in sight and not already struck: bashed
	static int Wedge(PlayerPawn mo, SSQ_ShieldSaw saw, Vector3 C, Vector2 f, double reach, double eff, Array<Actor> done, String touchId)
	{
		int n = 0;
		Vector3 nf = (f.x, f.y, 0);
		let it = BlockThingsIterator.CreateFromPos(C.x, C.y, C.z - reach, reach * 2.0, reach + 64, false);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || t == mo || !t.bShootable || t.health <= 0) continue;
			if (t.player && !deathmatch) continue;
			if (t.bFriendly && !deathmatch) continue;
			if (done.Find(t) < done.Size()) continue;
			Vector2 d = t.pos.xy - C.xy;
			double along = d dot f;
			if (along < -t.radius || along > reach + t.radius) continue;
			double side = abs(d.x * f.y - d.y * f.x);
			if (side > max(along, 0.0) + t.radius) continue;
			if (C.z < t.pos.z - 32 || C.z > t.pos.z + t.height + 32) continue;
			if (!mo.CheckSight(t, SF_IGNOREVISIBILITY)) continue;
			done.Push(t);
			SSQ_Upg.Touch(touchId, mo, t);
			Bash(mo, saw, t, C, nf, eff);
			n++;
		}
		return n;
	}

	// SHIELD DASH (Gun Bonsai VR patch, the owner 11-02: "some kind of movement dash forward so we can close and bash"):
	// 2 m + 1 m a level the way the shield faces, the pawn moved as RSQ Grapple's pull moves it (eased, capped at its 30
	// units a tic), never the camera on its own; stopped by walls and bodies; the thrust lands as a bash at the end; 2 s
	// before the next. Started from HeldTick (the synced hand), ticked here, so every machine moves it the same.
	void StartDash(PlayerPawn mo, Vector3 n, int lv, double eff)
	{
		if (!mo) return;
		dashDir = n.xy.Length() > 0.01 ? n.xy.Unit() : (cos(mo.angle), sin(mo.angle));
		dashLeft = SSQ_Handler.CM(100.0) * SSQ_Upg.Num("ShieldDash.m", lv, 2.0);
		dashEff = max(eff, SSQ_Handler.SV('ssq_bash_speed', 45.0) * 2.0);
		dashTics = 0; dashSent = 0; dashLast = mo.pos;
		SSQ_FX.At(mo, mo.pos + (0, 0, mo.height * 0.5), "ssq/dash", CHAN_6, 1.0);
	}
	void DashTick(PlayerPawn mo)
	{
		if (dashCool > 0) dashCool--;
		if (dashLeft <= 0) return;
		if (dashTics > 0)
		{
			double moved = (mo.pos.xy - dashLast.xy).Length();
			dashLeft -= moved;
			if (moved < dashSent * 0.33) dashLeft = 0;	// a wall or a body stopped it
		}
		if (dashLeft <= 1 || dashTics > 35) { EndDash(mo); return; }
		double sp = clamp(dashLeft * 0.4, 6.0, 30.0);
		mo.vel.xy = dashDir * sp;
		// the speed streaks, either side of you, standing along the dash
		Vector2 sd = (-dashDir.y, dashDir.x);
		for (int k = -1; k <= 1; k += 2)
		{
			Vector2 at = mo.pos.xy + sd * k * (mo.radius + random[SSQ_Fx](10, 30)) + dashDir * random[SSQ_Fx](0, 40);
			let st = Actor.Spawn("SSQ_DashStreak", (at.x, at.y, mo.pos.z + mo.height * frandom[SSQ_Fx](0.3, 0.9)));
			if (st) st.angle = atan2(dashDir.y, dashDir.x) + 90;
		}
		dashSent = sp; dashLast = mo.pos; dashTics++;
	}
	void EndDash(PlayerPawn mo)
	{
		dashLeft = 0; dashCool = 70;
		mo.vel.xy *= 0.3;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		Vector3 C = mo.pos + (dashDir.x * mo.radius, dashDir.y * mo.radius, mo.height * 0.5);
		Array<Actor> none;
		Wedge(mo, saw, C, dashDir, SSQ_Handler.CM(100.0), dashEff, none, "dash.bash");
	}

	static void HeldTick(PlayerPawn mo, SSQ_ShieldSaw saw, SSQ_Pose pose)
	{
		if (!mo || !saw || !pose || !pose.Fresh(mo.Level.maptime)) return;
		let g = SSQ_Guard(mo.FindInventory('SSQ_Guard'));
		if (!g) return;
		let p = mo.player;
		Vector3 C = PlateCentre(mo, pose, false);
		Vector3 n = PlateNormal(mo, pose, false);
		double R = PlateRadius(saw.Revved(), g.GrowK(), mo.PlayerNumber());

		if (SSQ_Handler.UVI(p, 'ssq_debug_ring', 0) != 0) g.Ring(mo, C, n, R * BraceK(SSQ_Handler.Get(), mo.PlayerNumber()), pose);

		if (g.bashCool > 0) g.bashCool--;
		// EVERY TIC NOW, CAPPED PER BODY. The tic gate that used to stand on this line
		// (maptime % ssq_grind_every == 0) is the per-victim cooldown in the loop below instead:
		// see grindWho/grindWhen. ssq_grind_every means the same thing to the player -- tics
		// between grind hits, the menu's "Grind Gap" -- it is only counted for each body
		// separately now, so nothing is skipped and nothing is hurt faster.
		int grindRate = max(1, SSQ_Handler.SVI('ssq_grind_every', 4));
		bool grindNow = saw.Revved() && SSQ_Handler.SVI('ssq_grind_damage', 6) > 0;
		Vector3 v = pose.Vel() * TICRATE;
		double shove = v dot n;
		// A COMMITTED PUSH IS A BASH TOO. `shove` is ONE tic of plate travel along the face, so
		// the only thing that ever reached ssq_bash_speed was a fast snap -- and now that the
		// body's own motion is out of the measurement, leaning the shield into a body or walking
		// it into a doorway full of them moves the plate steadily and slowly and would do nothing
		// at all, for as long as you held it. So the push is INTEGRATED as well as differenced: a
		// decaying sum worth about four tics, counted at ssq_bash_sustain of itself. Integrating
		// instead of differentiating is also what stops the turnaround of a shove lying to you.
		// 0 restores exactly the old behaviour. (The saber's cut does this with ubqs_cut_sustain.)
		if (mo.Level.maptime != g.lastPushTic + 1) g.pushPath = 0;
		g.lastPushTic = mo.Level.maptime;
		g.pushPath = g.pushPath * 0.75 + max(shove, 0.0);
		double eff = max(shove, g.pushPath * clamp(SSQ_Handler.SV('ssq_bash_sustain', 0.6), 0.0, 1.0));
		// SHIELD DASH (Gun Bonsai VR patch): the shield thrust forward at 3 m/s or more with the stick pushed forward
		if (g.dashLeft <= 0 && g.dashCool <= 0 && p.cmd.forwardmove > 0 && shove >= 3.0 * SSQ_Handler.CM(100.0))
		{
			int dl = SSQ_Upg.Lv(saw, "ShieldDash");
			if (dl > 0) g.StartDash(mo, n, dl, eff);
		}
		bool bashNow = SSQ_Handler.SVI('ssq_bash', 1) != 0 && g.bashCool == 0 && eff >= SSQ_Handler.SV('ssq_bash_speed', 45.0);
		if (!grindNow && !bashNow) return;

		// THE BASH REACHES FURTHER THAN THE GRIND. A shove is the whole shield and your whole
		// arm behind it, not the rim touching something: ssq_bash_reach opens the disc and its
		// depth by a fifth for the bash test only. The grind still has to actually be on them.
		double bashK = max(SSQ_Handler.SV('ssq_bash_reach', 1.2), 1.0);
		double bashR = R * bashK;
		// read above the iterator, like everything else here: SVI is an uncached lookup by name
		bool los = SSQ_Handler.SVI('ssq_bash_los', 1) != 0;
		// AND THE PLATE WALKS ITS OWN TIC HERE TOO. This loop tested ONE plate centre -- the one
		// the tic ended at -- while both block paths have walked the plate across its travel all
		// along (StopsHitscan, :378-384; DoEffect, :484-505, and PlateTravel's own comment says
		// why). The rim is the fastest-moving part of the shield and the grind is the rim
		// actually on a body: sweep the arm along a line of them at a plain 3 m/s (2.91 units a
		// tic) and the plate crossed that much between evaluations with the per-body cooldown
		// above, and about 11.6 units before it, against a 29 cm rim -- so bodies in the gap were
		// never tested. This was the last point-sampled contact in the mod.
		//
		// It costs no traces: PlateTravel() is the same one subtraction out of the synced history
		// the block already asks for, and the walk is two more subtractions and two dot products
		// per candidate, inside a BlockThingsIterator that was going to run anyway. The travel is
		// deliberately absolute, as it is for the block (pose.zs:72-74): the plate really did pass
		// through that world space, and the bodies it passed are in world space too.
		Vector3 travel = g.PlateTravel(true);
		// GUN BONSAI: the bash and the grind name the player as the inflictor (RS_Score reads that as the
		// shield), which leaves the VR patch nothing to tell the hands apart by -- measured, it paid the
		// main-hand weapon. So the damage is bracketed: the patch pays whatever happens inside to the saw.
		let upg = SSQ_Upg.Svc();
		Array<Actor> struck;	// bashed this tic (Charge strikes the rest)
		let it = BlockThingsIterator.Create(mo, bashR + 64);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || t == mo || !t.bShootable || t.health <= 0) continue;
			if (t.player && !deathmatch) continue;
			Vector3 tc = t.pos + (0, 0, t.height * 0.5);
			double reach = bashNow ? bashR : R;
			double depth = (bashNow ? (t.radius + 10) * bashK : t.radius + 10);
			// three places the plate was during this tic: where it came from, halfway, here --
			// the same walk in the same order as the two block paths. The first that touches
			// wins, and the tests below read ITS in-plane distance and depth: `along`'s sign is
			// what the bash turns on, so it has to be the sub-step that actually touched.
			double along = 0;
			bool got = false, onPlate = false;
			for (int s = 0; s <= 2 && !got; s++)
			{
				Vector3 d = tc - (C + travel * (1.0 - s * 0.5));
				double al = d dot n;
				Vector3 ip = d - n * al;
				if (ip.Length() > reach + t.radius) continue;
				if (abs(al) > depth) continue;
				got = true; along = al;
				// the grind is the rim on them, and keeps the tighter box
				onPlate = ip.Length() <= R + t.radius && abs(al) <= t.radius + 10;
			}
			if (!got) continue;
			// NOT THROUGH THE WALL. The iterator box is over a hundred units across and nothing here
			// asked whether the shield could reach what it found, so a bash beside a thin wall or a
			// closed door damaged and launched what was behind it. Last of the per-victim tests, so
			// it costs a sight check only for something the plate geometrically touched.
			// (The saber's cut took exactly this fix: ubqs_cut_los.)
			if (los && !mo.CheckSight(t, SF_IGNOREVISIBILITY)) continue;
			// ONCE EVERY ssq_grind_every TICS FOR THIS BODY, not once in that many for the whole
			// grind: see grindWho/grindWhen above. The bash is unaffected -- it keeps its own
			// global cooldown (bashCool), which is what a shove should have.
			bool grindHim = grindNow && onPlate;
			int gi = 0;
			if (grindHim)
			{
				gi = g.grindWho.Find(t);
				if (gi < g.grindWho.Size() && mo.Level.maptime - g.grindWhen[gi] < grindRate) grindHim = false;
			}
			if (grindHim)
			{
				// stamped BEFORE the damage: DamageMobj can destroy t (a gib leaves nothing to
				// look up, and the line below already expects that), and a body that was hurt
				// and lived must not be ground again next tic
				if (gi < g.grindWho.Size())
				{
					while (g.grindStart.Size() < g.grindWho.Size()) g.grindStart.Push(mo.Level.maptime);
					if (mo.Level.maptime - g.grindWhen[gi] > grindRate * 3) g.grindStart[gi] = mo.Level.maptime;   // a new grind, not the same one going on
					g.grindWhen[gi] = mo.Level.maptime;
				}
				else { g.grindWho.Push(t); g.grindWhen.Push(mo.Level.maptime); g.grindStart.Push(mo.Level.maptime); }
				int dmg = GrindDamage(mo);	// HUNGRY BLADES (Gun Bonsai VR patch) raises it
				if (upg) upg.GetInt("credit.push", "", 2, 0, saw);
				t.DamageMobj(mo, mo, dmg, 'Saw');
				if (upg) upg.GetInt("credit.pop", "", 0, 0, saw);
				if (!t) continue;
				SSQ_FX.At(mo, C + n * (t.radius * 0.5), "ssq/grind", CHAN_5, 0.8);
				SSQ_FX.Sparks(mo, C + n * (t.radius * 0.5), n, 4);
				SSQ_FX.Buzz(mo, 0.3, 3);
			}
			if (bashNow && along > 0)
			{
				Bash(mo, saw, t, C, n, eff);
				struck.Push(t);
				g.bashCool = 10;
			}
		}

		// CHARGE (Gun Bonsai VR patch): a bash on the move strikes the wedge ahead as well
		if (bashNow) Charge(mo, saw, C, n, eff, struck);

		// AND THE LIST IS SWEPT UP HERE, so it cannot grow for a whole map: anything gone or
		// dead, anything whose cooldown ran out long ago, and anything stamped in the future --
		// SSQ_Guard is PERSISTENTPOWER, so it outlives the level and maptime starts again, and
		// the stamp test is self-healing in the same way lastPushTic above is rather than
		// needing a second site to remember to clear it. (The saber prunes its own list the same
		// way, QuestSaber/zscript.txt:1968-1969.)
		for (int k = g.grindWho.Size() - 1; k >= 0; k--)
		{
			Actor gw = g.grindWho[k];
			int gt = g.grindWhen[k];
			if (!gw || gw.health <= 0 || mo.Level.maptime - gt > 70 || mo.Level.maptime < gt)
				{ g.grindWho.Delete(k); g.grindWhen.Delete(k); if (k < g.grindStart.Size()) g.grindStart.Delete(k); }
		}
	}

	// the plate as particles: rim, a spoke along the face normal, and the hand
	void Ring(PlayerPawn mo, Vector3 C, Vector3 n, double R, SSQ_Pose pose)
	{
		Vector3 a = pose.F;
		Vector3 b = (n.y * a.z - n.z * a.y, n.z * a.x - n.x * a.z, n.x * a.y - n.y * a.x);
		a = (b.y * n.z - b.z * n.y, b.z * n.x - b.x * n.z, b.x * n.y - b.y * n.x);
		// Colour-blind play (rsqa_colorblind, cb.zs): the red rim and green spoke are one colour to
		// a deuteranope, so they take the series pair; the hand goes grey. Sizes already differ.
		Color rim = SSQ_CB.Pick(SSQ_CB.CB_COULD, 0xff2020), spoke = SSQ_CB.Pick(SSQ_CB.CB_HAVE, 0x20ff20);
		Color hand = SSQ_CB.Pick(SSQ_CB.CB_IDLE, 0x3080ff);
		for (int k = 0; k < 36; k++)
		{
			double t = k * 10.0;
			SSQ_FX.Particle(mo, C + a * (R * cos(t)) + b * (R * sin(t)), (0, 0, 0), rim, 4, 6.0);
		}
		SSQ_FX.Particle(mo, C, (0, 0, 0), rim, 4, 8.0);
		for (int k = 1; k <= 6; k++) SSQ_FX.Particle(mo, C + n * (k * 3.0), (0, 0, 0), spoke, 4, 5.0);
		SSQ_FX.Particle(mo, pose.pos[0], (0, 0, 0), hand, 4, 7.0);
		for (int k = 1; k <= 4; k++) SSQ_FX.Particle(mo, pose.pos[0] + pose.F * (k * 3.0), (0, 0, 0), "ffffff", 4, 4.0);
	}
}


// The shield's bullet return is fired from here, so the engine traces it exactly along the
// deflection instead of re-aiming it down the gun (see StopsHitscan). One tic, then gone.
class SSQ_Ricochet : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}
