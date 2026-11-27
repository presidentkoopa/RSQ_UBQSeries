// RSQ Grenade -- THE HANDLING. Brutal Doom VR's way (the owner's BD22 VR Reloaded grenade, rsg/grenade.zs, his
// code, ported to this pack's own weapon), plus the teeth from his RS_Grenade (rs_vrgrenade.zs):
//   1. the OTHER hand's trigger takes the RING and pulls it away: the pin is out. Bring that hand back to the top and
//      take the ring again: the pin goes back in.
//   2. the holding hand's TRIGGER or ALT FIRE is your squeeze on the spoon (either held is the squeeze, both up the
//      let-go; 2026-11-09, Local below). Let go while swinging: thrown, at the speed and direction of the
//      swing. Let go while still: the spoon flies off and the fuse is lit in your hand (cooking). Squeeze and let go
//      again to throw it. With the pin still in, alt fire cycles the grenade kinds instead (THE KINDS below).
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
// THE THROW IS THE HAND'S OWN MOTION, measured the way the throws that work on the owner's PC VR measure it (BD22 VR
// Reloaded rsg/grenade.zs Swing, RSQ ShieldSaw pose.zs ThrowVel; 2026-11-09, below at Sample): the hand relative to
// the pawn, turned by the pawn's yaw into the body's frame (walking and turning are no swing), the fastest 2-tic
// window of the last seven tics, turned back into the world.
//
// STANDS DOWN with Brutal Doom VR Reloaded (its RSG_Handler, looked up by a String at run time: a quoted class name
// is resolved when the script compiles and would break this pack without Brutal Doom): then nothing here runs, and
// BD22 VR's own grenade does everything -- unless Replace Brutal Doom's Grenade (rsqgn_replace_bd) is on: then this
// pack runs, and BD22 VR stands its own grenade down on reading that cvar by name (Active, ReplacesBD).

class RSQGN_Geo play
{
	static bool InVR(PlayerPawn pmo)
	{
		return pmo && pmo.player && pmo.player.PlayInVR && pmo.OverrideAttackPosDir;
	}

	static Vector3 Pos(PlayerPawn pmo, int h) { return h == 0 ? pmo.AttackPos : pmo.OffhandPos; }

	// THE ENGINE'S FIXED EYE HEIGHT (owner 2026-11-11, design/rigtest_2026-11-10/RESULTS_DOWNSHOT.md). With
	// vr_crouch_use_button on, QuestZDoom 17.3 places the eyes and the hands at viewz + the headset's height - a height it
	// caches ONCE (hw_openxrdevice.cpp:158-170, getDoomPlayerHeightWithoutCrouch: the pawn's ViewHeight at its first
	// frame). RSQ SlowMo's DOWN scales the pawn's ViewHeight to 40% while you are down, so pmo.ViewHeight is not that number
	// then; the pawn class's default (pmo.Default) is, crouched or not. A crouch still reaches the eyes through viewz. Code only, not shown.
	static clearscope double StandEyeHeight(PlayerPawn pmo) { return pmo ? pmo.Default.ViewHeight : 41.0; }

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
			vz += (hy + (ha ? ha.GetFloat() : 0)) * Vu() / Ps(pmo) - StandEyeHeight(pmo);
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

// THE ONE THROW FEEL (owner 2026-11-22: "the shieldsaw, flare, and grenade... all the throwing isn't smooth. it feels like
// it takes too much effort, that nothing goes very far, and that it feels so floaty"). The same release and the same
// numbers in RSQ Grenade (RSQGN_Fling), RSQ FnF (RSQFF_Fling) and RSQ ShieldSaw (SSQ_Fling), copied so each still loads
// alone. Code only, not run (owner's call).
//   THE RELEASE   the fastest 2-tic window of the last 7 tics (never the slowed tic the fingers open on) that goes AWAY
//                 from you: across the ground within 60 degrees of where the body faces (Ahead). None such (a lob
//                 straight up, a sideways flick): the fastest of all. The throw goes the way that window went.
//   GAIN 4.0      what leaves the hand is 4x the hand's peak at Throw Strength 1.0 (it was 1x here and in FnF, 1.37x on
//                 the disc): a VR arm swings at a fraction of a real throw's speed and has no body behind it.
//   CAP 30 m/s    the most the arm's part can give (a Doom rocket is 20.6 m/s), so a hard swing is strong, not absurd.
//   FROM 1.5 m/s  a let-go slower than this is not a throw (it was 2.5 here and on the disc, 2.0 in FnF): a modest flick
//                 counts.
//   GRAVITY 0.5   of Doom's, for what falls (it was 0.27 here and in FnF, a long hang): a flick of 3.5 m/s now lands
//                 about 9 m out in under 0.7 s, a hard 6 m/s throw about 22 m (with this pack's Arc, 0.35).
class RSQGN_Fling
{
	const GAIN = 4.0;
	const CAP_MPS = 30.0;
	const MIN_MPS = 2.2;
	const GRAVITY = 0.5;
	const AHEAD_COS = 0.5;
	const MARK_MPS = 1.0;
	const MARK_COS = 0.5;
	const TURN_DEG = 9.0;

	// a motion `fwd` ahead of the body and `side` across it is a throw's: within 60 degrees of ahead across the ground
	static bool Ahead(double fwd, double side)
	{
		double a = sqrt(fwd * fwd + side * side);
		return a > 0.000001 && fwd >= AHEAD_COS * a;
	}

	// what the hand's velocity is multiplied by: GAIN x strength, the result held under CAP_MPS
	static double Mult(double handMps, double strength)
	{
		if (handMps <= 0) return 0;
		return min(handMps * GAIN * max(strength, 0.0), CAP_MPS) / handMps;
	}

	// a release with something marked is a throw when the hand moves at MARK_MPS or more, toward the mark (`hand` and
	// `toMark` any length, the same frame)
	static bool TowardMark(double handMps, Vector3 hand, Vector3 toMark)
	{
		double a = hand.Length(), b = toMark.Length();
		if (handMps < MARK_MPS || a < 0.000001 || b < 0.000001) return false;
		return (hand / a) dot (toMark / b) >= MARK_COS;
	}

	// a homing throw's heading this tic: `dir` turned toward `want` by at most TURN_DEG (both unit vectors); closer than
	// `near` map units it goes straight there (no orbiting a target it is about to hit)
	static Vector3 Turn(Vector3 dir, Vector3 want, double dist, double near)
	{
		if (dist <= near) return want;
		double c = clamp(dir dot want, -1.0, 1.0);
		double ang = acos(c);
		if (ang <= TURN_DEG) return want;
		double k = TURN_DEG / ang;
		Vector3 v = dir * (1.0 - k) + want * k;
		return v.Length() > 0.000001 ? v.Unit() : want;
	}
}

class RSQGN_Handler : EventHandler
{
	// A SHORT IN-PLAY MESSAGE AS A TOAST (design/PRESENTATION_GUIDE.md 5, owner 2026-11-16 03:11): RSQ VisualRewards, by name,
	// GetInt "toast" "<kind>|<text>" (kind: health, armor, invuln, ammo, lives, up, down, info). True when it took it; no
	// VisualRewards (or one without toasts, answering 0) -> false, and the caller prints as before
	static bool Toast(Actor who, String kind, String text)
	{
		if (!who) return false;
		let it = ServiceIterator.Find("RSQVR_Service");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RSQVR_Service') return s.GetInt("toast", kind .. "|" .. text, 0, 0, who) > 0;
		return false;
	}

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
	private transient bool ringHeld, grabPrev, trigPrev, faceReady, altPrev, squeezePrev, standNoted;
	private transient int faceTic, faceMiss, lastHand, waitUntil;
	private transient bool waitArmed, waitSpoon;
	private transient bool wasSame;
	private transient Vector3 relHist[2 * WIN];	// the hand in the body's frame, a tic each (Sample)
	private transient bool relOk[2 * WIN];
	private transient int histAt[2];

	// SHOOT THROWN GRENADES: the live missiles that are not this mod's own (projectiles are not in the blockmap, so a
	// grenade cannot find them by area); pruned each tic, kept only while a thrown grenade exists to be shot
	Array<Actor> missiles;
	Array<double> missLX, missLY, missLZ;	// ...where each was a tic ago (spawned: where it appeared); MissLast(i)
	Vector3 MissLast(int i) { return (missLX[i], missLY[i], missLZ[i]); }
	int nadeSerial;
	int quickAt[MAXPLAYERS];	// QUICK GRENADE: the tic the queued quick throw leaves (0: none)
	int quickFree[MAXPLAYERS];	// ...and the tic the next press is taken
	// (performance 2026-11-27: Active() -- a class looked up by name and two settings -- once a tic, not once a missile)
	private transient int actTic;
	private transient bool actNow;
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bMissile || a is "RSQGN_Thrown" || a is "RSQGN_Bomblet") return;
		if (actTic != level.maptime + 1) { actTic = level.maptime + 1; actNow = Active(); }
		if (!actNow) return;
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

	// REPLACE BRUTAL DOOM'S GRENADE (rsqgn_replace_bd, on by default since 2026-11-16, owner; BUGS_1.0 item 21): on, this pack does not stand down for
	// BD22 VR Reloaded. BD22 VR reads the same cvar by name and stands ITS grenade down (CVARINFO.txt says the handshake).
	static bool ReplacesBD()
	{
		let cv = CVar.FindCVar("rsqgn_replace_bd");
		if (cv && cv.GetBool()) return true;
		// BD22 VR's own "Use RSQ Grenade Instead" row (rsg_rsq_nade) means the same thing from its side
		let bd = CVar.FindCVar("rsg_rsq_nade");
		return bd && bd.GetBool();
	}

	static bool Active()
	{
		if (BDVR() && !ReplacesBD()) return false;
		let cv = CVar.FindCVar("rsqgn_on");
		return !cv || cv.GetBool();
	}

	// A GRENADE IN A HAND ALWAYS WORKS (owner 2026-11-09 17:41, PC VR with BD22 VR Reloaded: "there is no way to throw
	// grenades. I have it in hand, I pull pin ... and I can't throw it"). Standing down for BD22 VR used to switch the
	// WHOLE handling off -- the ring, the spoon, the throw (WorldTick and NetworkProcess returned at once) -- while a
	// grenade already carried (from a run with Replace Brutal Doom's Grenade on, a save, a pickup) still went into the
	// hand from slot 9: a dead grenade nothing could throw. Standing down now only means no grenades are handed out
	// (Equip) and BD22 VR's grenade stays; a player holding this one gets its full handling.
	static bool Held()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
			if (playeringame[n] && players[n].mo && HandOf(players[n]) >= 0) return true;
		return false;
	}
	static bool Live() { return Active() || Held(); }

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

	// THE THROW FEEL, ONCE (owner 2026-11-22, RSQGN_Fling): a config keeps every value it ever saved, so a machine that ran
	// an older build would never see the new Throw Speed and Gravity defaults. Each is moved once, and only off its OLD
	// default: a value the player chose is kept.
	override void OnRegister()
	{
		let v = CVar.FindCVar("rsqgn_feel");
		if (!v || v.GetInt() >= 1) return;
		let sw = CVar.FindCVar("rsqgn_throw_min");
		if (sw && abs(sw.GetFloat() - 2.5) < 0.001) sw.SetFloat(RSQGN_Fling.MIN_MPS);
		v.SetInt(1);
	}

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
		if (!Live()) return;
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
		if (Active()) QuickTick();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) continue;
			let p = players[n];
			let pmo = p.mo;
			if (!pmo) continue;
			int h = HandOf(p);
			if (h < 0 || pmo.health <= 0)
			{
				// switched away (or died) with the pin out: a lit fuse is DROPPED AT YOUR FEET and goes off when its fuse ends
				// (C8, owner 11-16: "Drop it at my feet"; it went off in the hand, at your body); a held spoon goes back in
				if (armed[n] && spoon[n]) DropLive(pmo, n, pmo.health <= 0 ? "died with it lit" : "switched away with it lit");
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
		if (!pmo || !pmo.player || pmo.PlayerNumber() != consoleplayer || !Live()) return;
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
		// EVERY OTHER MOD'S EVENT LEAVES AT ONCE (performance, 2026-11-27): every handler is handed every event, ~10 a tic in a
		// fight (the series' hand syncs and poses), and each used to run Active() and HandOf() below before its name was
		// tested. Every branch here wants a name starting "rsqgn_" (compared exactly, as below), and nothing above them
		// changes anything, so a name without it was always a no-op.
		if (e.Name.Left(6) != "rsqgn_") return;
		// The Quick Grenade key is an alias for "netevent rsqgn_quick", and QuestZDoom's netevent command marks what it sends
		// as manual (gzdoom src/events.cpp:2454): a key bind is manual too. Only that one event may come from a key.
		if (e.IsManual && e.Name != "rsqgn_quick") return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let p = players[n];
		let pmo = p.mo;
		if (!pmo || pmo.health <= 0) return;
		if (!Active() && HandOf(p) < 0) return;		// standing down: only a grenade in a hand (Live)
		if (e.Name == "rsqgn_quick") { if (Active()) QuickPress(pmo, n); return; }
		if (e.Name == "rsqgn_kind")
		{
			if (spoon[n]) return;
			int k = RSQGN_Kind.Next(pmo, kind[n]);
			if (k == kind[n]) return;
			kind[n] = k;
			pmo.A_StartSound("rsqgn/bounce", CHAN_AUTO, CHANF_OVERLAP, 0.6, ATTN_NORM, 1.3);
			RSQGN_Buzzer.Start(pmo, max(HandOf(p), 0), 0.3, 3);
			// THE KIND'S WORD (owner 2026-11-22, kinds.zs PopWord): the new kind's name on the grenade in the hand (its top:
			// NADE_F along the aim, a little over NADE_U)
			RSQGN_Kind.PopWord(pmo, k, String.Format("hand:%d,%.1f,%.1f", max(HandOf(p), 0), NADE_F, NADE_U + 3.5));
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

	// ---- QUICK GRENADE (owner 2026-11-10) ------------------------------------------------------------------------
	// A grenade thrown at any time from a key, whatever is in the hands, EXACTLY as Brutal Doom 22's Toss Grenade throws its
	// own (parsed from BD22 / BD22 VR Reloaded 2.0.4e actors/Weapons/DEFAULTWEAPON.dec, TossGrenade, and Grenades.dec
	// HandGrenade), so muscle memory carries over:
	//   - the key: BD22's own Toss Grenade (+user1, its default G) -- with RSQ Grenade in play BD22 VR stands its grenade
	//     down and that key throws nothing of its own -- or "Quick Grenade" (rsqgn_quickthrow) bound here;
	//   - the timing: the pin at tic 7 (GRTH ABCDEF 1 after one tic), the toss sound at tic 15, the grenade out at tic 17
	//     (FGHIJK 1, TNT1 2, LM 1), the next press taken at tic 22 (NOP 1, TNT1 1 and the jump back);
	//   - the flight: A_ThrowGrenade(.., 5, 45, 5) from the pawn (5 units above its default 35, 45 units a tic along the
	//     view, 5 up turned by the pitch, half the pawn's own speed, the engine's own random spread), with HandGrenade's
	//     gravity 0.7, bounce 0.6 and wall bounce 0.3;
	//   - its fuse, its kind and the rest are this pack's grenade (the kind in hand, Gun Bonsai VR's claim);
	//   - RSQ SlowMo: eight tics out, its Quick Grenade trigger (Your Triggers) slows the world so it can be shot in the air.
	// Off with Quick Grenade (rsqgn_quick, per player). Rig: not yet shown.
	const QUICK_PIN = 7;
	const QUICK_TOSS = 15;
	const QUICK_OUT = 17;
	const QUICK_NEXT = 22;
	const QUICK_SLOW_MS = 1500;		// RSQ SlowMo's slow after a quick throw (my number: a skeet-style window, 1.5 s)

	void QuickPress(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		if (!PFlag(p, "rsqgn_quick", true) || pmo.health <= 0) return;
		if (quickAt[n] > 0 || level.maptime < quickFree[n] || armed[n]) return;
		if (pmo.CountInv("RSQGN_Ammo") <= 0)
		{
			// a toast for every player (play code, the same on every machine); the old print only for this machine's player
			if (!Toast(pmo, "ammo", "No grenades") && n == consoleplayer) Console.MidPrint(null, "No grenades");
			quickFree[n] = level.maptime + QUICK_NEXT;
			return;
		}
		quickAt[n] = level.maptime + QUICK_OUT;
		quickFree[n] = level.maptime + QUICK_NEXT;
		if (Debug(p)) Console.Printf("RSQGN quick p%d t%d: queued, out at t%d", n, level.maptime, quickAt[n]);
	}

	void QuickTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) continue;
			let p = players[n];
			let pmo = p.mo;
			if (!pmo) { quickAt[n] = 0; continue; }
			// BD22's key (+user1), pressed this tic (the synced command, so every machine sees it)
			if ((p.cmd.buttons & BT_USER1) && !(p.oldbuttons & BT_USER1)) QuickPress(pmo, n);
			if (quickAt[n] <= 0) continue;
			if (pmo.health <= 0) { quickAt[n] = 0; continue; }
			int t = level.maptime - (quickAt[n] - QUICK_OUT);
			if (t == QUICK_PIN) pmo.A_StartSound("rsqgn/pin", CHAN_AUTO, CHANF_OVERLAP);
			if (t == QUICK_TOSS) pmo.A_StartSound("rsqgn/toss", CHAN_AUTO, CHANF_OVERLAP);
			if (level.maptime >= quickAt[n]) { quickAt[n] = 0; QuickThrow(pmo, n); }
		}
	}

	void QuickThrow(PlayerPawn pmo, int n)
	{
		if (pmo.CountInv("RSQGN_Ammo") <= 0) return;
		pmo.A_ThrowGrenade("RSQGN_Thrown", 5, 45, 5, false);
		// the grenade it just threw: the newest of ours with this thrower and no serial yet
		RSQGN_Thrown g = null;
		let it = ThinkerIterator.Create("RSQGN_Thrown");
		RSQGN_Thrown t;
		while (t = RSQGN_Thrown(it.Next())) if (t.target == pmo && t.serial == 0 && t.age == 0) g = t;
		if (!g) return;
		g.serial = ++nadeSerial;
		let gw = Weapon(pmo.FindInventory("RSQGN_Grenade"));
		if (gw)
		{
			g.master = gw;
			let si = ServiceIterator.Find("RSQ_MeleeUpgradeService");
			Service gb = si.Next();
			if (gb) gb.GetInt("claim", "", 0, 0, g);
		}
		int fuse = FuseTics(pmo);
		g.angle = VectorAngle(g.Vel.x, g.Vel.y);
		g.fuse = fuse;
		g.fuseTotal = fuse;
		g.dmgMult = 1.0;
		g.kind = RSQGN_Kind.Owns(pmo, kind[n]) ? kind[n] : RSQGN_Kind.FRAG;
		if (g.kind == RSQGN_Kind.FLASH) g.bBright = true;
		g.Gravity = 0.7;            // BD22's HandGrenade
		g.BounceFactor = 0.6;
		g.WallBounceFactor = 0.3;
		g.quick = true;
		pmo.TakeInventory("RSQGN_Ammo", 1);
		if (Debug(pmo.player))
			Console.Printf("RSQGN quick thrown p%d t%d: %.1f u/tic from (%.0f %.0f %.0f), fuse %d", n, level.maptime, g.Vel.Length(), g.pos.x, g.pos.y, g.pos.z, fuse);
	}

	// C8 DROP IT AT MY FEET (owner 2026-11-16): the cooking grenade leaves the hand that let it go. It falls at your feet,
	// half a body ahead of your middle, with half your own motion, and keeps what is left of its fuse; a dropped Impact
	// grenade waits for its fuse too. Thrown through Throw, so it is the same grenade every machine agrees on (serial,
	// kind, Gun Bonsai's claim).
	void DropLive(PlayerPawn pmo, int n, String why)
	{
		throwAt[n] = pmo.Pos + (cos(pmo.Angle) * pmo.Radius * 0.5, sin(pmo.Angle) * pmo.Radius * 0.5, 6);
		throwVel[n] = (pmo.Vel.x * 0.5, pmo.Vel.y * 0.5, 0);
		if (Debug(pmo.player)) Console.Printf("RSQGN dropped at the feet p%d t%d (%s)", n, level.maptime, why);
		Throw(pmo, n, -1, 0);
	}

	void Throw(PlayerPawn pmo, int n, int h, double ms)
	{
		bool dropped = h < 0;	// DropLive: no hand let it go by a swing
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
		g.dropped = dropped;
		int fa = RSQGN_Upg.Lv(pmo, "FlatArc"), bo = RSQGN_Upg.Lv(pmo, "Bounce");
		g.Gravity = clamp(SNum("rsqgn_grav", BALL_GRAVITY) * (fa > 0 ? RSQGN_Upg.Num("FlatArc.gravity", fa, 1.0) : 1.0), 0.05, 1.0);	// FLAT ARC
		g.BounceFactor = clamp(SNum("rsqgn_bounce", 0.5), 0.0, 0.9);
		g.WallBounceFactor = clamp(SNum("rsqgn_wallbounce", 0.25) + (bo > 0 ? RSQGN_Upg.Num("Bounce.wall", bo, 0) : 0), 0.0, 0.9);	// BOUNCE
		if (!dropped)
		{
			pmo.A_StartSound("rsqgn/toss", CHAN_WEAPON, CHANF_OVERLAP);
			if (!spoon[n]) pmo.A_StartSound("rsqgn/spoon", CHAN_AUTO, CHANF_OVERLAP);
			RSQGN_Buzzer.Start(pmo, h, 0.6, 5);
		}
		if (Debug(pmo.player))
			Console.Printf("RSQGN %s p%d t%d hand %d swing %.2f m/s, leaves at %.1f u/tic (%.2f m/s) from (%.0f %.0f %.0f), fuse %d of %d%s",
				dropped ? "dropped" : "thrown", n, level.maptime, h, ms, g.Vel.Length(), RSQGN_Geo.Metres(pmo, g.Vel) * TICRATE, g.pos.x, g.pos.y, g.pos.z, left, fuse, spoon[n] ? " (cooked)" : "");
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
		if (h < 0 || pmo.health <= 0) { ringHeld = false; trigPrev = false; squeezePrev = false; faceTic = 0; lastHand = -1; return; }
		if (!Active() && !standNoted && Debug(p))
		{
			standNoted = true;
			Console.Printf("RSQGN t%d: standing down for Brutal Doom VR (Replace Brutal Doom's Grenade off), but this grenade is in your hand: it works", level.maptime);
		}
		if (h != lastHand) { ringHeld = false; faceTic = 0; faceMiss = 0; faceReady = true; lastHand = h; }
		int o = 1 - h;
		int btn = p.cmd.buttons;
		bool trig = (btn & (h == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grab = (btn & (o == 0 ? BT_ATTACK : BT_OFFHANDATTACK)) != 0;
		bool grabPress = grab && !grabPrev;
		grabPrev = grab;
		trigPrev = trig;
		// THE KINDS: the holding hand's alt trigger cycles the kinds you own (Gun Bonsai VR patch) or, without the patch,
		// every kind (rsqgn_kinds_free, kinds.zs Owns), until the spoon flies. "Alt Fire Cycles Grenade Types"
		// (rsqgn_kind_alt) off: the alt trigger cycles nothing. At your mouth with the pin in, the alt trigger is the
		// teeth's squeeze instead (below), so it cycles nothing there.
		bool alt = (btn & (h == 0 ? BT_ALTATTACK : BT_OFFHANDALTATTACK)) != 0;
		bool altPress = alt && !altPrev;
		altPrev = alt;
		// THE SQUEEZE ON THE SPOON IS THE TRIGGER OR THE GRIPPED TRIGGER (owner 2026-11-09: "can't throw it while
		// holding trigger, can't throw it while holding altfire"). QuestZDoom's default vr_secondary_button_mappings
		// makes the grip a shift key: a hand closed round the grenade (grip) and squeezing (trigger) sends ALT fire and
		// no fire at all, so the spoon's let-go -- the fire button coming up -- never came, and nothing cooked or threw.
		// Either one held is the squeeze; both up is the let-go. (Once the pin is out the alt trigger is the squeeze
		// only: it cycles grenade kinds with the pin in, below.)
		bool squeeze = trig || alt;
		bool squeezeUp = !squeeze && squeezePrev;
		squeezePrev = squeeze;
		double mouth = MouthDist(pmo, h);
		bool faceOn = PFlag(p, "rsqgn_face", true);
		bool biting = faceOn && !armed[n] && mouth <= MouthReach(p);
		if (altPress && !armed[n])
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
			if (dbg && squeeze && level.maptime % 3 == 0)
			{
				double ms; Vector3 v;
				[ms, v] = Peak(pmo, h);
				Console.Printf("RSQGN squeeze t%d: hand %d trigger %d alt %d, swing %.2f m/s", level.maptime, h, trig, alt, ms);
			}
			if (squeezeUp)
			{
				double ms; Vector3 v;
				[ms, v] = Peak(pmo, h);
				double need = PNum(p, "rsqgn_throw_min", RSQGN_Fling.MIN_MPS);
				if (dbg) Console.Printf("RSQGN release t%d: swing %.2f m/s (throws from %.2f)", level.maptime, ms, need);
				if (ms >= need) SendThrow(pmo, h, ms, v);
				else Send("rsqgn_cook", int(ms * 100));
				Wait(n);
			}
			return;
		}
		if (squeezeUp)
		{
			double ms; Vector3 v;
			[ms, v] = Peak(pmo, h);
			if (dbg) Console.Printf("RSQGN release t%d (cooking): swing %.2f m/s, thrown", level.maptime, ms);
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
	// THE ONE THROW FEEL (owner 2026-11-22, RSQGN_Fling): the hand's peak times GAIN at Throw Strength 1.0, the arm's
	// part capped at CAP_MPS, along the hand's own motion (the scale keeps its direction); the lift and the run on top.
	// LIKE A BASEBALL OR A NEWSPAPER (owner 2026-11-24 15:08: "throwing a grenade feels all wrong, like it just rockets up
	// and bounces off the ceiling, it needs to be like a newspaper or a baseball"). Three things made it a rocket: 4x the
	// hand (the series' GAIN at Throw Strength 1.0) scaled the hand's upward part too, an Arc of 0.35 added more lift on
	// top, and nothing capped how steep it left. Now, for the grenade only (the saw and flare keep the one throw):
	//   STRENGTH  0.5 (rsqgn_strength): 2x the hand, a thrown ball's speed for a VR arm with no weight in it
	//   ARC       0 (rsqgn_arc): no lift added; the hand's own motion is the arc
	//   STEEPEST  BALL_MAX_UP degrees over level: a throw that leaves steeper keeps its speed and is laid down to it, so
	//             a hard overhand goes out, not up into the ceiling
	//   GRAVITY   0.35 of Doom's (rsqgn_grav; about 12.6 m/s^2): a 5 m/s throw at 25 degrees lands ~6 m out, a hard
	//             8 m/s one ~15 m, a 3 m/s toss ~2 m
	// The three cvars are new names, so an old saved Throw Strength 1.0, Arc 0.35 or Gravity 0.5 does not keep the rocket.
	// Code only, not run in the headset.
	const BALL_MAX_UP = 40.0;
	const BALL_GRAVITY = 0.35;
	static Vector3 LaunchVel(PlayerPawn pmo, Vector3 v)
	{
		let p = pmo.player;
		int sa = RSQGN_Upg.Lv(pmo, "StrongArm"), fa = RSQGN_Upg.Lv(pmo, "FlatArc");
		double strength = PNum(p, "rsqgn_strength", 0.5) * (sa > 0 ? RSQGN_Upg.Num("StrongArm.mult", sa, 1.0) : 1.0);
		double handMps = RSQGN_Geo.Metres(pmo, v) * TICRATE;
		Vector3 tv = v * RSQGN_Fling.Mult(handMps, strength);
		tv.z += tv.xy.Length() * PNum(p, "rsqgn_arc", 0.0) * (fa > 0 ? RSQGN_Upg.Num("FlatArc.lift", fa, 1.0) : 1.0);
		double flat = tv.xy.Length(), sp = tv.Length();
		if (sp > 0 && tv.z > flat * tan(BALL_MAX_UP))
		{
			Vector2 dir = flat > 0.001 ? tv.xy / flat : (cos(pmo.angle), sin(pmo.angle));
			tv = (dir * sp * cos(BALL_MAX_UP), sp * sin(BALL_MAX_UP));
		}
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

	// THE HAND'S SPEED (2026-11-09, owner on PC VR: no throw ever left the hand). It was RSQ Distance Grab's sampler: the
	// tracking space's yaw INFERRED from tic to tic (a pawn turn that both hands' yaws followed was a stick turn, one
	// they did not was a head turn), and every head turn faster than 0.5 degrees a tic BLINDED it for two tics, with
	// every tic whose hand position repeated counted as no motion. A real throw turns the head and the body with the
	// arm and twists the wrist, so the hand yaws never "follow": the throw's own tics were blinded, the peak read low,
	// the release cooked instead of throwing, and a cooked throw left with the little speed that was left. The throws
	// that do work for him measure it plainly -- BD22 VR Reloaded's grenade (rsg/grenade.zs Swing: the hand in the
	// BODY's frame, the pawn's yaw) and RSQ ShieldSaw's disc (pose.zs Rel / VelAt / ThrowVel: the same, over a 2-tic
	// window) -- and so does this now: each tic the hand relative to the pawn, turned by the pawn's own yaw. Kept: a
	// collapsed pose (a menu or a save writes both hands to one point) and a jump over a metre in two tics are no motion.
	private void Sample(PlayerPawn pmo)
	{
		bool same = pmo.AttackPos == pmo.OffhandPos && pmo.AttackAngle == pmo.OffhandAngle && pmo.AttackPitch == pmo.OffhandPitch;
		bool collapsed = same && !wasSame;
		wasSame = same;
		double c = cos(pmo.angle), sn = sin(pmo.angle);
		for (int h = 0; h < 2; h++)
		{
			Vector3 off = RSQGN_Geo.Pos(pmo, h) - pmo.Pos;
			int k = h * WIN + histAt[h];
			relHist[k] = (off.x * c + off.y * sn, off.y * c - off.x * sn, off.z);
			relOk[k] = !same && !collapsed;
			histAt[h] = (histAt[h] + 1) % WIN;
		}
	}

	// where hand h's sample `back` tics ago (0: this tic) sits in relHist / relOk (an index: a Vector3 handed back
	// through a multiple return is the kind of thing QZD 17.3's VM has dropped before -- ShieldSaw pose.zs)
	private int Hist(int h, int back) { return h * WIN + (histAt[h] - 1 - back + 2 * WIN) % WIN; }

	// The fastest 2-tic window of hand h over the last WIN tics: real m/s (the vertical squash taken out), and that
	// velocity in map units a tic, turned back into the world by the pawn's yaw now.
	// THE ONE THROW FEEL (owner 2026-11-22, RSQGN_Fling.Ahead): the fastest window that goes AWAY from you wins, so a
	// wind-up faster than the throw is never what leaves the hand; with none such (a lob straight up, a sideways flick)
	// the fastest of all, as before. relHist is in the body's frame: x ahead, y to the left.
	private double, Vector3 Peak(PlayerPawn pmo, int h)
	{
		Vector3 best = (0, 0, 0), bestAny = (0, 0, 0);
		double bestM = 0, bestAnyM = 0;
		for (int i = 0; i + 2 < WIN; i++)
		{
			int ka = Hist(h, i), kb = Hist(h, i + 2);
			if (!relOk[ka] || !relOk[kb]) continue;
			Vector3 v = (relHist[ka] - relHist[kb]) * 0.5;
			double m = RSQGN_Geo.Metres(pmo, v);
			if (m >= 0.5) continue;			// over a metre in two tics: a pose jump, not an arm
			if (m > bestAnyM) { bestAnyM = m; bestAny = v; }
			if (m > bestM && RSQGN_Fling.Ahead(v.x, v.y)) { bestM = m; best = v; }
		}
		if (bestM <= 0) { bestM = bestAnyM; best = bestAny; }
		double c = cos(pmo.angle), sn = sin(pmo.angle);
		return bestM * TICRATE, (best.x * c - best.y * sn, best.x * sn + best.y * c, best.z);
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

// AN UNDER-BARREL LAUNCHER'S GRENADE GOING OFF (RSQGN_Service "burst", 2026-11-17): BD22 VR Reloaded's Rifle and
// Machinegun fire the grenade loaded from RSQ Tactical Rig's grenade spot as their own 40 mm round; where it bursts, this
// is the grenade of its kind going off -- the hand blast's own states (the kind's Look, then the blast's two parts), only
// the obituary names the launcher.
class RSQGN_RoundBlast : RSQGN_HandBlast
{
	Default
	{
		Obituary "%o was popped by %k's launched grenade";
	}
}
