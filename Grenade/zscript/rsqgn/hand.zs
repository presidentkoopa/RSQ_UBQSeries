// RSQ Grenade -- THE HANDLING. Brutal Doom VR's way (the owner's BD22 VR Reloaded grenade, rsg/grenade.zs, his
// code, ported to this pack's own weapon), plus the teeth from his RS_Grenade (rs_vrgrenade.zs):
//   1. the OTHER hand's trigger takes the RING and pulls it away: the pin is out. Bring that hand back to the top and
//      take the ring again: the pin goes back in.
//   2. the holding hand's TRIGGER is your squeeze on the spoon. Let go of it while swinging: thrown, at the speed and
//      direction of the swing. Let go while still: the spoon flies off and the fuse is lit in your hand (cooking).
//      Squeeze and let go again to throw it.
//   3. cook too long and it goes off in your hand.
//   4. THE FACE ROUTE (RS_Grenade): squeeze and hold the grenade at your mouth for a moment: you pull the pin with
//      your teeth (2026-11-03: the mouth measured from the headset, the trigger or a gripped squeeze; Face below).
//      Once the pin is out the hand has to have been clear of your mouth (the far radius) before it can take another;
//      letting go re-arms it too (RS_Grenade's own rule).
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

	// YOUR REAL EYES, where the headset is, in the frame the engine places the hands in (2026-11-03, the teeth fix).
	// The hands are AttackPos.z = viewz - ViewHeight + (controller height + vr_height_adjust) * vu / ps
	// (hw_openxrdevice.cpp:595, gl_openvr.cpp GetHandTransform: the same on PC), so the eyes are the same with the
	// headset's height. player.viewz alone is the pawn's fixed eye (41 units, 1.45 m): 0.25 m under a 1.70 m headset,
	// more with vr_height_adjust (RSQ Tactical Rig cig.zs Eyes, BD22 VR rsq/scope.zs found the same). With
	// vr_crouch_use_button off the engine scales viewz to the headset already. No headset height read: viewz.
	static Vector3 Eyes(PlayerPawn pmo)
	{
		let p = pmo.player;
		double vz = p ? p.viewz : pmo.pos.z + pmo.height * 0.9;
		double hy = pmo.HmdPosition.y;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		if (p && hy > 0.3 && (!cb || cb.GetBool()))
		{
			let ha = CVar.FindCVar("vr_height_adjust");
			vz += (hy + (ha ? ha.GetFloat() : 0)) * Vu() / Ps(pmo) - pmo.ViewHeight;
		}
		return (pmo.pos.x, pmo.pos.y, vz);
	}

	// metres forward along where you look and down from the eyes, in the head's frame (it turns and nods with the
	// headset; the pawn's yaw and pitch are the headset's in VR). RSQ Tactical Rig cig.zs FromEyes.
	static Vector3 FromEyes(PlayerPawn pmo, double fwd, double down)
	{
		double u = Vu();
		double hp = clamp(pmo.pitch, -89, 89);
		double horiz = fwd * cos(hp) - down * sin(hp);
		double vert = -fwd * sin(hp) - down * cos(hp);
		return Eyes(pmo) + (cos(pmo.angle) * horiz * u, sin(pmo.angle) * horiz * u, vert * u / Ps(pmo));
	}

	// room metres from pt to the segment a-b (map points)
	static double SegDist(PlayerPawn pmo, Vector3 pt, Vector3 a, Vector3 b)
	{
		double ps = Ps(pmo), u = Vu();
		Vector3 ab = b - a, ap = pt - a;
		ab = (ab.x, ab.y, ab.z * ps) / u;
		ap = (ap.x, ap.y, ap.z * ps) / u;
		double ll = ab dot ab;
		double t = ll > 0 ? clamp((ap dot ab) / ll, 0.0, 1.0) : 0.0;
		return (ap - ab * t).Length();
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
	// THE MOUTH (the teeth, 2026-11-03): RSQ Tactical Rig's cigarette zone (cig.zs ZONE_*), from the lips (0.04 m
	// forward of the eyes, 0.06 under them) to just under the chin (0.08 forward, 0.19 under), in the head's frame;
	// in it when the controller, the drawn grenade or its ring is within rsqgn_mouth_r of that line
	const MOUTH_AF = 0.04;
	const MOUTH_AD = 0.06;
	const MOUTH_BF = 0.08;
	const MOUTH_BD = 0.19;
	const FACE_SLACK = 4;		// tics out of the zone (or off the squeeze) a hold forgives: a wobble is no restart

	// ---- the playsim's state (every machine, from the network events) ----
	bool armed[MAXPLAYERS];		// pin out
	bool spoon[MAXPLAYERS];		// spoon gone: the fuse burns in the hand
	int cookTic[MAXPLAYERS];
	int flashNext[MAXPLAYERS];
	int redUntil[MAXPLAYERS];
	bool amber[MAXPLAYERS];		// COOK SENSE 2: this flash is amber (the first half of the fuse)
	bool teethPin[MAXPLAYERS];	// TEETH (Gun Bonsai VR patch): this pin came out by the teeth
	int kind[MAXPLAYERS];		// THE KINDS (Gun Bonsai VR patch, kinds.zs): the one in the hand, RSQGN_Kind's number
	Vector3 throwAt[MAXPLAYERS], throwVel[MAXPLAYERS];

	// ---- the console player's hands (local) ----
	private transient bool ringHeld, grabPrev, trigPrev, faceReady, altPrev;
	private transient int faceTic, faceMiss, lastHand, waitUntil;
	private transient bool waitArmed, waitSpoon;
	private transient Vector3 lastRel[2], rawHand[2];
	private transient bool primed[2], framePrimed, wasSame;
	private transient double frameYaw, lastAngle, lastHandYaw[2];
	private transient int quietTics;
	private transient Vector3 samples[2 * WIN];
	private transient int sampleAt[2];

	// SHOOT THROWN GRENADES: the live missiles that are not this mod's own (projectiles are not in the blockmap, so a
	// grenade cannot find them by area); pruned each tic, kept only while a thrown grenade exists to be shot
	Array<Actor> missiles;
	Array<double> missLX, missLY, missLZ;	// ...where each was a tic ago (spawned: where it appeared); MissLast(i)
	Vector3 MissLast(int i) { return (missLX[i], missLY[i], missLZ[i]); }
	int nadeSerial;
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bMissile || a is "RSQGN_Thrown" || a is "RSQGN_Bomblet" || !Active()) return;
		missiles.Push(a);
		missLX.Push(a.pos.x); missLY.Push(a.pos.y); missLZ.Push(a.pos.z);
	}
	void PruneMissiles()
	{
		for (int i = missiles.Size() - 1; i >= 0; i--)
			if (!missiles[i] || missiles[i].bDestroyed || !missiles[i].bMissile) { missiles.Delete(i); missLX.Delete(i); missLY.Delete(i); missLZ.Delete(i); }
	}

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

	// SHORT FUSE (Gun Bonsai VR patch): the Fuse row less 0.5 s a level, never under half a second
	static int FuseTics(Actor who = null)
	{
		double s = clamp(SNum("rsqgn_fuse", 3.0), 0.5, 10.0);
		int lv = RSQGN_Upg.Lv(who, "ShortFuse");
		if (lv > 0) s = max(0.5, s - RSQGN_Upg.Num("ShortFuse.secs", lv, 0));
		return int(s * TICRATE);
	}

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

	// The held grenade's picture (weapon.zs A_RSQGNReady): 0 ring in, 1 pin out, 2 cooking, 3 cooking + red,
	// 4 cooking + amber (Cook Sense 2).
	static int KindOf(int n) { let h = Get(); return (h && n >= 0 && n < MAXPLAYERS) ? h.kind[n] : 0; }
	static int HeldFrame(int n)
	{
		let h = Get();
		if (!h || n < 0 || n >= MAXPLAYERS || !h.armed[n]) return 0;
		if (!h.spoon[n]) return 1;
		if (level.maptime >= h.redUntil[n]) return 2;
		return h.amber[n] ? 4 : 3;
	}
	// COOK SENSE 2 (Gun Bonsai VR patch): with this much of the fuse left the flash is amber, after it red
	static bool AmberAt(Actor who, int left, int total)
	{
		return total > 0 && left * 2 > total && RSQGN_Upg.Lv(who, "CookSense") >= 2;
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
		teethPin[n] = false;
		redUntil[n] = 0;
		flashNext[n] = 0;
	}

	// THE MENU'S GUN BONSAI VR GATING (RSQGN_Service GetIntUI, upg.zs): the console player's Skeet Window level, asked once a
	// second here in play (ui code cannot ask Gun Bonsai VR); and how many grenade kinds they have learned
	transient int menuSkeet, menuKinds, menuTic;
	void MenuRefresh()
	{
		if (menuTic > 0 && level.maptime >= menuTic && level.maptime < menuTic + 35) return;
		menuTic = max(level.maptime, 1);
		let mo = players[consoleplayer].mo;
		menuSkeet = RSQGN_Upg.Lv(mo, "SkeetWindow");
		menuKinds = 0;
		for (int k = RSQGN_Kind.FRAG + 1; k < RSQGN_Kind.COUNT; k++) if (RSQGN_Upg.Lv(mo, RSQGN_Kind.Node(k)) >= 1) menuKinds++;
	}

	override void WorldTick()
	{
		MenuRefresh();
		if (!Active()) return;
		// SHOOT THROWN GRENADES, projectiles: at the end of the tic every thing has moved, so each grenade's path this tic
		// (Prev to Pos) is tested against each missile's (RSQGN_Thrown.ShotByMissile, swept)
		{
			bool open = missiles.Size() > 0 && RSQGN_Slow.CanShoot();
			let ti = ThinkerIterator.Create("RSQGN_Thrown");
			RSQGN_Thrown tg;
			while (tg = RSQGN_Thrown(ti.Next()))
			{
				if (!tg.lastSet) { tg.lastPos = tg.pos; tg.lastSet = true; }
				if (open && !tg.boomed && tg.age >= RSQGN_Thrown.SHOT_GRACE) tg.ShotByMissile();
				tg.lastPos = tg.pos;
			}
			for (int i = 0; i < missiles.Size(); i++) if (missiles[i]) { missLX[i] = missiles[i].pos.x; missLY[i] = missiles[i].pos.y; missLZ[i] = missiles[i].pos.z; }
		}
		PruneMissiles();	// after the test: a missile that burst in this tic's movement still had its path tested
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
				int fuse = FuseTics(pmo);
				if (cooked >= fuse) { Boom(pmo, n, "cooked too long"); continue; }
				Flash(pmo, n, fuse - cooked, fuse);
				// COOK SENSE 1 (Gun Bonsai VR patch): a tick in the holding hand at each second of the fuse
				if (cooked > 0 && cooked % TICRATE == 0 && RSQGN_Upg.Lv(pmo, "CookSense") >= 1) RSQGN_Buzzer.Start(pmo, h, 0.35, 3);
			}
			// the last grenade gone: the hand gets something else (BD22 VR 1.12: an empty grenade hand vanished)
			if (!armed[n] && pmo.CountInv("RSQGN_Ammo") <= 0) Empty(pmo, h);
		}
		if (level.maptime % 17 == 0) for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			Carry(players[n].mo);
			if (!RSQGN_Kind.Owns(players[n].mo, kind[n])) kind[n] = RSQGN_Kind.FRAG;	// a kind no longer learned
		}
		let cp = players[consoleplayer].mo;
		if (playeringame[consoleplayer] && cp) Local(cp);
	}

	// BANDOLIER (Gun Bonsai VR patch): the carry 8 + 2 a level, a backpack doubling whatever it is. Without the patch
	// the ammo's own 8 / 16, untouched.
	static void Carry(PlayerPawn pmo)
	{
		if (!RSQGN_Upg.On()) return;
		let am = Ammo(pmo.FindInventory("RSQGN_Ammo"));
		if (!am) return;
		int lv = RSQGN_Upg.Lv(pmo, "Bandolier");
		int cap = am.Default.MaxAmount + (lv > 0 ? int(RSQGN_Upg.Num("Bandolier.carry", lv, 0)) : 0);
		if (pmo.FindInventory("BackpackItem", true)) cap *= 2;
		am.MaxAmount = cap;
		am.BackpackMaxAmount = max(am.BackpackMaxAmount, cap);
	}

	void Flash(PlayerPawn pmo, int n, int left, int total)
	{
		if (level.maptime < flashNext[n]) return;
		int per = FlashPeriod(left, total);
		redUntil[n] = level.maptime + max(1, per / 2);
		flashNext[n] = level.maptime + per;
		amber[n] = AmberAt(pmo, left, total);
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
		let b = RSQGN_HandBlast(Actor.Spawn("RSQGN_HandBlast", pmo.Pos + (0, 0, pmo.Height * 0.6), ALLOW_REPLACE));
		if (b) { b.target = pmo; b.kind = RSQGN_Kind.Owns(pmo, kind[n]) ? kind[n] : RSQGN_Kind.FRAG; }
		pmo.TakeInventory("RSQGN_Ammo", 1);
		if (Debug(pmo.player)) Console.Printf("RSQGN boom in hand p%d t%d (%s)", n, level.maptime, why);
		Reset(n);
	}

	// SHOOT THROWN GRENADES (owner 11-03 19:43; before it, only the Gun Bonsai VR patch's Skeet node, GBOVR_TREES.md
	// 4.5 Style): your own shot passing within RSQGN_Thrown.ShotR() (Shot Grenade Reach, 0.35 m = 12 units at most) of a thrown grenade, once it is
	// SHOT_GRACE tics out of the hand, sets it off there (in the air: a skeet). "Shoot Thrown Grenades" off: only the
	// Skeet node does, in the air, as before. Melee (a reach of 128 units or less) never does. Only the shooter's
	// machine knows where VR hands point (the engine writes the pose for the camera player alone), so it tests the ray
	// of the hand that fired and sends the grenade's serial; every machine sets off the same one (rsqgn_skeet). The shot
	// itself is untouched. Projectiles are caught by the grenade itself (RSQGN_Thrown.ShotByMissile).
	// WHICH HAND FIRED (0.99a bug 54; before, both hands' rays were tested, so the hand that only pointed could set a
	// grenade off): the shot says so itself. QuestZDoom 17.3's weapon attacks mark an off-hand shot -- A_FireBullets
	// LAF_ISOFFHAND, A_RailAttack RGF_ISOFFHAND (wadsrc stateprovider.zs) -- and P_LineAttack starts it from OffhandPos
	// for exactly that flag (p_map.cpp), which the hitscan event carries as AttackLineFlags and the railgun's as
	// RailParams.flags (events.cpp).
	// 11-03 (a scoping read): the railgun (A_RailAttack, BD's RailGun) does not call the hitscan hook on 4.14.3; it
	// has its own, taken the same way
	override bool WorldRailgunPreFired(WorldEvent e) { ShotTest(e, "railgun"); return false; }
	override bool WorldHitscanPreFired(WorldEvent e) { ShotTest(e, "hitscan"); return false; }

	void ShotTest(WorldEvent e, String how)
	{
		let pmo = PlayerPawn(e.Thing);
		if (!pmo || !pmo.player || pmo.PlayerNumber() != consoleplayer || !Active()) return;
		bool open = RSQGN_Slow.CanShoot();
		if (!open && RSQGN_Upg.Lv(pmo, "Skeet") <= 0) return;
		if (e.AttackDistance > 0 && e.AttackDistance <= 128) return;	// a punch, a bash: never
		double dist = e.AttackDistance > 0 ? e.AttackDistance : 8192;
		Vector3 a0, d0;
		int fh = 0;	// the hand that fired: its ray is the only one tested
		if (pmo.OverrideAttackPosDir)
		{
			bool off = how == "railgun" ? (e.RailParams.flags & RGF_ISOFFHAND) != 0 : (e.AttackLineFlags & LAF_ISOFFHAND) != 0;
			fh = off ? 1 : 0;
			a0 = off ? pmo.OffhandPos : pmo.AttackPos;
			d0 = RSQGN_Geo.Dir(pmo, fh, 0, 0);
		}
		else
		{
			double ca = cos(e.AttackPitch);
			a0 = pmo.pos + (0, 0, pmo.height * 0.5 - pmo.Floorclip + pmo.AttackZOffset * pmo.player.crouchfactor + e.AttackZ);
			d0 = (cos(e.AttackAngle) * ca, sin(e.AttackAngle) * ca, -sin(e.AttackPitch));
		}
		let it = ThinkerIterator.Create("RSQGN_Thrown");
		RSQGN_Thrown g;
		int seen = 0;
		while (g = RSQGN_Thrown(it.Next()))
		{
			if (g.boomed) continue;
			seen++;
			if (!open && (g.target != pmo || g.pos.z <= g.floorz + 2)) continue;	// the Skeet node alone: yours, in the air
			for (int k = 0; k < 1; k++)		// one ray: the firing hand's (a loop so a miss can `continue` to the next grenade)
			{
				int r = fh;
				Vector3 ra = a0;
				Vector3 rd = d0;
				Vector3 c = g.pos + (0, 0, 1.4) - ra;
				double along = c dot rd;
				if (along < 0 || along > dist) continue;
				double miss = (c - rd * along).Length();
				if (miss > RSQGN_Thrown.ShotR())
				{
					if (miss < 2 * RSQGN_Thrown.SHOT_R && Debug(pmo.player)) Console.Printf("RSQGN shot missed t%d: hand %d, %.1f units off its centre, reach %.1f", level.maptime, r, miss, RSQGN_Thrown.ShotR());
					continue;
				}
				if (g.age < RSQGN_Thrown.SHOT_GRACE)
				{
					if (Debug(pmo.player)) Console.Printf("RSQGN shot ignored t%d: the grenade is %d tics out of the hand (grace %d)", level.maptime, g.age, RSQGN_Thrown.SHOT_GRACE);
					continue;
				}
				if (Debug(pmo.player)) Console.Printf("RSQGN shot ray t%d (%s): hand %d, %.0f units out, %.1f units off its centre (reach %.1f)", level.maptime, how, r, along, miss, RSQGN_Thrown.ShotR());
				EventHandler.SendNetworkEvent("rsqgn_skeet", g.serial, how == "railgun" ? 1 : 0);	// the grenade itself, by its serial (a fast one moves far in the tic the event takes)
				return;
			}
		}
		if (Debug(pmo.player)) Console.Printf("RSQGN shot t%d: nothing set off (%d thrown grenades in the world; one in a hand is never shootable)", level.maptime, seen);
		return;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.IsManual || !Active()) return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let p = players[n];
		let pmo = p.mo;
		if (!pmo || pmo.health <= 0) return;
		if (e.Name == "rsqgn_kind")
		{
			if (spoon[n]) return;
			int k = RSQGN_Kind.Next(pmo, kind[n]);
			if (k == kind[n]) return;
			kind[n] = k;
			pmo.A_StartSound("rsqgn/bounce", CHAN_AUTO, CHANF_OVERLAP, 0.6, ATTN_NORM, 1.3);
			RSQGN_Buzzer.Start(pmo, max(HandOf(p), 0), 0.3, 3);
			if (Debug(p)) Console.Printf("RSQGN kind p%d t%d: %s", n, level.maptime, k == 0 ? "Frag" : RSQGN_Kind.Node(k));
			return;
		}
		if (e.Name == "rsqgn_skeet")
		{
			// the thrown grenade the shooter's machine saw, by its serial (validated: still live, and this player's own
			// unless Shoot Thrown Grenades is on)
			let it = ThinkerIterator.Create("RSQGN_Thrown");
			RSQGN_Thrown g;
			bool any = RSQGN_Slow.CanShoot();
			while (g = RSQGN_Thrown(it.Next()))
				if (g.serial == e.Args[0] && !g.boomed && (any || g.target == pmo)) { g.Shot(e.Args[1] == 1 ? "railgun" : "hitscan", pmo); break; }
			return;
		}
		int h = HandOf(p);
		if (e.Name == "rsqgn_at") { throwAt[n] = (e.Args[0], e.Args[1], e.Args[2]) / 8.0; return; }
		if (e.Name == "rsqgn_v") { throwVel[n] = (e.Args[0], e.Args[1], e.Args[2]) / 100.0; return; }
		if (h < 0) return;
		if (e.Name == "rsqgn_pin")
		{
			if (armed[n] || pmo.CountInv("RSQGN_Ammo") <= 0) return;
			armed[n] = true;
			teethPin[n] = e.Args[0] == 1;
			// TEETH 1 "pays Score": the thrown grenade carries it (Throw), answered by name
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
		int fuse = FuseTics(pmo);
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
		g.serial = ++nadeSerial;	// every machine throws the same grenades in the same order: the same serial
		g.target = pmo;
		// GUN BONSAI VR (2026-11-02, GBOVR_TREES.md section 1): the grenade weapon earns this throw. Gun Bonsai sees
		// the thrown grenade at its spawn, before target is set, so it registers nothing and would later guess a
		// hand by position. Naming the weapon as master and claiming the actor through the patch's service (by
		// name; nothing happens without it) pays the blast, its kills and anything it spawns to RSQGN_Grenade's
		// own record, so the grenade levels like a weapon. master is otherwise unused by RSQGN_Thrown.
		let gw = Weapon(pmo.FindInventory("RSQGN_Grenade"));
		if (gw)
		{
			g.master = gw;
			let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
			Service gb = it.Next();
			if (gb) gb.GetInt("claim", "", 0, 0, g);
		}
		g.Vel = throwVel[n];
		g.angle = VectorAngle(g.Vel.x, g.Vel.y);
		g.fuse = left;
		g.fuseTotal = fuse;
		g.dmgMult = 1.0;
		g.sticky = RSQGN_Upg.Lv(pmo, "Sticky");	// STICKY (Gun Bonsai VR patch)
		// TEETH 2-3 (Gun Bonsai VR patch): the throw after a teeth pull hits harder
		int tl = teethPin[n] ? RSQGN_Upg.Lv(pmo, "Teeth") : 0;
		if (tl >= 2) g.dmgMult *= RSQGN_Upg.Num("Teeth.mult", tl, 1.0);
		g.skeetWin = RSQGN_Upg.Lv(pmo, "SkeetWindow");			// SKEET WINDOW
		g.teeth = teethPin[n];									// for a scorer (RSQGN_Service "teeth")
		g.cooked = spoon[n] ? level.maptime - cookTic[n] : 0;	// SLOW BURN reads it (RSQGN_Service "cooked")
		g.kind = RSQGN_Kind.Owns(pmo, kind[n]) ? kind[n] : RSQGN_Kind.FRAG;	// THE KINDS
		if (g.kind == RSQGN_Kind.FLASH) g.bBright = true;
		int fa = RSQGN_Upg.Lv(pmo, "FlatArc"), bo = RSQGN_Upg.Lv(pmo, "Bounce");
		g.Gravity = clamp(SNum("rsqgn_gravity", 0.27) * (fa > 0 ? RSQGN_Upg.Num("FlatArc.gravity", fa, 1.0) : 1.0), 0.05, 1.0);	// FLAT ARC
		g.BounceFactor = clamp(SNum("rsqgn_bounce", 0.5), 0.0, 0.9);
		g.WallBounceFactor = clamp(SNum("rsqgn_wallbounce", 0.25) + (bo > 0 ? RSQGN_Upg.Num("Bounce.wall", bo, 0) : 0), 0.0, 0.9);	// BOUNCE
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
		if (h != lastHand) { ringHeld = false; faceTic = 0; faceMiss = 0; faceReady = true; lastHand = h; }
		int o = 1 - h;
		int btn = p.cmd.buttons;
		bool trig = (btn & (h == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grab = (btn & (o == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grabPress = grab && !grabPrev;
		grabPrev = grab;
		bool trigUp = !trig && trigPrev;
		trigPrev = trig;
		// THE KINDS: the holding hand's alt trigger cycles the kinds you own (Gun Bonsai VR patch) or, without the patch,
		// every kind (rsqgn_kinds_free, kinds.zs Owns), until the spoon flies. "Alt Fire Cycles Grenade Types"
		// (rsqgn_kind_alt) off: the alt trigger cycles nothing. At your mouth with the pin in, the alt trigger is the
		// teeth's squeeze instead (below), so it cycles nothing there.
		bool alt = (btn & (h == 0 ? BT_ALTATTACK : BT_OFFHANDALTATTACK)) != 0;
		bool altPress = alt && !altPrev;
		altPrev = alt;
		double mouth = MouthDist(pmo, h);
		bool faceOn = PFlag(p, "rsqgn_face", true);
		bool biting = faceOn && !armed[n] && mouth <= MouthReach(p);
		if (altPress && !spoon[n])
		{
			bool cyc = PFlag(p, "rsqgn_kind_alt", true);
			int nk = RSQGN_Kind.Next(pmo, kind[n]);
			if (cyc && !biting && nk != kind[n]) Send("rsqgn_kind");
			else if (Debug(p))
				Console.Printf("RSQGN alt t%d: no cycle (%s)", level.maptime, !cyc ? "Alt Fire Cycles Grenade Types is off" : biting ? "at the mouth: the teeth's squeeze" : "no other kind owned");
		}
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
			Face(pmo, p, n, h, trig || alt, trig ? "trigger" : alt ? "alt" : "none", mouth, dbg);
			return;
		}
		faceTic = 0;
		faceMiss = 0;
		if (!trig && !alt) faceReady = true;

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

	// THE TEETH (RS_Grenade's face route): the grenade squeezed and held at your mouth for a run of tics (12).
	// 2026-11-03 (owner: "I still haven't seen the face-mouth pin pull work"), what it was and what it is:
	//   THE EYES were player.viewz, the pawn's fixed 1.45 m eye, not the headset (RSQGN_Geo.Eyes): a 1.70 m player's
	//     mouth sat 0.25 m from where it was looked for, a tall one's with vr_height_adjust past the old 0.47 m.
	//   THE PLACE was a 0.47 m ball round that point: the chest counted, a high mouth did not. It is now the mouth:
	//     RSQ Tactical Rig's cigarette zone (lips to under the chin, the head's frame), the controller, the drawn
	//     grenade or its ring within "Teeth: Mouth Reach" (rsqgn_mouth_r, 0.15 m) of it.
	//   THE SQUEEZE was the holding hand's fire alone. QuestZDoom's default vr_secondary_button_mappings makes the main
	//     grip a shift key: grip and trigger together send ALT fire, never fire, so a fist round the grenade at the
	//     mouth was no squeeze. The holding hand's alt fire counts too here (and cycles no kind while at the mouth).
	//   A WOBBLE restarted the count: FACE_SLACK tics out of the zone or off the squeeze are forgiven.
	// Once taken, a hand clear of the mouth by "Teeth: Again Beyond" (0.71 m) or a let-go squeeze re-arms it.
	double MouthReach(PlayerInfo p) { return clamp(PNum(p, "rsqgn_mouth_r", 0.15), 0.03, 0.40); }

	// metres from the mouth zone's line to the nearest of the controller, the drawn grenade and its ring
	double MouthDist(PlayerPawn pmo, int h)
	{
		Vector3 a = RSQGN_Geo.FromEyes(pmo, MOUTH_AF, MOUTH_AD), b = RSQGN_Geo.FromEyes(pmo, MOUTH_BF, MOUTH_BD);
		Vector3 c = RSQGN_Geo.Pos(pmo, h);
		double d = RSQGN_Geo.SegDist(pmo, c, a, b);
		d = min(d, RSQGN_Geo.SegDist(pmo, c + RSQGN_Geo.FromHand(pmo, h, (NADE_F, NADE_L, NADE_U)), a, b));
		return min(d, RSQGN_Geo.SegDist(pmo, c + RSQGN_Geo.FromHand(pmo, h, (RING_F, RING_L, RING_U)), a, b));
	}

	private void Face(PlayerPawn pmo, PlayerInfo p, int n, int h, bool squeeze, String by, double mouth, bool dbg)
	{
		if (!PFlag(p, "rsqgn_face", true)) { faceTic = 0; faceMiss = 0; return; }
		double reach = MouthReach(p);
		double far = PNum(p, "rsqgn_face_far", 0.71);
		int hold = clamp(int(PNum(p, "rsqgn_face_hold", 12)), 1, 70);
		bool atMouth = mouth <= reach;
		if (!squeeze || mouth > far) faceReady = true;
		if (squeeze && atMouth) { faceTic++; faceMiss = 0; }
		else if (faceTic > 0 && ++faceMiss > FACE_SLACK) { faceTic = 0; faceMiss = 0; }
		if (faceReady && faceTic >= hold)
		{
			faceReady = false;
			faceTic = 0;
			faceMiss = 0;
			if (dbg) Console.Printf("RSQGN teeth t%d: hand %d, squeezed by %s, %.2f m from the mouth (reach %.2f) for %d tics", level.maptime, h, by, mouth, reach, hold);
			Send("rsqgn_pin", 1);
			Wait(n);
		}
		else if (dbg && (squeeze || atMouth) && level.maptime % 5 == 0)
		{
			Vector3 e = RSQGN_Geo.Eyes(pmo);
			Vector3 hp = RSQGN_Geo.Pos(pmo, h);
			Console.Printf("RSQGN face t%d hand %d mouth %.2f m (reach %.2f) squeeze %s held %d/%d ready %d; eyes %.2f m over viewz, hand %.2f m under the eyes",
				level.maptime, h, mouth, reach, by, faceTic, hold, faceReady, (e.z - p.viewz) * RSQGN_Geo.Ps(pmo) / RSQGN_Geo.Vu(),
				(e.z - hp.z) * RSQGN_Geo.Ps(pmo) / RSQGN_Geo.Vu());
		}
	}

	// what leaves the hand for a hand velocity v (map units a tic): the strength, the lift, the run you were in.
	// STRONG ARM and FLAT ARC (Gun Bonsai VR patch): the strength and the lift, read on the thrower's machine and sent
	// with the throw like everything else in it.
	static Vector3 LaunchVel(PlayerPawn pmo, Vector3 v)
	{
		let p = pmo.player;
		int sa = RSQGN_Upg.Lv(pmo, "StrongArm"), fa = RSQGN_Upg.Lv(pmo, "FlatArc");
		Vector3 tv = v * PNum(p, "rsqgn_throw", 1.0) * (sa > 0 ? RSQGN_Upg.Num("StrongArm.mult", sa, 1.0) : 1.0);
		tv.z += tv.xy.Length() * PNum(p, "rsqgn_lift", 0.35) * (fa > 0 ? RSQGN_Upg.Num("FlatArc.lift", fa, 1.0) : 1.0);
		return tv + pmo.Vel;
	}

	private void SendThrow(PlayerPawn pmo, int h, double ms, Vector3 v)
	{
		let p = pmo.player;
		Vector3 at = RSQGN_Geo.Pos(pmo, h) + RSQGN_Geo.FromHand(pmo, h, (NADE_F, NADE_L, NADE_U));
		// RS_Grenade's flight: the hand's own velocity (times a trim), and a lift of a fraction of its speed across the
		// ground, so a hard throw arcs more than a gentle one; and the run you were in carries on with it
		Vector3 tv = LaunchVel(pmo, v);
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
	int kind;	// THE KINDS: what went off in the hand
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
		TNT1 A 0 NoDelay { RSQGN_Kind.Look(self, kind, target); }
		TNT1 A 1 { RSQGN_Thrown.Blast(self, target, 0, 1.0); }
		TNT1 A 1 { RSQGN_Thrown.Blast(self, target, 1, 1.0); }
		Stop;
	}
}
