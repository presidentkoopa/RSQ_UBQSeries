// RSQ Grenade -- THE HANDLING. Brutal Doom VR's way (the owner's BD22 VR Reloaded grenade, rsg/grenade.zs, his
// code, ported to this pack's own weapon), plus the teeth from his RS_Grenade (rs_vrgrenade.zs):
//   1. the OTHER hand's trigger takes the RING and pulls it away: the pin is out. Bring that hand back to the top and
//      take the ring again: the pin goes back in.
//   2. the holding hand's TRIGGER is your squeeze on the spoon. Let go of it while swinging: thrown, at the speed and
//      direction of the swing. Let go while still: the spoon flies off and the fuse is lit in your hand (cooking).
//      Squeeze and let go again to throw it.
//   3. cook too long and it goes off in your hand.
//   4. THE FACE ROUTE (RS_Grenade): squeeze the trigger and hold the grenade at your face for a moment: you pull the
//      pin with your teeth. Two radii, not one: once the pin is out the hand has to have been clear of your face (the
//      far radius) before it can take another; letting go of the trigger re-arms it too (RS_Grenade's own rule).
//   5. THE FUSE YOU CAN SEE: while the fuse burns the grenade flashes red, faster and faster, with a tick each flash
//      (RS_Grenade's README; the tick is its GPIN, the flash its idea, built here).
//
// THE GEOMETRY IS BRUTAL DOOM VR'S, so the ring is where it is drawn: the grenade is drawn with BD22 VR's own
// placement of nade.md3 (MODELDEF.txt, its HandGrenades block, lane B's fit_nade.py), and the ring and the body
// centre are BD22 VR's measured points in the holding hand's frame (cm forward, left, up of the controller).
//
// NETPLAY, THE SERIES' WAY: the hands are read on the console player's machine only (the engine writes the VR pose
// fields for the camera player alone), and what they decide travels as network events (rsqgn_pin, rsqgn_unpin,
// rsqgn_cook, rsqgn_at / rsqgn_v / rsqgn_throw). Everything that follows -- the pin state, the fuse, the cook-off,
// the throw -- runs from those events on every machine alike.
//
// THE THROW IS THE HAND'S OWN MOTION, measured as the series does (RSQ Distance Grab aim.zs PalmVelocity, RSQ
// Tactical Rig's gun throw): the hand relative to the pawn, in the tracking space's frame (so walking, snap turns
// and head turns are no swing), the fastest 2-tic window of the last seven tics, turned back into the world.
//
// STANDS DOWN with Brutal Doom VR Reloaded (its RSG_Handler, looked up by a String at run time: a quoted class name
// is resolved when the script compiles and would break this pack without Brutal Doom): then nothing here runs, and
// BD22 VR's own grenade does everything.

class RSQGN_Geo play
{
	static bool InVR(PlayerPawn pmo)
	{
		return pmo && pmo.player && pmo.player.PlayInVR && pmo.OverrideAttackPosDir;
	}

	static Vector3 Pos(PlayerPawn pmo, int h) { return h == 0 ? pmo.AttackPos : pmo.OffhandPos; }

	static double Ps(PlayerPawn pmo)
	{
		double ps = pmo.Level.pixelstretch;
		return ps > 0 ? ps : 1.2;
	}

	static double Vu()
	{
		let cv = CVar.FindCVar("vr_vunits_per_meter");
		double v = cv ? cv.GetFloat() : 34;
		return v > 0 ? v : 34;
	}

	// a unit direction of hand h's own frame (yaw 0 pitch 0 forward, yaw 90 left, pitch 90 up), the vertical squash
	// taken back out (BD22 VR rsvr/vrhand.zs HandDir / OffDir). The engine's pointer behind AttackDir is set only
	// while a frame renders; a pawn restored from a save thinks before its first frame (BD22 VR's save crash), so it
	// is only called while live.
	static Vector3 Dir(PlayerPawn pmo, int h, double yaw, double pitch)
	{
		Vector3 ap;
		if (!pmo.OverrideAttackPosDir) ap = (pmo.angle + yaw, pmo.pitch + pitch, 0);
		else ap = h == 0 ? pmo.AttackDir(pmo, pmo.angle + yaw, pmo.pitch + pitch) : pmo.OffhandDir(pmo, pmo.angle + yaw, pmo.pitch + pitch);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * Ps(pmo));
		double l = v.Length();
		return l > 0 ? v / l : (1, 0, 0);
	}

	// hand h's frame, cm (forward, left, up) -> a world offset from that controller (BD22 VR RSR_State.FromGun)
	static Vector3 FromHand(PlayerPawn pmo, int h, Vector3 cm)
	{
		Vector3 w = Dir(pmo, h, 0, 0) * cm.x + Dir(pmo, h, 90, 0) * cm.y + Dir(pmo, h, 0, 90) * cm.z;
		w *= Vu() / 100.0;
		w.z /= Ps(pmo);
		return w;
	}

	// a map-space vector's real length in metres (34 units a metre across, 34 / 1.2 up)
	static double Metres(PlayerPawn pmo, Vector3 v)
	{
		return (v.x, v.y, v.z * Ps(pmo)).Length() / Vu();
	}
}

class RSQGN_Handler : EventHandler
{
	// BD22 VR rsg/grenade.zs, measured there for the placement MODELDEF.txt copies (holding hand's frame, cm F L U)
	const RING_F = 3.45;
	const RING_L = 5.12;
	const RING_U = 5.06;
	const NADE_F = 2.77;
	const NADE_L = 4.23;
	const NADE_U = -1.97;
	const RING_GRAB = 12.0;		// cm round the ring the other hand can take it (BD22 VR)
	const PULL = 8.0;			// cm past that: the pin is out (BD22 VR)
	const WIN = 7;				// tics of hand history (RSQ Distance Grab's PITCH_WINDOW, ~200 ms)

	// ---- the playsim's state (every machine, from the network events) ----
	bool armed[MAXPLAYERS];		// pin out
	bool spoon[MAXPLAYERS];		// spoon gone: the fuse burns in the hand
	int cookTic[MAXPLAYERS];
	int flashNext[MAXPLAYERS];
	int redUntil[MAXPLAYERS];
	Vector3 throwAt[MAXPLAYERS], throwVel[MAXPLAYERS];

	// ---- the console player's hands (local) ----
	private transient bool ringHeld, grabPrev, trigPrev, faceReady;
	private transient int faceTic, lastHand, waitUntil;
	private transient bool waitArmed, waitSpoon;
	private transient Vector3 lastRel[2], rawHand[2];
	private transient bool primed[2], framePrimed, wasSame;
	private transient double frameYaw, lastAngle, lastHandYaw[2];
	private transient int quietTics;
	private transient Vector3 samples[2 * WIN];
	private transient int sampleAt[2];

	static RSQGN_Handler Get() { return RSQGN_Handler(EventHandler.Find("RSQGN_Handler")); }

	// Brutal Doom VR Reloaded is loaded: its own grenade does everything and this pack does nothing
	static bool BDVR()
	{
		String n = "RSG_Handler";
		class<Object> c = n;
		return c != null;
	}

	static bool Active()
	{
		if (BDVR()) return false;
		let cv = CVar.FindCVar("rsqgn_on");
		return !cv || cv.GetBool();
	}

	static bool PFlag(PlayerInfo p, String n, bool d) { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }
	static double PNum(PlayerInfo p, String n, double d) { let c = CVar.GetCVar(n, p); return c ? c.GetFloat() : d; }
	static double SNum(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool Debug(PlayerInfo p) { return PFlag(p, "rsqgn_debug", false); }

	static int FuseTics() { return int(clamp(SNum("rsqgn_fuse", 3.0), 0.5, 10.0) * TICRATE); }

	// the flash: every period tics, red for half of it; the period runs from 16 tics with the whole fuse left down to 2
	// at the end, so the flashes come faster and faster
	static int FlashPeriod(int left, int total)
	{
		if (total <= 0) return 2;
		return clamp(2 + int(14.0 * left / total + 0.5), 2, 16);
	}

	// Which hand holds the grenade: 0 main, 1 off, -1 neither (or the main hand is switching away).
	static int HandOf(PlayerInfo p)
	{
		if (!p) return -1;
		if (p.OffhandWeapon is "RSQGN_Grenade") return 1;
		if (p.ReadyWeapon is "RSQGN_Grenade" && (p.PendingWeapon == WP_NOCHANGE || p.PendingWeapon == p.ReadyWeapon)) return 0;
		return -1;
	}

	// The held grenade's picture (weapon.zs A_RSQGNReady): 0 ring in, 1 pin out, 2 cooking, 3 cooking + red.
	static int HeldFrame(int n)
	{
		let h = Get();
		if (!h || n < 0 || n >= MAXPLAYERS || !h.armed[n]) return 0;
		if (!h.spoon[n]) return 1;
		return level.maptime < h.redUntil[n] ? 3 : 2;
	}

	// ---- the playsim ----------------------------------------------------------------------------------------------

	override void WorldLoaded(WorldEvent e)
	{
		// a new map starts clean (BD22 VR's quiet put-away): the pin goes back in, nothing is spent
		if (e.IsSaveGame) return;
		for (int n = 0; n < MAXPLAYERS; n++) Reset(n);
	}

	override void PlayerEntered(PlayerEvent e) { Equip(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { Equip(e.PlayerNumber); }

	// The grenade and a few to start with (rsqgn_start, 3), once: a player who has it already (carried from the last
	// map) gets nothing. Never with Brutal Doom VR loaded.
	void Equip(int n)
	{
		if (!Active() || n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo || pmo.FindInventory("RSQGN_Grenade")) return;
		pmo.GiveInventory("RSQGN_Grenade", 1);
		int want = clamp(int(SNum("rsqgn_start", 3)), 0, 8);
		int have = pmo.CountInv("RSQGN_Ammo");
		if (want > have) pmo.GiveInventory("RSQGN_Ammo", want - have);
		if (Debug(players[n])) Console.Printf("RSQGN equip p%d: grenade + %d (start %d)", n, pmo.CountInv("RSQGN_Ammo"), want);
	}

	void Reset(int n)
	{
		armed[n] = false;
		spoon[n] = false;
		redUntil[n] = 0;
		flashNext[n] = 0;
	}

	override void WorldTick()
	{
		if (!Active()) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) continue;
			let p = players[n];
			let pmo = p.mo;
			if (!pmo) continue;
			int h = HandOf(p);
			if (h < 0 || pmo.health <= 0)
			{
				// switched away (or died) with the pin out: a lit fuse still goes off, a held spoon goes back in
				if (armed[n] && spoon[n]) Boom(pmo, n, "left the hand lit");
				else if (armed[n]) Reset(n);
				continue;
			}
			if (spoon[n])
			{
				int cooked = level.maptime - cookTic[n];
				if (cooked < 0) { cookTic[n] = level.maptime; cooked = 0; }	// BD22 VR: re-base, never latch
				int fuse = FuseTics();
				if (cooked >= fuse) { Boom(pmo, n, "cooked too long"); continue; }
				Flash(pmo, n, fuse - cooked, fuse);
			}
			// the last grenade gone: the hand gets something else (BD22 VR 1.12: an empty grenade hand vanished)
			if (!armed[n] && pmo.CountInv("RSQGN_Ammo") <= 0) Empty(pmo, h);
		}
		let cp = players[consoleplayer].mo;
		if (playeringame[consoleplayer] && cp) Local(cp);
	}

	void Flash(PlayerPawn pmo, int n, int left, int total)
	{
		if (level.maptime < flashNext[n]) return;
		int per = FlashPeriod(left, total);
		redUntil[n] = level.maptime + max(1, per / 2);
		flashNext[n] = level.maptime + per;
		pmo.A_StartSound("rsqgn/tick", CHAN_5, CHANF_OVERLAP, left < TICRATE ? 0.85 : 0.5);
		if (Debug(pmo.player)) Console.Printf("RSQGN flash hand t%d period %d left %d", level.maptime, per, left);
	}

	void Empty(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		if (h == 0)
		{
			if (p.PendingWeapon == WP_NOCHANGE) pmo.PickNewWeapon(null);
		}
		else
		{
			p.SetPsprite(PSP_OFFHANDWEAPON, null);
			p.OffhandWeapon = null;
		}
	}

	// It went off in the hand. At the body (the hand's pose is known on its owner's machine only, and where the blast
	// is decides who it hurts, so every machine must agree); at that range it makes no difference.
	void Boom(PlayerPawn pmo, int n, String why)
	{
		let b = Actor.Spawn("RSQGN_HandBlast", pmo.Pos + (0, 0, pmo.Height * 0.6), ALLOW_REPLACE);
		if (b) b.target = pmo;
		pmo.TakeInventory("RSQGN_Ammo", 1);
		if (Debug(pmo.player)) Console.Printf("RSQGN boom in hand p%d t%d (%s)", n, level.maptime, why);
		Reset(n);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.IsManual || !Active()) return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let p = players[n];
		let pmo = p.mo;
		if (!pmo || pmo.health <= 0) return;
		int h = HandOf(p);
		if (e.Name == "rsqgn_at") { throwAt[n] = (e.Args[0], e.Args[1], e.Args[2]) / 8.0; return; }
		if (e.Name == "rsqgn_v") { throwVel[n] = (e.Args[0], e.Args[1], e.Args[2]) / 100.0; return; }
		if (h < 0) return;
		if (e.Name == "rsqgn_pin")
		{
			if (armed[n] || pmo.CountInv("RSQGN_Ammo") <= 0) return;
			armed[n] = true;
			pmo.A_StartSound("rsqgn/pin", CHAN_WEAPON, CHANF_OVERLAP);
			RSQGN_Buzzer.Start(pmo, e.Args[0] == 1 ? h : 1 - h, 0.6, 5);
			if (Debug(p)) Console.Printf("RSQGN pin out p%d t%d by %s (hand %d)", n, level.maptime, e.Args[0] == 1 ? "teeth" : "ring", h);
		}
		else if (e.Name == "rsqgn_unpin")
		{
			if (!armed[n] || spoon[n]) return;
			Reset(n);
			pmo.A_StartSound("rsqgn/pin", CHAN_WEAPON, CHANF_OVERLAP);
			RSQGN_Buzzer.Start(pmo, 1 - h, 0.4, 4);
			if (Debug(p)) Console.Printf("RSQGN pin back in p%d t%d", n, level.maptime);
		}
		else if (e.Name == "rsqgn_cook")
		{
			if (!armed[n] || spoon[n]) return;
			spoon[n] = true;
			cookTic[n] = level.maptime;
			flashNext[n] = level.maptime;
			pmo.A_StartSound("rsqgn/spoon", CHAN_AUTO, CHANF_OVERLAP);
			RSQGN_Buzzer.Start(pmo, h, 0.5, 4);
			if (Debug(p)) Console.Printf("RSQGN spoon off p%d t%d: cooking (swing was %.2f m/s)", n, level.maptime, e.Args[0] / 100.0);
		}
		else if (e.Name == "rsqgn_throw")
		{
			if (!armed[n]) return;
			Throw(pmo, n, h, e.Args[0] / 100.0);
		}
	}

	void Throw(PlayerPawn pmo, int n, int h, double ms)
	{
		int fuse = FuseTics();
		int left = spoon[n] ? fuse - (level.maptime - cookTic[n]) : fuse;
		left = max(left, 1);
		Vector3 mid = pmo.Pos + (0, 0, pmo.Height * 0.6);
		Vector3 at = throwAt[n];
		if ((at - mid).Length() > 96) at = mid;		// a hand never further than an arm's length
		// the hand through a wall: it leaves from where the wall stops it (a missile ignores the player who threw it,
		// so starting inside the player is fine; TestMobjLocation would refuse the player's own body)
		Vector3 dv = at - mid;
		double dl = dv.Length();
		if (dl > 0.5)
		{
			FLineTraceData tr;
			pmo.LineTrace(VectorAngle(dv.x, dv.y), dl, -atan2(dv.z, dv.xy.Length()), TRF_THRUACTORS, mid.z - pmo.pos.z, 0, 0, tr);
			if (tr.HitType != TRACE_HitNone && tr.Distance < dl) at = mid + dv / dl * max(0, tr.Distance - 4);
		}
		let g = RSQGN_Thrown(Actor.Spawn("RSQGN_Thrown", at, ALLOW_REPLACE));
		if (!g) return;
		g.target = pmo;
		g.Vel = throwVel[n];
		g.angle = VectorAngle(g.Vel.x, g.Vel.y);
		g.fuse = left;
		g.fuseTotal = fuse;
		g.Gravity = clamp(SNum("rsqgn_gravity", 0.27), 0.05, 1.0);
		g.BounceFactor = clamp(SNum("rsqgn_bounce", 0.5), 0.0, 0.9);
		g.WallBounceFactor = clamp(SNum("rsqgn_wallbounce", 0.25), 0.0, 0.9);
		pmo.A_StartSound("rsqgn/toss", CHAN_WEAPON, CHANF_OVERLAP);
		if (!spoon[n]) pmo.A_StartSound("rsqgn/spoon", CHAN_AUTO, CHANF_OVERLAP);
		RSQGN_Buzzer.Start(pmo, h, 0.6, 5);
		if (Debug(pmo.player))
			Console.Printf("RSQGN thrown p%d t%d hand %d swing %.2f m/s, leaves at %.1f u/tic (%.2f m/s) from (%.0f %.0f %.0f), fuse %d of %d%s",
				n, level.maptime, h, ms, g.Vel.Length(), RSQGN_Geo.Metres(pmo, g.Vel) * TICRATE, g.pos.x, g.pos.y, g.pos.z, left, fuse, spoon[n] ? " (cooked)" : "");
		pmo.TakeInventory("RSQGN_Ammo", 1);
		Reset(n);
	}

	// ---- the console player's hands -------------------------------------------------------------------------------

	private void Send(String what, int a = 0, int b = 0, int c = 0)
	{
		EventHandler.SendNetworkEvent(what, a, b, c);
	}

	// wait for the event just sent to come back as a state change (or 4 tics) before deciding anything else
	private void Wait(int n)
	{
		waitUntil = level.maptime + 4;
		waitArmed = armed[n];
		waitSpoon = spoon[n];
	}

	private void Local(PlayerPawn pmo)
	{
		let p = pmo.player;
		int n = consoleplayer;
		if (!RSQGN_Geo.InVR(pmo)) return;
		Sample(pmo);
		int h = HandOf(p);
		if (h < 0 || pmo.health <= 0) { ringHeld = false; trigPrev = false; faceTic = 0; lastHand = -1; return; }
		if (h != lastHand) { ringHeld = false; faceTic = 0; faceReady = true; lastHand = h; }
		int o = 1 - h;
		int btn = p.cmd.buttons;
		bool trig = (btn & (h == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grab = (btn & (o == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grabPress = grab && !grabPrev;
		grabPrev = grab;
		bool trigUp = !trig && trigPrev;
		trigPrev = trig;
		if (!grab) ringHeld = false;
		if (level.maptime < waitUntil && armed[n] == waitArmed && spoon[n] == waitSpoon) return;
		waitUntil = 0;

		Vector3 ring = RSQGN_Geo.Pos(pmo, h) + RSQGN_Geo.FromHand(pmo, h, (RING_F, RING_L, RING_U));
		double d = RSQGN_Geo.Metres(pmo, RSQGN_Geo.Pos(pmo, o) - ring) * 100.0;
		bool dbg = Debug(p);

		if (!armed[n])
		{
			if (pmo.CountInv("RSQGN_Ammo") <= 0) return;
			if (grabPress && d < RING_GRAB)
			{
				ringHeld = true;
				RSQGN_Buzzer.Start(pmo, o, 0.3, 3);
				if (dbg) Console.Printf("RSQGN ring taken t%d (other hand %.1f cm from it)", level.maptime, d);
			}
			else if (grabPress && dbg) Console.Printf("RSQGN ring missed t%d (other hand %.1f cm from it, needs < %.0f)", level.maptime, d, RING_GRAB);
			if (ringHeld && d > RING_GRAB + PULL)
			{
				ringHeld = false;
				if (dbg) Console.Printf("RSQGN ring pulled t%d (%.1f cm)", level.maptime, d);
				Send("rsqgn_pin", 0);
				Wait(n);
				return;
			}
			Face(pmo, p, n, h, trig, dbg);
			return;
		}
		faceTic = 0;
		if (!trig) faceReady = true;

		if (!spoon[n])
		{
			if (grabPress && d < RING_GRAB * 0.6)
			{
				Send("rsqgn_unpin");
				Wait(n);
				return;
			}
			if (trigUp)
			{
				double ms; Vector3 v;
				[ms, v] = Peak(pmo, h);
				double need = PNum(p, "rsqgn_swing", 2.5);
				if (dbg) Console.Printf("RSQGN release t%d: swing %.2f m/s (throws from %.2f)", level.maptime, ms, need);
				if (ms >= need) SendThrow(pmo, h, ms, v);
				else Send("rsqgn_cook", int(ms * 100));
				Wait(n);
			}
			return;
		}
		if (trigUp)
		{
			double ms; Vector3 v;
			[ms, v] = Peak(pmo, h);
			SendThrow(pmo, h, ms, v);
			Wait(n);
		}
	}

	// THE TEETH (RS_Grenade's face route): the trigger squeezed and the grenade held at your face for a run of tics.
	// The distance is from the drawn grenade to your eyes (the headset), in metres, RS_Grenade's 16 / 24 map units
	// (0.47 / 0.71 m) and 12 tics. Once taken, the far radius (or letting go of the trigger) re-arms it.
	private void Face(PlayerPawn pmo, PlayerInfo p, int n, int h, bool trig, bool dbg)
	{
		if (!PFlag(p, "rsqgn_face", true)) { faceTic = 0; return; }
		Vector3 head = (pmo.Pos.x, pmo.Pos.y, p.viewz);
		Vector3 nade = RSQGN_Geo.Pos(pmo, h) + RSQGN_Geo.FromHand(pmo, h, (NADE_F, NADE_L, NADE_U));
		double dist = RSQGN_Geo.Metres(pmo, nade - head);
		double near = PNum(p, "rsqgn_face_near", 0.47);
		double far = PNum(p, "rsqgn_face_far", 0.71);
		int hold = int(PNum(p, "rsqgn_face_hold", 12));
		if (!trig || dist > far) faceReady = true;
		if (trig && dist <= near) faceTic++; else faceTic = 0;
		if (faceReady && faceTic >= hold)
		{
			faceReady = false;
			faceTic = 0;
			if (dbg) Console.Printf("RSQGN teeth t%d: grenade %.2f m from the eyes for %d tics", level.maptime, dist, hold);
			Send("rsqgn_pin", 1);
			Wait(n);
		}
		else if (dbg && trig && level.maptime % 10 == 0)
			Console.Printf("RSQGN face t%d d=%.2f m near=%.2f far=%.2f held=%d/%d ready=%d", level.maptime, dist, near, far, faceTic, hold, faceReady);
	}

	private void SendThrow(PlayerPawn pmo, int h, double ms, Vector3 v)
	{
		let p = pmo.player;
		Vector3 at = RSQGN_Geo.Pos(pmo, h) + RSQGN_Geo.FromHand(pmo, h, (NADE_F, NADE_L, NADE_U));
		// RS_Grenade's flight: the hand's own velocity (times a trim), and a lift of a fraction of its speed across the
		// ground, so a hard throw arcs more than a gentle one; and the run you were in carries on with it
		Vector3 tv = v * PNum(p, "rsqgn_throw", 1.0);
		tv.z += tv.xy.Length() * PNum(p, "rsqgn_lift", 0.35);
		tv += pmo.Vel;
		Send("rsqgn_at", int(at.x * 8), int(at.y * 8), int(at.z * 8));
		Send("rsqgn_v", int(tv.x * 100), int(tv.y * 100), int(tv.z * 100));
		Send("rsqgn_throw", int(ms * 100));
	}

	// THE HAND'S SPEED (RSQ Distance Grab aim.zs, condensed): each tic the hand's step relative to the pawn, in the
	// tracking space's frame. The tracking yaw is not exposed, so it is inferred: a snap or stick turn turns the pawn
	// AND both hands' yaws by the same amount in one tic; a head turn turns the pawn alone (the hands stay where they
	// are) and blinds the sampler for two tics (the engine builds the hand from the new head yaw for one tic). A
	// collapsed pose (a menu or a save: both hands written to one point), a jump over a metre and a tic with no new
	// frame (the hand repeated) are no motion.
	private void Sample(PlayerPawn pmo)
	{
		bool same = pmo.AttackPos == pmo.OffhandPos && pmo.AttackAngle == pmo.OffhandAngle && pmo.AttackPitch == pmo.OffhandPitch;
		bool collapsed = same && !wasSame;
		wasSame = same;
		double ang = pmo.Angle;
		double hy0 = pmo.AttackAngle, hy1 = pmo.OffhandAngle;
		if (framePrimed)
		{
			double dA = Actor.Normalize180(ang - lastAngle);
			double d0 = Actor.Normalize180(hy0 - lastHandYaw[0]);
			double d1 = Actor.Normalize180(hy1 - lastHandYaw[1]);
			bool followed = abs(d0 - dA) < 1.5 && abs(d1 - dA) < 1.5;
			if (abs(dA) > 0.01 && followed) frameYaw = Actor.Normalize180(frameYaw + dA);
			if (abs(dA) > 0.5 && !followed) quietTics = 2;
		}
		else { frameYaw = ang; framePrimed = true; }
		lastAngle = ang;
		lastHandYaw[0] = hy0;
		lastHandYaw[1] = hy1;
		for (int h = 0; h < 2; h++)
		{
			Vector3 now = RSQGN_Geo.Pos(pmo, h);
			// a tic with no new frame repeats the hand (RSQ Tactical Rig): no motion that tic, and no step
			// against the pawn, which may have moved on
			bool stale = now == rawHand[h];
			rawHand[h] = now;
			if (stale && !collapsed)
			{
				samples[h * WIN + sampleAt[h]] = (0, 0, 0);
				sampleAt[h] = (sampleAt[h] + 1) % WIN;
				continue;
			}
			Vector3 off = now - pmo.Pos;
			Vector2 flat = Actor.RotateVector(off.xy, -frameYaw);
			Vector3 rel = (flat.x, flat.y, off.z);
			Vector3 step = rel - lastRel[h];
			bool good = primed[h] && !same && quietTics <= 0 && RSQGN_Geo.Metres(pmo, step) < 1.0;
			samples[h * WIN + sampleAt[h]] = good ? step : (0, 0, 0);
			sampleAt[h] = (sampleAt[h] + 1) % WIN;
			lastRel[h] = rel;
			primed[h] = !collapsed;
		}
		if (quietTics > 0) quietTics--;
	}

	// The fastest 2-tic window (each pair of adjacent steps averaged) of hand h: real m/s, and that velocity in map
	// units a tic, turned back into the world.
	private double, Vector3 Peak(PlayerPawn pmo, int h)
	{
		Vector3 best = (0, 0, 0);
		double bestM = 0;
		for (int i = 0; i < WIN; i++)
		{
			if (i == sampleAt[h]) continue;		// the oldest sample has no older partner in the window
			int j = (i + WIN - 1) % WIN;
			Vector3 v = (samples[h * WIN + i] + samples[h * WIN + j]) * 0.5;
			double m = RSQGN_Geo.Metres(pmo, v);
			if (m > bestM) { bestM = m; best = v; }
		}
		Vector2 w = Actor.RotateVector(best.xy, frameYaw);
		return bestM * TICRATE, (w.x, w.y, best.z);
	}
}

// It went off in the hand: the same blast and damage as a thrown one, credited to its owner.
class RSQGN_HandBlast : Actor
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTELEPORT
		Radius 1;
		Height 1;
		DamageType "Explosive";
		Obituary "%o was popped by %k's grenade";
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_StartSound("rsqgn/explode", CHAN_AUTO);
		TNT1 A 0 A_StartSound("rsqgn/farexpl", CHAN_7);
		TNT1 A 0 A_AlertMonsters;
		TNT1 A 0 A_SpawnItemEx("RSQGN_Blast", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Explode(85, 200, XF_HURTSOURCE);
		TNT1 A 1 A_Explode(75, 255, XF_HURTSOURCE);
		Stop;
	}
}
