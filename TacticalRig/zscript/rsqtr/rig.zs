// RSQ_TacticalRig -- weapons carried on the body.
//
// SIX GUN HOLSTERS AND TWO SABER SPOTS (the owner's simple rig, 2026-10-27; the chest pair added
// 2026-10-31: "i want two more holsters, six seems like good number", both sides of the chest): both
// hips, both sides of the chest and both shoulders hold one gun each, exactly the one you put there; just below each hip is a
// spot for RSQ_Saber's hilts. Grip (or press Use) at a holster with a gun in the
// hand and it goes in (a full holster swaps: its gun comes out); with the hand empty, the
// holster's gun is drawn. Each hand holsters and draws its own gun.
//
// Credit: the tactical vest and the cigarette are Ermac's ideas (his Virtual
// Tactical Vest for Doom VR). This is a new implementation for stock QuestZDoom
// 17.3 that reads the real hand poses and keeps the rig on the body rather than the
// head.
//
// NETPLAY: the hand poses exist only for the camera player, so the console player's
// machine decides (hover, press) and sends one network event per ACTION;
// every machine applies it from the same inventory, so the worlds agree. Feedback
// (markers, icons, rumble, sound) is local.

class RSQTR_Region
{
	// ELEVEN INDICES, TEN IN USE. The index is a place's identity: its cvars (rsqtr_rN_*) and its
	// position in a saved holster profile. 0 1 hips, 3 the grenade spot, 4 5 shoulders, 6 7 the chest
	// (cross-draw, owner 2026-10-31), 8 the keyring (owner 2026-11-01: "its own spot"), 9 10 saber spots.
	// 2 (the stomach) is RETIRED: never live, no settings; kept as an index so nothing renumbers. A
	// profile saved before the chest pair has them empty: they keep the values they had. One saved
	// before the keyring had index 8 (then retired, the lower back) empty: loading it puts the keyring
	// back at its default (Profile).
	const N = 14;
	static const String NAMES[] = { "Left hip", "Right hip", "", "Grenades", "Left shoulder", "Right shoulder", "Left chest", "Right chest", "Keyring", "Left saber", "Right saber", "Whip", "Flare", "Ammo pouch" };
	const SABER_L = 9;
	const GRENADES = 3;
	const KEYRING = 8;
	const SABER_R = 10;
	const WHIP = 11;
	const FLARE = 12;
	const POUCH = 13;
	static bool Retired(int r) { return r == 2; }

	// Defaults, metres from the head in the body frame: forward, left, up, radius (0: retired).
	// The chest pair: 0.46 m under the eyes, 0.12 m either side of the breastbone, 0.10 m in front;
	// a little smaller (0.11) so a gun held at the chest does not sit in one. No two places overlap:
	// 0.27 m from the hips, 0.40 m from the shoulders, 0.21 m from the cigarette pocket (cig.zs, radius
	// 0.09 at 0.25 m under the eyes) -- at 0.38 m they sat on the pocket.
	// 3, THE GRENADE SPOT (owner 2026-10-31: "dedicated grenade spot"): the front of the belt, the buckle, 0.62 m
	// under the eyes, radius 0.08 -- 0.19 m from each chest holster and 0.22 m from each hip.
	// 8, THE KEYRING: where keyring.zs hung it until 11-01 (its RING_F / RING_L / RING_U constants, 0.14 forward,
	// 0.13 to the off-hand side, 0.70 under the eyes), radius its old grab reach (GRAB_M, 0.12). Its "left" is
	// TOWARD THE OFF HAND (mirrored for a left-handed layout, as it always hung), not the body's left.
	// It is no gun holster: only the keyring and its key-doors grip use it.
	// 11 THE WHIP and 12 THE FLARE (owner 2026-11-03 20:14: "a dedicated whip holster on the right hip, a few units behind
	// and to the right (outside) of the lightsaber holster, same height above the ground; and its mirror on the left hip
	// for the flare"). Measured against the saber spots' own numbers (above: 0.02 forward, 0.21 out, 0.84 under the eyes,
	// radius 0.10): 0.08 m further back and 0.09 m further out, the same 0.84 down -- 0.12 m (4.1 map units at 34 a metre)
	// from the saber spot's centre, 0.19 m from the hip holster's. Radius 0.09: the spheres touch the saber's and the hip's
	// a little, and the nearest centre wins (WorldTick), so each is found by reaching a hand's width past the saber.
	// Their "left" is TOWARD A HAND (as the keyring's): the whip's toward the MAIN hand, the flare's toward the OFF hand
	// (Settings turns it into the body's left for the engine's handedness, LeftHanded, as the saber spots follow it).
	// 13 THE AMMO POUCH (owner 2026-11-03 20:46: "a dedicated ammo pouch ... directly to the left of the belt-buckle grenade
	// spot, at about buckle height, spaced so it never overlaps the buckle or the left-hip flare holster"): for Brutal Doom
	// 22 VR's hand reloads, which take their magazines, shells and rounds ONLY here while the rig answers (its "pouch.at").
	// Searched against every place near it (a 1 cm grid, the spot with the most room within 4 cm of the buckle's height and
	// 4 cm of its depth): 0.16 forward, 0.13 toward the off hand, 0.61 under the eyes, radius 0.045 -- 0.011 m clear of the
	// buckle, 0.005 of the off hip, 0.007 of the off chest holster, 0.276 of the flare holster. Its "left" is toward the OFF
	// hand (the engine's handedness, LeftHanded: the reload's hand), so a left-hander's is beside the buckle on the right.
	// MUCH LARGER (owner 11-05 01:07 "Ammo pouch needs to be much larger"): radius 0.10 (2.2x), moved 0.04 forward, 0.01
	// toward the off hand and 0.01 down to (0.20, 0.14, -0.62) -- the belt-bound spot (no further forward than 0.20) where a
	// 0.10 sphere is closest to clear: it overlaps the off hip's sphere by 0.021 and nothing else; by the nearest-centre rule
	// (WorldTick) the pouch owns 99% of its sphere (measured, 1 cm grid + Monte Carlo against every place). The old spot
	// had room for 0.063 at most. SHRUNK TO THE ITEM (owner 11-05 01:07 "their spheres can shrink a little ... just a little
	// larger than it"): the whip 0.09 -> 0.08, the coiled mesh's thickness out of and into the hip (0.051 / 0.070 m, the
	// rsqwp_coil.md3 thong measured) plus a centimetre. The grenade (mesh 0.069 m from its centre: 0.08 already), keyring
	// (keys hang 0.11 m below the ring), flare and sabers (meshes longer than their spheres: 0.116 and 0.125 m half-length,
	// a hand in the sphere is already on the mesh) keep theirs.
	static const double DF[] = {  0.00,  0.00, 0,  0.12, -0.08, -0.08,  0.10,  0.10,  0.14,  0.02,  0.02, -0.06, -0.06,  0.20 };
	static const double DL[] = {  0.18, -0.18, 0,  0.00,  0.18, -0.18,  0.12, -0.12,  0.13,  0.21, -0.21,  0.30,  0.30,  0.14 };
	static const double DU[] = { -0.70, -0.70, 0, -0.62, -0.10, -0.10, -0.46, -0.46, -0.70, -0.84, -0.84, -0.84, -0.84, -0.62 };
	static const double DR[] = {  0.14,  0.14, 0,  0.08,  0.14,  0.14,  0.11,  0.11,  0.12,  0.10,  0.10,  0.08,  0.09,  0.10 };
}

class RSQTR_Rig : EventHandler
{
	const STEADY_RANGE = 0.50;    // metres: the engine's own two-hand steadying distance

	// ---- synced state (written by NetworkProcess on every machine) --------------
	bool   gripDown[MAXPLAYERS * 2];
	String lastPut[MAXPLAYERS * RSQTR_Region.N];   // the weapon last holstered there (its icon)
	bool lastPair[MAXPLAYERS * RSQTR_Region.N];    // ...and it went away as a PAIR (one in each hand)
	// HOLSTER ASSIGNMENT (owner 2026-11-07 07:36-07:47, design/PARKED.md "Wheel holster web"; replaces 11-06's Holster
	// Lock and its option row): the gun each gun holster is ASSIGNED to ("" unassigned). A gun put by hand into an
	// unassigned, empty holster is assigned to it; RSQ Wheel's holster web assigns ("rsqtr_assign:<gun>", taking the
	// holster over from another gun) and clears ("rsqtr_unassign:<gun>"). An assigned holster is its gun's whether the gun
	// is in it or in a hand: no other gun goes in. An assigned gun put at any other holster goes to its own, and a full
	// holster's gun comes out to the hand (Quick Swap, LockedHome); an unassigned gun at a full or another gun's holster:
	// nothing happens.
	String lockCls[MAXPLAYERS * RSQTR_Region.N];
	String offNext[MAXPLAYERS];                     // the off-hand weapon to raise once the main hand has switched
	int offWait[MAXPLAYERS];
	// The last draw from a holster, PER HAND (11-03: since 11-02 each hand draws its own gun, and a scorer judges the
	// hand that fired), for a scorer's Quick Draw (RSQTR_RigService "rig.drawtic" / "rig.drawn", intArg the hand).
	// Written in Draw() / DrawOff(), which every machine runs from the same network event, so it is the same
	// everywhere. Index player * 2 + hand (0 main, 1 off); drawTic is level.maptime + 1 (0 = none).
	int drawTic[MAXPLAYERS * 2];
	String drawClass[MAXPLAYERS * 2];

	// ---- local state (console player) -------------------------------------------
	private transient RSQTR_Body body;
	private transient int  hoverR[2];          // region each hand is in, -1 none
	private transient bool pressWas[2];
	private transient bool useWas;
	private transient Vector3 relHand[12];    // per hand, the last six body-relative hand positions (newest first)
	private transient int relN[2];
	private transient Vector3 rawHand[2];

	// The fastest 2-tic window of the last six body-relative samples: room m/s, and that velocity (map units a tic)
	// turned into the frame the player faces now.
	private double, Vector3 SwingPeak(PlayerPawn pmo, int h, Vector3 hp)
	{
		Vector3 d = level.Vec3Diff(pmo.Pos, hp);
		double c = cos(pmo.Angle), sn = sin(pmo.Angle);
		Vector3 rel = (d.x * c + d.y * sn, d.y * c - d.x * sn, d.z);
		// A STALE HAND IS NOT A SAMPLE: the hand fields are written when a frame is drawn, so a tic with no new frame
		// repeats the last hand while the pawn has moved on -- read as the hand jerking back by the walk (rig, walking).
		bool stale = hp == rawHand[h];
		rawHand[h] = hp;
		if (!stale)
		{
			for (int k = 5; k > 0; k--) relHand[h * 6 + k] = relHand[h * 6 + k - 1];
			relHand[h * 6] = rel;
			if (relN[h] < 6) relN[h]++;
		}
		double best = 0; Vector3 bv = (0, 0, 0);
		for (int k = 0; k + 2 < relN[h]; k++)
		{
			Vector3 v = (relHand[h * 6 + k] - relHand[h * 6 + k + 2]) / 2.0;
			// ACROSS THE GROUND ONLY: the view height eases after a step down a stair, and the hand eases with it --
			// a vertical "swing" the arm never made (rig: walking down the start room's steps read 2.6 m/s). A throw
			// goes out from you; its speed is counted across the ground, its velocity keeps the lift.
			double ms = v.xy.Length() / RSQTR_Body.Upm() * TICRATE;
			if (ms > best) { best = ms; bv = v; }
		}
		return best, (bv.x * c - bv.y * sn, bv.x * sn + bv.y * c, bv.z);
	}
	transient Actor marker[RSQTR_Region.N];   // read by the mirror (mirror.zs)
	transient Actor fnfMark[2];               // RSQ FlashFlare's flare pocket and flashlight clip (DrawFnFMarkers), read by the mirror too
	transient Actor icon[RSQTR_Region.N];
	transient Actor pip[RSQTR_Region.N];      // the ammo light in a full holster
	transient Actor nadeShow;                 // the grenade at the grenade spot (DrawNade)
	private transient int  buzzCool[2];
	private transient bool offHeldSaid[MAXPLAYERS];   // said once per hold, why the off-hand raise is waiting (TickPairs)
	private transient int  hoverT[2];          // tics the hand has been in its region
	private transient bool pendPress[2];       // pressed before the dwell was up
	private transient int  editHand, editRegion;   // a region being carried in edit mode
	private transient Vector3 editAt;

	// ui: the grip arrives as raw key events
	ui Array<int> keysMain, keysOff;
	ui String keysMainFrom, keysOffFrom;
	ui bool keyState[2];

	static RSQTR_Rig Get() { return RSQTR_Rig(EventHandler.Find("RSQTR_Rig")); }

	// ---- THE GUN BONSAI VR PATCH'S LEVELS (GBOVR_TREES.md 4.8), asked by name once a second per player ----------------
	// Without the patch Gb is -1 and every row works as before. With it, Smoker lengthens the smoke's slow motion and makes
	// you untouchable through it (cig.zs); Chain Smoker adds to the pack; Gun Toss and Boomerang Gun act on a thrown gun.
	// (Owner, 11-03: Ammo Count, Keys to Doors and Cigarettes are menu rows, never unlocks; the cigarette is yours from the
	// start.)
	transient int gbTic[MAXPLAYERS], gbSmoker[MAXPLAYERS], gbChain[MAXPLAYERS];
	transient int gbToss[MAXPLAYERS], gbBoom[MAXPLAYERS];
	transient bool gbOn;
	void GbRefresh(int n)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return;
		if (gbTic[n] > 0 && level.maptime < gbTic[n] && level.maptime >= gbTic[n] - 35) return;
		gbTic[n] = level.maptime + 35;
		let svc = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		gbOn = svc != null;
		gbSmoker[n] = 0; gbChain[n] = 0; gbToss[n] = 0; gbBoom[n] = 0;
		if (!svc) return;
		let pmo = players[n].mo;
		gbSmoker[n] = max(0, svc.GetInt("plevel", "Smoker", 0, 0, pmo));
		gbChain[n]  = max(0, svc.GetInt("plevel", "ChainSmoker", 0, 0, pmo));
		gbToss[n]   = max(0, svc.GetInt("plevel", "GunToss", 0, 0, pmo));
		gbBoom[n]   = max(0, svc.GetInt("plevel", "BoomerangGun", 0, 0, pmo));
	}
	// that player's level of a node, -1 without the patch
	static int Gb(PlayerInfo p, Name what)
	{
		let me = Get();
		if (!me || !me.gbOn || !p || !p.mo) return -1;
		int n = p.mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS) return -1;
		switch (what)
		{
		case 'Smoker':       return me.gbSmoker[n];
		case 'ChainSmoker':  return me.gbChain[n];
		case 'GunToss':      return me.gbToss[n];
		case 'BoomerangGun': return me.gbBoom[n];
		}
		return -1;
	}
	RSQTR_Body GetBody() const { return body; }
	private transient RSQTR_Fit fitData;
	RSQTR_Fit GetFit() { if (!fitData) fitData = RSQTR_Fit.Load(); return fitData; }
	int HoverRegion(int h) const { return (h == 0 || h == 1) ? hoverR[h] : -1; }
	// Busy = INSIDE a holster. "Near" was tried (10-27) and switched Distance Grab off
	// for good: a hand resting at your side is always within reach of a hip holster.
	bool HandBusy(int h) const { return (h == 0 || h == 1) && hoverR[h] >= 0; }

	// ---- settings ----------------------------------------------------------------
	static double Num(String n, PlayerInfo p, double d) { let c = CVar.GetCVar(n, p); return c ? c.GetFloat() : d; }
	static int Opt(String n, PlayerInfo p, int d) { let c = CVar.GetCVar(n, p); return c ? c.GetInt() : d; }
	static bool Flag(String n, PlayerInfo p, bool d) { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }

	// THE PLACES' SETTINGS, READ ONCE A TIC (the runtime audit, 10-27: building "rsqtr_r%d_f" names
	// and looking each up, 11 places x 2 hands x several loops every tic, made the rig the suite's
	// costliest handler, 0.37-0.54 ms/tic on BD22Q).
	private transient double cF[RSQTR_Region.N], cL[RSQTR_Region.N], cU[RSQTR_Region.N], cR[RSQTR_Region.N];
	private transient int cTic, cWho;
	private transient bool cOk;
	private void Settings(PlayerInfo p)
	{
		int who = p ? p.mo.PlayerNumber() : -1;
		if (cOk && cTic == level.maptime && cWho == who) return;
		cOk = true; cTic = level.maptime; cWho = who;
		double reach = Num("rsqtr_reach", p, 1.0) * BodyScale(p);
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (RSQTR_Region.Retired(r)) { cF[r] = 0; cL[r] = 0; cU[r] = 0; cR[r] = 0; continue; }
			cF[r] = Num(String.Format("rsqtr_r%d_f", r), p, RSQTR_Region.DF[r]);
			cL[r] = Num(String.Format("rsqtr_r%d_l", r), p, RSQTR_Region.DL[r]);
			cU[r] = Num(String.Format("rsqtr_r%d_u", r), p, RSQTR_Region.DU[r]);
			cR[r] = Num(String.Format("rsqtr_r%d_rad", r), p, RSQTR_Region.DR[r]) * reach;
		}
		// the keyring's "left" is toward the off hand (RSQTR_Region.DL's note)
		if (RSQTR_Body.LayoutLeft()) cL[RSQTR_Region.KEYRING] = -cL[RSQTR_Region.KEYRING];
		// the whip's "left" is toward the main hand, the flare's toward the off hand (RSQTR_Region.DL's note)
		bool lh = RSQTR_Body.LeftHanded();
		if (!lh) cL[RSQTR_Region.WHIP] = -cL[RSQTR_Region.WHIP];
		if (lh) cL[RSQTR_Region.FLARE] = -cL[RSQTR_Region.FLARE];
		if (lh) cL[RSQTR_Region.POUCH] = -cL[RSQTR_Region.POUCH];
	}

	// Where region r is, in the world, for this player.
	Vector3 RegionAt(PlayerPawn pmo, int r)
	{
		let p = pmo.player;
		if (editHand >= 0 && editRegion == r && pmo.player == players[consoleplayer]) return editAt;
		Settings(p);
		return BodyPoint(pmo, cF[r], cL[r], cU[r]);
	}

	// Any point on the body (metres, body frame): the cigarette pocket uses it too.
	// Scaled to the player: the defaults are for an eye height of 1.62 m (a ~1.75 m
	// person); after "Measure my height" every offset scales by your eye height over
	// that, so a short and a tall player both find the hips at their own hips.
	const REF_EYE = 1.62;
	static double BodyScale(PlayerInfo p)
	{
		double eye = Num("rsqtr_eye_m", p, 0);
		return eye > 0.8 ? clamp(eye / REF_EYE, 0.7, 1.3) : 1.0;
	}

	Vector3 BodyPoint(PlayerPawn pmo, double f, double l, double u)
	{
		double k = BodyScale(pmo.player);
		f *= k; l *= k; u *= k;
		if (body && body.primed) return body.At(pmo, f, l, u);
		RSQTR_Body tmp = new("RSQTR_Body");
		tmp.yaw = pmo.angle; tmp.primed = true;
		return tmp.At(pmo, f, l, u);
	}

	double BodyYaw(PlayerPawn pmo) { return (body && body.primed) ? body.yaw : pmo.angle; }

	// The other way: a world point as body-frame metres (unscaled), for edit mode.
	void BodyOffsets(PlayerPawn pmo, Vector3 at, out double f, out double l, out double u)
	{
		double yaw = (body && body.primed) ? body.yaw : pmo.angle;
		Vector3 d = at - RSQTR_Body.Head(pmo);
		double k = BodyScale(pmo.player);
		f = (d.x * cos(yaw) + d.y * sin(yaw)) / RSQTR_Body.Upm() / k;
		l = (-d.x * sin(yaw) + d.y * cos(yaw)) / RSQTR_Body.Upm() / k;
		u = d.z * RSQTR_Body.Ps() / RSQTR_Body.Upm() / k;
	}

	double RegionRadius(PlayerInfo p, int r)
	{
		Settings(p);
		return cR[r];
	}

	// ---- the saber spots ------------------------------------------------------------
	// The saber classes this player owns that belong at place r. ONE SPOT PER SABER (the owner,
	// 10-27): the main saber's is on the main hand's side (the home spot, SaberHome), the
	// second saber's on the off hand's side (10-29; it was cross-draw). Found by class name so the saber
	// need not be loaded. The main saber is also listed on a hip with rsqtr_saber_hip.
	// Gun holsters hold what was put there (Content), not a list.
	static void Owned(PlayerPawn pmo, int r, out Array<String> into)
	{
		into.Clear();
		if (!pmo || !pmo.player) return;
		int home = SaberHome();
		int away = SaberAway();
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || w.bPOWERED_UP || w.Amount <= 0 || !IsSaber(w)) continue;
			if (IsSecondSaber(w)) { if (r == away && SecondSaberAllowed()) into.Push(w.GetClassName()); }
			else if (r == home) into.Push(w.GetClassName());
			else if ((r == 0 || r == 1) && Flag("rsqtr_saber_hip", pmo.player, false)) into.Push(w.GetClassName());
		}
	}

	// WHAT THE HAND HOLDS, as the rig files it. Brutal Doom's dual guns (DualRifles,
	// DualPistols, DualSMG, ...) are separate weapons outside the slots
	// (CHEATNOTWEAPON), switched to from inside the single gun with A_SelectWeapon
	// (BD22 Rifle.dec:830). They are filed as the single gun they pair: the class whose
	// name ends with the dual's name minus "Dual" and a plural s (Rifle, BrutalPistol,
	// BrutalSMG), else the slotted gun with the same SelectionOrder (DualRifles and
	// Rifle are both 800). Holstering a pair puts the gun away; drawing gives the
	// single, and Brutal Doom's own control pairs it again.
	static String HeldAs(PlayerPawn pmo, Weapon w)
	{
		if (!w) return "";
		String cls = w.GetClassName();
		if (w.bOffhandWeapon) return cls;      // (BD22Q's DualRifles is not CHEATNOTWEAPON: measured)
		String low = cls.MakeLower();
		if (low.IndexOf("dual") != 0) return cls;
		String stem = low.Mid(4);
		if (stem.Length() > 1 && stem.Mid(stem.Length() - 1) == "s") stem = stem.Left(stem.Length() - 1);
		Weapon bySel = null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let o = Weapon(it);
			if (!o || o == w || o.bCHEATNOTWEAPON || o.bOffhandWeapon) continue;
			String on = o.GetClassName();
			if (on.MakeLower().IndexOf("dual") == 0) continue;
			String ol = on.MakeLower();
			if (stem.Length() > 0 && ol.Length() >= stem.Length() && ol.Mid(ol.Length() - stem.Length()) == stem) return on;
			if (!bySel && o.SelectionOrder == w.SelectionOrder) bySel = o;
		}
		if (bySel) { String bn = bySel.GetClassName(); return bn; }
		return cls;
	}

	// EACH SABER ON ITS OWN HAND'S SIDE (the owner, 10-29: "saber holsters seem to be swapped"):
	// the main saber hangs on the main hand's side, the second saber on the off hand's side.
	// Until 10-29 they were cross-draw (main saber on the left hip for a right-handed player).
	static int SaberHome() { return RSQTR_Body.LeftHanded() ? RSQTR_Region.SABER_L : RSQTR_Region.SABER_R; }
	static int SaberAway() { return RSQTR_Body.LeftHanded() ? RSQTR_Region.SABER_R : RSQTR_Region.SABER_L; }

	static bool IsSecondSaber(Weapon w)
	{
		String n = w.GetClassName();
		n = n.MakeLower();
		return n == "ubqs_saberoff";
	}

	// The saber's own switches (server cvars, read by name): a second saber at all, and not "one only".
	static bool SecondSaberAllowed()
	{
		let d = CVar.FindCVar("ubqs_dual");
		let m = CVar.FindCVar("ubqs_dual_mode");
		return (!d || d.GetBool()) && (!m || m.GetInt() != 0);
	}

	static bool IsSaber(Weapon w)
	{
		String n = w.GetClassName();
		n = n.MakeLower();
		return n.IndexOf("ubqs_saber") == 0;
	}

	// The series' own slot-1 tools are never an "empty hand" (owner 2026-11-02: on the full set the empty hand
	// was the Whip, RSQWP_WhipWeapon, the highest SelectionOrder in slot 1). Whip, ShieldSaw, Grapple, Grenade.
	static bool IsSeriesTool(Weapon w)
	{
		String n = w.GetClassName();
		n = n.MakeLower();
		return n.IndexOf("rsqwp_") == 0 || n.IndexOf("ssq_") == 0 || n.IndexOf("rsqgr_") == 0
			|| n.IndexOf("rsqgn_") == 0 || n.IndexOf("rsq_grenade") == 0;
	}

	// ---- THE WHIP AND FLARE HOLSTERS (owner 2026-11-03 20:14, "Build both now") ---------------------------------------
	// Two dedicated holsters, each holding ONE thing and nothing else, found by name (the rig works without either mod):
	//   THE WHIP (RSQ Whip's RSQWP_WhipWeapon) at place 11, on the main hand's hip (rsqtr_whip_holster). Like the saber's
	//   spot it holds no copy: the whip is in its holster whenever you own it and it is in neither hand. So it never goes
	//   into a gun holster (HoldsGun / IsMovedGun / Content leave it out while this holster is on), and whatever takes it
	//   out of the hand -- a draw from another holster, the weapon wheel, a slot key, BD's own switches -- leaves it home.
	//   A hand holding it at an EMPTY gun holster puts it home (as the saber's "put anywhere, goes home"). Drawn into the
	//   hand RSQ Whip's Whip In names (rsqwp_whip_hand, by name: main unless set to the off hand); only that hand works it.
	//   THE FLARE (RSQ FnF's road flare) at place 12, on the off hand's hip (rsqtr_flare_holster). It holds the same
	//   flares as FnF's chest pocket (its RSQFF_Ammo): the off hand grips there and FnF's own take brings an unlit flare up
	//   (its "rsqff_take", which waits out the engine's two-hand steadying and gives the hand back what it had); an unlit
	//   flare gripped there goes back (FnF's "rsqff_back"). A LIT FLARE CANNOT GO IN (FnF's rule: only unlit flares go
	//   back): the rig refuses with a short tick and FnF's own grip rule acts as anywhere else (a still grip drops it at
	//   your feet, burning; a swing throws it). Taken from the off hand any other way (an off-hand draw from another
	//   holster, another weapon raised there), FnF itself puts an unlit flare back (so it is in this holster again) and
	//   lets a lit one fall burning. FnF's state is asked of its RSQFF_Service ("flare.phase", "flare.count").
	// Each shows on the body as its own model while stored (RSQ Whip's Show Whip / RSQ FnF's Show Flare, by name): the class RSQ Whip /
	// RSQ FnF ship for it (RSQWP_Stowed, RSQFF_Stowed, MODELDEF in their pk3s), spawned by name; without it, nothing.
	const WHIP_CLASS = "RSQWP_WhipWeapon";
	static bool WhipLoaded() { String n = WHIP_CLASS; class<Weapon> c = n; return c != null; }
	static bool FlareLoaded() { String n = "RSQFF_Held"; class<Weapon> c = n; return c != null; }
	static bool IsWhip(Weapon w) { if (!w) return false; String n = w.GetClassName(); return n ~== WHIP_CLASS; }
	static bool WhipHolsterOn(PlayerInfo p) { return Flag("rsqtr_whip_holster", p, true) && WhipLoaded(); }
	static bool FlareHolsterOn(PlayerInfo p)
	{
		if (!Flag("rsqtr_flare_holster", p, true) || !FlareLoaded()) return false;
		let c = CVar.FindCVar("rsqff_on");
		return !c || c.GetBool();
	}
	// a whip that stays out of the gun holsters: the holster is on for its owner
	static bool HomeWhip(Weapon w) { return IsWhip(w) && w.Owner && w.Owner.player && WhipHolsterOn(w.Owner.player); }
	static Weapon WhipOf(PlayerPawn pmo)
	{
		String n = WHIP_CLASS;
		class<Weapon> c = n;
		return (c && pmo) ? Weapon(pmo.FindInventory(c)) : null;
	}
	// the hand the whip belongs to: the hand holding it, else RSQ Whip's Whip In (0 main, 1 off)
	static int WhipHand(PlayerPawn pmo)
	{
		let w = WhipOf(pmo);
		let p = pmo.player;
		if (w && p.ReadyWeapon == w) return 0;
		if (w && p.OffhandWeapon == w) return 1;
		let cv = CVar.GetCVar("rsqwp_whip_hand", p);
		return (cv && cv.GetInt() == 1) ? 1 : 0;
	}
	static bool WhipInHand(PlayerPawn pmo)
	{
		let w = WhipOf(pmo);
		let p = pmo.player;
		return w && (p.ReadyWeapon == w || p.OffhandWeapon == w || p.PendingWeapon == w);
	}
	// RSQ FnF, asked by name: the flare in that player's off hand (0 none, 1 unlit, 2 lit; -1 no answer) and the flares
	// carried (its pocket's count, the same flares this holster holds)
	static int FlareAsk(String what, PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQFF_Service");
		Service s;
		while (s = it.Next()) return s.GetInt(what, "", pmo.PlayerNumber(), 0, pmo);
		return -1;
	}

	// ---- THE AMMO POUCH (owner 2026-11-03 20:46) ---------------------------------------------------------------------------
	// Live with Ammo Pouch on (rsqtr_pouch) and Brutal Doom 22 VR loaded (its RSQ_Hands, by name: the pouch is for its hand
	// reloads). Published as RSQTR_RigService "pouch.at": 1 the hand is in the pouch, 0 it is not, -1 no pouch (off, no BD22
	// VR, the rig off or out of VR) -- then BD22 VR keeps its own rule. Pressing in it does nothing of the rig's own.
	static bool PouchOn(PlayerInfo p) { return Flag("rsqtr_pouch", p, true) && OffEmptyName(p ? p.mo : null) != ""; }
	transient bool rigLive;          // the rig ran this tic (on, alive, in VR): hover is meaningful
	int PouchAt(PlayerPawn pmo, int h)
	{
		if (!pmo || !rigLive || !PouchOn(pmo.player)) return -1;
		return hoverR[h & 1] == RSQTR_Region.POUCH ? 1 : 0;
	}

	// The weapon an empty hand holds: a slot-1 weapon you own, the fist rather than
	// the chainsaw (the higher SelectionOrder: Doom picks the chainsaw first).
	// rsqtr_empty names one explicitly.
	static Weapon EmptyHand(PlayerPawn pmo)
	{
		String want = "";
		let cv = CVar.GetCVar("rsqtr_empty", pmo.player);
		if (cv) want = cv.GetString();
		if (want != "")
		{
			class<Weapon> wc = want;
			if (wc) { let w = Weapon(pmo.FindInventory(wc)); if (w) return w; }
		}
		Weapon best = null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			// CHEATNOTWEAPON is allowed here: Brutal Doom's own fists (Melee_Attacks, slot 1,
			// SelectionOrder 3700) are one; otherwise the axe or the DSweap won.
			if (!w || w.bOffhandWeapon || IsSaber(w) || IsSeriesTool(w)) continue;   // the saber is not an empty hand
			bool found; int slot, idx;
			[found, slot, idx] = pmo.player.weapons.LocateWeapon(w.GetClass());
			if (!found || slot != 1) continue;
			if (!best || w.SelectionOrder > best.SelectionOrder) best = w;
		}
		return best;
	}

	// ---- input: the grips ----------------------------------------------------------
	// QuestZDoom sends the off-hand grip as KEY_PAD_RTHUMB (443), or KEY_PAD_DPAD_UP
	// (436) while the main grip is held as a shift; the main grip is a key of its own
	// (KEY_PAD_LTRIGGER, 446) only when vr_secondary_button_mappings is off. Both lists
	// are cvars, so another layout is a menu change, not a code change.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		let me = players[consoleplayer];
		Refresh("rsqtr_keys_main", "446", me, keysMain, keysMainFrom);
		Refresh("rsqtr_keys_off", "443 436", me, keysOff, keysOffFrom);
		bool down = e.Type == InputEvent.Type_KeyDown;
		for (int h = 0; h < 2; h++)
		{
			bool mine = h == 0 ? keysMain.Find(e.KeyScan) < keysMain.Size() : keysOff.Find(e.KeyScan) < keysOff.Size();
			if (!mine) continue;
			if (keyState[h] == down) continue;
			keyState[h] = down;
			EventHandler.SendNetworkEvent("rsqtr_grip", h, down ? 1 : 0);
		}
		return false;   // never eaten: the grip keeps everything else it does
	}

	private ui void Refresh(String cvn, String def, PlayerInfo me, out Array<int> keys, out String from)
	{
		let cv = CVar.GetCVar(cvn, me);
		String s = cv ? cv.GetString() : def;
		if (s == from) return;
		from = s;
		keys.Clear();
		Array<String> w;
		s.Split(w, " ", TOK_SKIPEMPTY);
		for (int i = 0; i < w.Size(); i++) keys.Push(w[i].ToInt());
	}

	// ---- actions (every machine) -----------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (e.Name == "rsqtr_grip")
		{
			int h = e.Args[0];
			if (h == 0 || h == 1) gripDown[n * 2 + h] = e.Args[1] != 0;
			return;
		}
		if (e.Name == "rsqtr_calib")
		{
			// The headset's own height above the room floor. Measured on the machine
			// that owns the headset and stored in that player's own setting.
			if (n == consoleplayer && pmo)
			{
				double eye = pmo.HmdPosition.y;
				if (eye > 0.8 && eye < 2.3)
				{
					CVar.FindCVar("rsqtr_eye_m").SetFloat(eye);     // this machine's own setting (GetCVar with a player is that player's copy)
					pmo.A_Print(String.Format("Tactical Rig: eye height %.2f m (rig scaled %.0f%%)", eye, 100 * clamp(eye / REF_EYE, 0.7, 1.3)), 0, RSQTR_A11y.PrintFont());
				}
				else pmo.A_Print("Tactical Rig: stand up straight and try again (no headset height read)", 0, RSQTR_A11y.PrintFont());
			}
			return;
		}
		if (e.Name == "rsqtr_prof_save" || e.Name == "rsqtr_prof_load")
		{
			if (n == consoleplayer) Profile(pmo, e.Args[0], e.Name == "rsqtr_prof_save");
			return;
		}
		// "Recenter Torso" (KEYCONF rsqtr_recenter, 11-03 18:56): the body is this machine's own, so only its player's
		if (e.Name == "rsqtr_recenter")
		{
			if (n == consoleplayer && pmo) DoRecenter(pmo);
			return;
		}
		if (!pmo || pmo.health <= 0) return;
		if (e.Name == "rsqtr_whip") { WhipApply(pmo, e.Args[0] & 1, e.Args[1] != 0); return; }
		if (e.Name == "rsqtr_holster_off") { HolsterOff(pmo, e.Args[0]); return; }
		// RSQ Wheel's holster web (11-07): the gun's name rides in the event's name
		if (e.Name.Left(13) == "rsqtr_assign:") { WebAssign(pmo, e.Name.Mid(13), e.Args[0]); return; }
		if (e.Name.Left(15) == "rsqtr_unassign:") { WebUnassign(pmo, e.Name.Mid(15)); return; }
		if (e.Name == "rsqtr_draw_off") { DrawOff(pmo, e.Args[0]); return; }
		if (e.Name == "rsqtr_holster") Holster(pmo, e.Args[0]);
		else if (e.Name == "rsqtr_draw") Draw(pmo, e.Args[0], e.Args[1]);
		else if (e.Name == "rsqtr_nade") Nade(pmo);
		else if (e.Name == "rsqtr_throwat") throwAt[n] = (e.Args[0], e.Args[1], e.Args[2]) / 8.0;
		else if (e.Name == "rsqtr_throwv") throwVel[n] = (e.Args[0], e.Args[1], e.Args[2]) / 100.0;
		else if (e.Name == "rsqtr_throw") ThrowGun(pmo, e.Args[0] & 1);
		else if (e.Name == "rsqtr_watchmove") WatchMoveApply(pmo, e.Args[0] & 1);
	}

	// HOLSTER PROFILES (the owner, 10-27: "save up to four holster profiles"). Every place's
	// position and size, written into one of this machine's own settings (rsqtr_profile1..4) or
	// read back from it. Format: "f,l,u,rad|..." by place index (a retired index is left empty).
	// Profiles saved before 10-27 carry a fifth field, the old slot list: ignored. Index 8 is the keyring
	// (11-01); a profile saved before it has that field empty, and loading it puts the keyring at its default.
	private void Profile(Actor who, int k, bool save)
	{
		if (k < 1 || k > 4) return;
		let pc = CVar.FindCVar(String.Format("rsqtr_profile%d", k));
		if (!pc) return;
		if (save)
		{
			String txt = "";
			for (int r = 0; r < RSQTR_Region.N; r++)
			{
				if (r) txt = txt .. "|";
				if (RSQTR_Region.Retired(r)) continue;
				txt = txt .. String.Format("%.3f,%.3f,%.3f,%.3f",
					CVar.FindCVar(String.Format("rsqtr_r%d_f", r)).GetFloat(), CVar.FindCVar(String.Format("rsqtr_r%d_l", r)).GetFloat(),
					CVar.FindCVar(String.Format("rsqtr_r%d_u", r)).GetFloat(), CVar.FindCVar(String.Format("rsqtr_r%d_rad", r)).GetFloat());
			}
			pc.SetString(txt);
			CVar.FindCVar("rsqtr_profile_active").SetInt(k);
			if (who) who.A_Print(String.Format("Tactical Rig: holsters saved to %s", ProfileName(k)), 0, RSQTR_A11y.PrintFont());
			return;
		}
		String all = pc.GetString();
		if (all == "") { if (who) who.A_Print(String.Format("Tactical Rig: %s is empty -- save to it first", ProfileName(k)), 0, RSQTR_A11y.PrintFont()); return; }
		Array<String> places;
		all.Split(places, "|");
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (RSQTR_Region.Retired(r)) continue;
			Array<String> f;
			if (r < places.Size()) places[r].Split(f, ",");
			if (f.Size() < 4)
			{
				// a profile from before the keyring was a place: the keyring goes back to its default
				if (r == RSQTR_Region.KEYRING)
				{
					static const String KR[] = { "f", "l", "u", "rad" };
					for (int j = 0; j < 4; j++) CVar.FindCVar(String.Format("rsqtr_r%d_%s", r, KR[j])).ResetToDefault();
				}
				continue;
			}
			CVar.FindCVar(String.Format("rsqtr_r%d_f", r)).SetFloat(f[0].ToDouble());
			CVar.FindCVar(String.Format("rsqtr_r%d_l", r)).SetFloat(f[1].ToDouble());
			CVar.FindCVar(String.Format("rsqtr_r%d_u", r)).SetFloat(f[2].ToDouble());
			CVar.FindCVar(String.Format("rsqtr_r%d_rad", r)).SetFloat(f[3].ToDouble());
		}
		CVar.FindCVar("rsqtr_profile_active").SetInt(k);
		if (who) who.A_Print(String.Format("Tactical Rig: holsters loaded from %s", ProfileName(k)), 0, RSQTR_A11y.PrintFont());
	}

	static String ProfileName(int k)
	{
		static const String NM[] = { "Standing A (blue)", "Standing B (orange)", "Seated A (purple)", "Seated B (yellow)" };
		return NM[clamp(k, 1, 4) - 1];
	}

	// THE SIMPLE RIG (the owner, 10-27: "it's impossible to keep track what is where, everything
	// moves around"). Six gun holsters -- both hips, both sides of the chest, both shoulders -- and the two
	// saber spots.
	// A gun holster holds exactly what you put in it: any gun, one at a time, never chosen for
	// you. Grip a holster with a gun in your hand and the gun goes in (if one was there, you
	// swap: that one comes out); grip a full holster with your hand empty and you draw it; an
	// empty holster with an empty hand does nothing.
	static bool IsGunRegion(int r) { return r == 0 || r == 1 || r == 4 || r == 5 || r == 6 || r == 7; }
	static bool LockOn(PlayerInfo p) { return true; }   // assignment is always on (the option row is removed, 11-07)
	// the gun holster cls is assigned to, or -1
	int LockedTo(int n, String cls)
	{
		if (n < 0 || n >= MAXPLAYERS || cls == "" || !playeringame[n] || !LockOn(players[n])) return -1;
		for (int r = 0; r < RSQTR_Region.N; r++) if (lockCls[n * RSQTR_Region.N + r] ~== cls) return r;
		return -1;
	}
	// May gun cls (unassigned) go into gun holster r by hand? Only an unassigned, empty one (owner 07:44-07:46).
	bool MayEnter(PlayerPawn pmo, String cls, int r)
	{
		int k = pmo.PlayerNumber() * RSQTR_Region.N + r;
		if (lockCls[k] != "" && !(lockCls[k] ~== cls)) return false;
		String c = Content(pmo, r);
		return c == "" || c ~== cls;
	}
	// cls is assigned to gun holster r (and to no other)
	void Assign(int n, String cls, int r)
	{
		if (n < 0 || n >= MAXPLAYERS || cls == "" || !IsGunRegion(r)) return;
		for (int j = 0; j < RSQTR_Region.N; j++) if (lockCls[n * RSQTR_Region.N + j] ~== cls) lockCls[n * RSQTR_Region.N + j] = "";
		lockCls[n * RSQTR_Region.N + r] = cls;
	}
	// a press at a holster the gun may not enter: nothing happens but a dull tick in that hand
	private void Refused(PlayerPawn pmo, int h, String cls, int r)
	{
		if (pmo.PlayerNumber() == consoleplayer) RSQTR_Buzzer.Start(pmo, h, 0.15, 2);
		if (Flag("rsqtr_messages", pmo.player, false))
			Console.Printf("T_ASSIGN t%d: %s may not go into %s (assigned to %s, holding %s)", level.maptime, cls, RSQTR_Region.NAMES[r],
				lockCls[pmo.PlayerNumber() * RSQTR_Region.N + r], Content(pmo, r));
	}
	// THE HOLSTER WEB (RSQ Wheel, "rsqtr_assign:<gun>", Args[0] the holster): the gun is assigned to holster r and goes
	// into it at once -- out of the hand that holds it (that hand goes empty), out of any other holster. A gun r held
	// or was assigned to loses its assignment and leaves the holster (it stays in your inventory).
	private void WebAssign(PlayerPawn pmo, String cls, int r)
	{
		if (!IsGunRegion(r) || cls == "") return;
		class<Weapon> wc = cls;
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w || IsSaber(w) || RSQTR_Cig.IsProp(w) || HomeWhip(w) || w == EmptyHand(pmo)) return;
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		int base = n * RSQTR_Region.N;
		String was = lockCls[base + r];
		if (was != "" && !(was ~== cls)) lockCls[base + r] = "";
		if (lastPut[base + r] != "" && !(lastPut[base + r] ~== cls)) { lastPut[base + r] = ""; lastPair[base + r] = false; }
		for (int k = 0; k < RSQTR_Region.N; k++) if (k != r && lastPut[base + k] ~== cls) { lastPut[base + k] = ""; lastPair[base + k] = false; }
		Assign(n, cls, r);
		lastPut[base + r] = cls; lastPair[base + r] = false;
		// out of the hands
		if (p.ReadyWeapon && MainOf(HeldAs(pmo, p.ReadyWeapon)) ~== cls)
		{
			let empty = EmptyHand(pmo);
			if (empty && empty != p.ReadyWeapon) p.PendingWeapon = empty;
		}
		if (p.OffhandWeapon && MainOf(p.OffhandWeapon.GetClassName()) ~== cls) EmptyOff(pmo);
		pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
		if (Flag("rsqtr_messages", p, false))
			Console.Printf("T_ASSIGN t%d: web: %s assigned to %s and holstered there%s", level.maptime, cls, RSQTR_Region.NAMES[r],
				(was != "" && !(was ~== cls)) ? String.Format(" (%s loses it)", was) : "");
	}
	// THE WEB'S CLEAR ("rsqtr_unassign:<gun>"): no holster is assigned to the gun, and it is in none (inventory only)
	private void WebUnassign(PlayerPawn pmo, String cls)
	{
		if (cls == "") return;
		int base = pmo.PlayerNumber() * RSQTR_Region.N;
		for (int k = 0; k < RSQTR_Region.N; k++)
		{
			if (lockCls[base + k] ~== cls) lockCls[base + k] = "";
			if (IsGunRegion(k) && lastPut[base + k] ~== cls) { lastPut[base + k] = ""; lastPair[base + k] = false; }
		}
		if (Flag("rsqtr_messages", pmo.player, false)) Console.Printf("T_ASSIGN t%d: web: %s cleared (no holster)", level.maptime, cls);
	}
	// A LOCKED GUN GOES HOME. The hand holding gun cls at gun holster r, cls locked to holster home (not r): cls goes into
	// home, and r's gun (if any) comes out to that hand as a draw. A gun someone put in home meanwhile goes into r, so no
	// holstered gun is lost. Returns the gun that comes out to the hand (or null).
	private Weapon LockedHome(PlayerPawn pmo, String cls, int r, int home)
	{
		int n = pmo.PlayerNumber();
		int base = n * RSQTR_Region.N;
		String atR = Content(pmo, r);
		String atHome = lastPut[base + home];
		class<Weapon> ic = atR;
		Weapon outW = (atR != "" && !(atR ~== cls) && ic) ? Weapon(pmo.FindInventory(ic)) : null;
		for (int k = 0; k < RSQTR_Region.N; k++) if (lastPut[base + k] ~== cls) { lastPut[base + k] = ""; lastPair[base + k] = false; }
		lastPut[base + home] = cls; lastPair[base + home] = false;
		lastPut[base + r] = (atHome != "" && !(atHome ~== cls)) ? atHome : "";
		lastPair[base + r] = false;
		if (Flag("rsqtr_messages", pmo.player, false))
			Console.Printf("T_LOCK t%d: %s is locked to %s: it goes there, not to %s%s", level.maptime, cls, RSQTR_Region.NAMES[home], RSQTR_Region.NAMES[r],
				outW ? String.Format(" (%s comes out)", outW.GetClassName()) : "");
		return outW;
	}
	static bool IsSaberRegion(int r) { return r == RSQTR_Region.SABER_L || r == RSQTR_Region.SABER_R; }
	static bool IsGrenadeRegion(int r) { return r == RSQTR_Region.GRENADES; }
	// the colour of RSQ Grenade's kind in this player's hand (its "kind.colour", by name; -1 the frag or no RSQ Grenade)
	static int KindColour(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || NadeWeapon() != RSQ_GRENADE) return -1;
		let s = ServiceIterator.Find("RSQGN_Service").Next();
		return s ? s.GetInt("kind.colour", "", pmo.PlayerNumber()) : -1;
	}

	// THE GRENADE SPOT. Grip it (either hand) and the weapon pack's own hand grenade comes to the MAIN hand -- with
	// Brutal Doom VR that is its VR grenade: the off hand pulls the pin, you throw it by hand. Grip it again with the
	// grenade in the hand and the gun you had comes back. The spot shows only when the pack has a hand grenade
	// (NadeWeapon: Brutal Doom's, else RSQ Grenade's) and rsqtr_grenades is on; its light is the grenade count (green 2+, yellow 1, red none).
	// 2026-11-01: without Brutal Doom's grenade, RSQ Grenade's own (RSQGN_Grenade, its ammo RSQGN_Ammo) when that pk3
	// is loaded, handed out the same way. Brutal Doom's comes first: with Brutal Doom VR loaded RSQ Grenade stands down.
	const GRENADE_WEAPON = "HandGrenades";
	const GRENADE_AMMO = "GrenadeAmmo";
	const RSQ_GRENADE = "RSQGN_Grenade";
	const RSQ_GRENADE_AMMO = "RSQGN_Ammo";
	String nadePrev[MAXPLAYERS];
	// The hand grenade the spot hands out ("" for none), and its ammo. Looked up from Strings at run time: a const
	// or quoted class name would be resolved at compile time and fail without that pk3 ("Unknown class name").
	static String NadeWeapon()
	{
		// BD22 VR's grenade standing down for RSQ Grenade's (BD22's rsg_rsq_nade, or RSQ Grenade's rsqgn_replace_bd, with
		// RSQ Grenade's handler there): the spot hands out RSQ Grenade's grenades
		{
			String rn = RSQ_GRENADE;
			class<Weapon> rc = rn;
			String hn = "RSQGN_Handler";
			class<StaticEventHandler> hc = hn;
			let c1 = CVar.FindCVar("rsg_rsq_nade"), c2 = CVar.FindCVar("rsqgn_replace_bd");
			bool yield = (c1 && c1.GetInt() != 0) || (c2 && c2.GetInt() != 0);
			if (rc && hc && yield && (EventHandler.Find(hc) || StaticEventHandler.Find(hc))) return rn;
		}
		String wn = GRENADE_WEAPON;
		class<Weapon> wc = wn;
		if (wc) return wn;
		wn = RSQ_GRENADE;
		wc = wn;
		return wc ? wn : "";
	}
	static String NadeAmmo()
	{
		String wn = NadeWeapon();
		if (wn == GRENADE_WEAPON) return GRENADE_AMMO;
		if (wn == RSQ_GRENADE) return RSQ_GRENADE_AMMO;
		return "";
	}
	static int Grenades(PlayerPawn pmo)
	{
		String an = NadeAmmo();        // run-time, as above
		class<Inventory> ac = an;
		return ac ? pmo.CountInv(ac) : 0;
	}
	static bool HasGrenadeWeapon()
	{
		return NadeWeapon() != "";
	}
	private void Nade(PlayerPawn pmo)
	{
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		String wn = NadeWeapon();      // run-time, as above
		class<Weapon> wc = wn;
		if (!wc) return;
		let w = Weapon(pmo.FindInventory(wc));
		if (p.ReadyWeapon && p.ReadyWeapon is wc)
		{
			// back: the gun you had
			class<Weapon> pc = nadePrev[n];
			let back = pc ? Weapon(pmo.FindInventory(pc)) : null;
			if (!back) back = EmptyHand(pmo);
			if (back) p.PendingWeapon = back;
			pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.7);
			return;
		}
		if (!w || Grenades(pmo) <= 0) return;
		nadePrev[n] = p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'None';
		if (nadePrev[n] == "None") nadePrev[n] = "";
		p.PendingWeapon = w;
		drawTic[n * 2] = level.maptime + 1;
		drawClass[n * 2] = w.GetClassName();
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);	if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG grenade out t%d (had %s, %d grenades)", level.maptime, nadePrev[n], Grenades(pmo));
	}

	// THROW THE GUN AWAY (owner 2026-10-31): grip with the hand swinging fast (rsqtr_throw_speed m/s), outside every
	// holster, and the gun in that hand leaves it: it flies from the hand with the hand's speed and lands as a pickup
	// you can take again. The hand is empty after. Its holster (if it had one) forgets it.
	Vector3 throwAt[MAXPLAYERS], throwVel[MAXPLAYERS];
	private void ThrowGun(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		Weapon w = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w || (h == 0 && !HoldsGun(pmo)) || (h == 1 && !OffHoldsGun(pmo))) return;
		class<Weapon> wc = w.GetClass();
		String cls = w.GetClassName();
		int home = -1;	// BOOMERANG GUN: the holster it came from, to go back to
		for (int k = 0; k < RSQTR_Region.N; k++)
			if (lastPut[n * RSQTR_Region.N + k] == cls) { home = k; lastPut[n * RSQTR_Region.N + k] = ""; lastPair[n * RSQTR_Region.N + k] = false; }
		// the hand goes empty first, so the engine is not left holding a gun that is gone
		if (h == 0) { let empty = EmptyHand(pmo); if (empty && empty != w) p.PendingWeapon = empty; }
		else EmptyOff(pmo);
		Inventory thrown = pmo.DropInventory(w, 1);
		if (Flag("rsqtr_debug_throw", p, false)) Console.Printf("T_THROWN t%d %s", level.maptime, cls);
		if (!thrown)
		{
			// a pack that will not let it drop: the same gun as a pickup that gives no ammo, the hand's copy taken
			let g = Weapon(Actor.Spawn(wc, throwAt[n], NO_REPLACE));
			if (g) { g.AmmoGive1 = 0; g.AmmoGive2 = 0; g.bDROPPED = true; }
			thrown = g;
			if (p.ReadyWeapon == w) p.ReadyWeapon = null;
			if (p.OffhandWeapon == w) { p.SetPsprite(PSP_OFFHANDWEAPON, null); p.OffhandWeapon = null; }
			pmo.TakeInventory(wc, 1);
		}
		if (thrown)
		{
			thrown.SetOrigin(throwAt[n], false);
			thrown.vel = throwVel[n];
			thrown.angle = atan2(throwVel[n].y, throwVel[n].x);
			ArmThrown(thrown, n, home);
		}
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.9);
		if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG threw %s t%d from (%.0f %.0f %.0f) at %.1f a tic -> %s", cls, level.maptime, throwAt[n].x, throwAt[n].y, throwAt[n].z, throwVel[n].Length(), thrown ? thrown.GetClassName() : 'nothing');
	}

	// ---- A THROWN GUN HITS (owner's pick 16, 2026-10-31) -----------------------------------------------------
	// A dropped gun is a pickup: not solid, not a missile, and not our class, so the engine's own impact callback
	// (+SKULLFLY -> Slam, Quest teardown surveys/06_GRAB_INTERACTION.md 4.4) cannot be put on it. So the rig watches
	// it instead, in the sim on every machine: each tic, the path it flew last tic (WorldTick runs before the
	// thinkers move it) is tested against the bodies near it; the first live one it passes through is hit, once.
	// THE HIT, 06_GRAB 4.4's form: damage = speed^2 (units a tic) x weight x 0.2 x rsqtr_throw_damage, 1..60.
	// THE WEIGHT IS MEASURED OFF THE GUN: the area of its own pickup sprite as it lies, against Doom's shotgun
	// pickup (SHOTA0, 63 x 12 = 756 px): a pistol is about a quarter, a BFG two and a half (clamped 0.25..3).
	// THE STAGGER, 01_MELEE.md 4.7: the plain pain state forced (not Pain.Melee, which Brutal Doom turns into its
	// stealth-kill cutscene on an unaware monster), 3 tics frozen, a shove along the throw by weight and the
	// victim's mass. The gun drops off it (06_GRAB 4.4: the velocity x -0.2).
	Array<Actor>  thrownGun;
	Array<int>    thrownBy, thrownUntil, thrownFrom;
	Array<double> thrownW, thrownPX, thrownPY, thrownPZ;

	static double GunWeight(Actor g)
	{
		if (!g || !g.curstate) return 1.0;
		let tex = g.curstate.GetSpriteTexture(0);
		if (!tex.IsValid()) return 1.0;
		Vector2 sz = TexMan.GetScaledSize(tex);
		double area = sz.x * abs(g.Scale.X) * sz.y * abs(g.Scale.Y);
		return area > 0 ? clamp(area / 756.0, 0.25, 3.0) : 1.0;
	}

	// public for a probe (as RSQ Melee's Deliver is): a gun that is flying, armed to hit as a thrown one
	void ArmThrown(Actor g, int n, int home = -1)
	{
		if (!Flag("rsqtr_throw_hurt", players[n], true)) return;
		if (thrownGun.Size() >= 16) DropThrown(0);
		double w = GunWeight(g);
		thrownGun.Push(g); thrownBy.Push(n); thrownUntil.Push(level.maptime + 70); thrownW.Push(w); thrownFrom.Push(home);
		thrownPX.Push(g.pos.x); thrownPY.Push(g.pos.y); thrownPZ.Push(g.pos.z);
		if (Flag("rsqtr_debug_throw", players[n], false)) Console.Printf("T_ARMED t%d %s weight %.2f (sprite) speed %.1f a tic", level.maptime, g.GetClassName(), w, g.vel.Length());
	}

	private void DropThrown(int k)
	{
		thrownGun.Delete(k); thrownBy.Delete(k); thrownUntil.Delete(k); thrownW.Delete(k); thrownPX.Delete(k); thrownPY.Delete(k); thrownPZ.Delete(k);
		if (k < thrownFrom.Size()) thrownFrom.Delete(k);
	}

	private void ThrownTick()
	{
		for (int k = thrownGun.Size() - 1; k >= 0; k--)
		{
			let g = Inventory(thrownGun[k]);
			int n = thrownBy[k];
			Vector3 from = (thrownPX[k], thrownPY[k], thrownPZ[k]);
			if (!g || g.Owner || level.maptime > thrownUntil[k] || !playeringame[n]) { DropThrown(k); continue; }
			Vector3 to = g.pos;
			thrownPX[k] = to.x; thrownPY[k] = to.y; thrownPZ[k] = to.z;
			Vector3 d = to - from;
			double spd = d.Length();
			if (spd < 2.0) { if (g.vel.Length() < 2.0) DropThrown(k); continue; }   // landed: a gun on the floor hurts nobody
			let thrower = players[n].mo;
			Vector3 mid = from + d * 0.5;
			let it = BlockThingsIterator.CreateFromPos(mid.x, mid.y, mid.z, 0, spd * 0.5 + 64, false);
			Actor hit = null; double hitAt = 2.0;
			while (it.Next())
			{
				let t = it.thing;
				if (!t || t == g || t == thrower || !t.bShootable || t.health <= 0 || t.bMissile) continue;
				if (t.player && !deathmatch) continue;
				// the closest point of the flight to the body's axis, across the ground
				Vector2 a = t.pos.xy - from.xy;
				double dd = d.xy dot d.xy;
				double f = dd > 0 ? clamp((a dot d.xy) / dd, 0.0, 1.0) : 0.0;
				Vector3 q = from + d * f;
				if ((q.xy - t.pos.xy).Length() > t.radius + 6) continue;
				if (q.z < t.pos.z - 4 || q.z > t.pos.z + t.height + 4) continue;
				if (f < hitAt) { hitAt = f; hit = t; }
			}
			if (!hit) continue;
			double w = thrownW[k];
			// GUN TOSS (Gun Bonsai VR): the hit x1.5, 2.0, 2.5 and a stagger 10 tics a level longer
			int toss = max(Gb(players[n], 'GunToss'), 0);
			double tk = toss >= 3 ? 2.5 : toss == 2 ? 2.0 : toss == 1 ? 1.5 : 1.0;
			int dmg = int(clamp(spd * spd * w * 0.2 * Num("rsqtr_throw_damage", players[n], 1.0) * tk, 1, 60 * tk));
			int hp = hit.health;
			hit.DamageMobj(g, thrower, dmg, 'Melee');
			if (toss > 0 && hit) { let sc = ServiceIterator.Find("RS_ScoreService").Next(); if (sc) sc.GetInt("touch", "gun.toss", n, 0, hit); }
			if (hit && hit.health > 0)
			{
				hit.TriggerPainChance('None', true);
				hit.freezetics = max(hit.freezetics, 3 + 10 * toss);
				double mk = clamp(100.0 / max(hit.Mass, 1.0), 0.05, 2.0);
				if (!hit.bDontThrust && hit.Mass < 0x7FFFFFFF) hit.Thrust(clamp(spd * w * 0.5, 1.0, 10.0) * mk, atan2(d.y, d.x));
			}
			if (Flag("rsqtr_debug_throw", players[n], false))
				Console.Printf("T_HIT t%d %s hit %s at %.1f a tic, weight %.2f: dmg %d (hp %d -> %d)", level.maptime, g.GetClassName(), hit ? hit.GetClassName() : 'gone', spd, w, dmg, hp, hit ? hit.health : 0);
			g.A_StartSound("rsqtr/gunhit", CHAN_AUTO, 0, 0.8);
			// BOOMERANG GUN (Gun Bonsai VR): it flies back -- to the holster it came from (2: to your hand)
			int boom = max(Gb(players[n], 'BoomerangGun'), 0);
			if (boom > 0 && thrower) StartReturn(g, n, k < thrownFrom.Size() ? thrownFrom[k] : -1, boom);
			else g.vel *= -0.2;
			DropThrown(k);
		}
	}

	// ---- BOOMERANG GUN (Gun Bonsai VR, GBOVR_TREES.md 4.8): the way back ---------------------------------------------
	// The gun that hit flies back to its thrower (steered at his chest, no gravity, two seconds at most); arrived, it is
	// taken back: into the holster it came from or the first empty gun holster (level 1), or into the main hand (level 2).
	Array<Actor> retGun;
	Array<int>   retBy, retFrom, retLv, retUntil;
	private void StartReturn(Actor g, int n, int home, int lv)
	{
		if (!g) return;
		g.bNoGravity = true;
		retGun.Push(g); retBy.Push(n); retFrom.Push(home); retLv.Push(lv); retUntil.Push(level.maptime + 70);
		if (Flag("rsqtr_debug_throw", players[n], false)) Console.Printf("T_BOOMERANG t%d %s comes back (level %d, from holster %d)", level.maptime, g.GetClassName(), lv, home);
	}
	private void ReturnTick()
	{
		for (int k = retGun.Size() - 1; k >= 0; k--)
		{
			let g = Inventory(retGun[k]);
			int n = retBy[k];
			let pmo = playeringame[n] ? players[n].mo : null;
			if (!g || !pmo || pmo.health <= 0) { if (g) g.bNoGravity = false; DropReturn(k); continue; }
			Vector3 to = pmo.pos + (0, 0, pmo.height * 0.6);
			Vector3 d = to - g.pos;
			if (g.Owner || d.Length() < 40 || level.maptime > retUntil[k]) { Arrive(g, pmo, n, retFrom[k], retLv[k]); DropReturn(k); continue; }
			g.vel = d.Unit() * min(18.0, d.Length() * 0.4 + 6.0);
		}
	}
	private void DropReturn(int k) { retGun.Delete(k); retBy.Delete(k); retFrom.Delete(k); retLv.Delete(k); retUntil.Delete(k); }
	private void Arrive(Inventory g, PlayerPawn pmo, int n, int home, int lv)
	{
		let p = pmo.player;
		String cls = g.GetClassName();
		class<Weapon> wc = cls;
		if (!g.Owner) { g.bNoGravity = false; if (!g.CallTryPickup(pmo)) return; }
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w) return;
		if (lv >= 2) p.PendingWeapon = w;
		else
		{
			if (p.PendingWeapon == w) p.PendingWeapon = WP_NOCHANGE;	// a pickup may want to switch to it: it goes to the holster
			int r = -1;
			if (home >= 0 && IsGunRegion(home) && Content(pmo, home) == "") r = home;
			for (int k = 0; r < 0 && k < RSQTR_Region.N; k++) if (IsGunRegion(k) && Content(pmo, k) == "") r = k;
			if (r >= 0) lastPut[n * RSQTR_Region.N + r] = cls;
		}
		let sc = ServiceIterator.Find("RS_ScoreService").Next();
		if (sc) sc.GetInt("touch", "boomerang.gun", n, 0, pmo);
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.7);
		if (Flag("rsqtr_debug_throw", p, false)) Console.Printf("T_BOOMERANG t%d %s back %s", level.maptime, cls, lv >= 2 ? "in the hand" : "in a holster");
	}

	// The gun in gun holster r for player n: what was put there, while you still own it. A whip filed in a gun holster
	// before the whip holster existed (or while it was off) is not there while the whip holster is on: it is home.
	String Content(PlayerPawn pmo, int r)
	{
		if (!pmo || !IsGunRegion(r)) return "";
		String c = lastPut[pmo.PlayerNumber() * RSQTR_Region.N + r];
		if (c == "") return "";
		if (c ~== WHIP_CLASS && WhipHolsterOn(pmo.player)) return "";
		class<Weapon> wc = c;
		return (wc && pmo.FindInventory(wc)) ? c : "";
	}

	// THE WHIP HOLSTER'S ACTION (every machine, from the network event): put the whip away from hand h, or draw it into h.
	private void WhipApply(PlayerPawn pmo, int h, bool draw)
	{
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		let w = WhipOf(pmo);
		if (!w || !WhipHolsterOn(p)) return;
		bool dbg = Flag("rsqtr_messages", p, false);
		if (!draw)
		{
			if (h == 0 && p.ReadyWeapon == w)
			{
				let empty = EmptyHand(pmo);
				if (empty && empty != w) p.PendingWeapon = empty;
			}
			else if (h == 1 && p.OffhandWeapon == w) EmptyOff(pmo);
			else return;
			pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
			if (dbg) Console.Printf("T_RIG whip holster t%d: the whip goes home from the %s hand", level.maptime, h ? "off" : "main");
			return;
		}
		if (p.ReadyWeapon == w || p.OffhandWeapon == w) return;
		if (h == 0) { w.bOffhandWeapon = false; p.PendingWeapon = w; }
		else { w.bOffhandWeapon = true; QueueOff(n, WHIP_CLASS); }
		drawTic[n * 2 + h] = level.maptime + 1;
		drawClass[n * 2 + h] = w.GetClassName();
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
		if (dbg) Console.Printf("T_RIG whip holster t%d: the whip drawn into the %s hand", level.maptime, h ? "off" : "main");
	}

	// A real gun in the main hand: not the empty hand (fists / BD22Q's hands), not a saber.
	static bool HoldsGun(PlayerPawn pmo)
	{
		let w = pmo.player.ReadyWeapon;
		if (!w || IsSaber(w) || RSQTR_Cig.IsProp(w)) return false;    // the cigarette is no gun (never thrown, never holstered)
		if (HomeWhip(w)) return false;                                 // the whip has its own holster
		let empty = EmptyHand(pmo);
		return w != empty;
	}

	// A GUN IN THE OFF HAND, put there by the engine's own switchhand (the owner's "move weapon to
	// off hand" button): a weapon whose class is NOT an off-hand weapon by default. Off-hand-only
	// things -- Brutal Doom Quest's hands and its Dual copies, the saber's second hilt, the shield --
	// are not guns the rig moves (Dual is its own key).
	static bool IsMovedGun(Weapon w)
	{
		if (!w || IsSaber(w) || RSQTR_Cig.IsProp(w) || HomeWhip(w)) return false;
		// BD22 VR's off-hand version of a gun (2.0.3y: it passes between hands, BD22 turns it into the right version
		// in each hand) is a gun the rig moves, filed under its gun's name (MainOf)
		String cn = w.GetClassName();
		if (!(MainOf(cn) ~== cn)) return true;
		let d = GetDefaultByType(w.GetClass());
		return d && !d.bOffhandWeapon;
	}

	// The main-hand gun a BD22 VR off-hand version belongs to, asked by name (RSQ_BD22OffhandService "main.of"): the class
	// itself for anything else, and without BD22 VR.
	static String MainOf(String cls)
	{
		let sv = ServiceIterator.Find("RSQ_BD22OffhandService").Next();
		if (!sv || cls == "") return cls;
		String m = sv.GetString("main.of", cls);
		return m != "" ? m : cls;
	}

	static bool OffHoldsGun(PlayerPawn pmo) { return IsMovedGun(pmo.player.OffhandWeapon); }

	// The off hand goes empty: Brutal Doom Quest's hands if it has them, else nothing.
	private void EmptyOff(PlayerPawn pmo)
	{
		let p = pmo.player;
		String en = OffEmptyName(pmo);
		if (en != "") { QueueOff(pmo.PlayerNumber(), en); return; }
		p.SetPsprite(PSP_OFFHANDWEAPON, null);
		p.OffhandWeapon = null;
	}

	// The OFF hand's gun onto holster r (a full one swaps: its gun comes to the off hand).
	private void HolsterOff(PlayerPawn pmo, int r)
	{
		if (!IsGunRegion(r)) return;
		let p = pmo.player;
		let w = p.OffhandWeapon;
		if (!IsMovedGun(w)) return;
		int n = pmo.PlayerNumber();
		String cls = MainOf(w.GetClassName());     // BD22 VR's off-hand version goes in under its gun's name
		int lockHome = LockedTo(n, cls);
		if (lockHome < 0 && !MayEnter(pmo, cls, r)) { Refused(pmo, 1, cls, r); return; }
		if (lockHome >= 0 && lockHome != r)
		{
			let outW = LockedHome(pmo, cls, r, lockHome);
			if (outW && outW != p.ReadyWeapon) { outW.bOffhandWeapon = true; QueueOff(n, outW.GetClassName()); }
			else EmptyOff(pmo);
			pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
			return;
		}
		String was = Content(pmo, r);
		for (int k = 0; k < RSQTR_Region.N; k++)
			if (k != r && lastPut[n * RSQTR_Region.N + k] == cls) lastPut[n * RSQTR_Region.N + k] = "";
		lastPut[n * RSQTR_Region.N + r] = cls;
		lastPair[n * RSQTR_Region.N + r] = false;
		Assign(n, cls, r);
		class<Weapon> ic = was;
		let incoming = (was != "" && was != cls && ic) ? Weapon(pmo.FindInventory(ic)) : null;
		if (incoming && incoming != p.ReadyWeapon)
		{
			incoming.bOffhandWeapon = true;
			QueueOff(n, was);
		}
		else EmptyOff(pmo);
		pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// Holster r's gun into the OFF hand.
	private void DrawOff(PlayerPawn pmo, int r)
	{
		let p = pmo.player;
		String c = Content(pmo, r);
		if (c == "") return;
		class<Weapon> wc = c;
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w || w == p.ReadyWeapon) return;
		w.bOffhandWeapon = true;
		lastPut[pmo.PlayerNumber() * RSQTR_Region.N + r] = "";
		QueueOff(pmo.PlayerNumber(), c);
		drawTic[pmo.PlayerNumber() * 2 + 1] = level.maptime + 1;   // the off hand's draw, for a scorer
		drawClass[pmo.PlayerNumber() * 2 + 1] = w.GetClassName();
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// ---- MOVE A GUN TO THE OTHER HAND AT THE WATCH CHECK (owner 2026-11-01, rsqtr_watch_move, off by default) ----
	// "use during watch check, as a toggle on off option". While a hand's watch check is held (RSQ Gestures' "inspect"
	// answer 2, the one that brings up RSQ_GunCards' watch card), a Use press (the BT_USE edge) moves the gun in THAT
	// hand to the other hand; a movable gun in the other hand comes back (a swap). A hand left empty gets its empty-hand
	// weapon (EmptyHand / OffEmptyName).
	// WHO READS THE WATCH CHECK (owner 2026-11-04 19:45: every mod's standout works without RSQ Gestures): RSQ Gestures
	// when it is loaded (RSQG_Service, as before); else RSQ Gun Cards' own copy of that reader (RSQGC_GCopyService, by
	// name: the same reader the watch card shows from); else the Rig's own copy (gestcopy.zs). One reader at a time, the
	// same pose and numbers in all three (tools/gestcopy).
	// The holsters' rules: sabers, the ShieldSaw, the cigarette and Zippo, fists / the empty hands and Brutal
	// Doom's off-hand dual copies (RSQ_Off_*) never move, and a hand holding one blocks the move; Brutal Doom's
	// Dual (DualPistols ...) stays on BD's own key. A hand inside a holster (or the keyring in edit mode) keeps
	// Use for the holster: no move while either hand is in one. A Bossfight ready to call (RSQ Miniboss) keeps Use for its
	// call-in: no move while it would take the press (BossfightCallReady).
	// Not into the off hand while the engine's two-hand latch is on (WF_TWOHANDSTABILIZED: an off-hand weapon
	// raised then arrives invisible, apply/07_WHEEL.md 4; TickPairs' note).
	const WATCH_GRACE = 8;                   // tics after the watch check lets go that a Use press still counts (a thumb on a button can tip the wrist)
	private transient int watchTic[2];       // level.maptime + 1 when that hand's watch check was last held (GestureInspect)

	static int GestureInspect(PlayerPawn pmo, int h)
	{
		let it = ServiceIterator.Find("RSQG_Service");
		Service s;
		while (s = it.Next()) return s.GetInt("inspect", "", h, 0, pmo);
		// no RSQ Gestures: RSQ Gun Cards' copy, then our own (-1 from either: it stands down, ask the next)
		it = ServiceIterator.Find("RSQGC_GCopyService");
		while (s = it.Next()) { int g = s.GetInt("inspect", "", h, 0, pmo); if (g >= 0) return g; }
		let own = RSQTR_GCopy.Get();
		return own ? own.Inspect(pmo.PlayerNumber(), h) : -1;
	}

	// RSQ Miniboss's call-in would take a watch check + Use press now (RSQMB_Service "callin", by name; 0 without Miniboss)
	static bool BossfightCallReady(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQMB_Service");
		Service s;
		while (s = it.Next()) if (s.GetInt("callin", "", 0, 0, pmo) == 1) return true;
		return false;
	}

	// What a hand holds, for the move: 0 empty (its empty-hand weapon or nothing), 1 a gun that may move, 2 anything else.
	static int HandKind(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		if (h == 0)
		{
			let w = p.ReadyWeapon;
			if (!w || w == EmptyHand(pmo)) return 0;
			if (w is "RSQTR_CigWeapon" || !IsMovedGun(w)) return 2;
			return HeldAs(pmo, w) == w.GetClassName() ? 1 : 2;    // a BD Dual (filed as its single gun) stays on BD's key
		}
		let o = p.OffhandWeapon;
		if (!o) return 0;
		String on = o.GetClassName();
		String en = OffEmptyName(pmo);
		if (en != "" && on ~== en) return 0;     // (BD22 VR Reloaded's class reads back as "rsq_hands")
		return IsMovedGun(o) ? 1 : 2;
	}

	bool CanWatchMove(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		if (p.PendingWeapon != WP_NOCHANGE || offNext[n] != "") return false;    // a switch already under way
		let cig = RSQTR_Cig.Get();
		if (cig && cig.phase[n] != RSQTR_Cig.PH_NONE) return false;
		int mine = HandKind(pmo, h), other = HandKind(pmo, 1 - h);
		if (mine != 1 || other == 2) return false;
		bool latched = (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
		if (latched && (h == 0 || other == 1)) return false;               // that would put a gun into the off hand
		if (h == 0 && other == 0 && !EmptyHand(pmo)) return false;         // nothing for the main hand to hold
		return true;
	}

	// this machine: is a watch check up, and was Use pressed?
	private void WatchMove(PlayerPawn pmo, PlayerInfo p, bool useEdge)
	{
		if (!Flag("rsqtr_watch_move", p, false)) { watchTic[0] = 0; watchTic[1] = 0; return; }
		for (int h = 0; h < 2; h++) if (GestureInspect(pmo, h) >= 2) watchTic[h] = level.maptime + 1;
		if (!useEdge || Flag("rsqtr_edit", p, false)) return;
		if (hoverR[0] >= 0 || hoverR[1] >= 0) return;          // a hand in a holster: Use is the holster's
		int h = -1;
		for (int k = 0; k < 2 && h < 0; k++)
		{
			int ago = level.maptime + 1 - watchTic[k];
			if (watchTic[k] > 0 && ago >= 0 && ago <= WATCH_GRACE) h = k;
		}
		if (h < 0) return;
		// A BOSSFIGHT READY TO CALL TAKES THE PRESS (owner 11-05: "Calling a Bossfight must never also move the gun"): RSQ
		// Miniboss calls a full meter's Bossfight in on the same watch check + Use. While its call-in would take this press
		// (RSQMB_Service "callin", by name: the meter full, not yet called, Call It In on) the press is the call-in's and the
		// gun stays; otherwise (no Miniboss, the meter not full) the press is ours as before.
		if (BossfightCallReady(pmo))
		{
			if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG watch move hand %d t%d: skipped, the press calls the Bossfight in (RSQ Miniboss)", h, level.maptime);
			watchTic[0] = 0; watchTic[1] = 0;
			return;
		}
		if (!CanWatchMove(pmo, h))
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG watch move hand %d t%d: refused (%s / %s)", h, level.maptime,
				p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
			return;
		}
		EventHandler.SendNetworkEvent("rsqtr_watchmove", h);
		RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
		RSQTR_Buzzer.Start(pmo, 1 - h, 0.65, 6);
		watchTic[0] = 0; watchTic[1] = 0;
	}

	// every machine
	private void WatchMoveApply(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		if (!Flag("rsqtr_watch_move", p, false) || !CanWatchMove(pmo, h)) return;
		let mainW = p.ReadyWeapon, offW = p.OffhandWeapon;
		bool swap = HandKind(pmo, 1 - h) == 1;
		String toOff;
		if (h == 0 && !swap)
		{
			// the main hand's gun across; the main hand goes empty
			p.PendingWeapon = EmptyHand(pmo);
			toOff = mainW.GetClassName();
		}
		else
		{
			// the off hand's gun comes to the main hand (h 1, or the other half of a swap)
			p.SetPsprite(PSP_OFFHANDWEAPON, null);
			p.OffhandWeapon = null;
			offW.bOffhandWeapon = false;
			p.PendingWeapon = offW;
			if (swap) toOff = mainW.GetClassName();
			else toOff = OffEmptyName(pmo);
		}
		// into the off hand once the main hand has switched (TickPairs flips a gun to an off-hand weapon there)
		if (toOff != "") QueueOff(n, toOff);
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
		if (Flag("rsqtr_messages", p, false))
			Console.Printf("T_RIG watch move hand %d t%d: %s -> main, %s -> off", h, level.maptime,
				p.PendingWeapon ? p.PendingWeapon.GetClassName() : 'none', toOff == "" ? "(nothing)" : toOff);
	}

	// Put the main hand's weapon on the body at region r. On a gun holster that already holds
	// a gun, the two swap.
	private void Holster(PlayerPawn pmo, int r)
	{
		if (r < 0 || r >= RSQTR_Region.N) return;
		let p = pmo.player;
		let w = p.ReadyWeapon;
		if (!w) return;
		String cls = HeldAs(pmo, w);
		int n = pmo.PlayerNumber();
		Weapon incoming = null;
		// BRUTAL DOOM'S COMBINED DUAL (BD22's DualPistols and kin: one weapon that is two guns; selecting it takes the
		// single gun out of the inventory, DualPistol.dec Select) GOES IN AS ONE GUN (the owner, 11-02: "storing a weapon
		// for which i have two of ... causes me to instantly equip them both when i unholster just one"). The holster
		// keeps the single gun, given back as BD22's own switch to single does (DualPistol.dec gives BrutalPistol), so
		// drawing gives one; BD22's single Select takes the Dual item away itself, and its HasDual token stays for the Dual key.
		if (IsGunRegion(r) && HoldsGun(pmo))
		{
			String single = SingleOf(pmo, cls);
			if (single != "" && single != cls)
			{
				class<Weapon> sc = single;
				if (sc && !pmo.FindInventory(sc))
				{
					let g = Weapon(Actor.Spawn(sc, pmo.pos, NO_REPLACE));
					if (g) { g.AmmoGive1 = 0; g.AmmoGive2 = 0; if (!g.CallTryPickup(pmo)) g.Destroy(); }
				}
				if (sc && pmo.FindInventory(sc))
				{
					if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG holster t%d: %s (Brutal Doom's two-gun weapon) goes in as one %s", level.maptime, cls, single);
					cls = single;
				}
			}
		}
		int lockHome = IsGunRegion(r) && HoldsGun(pmo) ? LockedTo(n, cls) : -1;
		// ASSIGNMENT (11-07): an unassigned gun enters only an unassigned, empty holster (and is assigned to it)
		if (lockHome < 0 && IsGunRegion(r) && HoldsGun(pmo) && !MayEnter(pmo, cls, r)) { Refused(pmo, 0, cls, r); return; }
		if (lockHome >= 0 && lockHome != r)
		{
			incoming = LockedHome(pmo, cls, r, lockHome);
			if (incoming && incoming != w)
			{
				if (IsMovedGun(incoming)) incoming.bOffhandWeapon = false;
				p.PendingWeapon = incoming;
				drawTic[n * 2] = level.maptime + 1;
				drawClass[n * 2] = incoming.GetClassName();
				pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
			}
			else
			{
				let empty = EmptyHand(pmo);
				if (empty && empty != w) p.PendingWeapon = empty;
			}
			pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
			return;
		}
		if (IsSaberRegion(r))
		{
			Array<String> own;
			Owned(pmo, r, own);
			if (own.Find(cls) == own.Size()) return;
		}
		else
		{
			if (!IsGunRegion(r) || !HoldsGun(pmo)) return;
			String was = Content(pmo, r);
			if (was != "" && was != cls)
			{
				class<Weapon> ic = was;
				incoming = ic ? Weapon(pmo.FindInventory(ic)) : null;
			}
			// one gun, one place: put here, it leaves wherever else it was
			for (int k = 0; k < RSQTR_Region.N; k++)
				if (k != r && lastPut[n * RSQTR_Region.N + k] == cls) { lastPut[n * RSQTR_Region.N + k] = ""; lastPair[n * RSQTR_Region.N + k] = false; }
		}
		int slot = n * RSQTR_Region.N + r;
		lastPut[slot] = cls;
		if (IsGunRegion(r)) Assign(n, cls, r);
		// ONE GUN IN, ONE GUN OUT (11-02; Dual is its own key, the owner 10-27): the off hand is never touched here. Its
		// copy of the gun (BD22 VR's RSQ_Off_<gun>) stays in the off hand if it is there.
		let off = p.OffhandWeapon;
		class<Weapon> wc = cls;
		lastPair[slot] = off && wc && off is wc && off.GetClass() != wc;    // kept for the profiles' format only
		if (incoming)
		{
			if (IsMovedGun(incoming)) incoming.bOffhandWeapon = false;
			p.PendingWeapon = incoming;
			drawTic[n * 2] = level.maptime + 1;
			drawClass[n * 2] = incoming.GetClassName();
			pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);   // a swap: the draw as well
		}
		else
		{
			let empty = EmptyHand(pmo);
			if (empty && empty != w) p.PendingWeapon = empty;
		}
		pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// Draw from region r: a gun holster's one gun, or (a saber spot) the saber.
	private void Draw(PlayerPawn pmo, int r, int idx)
	{
		if (r < 0 || r >= RSQTR_Region.N) return;
		let p = pmo.player;
		int n = pmo.PlayerNumber();
		int slot = n * RSQTR_Region.N + r;
		class<Weapon> wc = null;
		if (IsGunRegion(r))
		{
			String c = Content(pmo, r);
			if (c == "") return;
			wc = c;
		}
		else
		{
			Array<String> own;
			Owned(pmo, r, own);
			if (idx < 0 || idx >= own.Size()) return;
			wc = own[idx];
		}
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w) return;
		if (IsSaber(w) && IsSecondSaber(w)) return;     // the saber moves its own second hilt (Press)
		if (w == p.OffhandWeapon) return;               // already in the other hand
		if (IsMovedGun(w)) w.bOffhandWeapon = false;
		if (p.ReadyWeapon != w) p.PendingWeapon = w;
		// ONE GUN, IN THE HAND THAT DREW IT (the owner, 11-02: "storing a weapon for which i have two of ... causes me to
		// instantly equip them both when i unholster just one, this is a problem"). The off-hand copy is never brought
		// along: Dual is its own key (the owner, 10-27). The Draw Pairs row (rsqtr_pairs) that did so is retired.
		if (IsGunRegion(r)) { lastPut[slot] = ""; lastPair[slot] = false; }
		drawTic[n * 2] = level.maptime + 1;
		drawClass[n * 2] = w.GetClassName();
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// The gun's own off-hand copy, if the player has one: a weapon flagged OFFHANDWEAPON that
	// is a subclass of it (BD22Q's RSQ_Off_<gun>). Found by inheritance, not by name.
	static Weapon OffCopy(PlayerPawn pmo, class<Weapon> wc)
	{
		if (!pmo || !wc) return null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (w && w.bOffhandWeapon && w is wc && w.GetClass() != wc) return w;
		}
		return null;
	}

	// The single gun of Brutal Doom's combined two-gun weapon ("DualPistols" -> "BrutalPistol"), or "" if cls is not one.
	// Found, not named: the parent of an off-hand copy you own whose name ends the same way (BD22 VR's RSQ_Off_<gun>),
	// else a weapon class (not a copy, not CHEATNOTWEAPON) whose name ends in the Dual name's stem.
	static String SingleOf(PlayerPawn pmo, String cls)
	{
		String low = cls.MakeLower();
		if (low.IndexOf("dual") != 0) return "";
		String stem = low.Mid(4);
		if (stem.Length() > 1 && stem.Mid(stem.Length() - 1) == "s") stem = stem.Left(stem.Length() - 1);
		if (stem.Length() < 3) return "";
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || !w.bOffhandWeapon) continue;
			class<Weapon> pc = (class<Weapon>)(w.GetParentClass());
			if (!pc) continue;
			String pn = pc.GetClassName(); String pl = pn.MakeLower();
			if (pl.IndexOf("dual") != 0 && pl.Length() >= stem.Length() && pl.Mid(pl.Length() - stem.Length()) == stem) return pn;
		}
		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			class<Weapon> c = (class<Weapon>)(AllActorClasses[i]);
			if (!c) continue;
			let d = GetDefaultByType(c);
			if (!d || d.bOffhandWeapon || d.bCHEATNOTWEAPON) continue;
			String cn = c.GetClassName(); String cl = cn.MakeLower();
			if (cl.IndexOf("dual") == 0 || cl.Length() < stem.Length() || cl.Mid(cl.Length() - stem.Length()) != stem) continue;
			return cn;
		}
		return "";
	}

	// What the off hand holds when it is empty: the pack's own hands weapon (BD22Q's RSQ_Hands).
	static String OffEmptyName(PlayerPawn pmo)
	{
		String hn = "RSQ_Hands";        // a run-time lookup: null without Brutal Doom Quest
		class<Weapon> h = hn;
		return h ? hn : "";
	}

	void QueueOff(int n, String cls)     // (cig.zs: the Zippo into the off hand, and back)
	{
		if (cls == "") return;
		offNext[n] = cls;
		offWait[n] = 70;
	}

	// Once the main hand has finished switching, raise the queued weapon into the off hand
	// (an OFFHANDWEAPON raised through PendingWeapon goes to the off hand, as BD22Q's Dual key
	// does it). Every player, every tic: this is the playsim, not the local look.
	private void TickPairs()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (offNext[n] == "") continue;
			let p = players[n];
			if (!playeringame[n] || !p.mo || p.mo.health <= 0) { offNext[n] = ""; continue; }
			// WHILE THE ENGINE IS STEADYING THE GUN, THE OFF HAND CANNOT HOLD ANYTHING: WAIT.
			//
			// The holster still wins the press -- that is the owner's rule of 10-29 and it is
			// untouched here; only the RAISE waits. With vr_two_handed_weapons on (default
			// true, hw_vrmodes.cpp:119) the off-hand grip pressed with the hands inside 0.50 m
			// latches weaponStabilised on the grip's rising edge (gl_openvr.cpp:1716-1727) --
			// and that is the same edge the rig acts on, with the two shipped hips 0.36 m apart
			// (CVARINFO.txt:34-35, rsqtr_r0_l / rsqtr_r1_l at +-0.18), so a cross-draw is in the
			// window. A weapon raised into the off hand then fires nothing (player.zs:393-396,
			// :426), answers no button (p_pspr.cpp:755-757) and is not drawn at all (sprites
			// hw_weapon.cpp:832-835, models :917-920): the player hears the draw, feels the
			// buzz, and gets an empty hand for as long as the grip is held.
			//
			// So hold the queued gun rather than hand over a dead one, and do NOT run offWait
			// down while holding: release clears the latch with no distance test
			// (gl_openvr.cpp:1724-1726), so the wait is however long the grip is held, which
			// for a player who holds grip to keep hold of a gun is the rest of the fight. The
			// gun arrives on release. Nothing is leaked by waiting: the next QueueOff replaces
			// it, and death or a level change clears it above.
			//
			// NOT a distance test of our own (that was the pre-10-29 guard): once latched the
			// engine ignores distance entirely, so a geometric guard lets go before the engine
			// does. NOT by clearing the flag either -- p_pspr.cpp:512-515 re-asserts it from
			// the C++ global on every psprite state set. Only gl_openvr.cpp:1723 / :1726 write
			// weaponStabilised in this tree, so this holds on OpenVR/SteamVR and never fires
			// on Quest/OpenXR.
			if ((p.WeaponState & WF_TWOHANDSTABILIZED) != 0)
			{
				if (!offHeldSaid[n])
				{
					offHeldSaid[n] = true;
					if (n == consoleplayer && Flag("rsqtr_messages", p, false))
						p.mo.A_Print("Off hand is steadying the gun: the draw waits for the grip", 0, RSQTR_A11y.PrintFont());
				}
				continue;
			}
			offHeldSaid[n] = false;
			if (--offWait[n] <= 0) { offNext[n] = ""; continue; }
			if (p.PendingWeapon != WP_NOCHANGE) continue;          // the main hand is still switching
			class<Weapon> c = offNext[n];
			offNext[n] = "";
			if (!c) continue;
			let w = Weapon(p.mo.FindInventory(c));
			if (!w) { p.mo.GiveInventory(c, 1); w = Weapon(p.mo.FindInventory(c)); }
			// a gun that is not an off-hand weapon by default goes to the off hand flagged as one (the flip the
			// holsters make in HolsterOff / DrawOff); done here, once the main hand has let go of it, for a gun
			// moved across at the watch check (WatchMoveApply)
			if (w && IsMovedGun(w) && w != p.ReadyWeapon) w.bOffhandWeapon = true;
			if (w && p.OffhandWeapon != w) p.PendingWeapon = w;
		}
	}

	// ---- the local loop (console player) ----------------------------------------------
	override void WorldTick()
	{
		for (int gn = 0; gn < MAXPLAYERS; gn++) GbRefresh(gn);
		ThrownTick();
		ReturnTick();
		TickPairs();
		TickLoadout();
		if (afterLoad) { afterLoad = false; ClearLocalMarks(); }
		if (!migrated) { migrated = true; MigratePlaces(); }
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		if (!body) body = new("RSQTR_Body");
		body.Update(pmo);

		// NOT IN VR, NO RIG (Quest teardown, apply/06 1.9): without OverrideAttackPosDir the hand fields are not the
		// controllers -- both collapse to one point -- and a hand "in" a holster there held the rig busy for good,
		// standing every other mod's grip down with it.
		bool on = pmo.health > 0 && Flag("rsqtr_on", p, true) && pmo.OverrideAttackPosDir;
		rigLive = on;
		if (!on) { HideAll(); return; }

		int n = consoleplayer;
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		bool useEdge = useDown && !useWas;
		// WHILE THE CIGARETTE IS OUT, USE IS ITS (cig.zs): no holster, no watch move on a Use press
		bool usePress = Flag("rsqtr_use", p, true) && !RSQTR_Cig.IsOut(n);
		bool gripOk = Flag("rsqtr_grip", p, true);
		bool editing = Flag("rsqtr_edit", p, false);

		for (int h = 0; h < 2; h++)
		{
			if (buzzCool[h] > 0) buzzCool[h]--;
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			int r = -1;
			double best = 1e9;
			for (int i = 0; i < RSQTR_Region.N; i++)
			{
				if (!RegionLive(pmo, i)) continue;
				// THE KEYRING IS NO HOLSTER: a hand there is the rig's only to carry it in edit mode. Its grip
				// (keys to a door) is keyring.zs's own, as before it was a place.
				if (i == RSQTR_Region.KEYRING && !editing) continue;
				double d = RSQTR_Body.RoomMetres(hp, RegionAt(pmo, i));
				if (d <= RegionRadius(p, i) && d < best) { best = d; r = i; }
			}
			// A HAND GRIPPING IN A HOLSTER COMES FIRST (the owner, 10-29: "when hands are gripping in
			// holsters they should take precedent over everything"). Until 10-29 an off hand within
			// half a metre of the gun with grip held was read as the engine's two-hand steadying and
			// the holster was ignored; now the holster wins. Other mods yield through "rig.busy".
			if (r != hoverR[h])
			{
				if (r >= 0 && buzzCool[h] <= 0) { RSQTR_Buzzer.Start(pmo, h, 0.18, 3); buzzCool[h] = 10; }
				hoverR[h] = r;
				hoverT[h] = 0;
				pendPress[h] = false;
			}
			else if (r >= 0) hoverT[h]++;

			bool gripNow = gripOk && gripDown[n * 2 + h];
			bool pressNow = gripNow || (usePress && useDown && (h == 0 || hoverR[0] < 0));
			bool edge = pressNow && !pressWas[h] && (gripNow || useEdge);
			// THROW THE GUN: the grip pressed (not Use) with the hand swinging fast, outside every holster
			// THE ARM'S OWN SWING, NOT THE BODY'S (Quest teardown 00 1.3 / gotcha 6; the ShieldSaw's pose.zs fix): the
			// hand differenced in the body's frame -- relative to the pawn, turned back by its yaw -- so walking, running
			// and snap turns are no swing, and the throw is the FASTEST 2-tic window of the last six, not the release
			// tic, when the arm is already slowing. Turned back to where you face now; the run is added on top.
			double handMs; Vector3 handV;
			[handMs, handV] = SwingPeak(pmo, h, hp);
			if (h == 0 && Flag("rsqtr_debug_throw", p, false)) Console.Printf("T_SWING t%d hand %.1f %.1f %.1f pawn %.1f %.1f peak %.2f grip %d", level.maptime, hp.x, hp.y, hp.z, pmo.Pos.x, pmo.Pos.y, handMs, gripOk && gripDown[n * 2 + h]);
			// (a main-hand grip at the mouth with an unlit cigarette in it is the cigarette's pull, cig.zs, never a throw; nor is
			// a main-hand press at the cigarette pocket, which takes one: 4fb3b1ca9's throw on Use threw the gun in the hand
			// there, rig 11-03, T_THROWN on the same tic as the take)
			// THE MAIN HAND THROWS ON USE TOO (owner, 11-03: its grip is the gun's own, so the swing-and-grip throw was the off
			// hand's in practice): a Use press with the same fast swing, outside every holster (rsqtr_throw_use). The off hand
			// throws on its grip as before. Use while the cigarette is out is the cigarette's (usePress is false then).
			bool throwPress = (gripNow && !pressWas[h]) || (h == 0 && useEdge && usePress && Flag("rsqtr_throw_use", p, true));
			if (throwPress && r < 0 && Flag("rsqtr_throw", p, true) && handMs >= Num("rsqtr_throw_speed", p, 2.5) && handMs < 20
				&& (h == 0 ? HoldsGun(pmo) : OffHoldsGun(pmo)) && !(h == 0 && (RSQTR_Cig.PullAtMouth(pmo) || RSQTR_Cig.AtPocket(pmo))))
			{
				Vector3 tv = handV * 1.6 + pmo.Vel;   // a throw carries on a little faster than the hand, and with you
				EventHandler.SendNetworkEvent("rsqtr_throwat", int(hp.x * 8), int(hp.y * 8), int(hp.z * 8));
				EventHandler.SendNetworkEvent("rsqtr_throwv", int(tv.x * 100), int(tv.y * 100), int(tv.z * 100));
				EventHandler.SendNetworkEvent("rsqtr_throw", h);
				RSQTR_Buzzer.Start(pmo, h, 0.5, 4);
				pressWas[h] = pressNow;
				continue;
			}
			bool release = !pressNow && pressWas[h];
			pressWas[h] = pressNow;

			// EDIT MODE (rsqtr_edit): grip in a region carries it with the hand; let go
			// and it stays there, saved to that region's settings.
			if (editing)
			{
				if (editHand == h)
				{
					editAt = hp;
					if (release) { SaveEdit(pmo, p); RSQTR_Buzzer.Start(pmo, h, 0.5, 5); }
				}
				else if (edge && r >= 0 && editHand < 0)
				{
					editHand = h; editRegion = r; editAt = hp;
					RSQTR_Buzzer.Start(pmo, h, 0.4, 4);
				}
				continue;
			}
			else if (editHand >= 0) editHand = -1;

			// A hand passing through a region does not act on it: the press counts once
			// the hand has been there rsqtr_dwell tics (a press a moment early waits).
			int dwell = Opt("rsqtr_dwell", p, 3);
			// QUICK SWAP (owner 2026-10-31): a gun in the hand at a full holster swaps at once, no wait
			if (r >= 0 && IsGunRegion(r) && Flag("rsqtr_quickswap", p, true) && Content(pmo, r) != ""
				&& (h == 0 ? HoldsGun(pmo) : OffHoldsGun(pmo))) dwell = 0;
			if (edge && r >= 0) pendPress[h] = true;
			if (!pressNow) pendPress[h] = false;
			if (pendPress[h] && r >= 0 && hoverT[h] >= dwell) { pendPress[h] = false; Press(pmo, p, h, r, hp); }
		}
		// after the holsters: a Use press with a hand in a holster was the holster's (WatchMove stands down)
		WatchMove(pmo, p, useEdge);
		useWas = useDown;
		RecenterTick(pmo, p, n);
		DrawMarkers(pmo, p);
	}

	// ---- RECENTER (the owner's choice, 11-03 18:56: "Stick turns + recenter") ---------------------------------------
	// The torso turns only with snap and smooth turns (body.zs), so after a real turn in the room it is put back in
	// front of you by hand: BOTH HANDS TO THE CHEST (rsqtr_recenter_hands, on), both controllers held against your
	// chest for REC_HOLD tics, or the bound key "Recenter Torso" (rsqtr_recenter). Either turns the torso to where your
	// head faces (yaw only), with a soft click and a short tick in both hands. On its own, silently, at map start, a
	// level change and a loaded save (the body is this level's and transient: a new one starts facing the head) and at
	// a respawn (PlayerRespawned).
	// THE POSE, in the HEAD's frame from your live eyes (RSQTR_Body.HeadLocal), room metres: each controller within
	// REC_RAD of the chest point REC_F forward, on the centre line, REC_U down. Measured on the rig (turnprobe, 11-03):
	// controllers held against the sternum (0.12 m in front of and 0.30 m under the eyes, 0.07 m either side of the
	// centre) read 0.12 forward, +-0.07 left, -0.30 up. The ready pose (0.25 to the side, 0.30 forward, 0.30 down) is
	// 0.31 m out; hands at the hips 0.4 m out.
	// IT CANNOT FIRE WHILE DRAWING FROM A CHEST HOLSTER: it wants BOTH hands there, no grip held (rsqtr_grip's keys)
	// and no Use or fire button, and (with the torso within REC_NEAR of the head) neither hand inside any holster, all
	// for the whole hold; and once it fired, a hand must leave the pose before it can fire again.
	const REC_F = 0.12;
	const REC_U = -0.30;
	const REC_RAD = 0.20;
	const REC_HOLD = 14;      // tics (0.4 s)
	const REC_NEAR = 20.0;    // degrees: a torso this close to the head's facing has its holsters in place (below)
	private transient int recFor;
	private transient bool recDone;
	transient double recGap[2];       // each hand's distance from the chest point, metres (the turn probe reads it)

	void RecenterTick(PlayerPawn pmo, PlayerInfo p, int n)
	{
		bool inPose = true;
		for (int h = 0; h < 2; h++)
		{
			Vector3 l = RSQTR_Body.HeadLocal(pmo, RSQTR_Body.Hand(pmo, h));
			recGap[h] = (l.x - REC_F, l.y, l.z - REC_U).Length();
			if (recGap[h] > REC_RAD) inPose = false;
		}
		if (!inPose) { recFor = 0; recDone = false; return; }
		int bt = p.cmd.buttons;
		// a hand in a holster counts only while the torso already faces within REC_NEAR of the head: then the holsters are
		// where they belong and a hand at one is drawing (and a recenter would move nothing anyway); with the torso turned
		// away they hang somewhere else, and measured on the rig (turnprobe, 11-03) the off hand at the chest was in the
		// off shoulder holster of a torso left 90 degrees round, which blocked the very recenter it needed
		bool near = body && body.primed && abs(Actor.DeltaAngle(body.yaw, pmo.angle)) < REC_NEAR;
		bool busy = (near && (hoverR[0] >= 0 || hoverR[1] >= 0)) || gripDown[n * 2] || gripDown[n * 2 + 1]
			|| (bt & (BT_USE | BT_ATTACK | BT_ALTATTACK | BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) != 0;
		if (busy || recDone || !Flag("rsqtr_recenter_hands", p, true)) { recFor = 0; return; }
		if (++recFor < REC_HOLD) return;
		recFor = 0;
		recDone = true;
		DoRecenter(pmo);
	}

	// the torso to the head's facing, with the click and the tick (the gesture, the key, RSQ ShieldSaw's key)
	void DoRecenter(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) return;
		if (!body) body = new("RSQTR_Body");
		body.Recenter(pmo);
		// a soft click: Doom's own switch sound (doom2.wad DSSWTCHN), quiet, heard only here
		pmo.A_StartSound("switches/normbutn", CHAN_AUTO, CHANF_LOCAL, 0.3);
		RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		RSQTR_Buzzer.Start(pmo, 1, 0.3, 3);
		if (Flag("rsqtr_messages", pmo.player, false)) pmo.A_Print("Torso recentered", 0, RSQTR_A11y.PrintFont());
	}

	// a respawn: the new pawn's torso faces where its head does
	override void PlayerRespawned(PlayerEvent e)
	{
		if (e.PlayerNumber == consoleplayer && body) body.primed = false;
	}

	// Saved settings outlive new defaults (a user cvar keeps its stored value), so a setting
	// still at an OLD default is moved to the new one, once (rsqtr_cfgver).
	private transient bool migrated;
	private void MigratePlaces()
	{
		// settings version 2 (10-27): the saber has two holsters of its own, so it no longer
		// also hangs on the hips unless asked
		let ver = CVar.FindCVar("rsqtr_cfgver");
		if (ver && ver.GetInt() < 2)
		{
			let sh = CVar.FindCVar("rsqtr_saber_hip");
			if (sh) sh.SetBool(false);
			ver.SetInt(2);
		}
		// settings version 3 (10-27, the simple rig): the body's turn rule becomes 35 degrees
		// held 1 s with a slow ease (it was 25 at once: "everything moves around")
		// settings version 4 (10-27): DUAL IS ITS OWN THING (the owner: "I have a button that is
		// dedicated to... put it in offhand / take it out of offhand; leave its appearance and
		// disappearance in the off hand as a different kind of thing"). The rig never touches the
		// off hand for a pair any more: rsqtr_pairs 0 (it was 2).
		if (ver && ver.GetInt() < 4)
		{
			let pr = CVar.FindCVar("rsqtr_pairs");
			if (pr) pr.SetInt(0);
			if (ver.GetInt() >= 3) ver.SetInt(4);
		}
		if (ver && ver.GetInt() < 3)
		{
			let bt3 = CVar.FindCVar("rsqtr_body_turn"), bs3 = CVar.FindCVar("rsqtr_body_secs");
			if (bt3) bt3.SetFloat(35);
			if (bs3) bs3.SetFloat(1);
			ver.SetInt(4);
		}
		// the body's turn rule was 60 degrees held 2 s until 10-27 (the regions stood in the
		// room while he turned); still at those, it moves to the new 25 / 0
		let bt = CVar.FindCVar("rsqtr_body_turn"), bs = CVar.FindCVar("rsqtr_body_secs");
		if (bt && bs && abs(bt.GetFloat() - 60) < 0.01 && abs(bs.GetFloat() - 2) < 0.01) { bt.SetFloat(25); bs.SetFloat(0); }
		// settings version 5 (10-31): the chest holsters' first height (-0.38) sat on the cigarette pocket;
		// still there, they move to -0.46
		if (ver && ver.GetInt() < 5)
		{
			for (int r = 6; r <= 7; r++)
			{
				let u = CVar.FindCVar(String.Format("rsqtr_r%d_u", r));
				if (u && abs(u.GetFloat() + 0.38) < 0.001) u.SetFloat(-0.46);
			}
			ver.SetInt(5);
		}
		// settings version 6 (11-03 18:56, "Stick turns + recenter"): the torso never guesses a turn from the head or
		// hands, so "Torso Turns With Head and Hands" goes off (it was on from 11-03 13:00) whatever was saved
		if (ver && ver.GetInt() < 6)
		{
			let bh = CVar.FindCVar("rsqtr_body_hands");
			if (bh) bh.SetBool(false);
			ver.SetInt(6);
		}
		// settings version 7 (11-05 01:07): the whip holster shrinks to its coil (0.09 -> 0.08) and the ammo pouch grows
		// (0.045 -> 0.10, re-placed 0.16/0.13/-0.61 -> 0.20/0.14/-0.62); each moves only while still at its old default
		if (ver && ver.GetInt() < 7)
		{
			let wr = CVar.FindCVar("rsqtr_r11_rad");
			if (wr && abs(wr.GetFloat() - 0.09) < 0.001) wr.SetFloat(RSQTR_Region.DR[RSQTR_Region.WHIP]);
			let pf = CVar.FindCVar("rsqtr_r13_f"), pl = CVar.FindCVar("rsqtr_r13_l"), pu = CVar.FindCVar("rsqtr_r13_u"), pr = CVar.FindCVar("rsqtr_r13_rad");
			int k = RSQTR_Region.POUCH;
			if (pf && pl && pu && abs(pf.GetFloat() - 0.16) < 0.001 && abs(pl.GetFloat() - 0.13) < 0.001 && abs(pu.GetFloat() + 0.61) < 0.001)
			{
				pf.SetFloat(RSQTR_Region.DF[k]); pl.SetFloat(RSQTR_Region.DL[k]); pu.SetFloat(RSQTR_Region.DU[k]);
			}
			if (pr && abs(pr.GetFloat() - 0.045) < 0.001) pr.SetFloat(RSQTR_Region.DR[k]);
			ver.SetInt(7);
		}
		// settings version 8 (owner 11-05 01:53, "switch off weapon throwing and hide the options for it, I'm not happy
		// with it"): gun throwing goes off, whatever was saved; its rows are out of the menu
		if (ver && ver.GetInt() < 8)
		{
			let th = CVar.FindCVar("rsqtr_throw"), tu = CVar.FindCVar("rsqtr_throw_use");
			if (th) th.SetBool(false);
			if (tu) tu.SetBool(false);
			ver.SetInt(8);
		}
	}

	private void SaveEdit(PlayerPawn pmo, PlayerInfo p)
	{
		int r = editRegion;
		double f, l, u;
		BodyOffsets(pmo, editAt, f, l, u);
		if (r == RSQTR_Region.KEYRING && RSQTR_Body.LayoutLeft()) l = -l;     // its "left" is toward the off hand
		if ((r == RSQTR_Region.WHIP && !RSQTR_Body.LeftHanded()) || ((r == RSQTR_Region.FLARE || r == RSQTR_Region.POUCH) && RSQTR_Body.LeftHanded())) l = -l;   // toward a hand
		CVar.FindCVar(String.Format("rsqtr_r%d_f", r)).SetFloat(f);
		CVar.FindCVar(String.Format("rsqtr_r%d_l", r)).SetFloat(l);
		CVar.FindCVar(String.Format("rsqtr_r%d_u", r)).SetFloat(u);
		pmo.A_Print(String.Format("%s: %.2f forward, %.2f left, %.2f up", RSQTR_Region.NAMES[r], f, l, u), 0, RSQTR_A11y.PrintFont());
		editHand = -1; editRegion = -1;
	}

	static bool CVarOn(String name)
	{
		let cv = CVar.FindCVar(name);
		return cv && cv.GetBool();
	}

	// A region another mod has claimed right now answers here (rig.slot service,
	// hooks.zs); a claimed region is not ours to act on.
	bool RegionLive(PlayerPawn pmo, int r)
	{
		if (IsSaberRegion(r)) { if (!SaberLoaded()) return false; }
		else if (IsGrenadeRegion(r)) { if (!HasGrenadeWeapon() || !Flag("rsqtr_grenades", pmo.player, true)) return false; }
		else if (r == RSQTR_Region.KEYRING) { if (!Flag("rsqtr_keyring", pmo.player, true)) return false; }
		else if (r == RSQTR_Region.WHIP) { if (!WhipHolsterOn(pmo.player)) return false; }
		else if (r == RSQTR_Region.FLARE) { if (!FlareHolsterOn(pmo.player)) return false; }
		else if (r == RSQTR_Region.POUCH) { if (!PouchOn(pmo.player)) return false; }
		else if (!IsGunRegion(r)) return false;      // a retired index (RSQTR_Region.Retired)
		return !RSQTR_Hooks.Claimed(pmo, r);
	}

	static bool SaberLoaded()
	{
		String n = "UBQS_Saber";
		class<Actor> c = n;
		return c != null;
	}

	private void Press(PlayerPawn pmo, PlayerInfo p, int h, int r, Vector3 hp)
	{
		// WITH THE CIGARETTE OUT, A HOLSTER ENDS IT AND IS CARRIED OUT (cig.zs "the end", the owner 11-03): either hand's
		// grip at a holster ends the ritual (unlit: the pocket, lit: flicked, the Zippo gone that tic), then the press does
		// what it does with the hands as they are, in the events after the end's: a hand holding the cigarette (or the
		// Zippo) is an empty hand, so it draws a full holster; the gun back in the main hand (cigarette in the mouth) goes
		// in, or swaps. The grenade spot, the saber spots and the keyring only end it.
		if (RSQTR_Cig.IsOut(pmo.PlayerNumber()))
		{
			EventHandler.SendNetworkEvent("rsqtr_cigend", h);
			RSQTR_Buzzer.Start(pmo, h, 0.4, 4);
			if (!IsGunRegion(r)) return;
		}
		if (IsGrenadeRegion(r))
		{
			String nw = NadeWeapon();
			bool inHand = p.ReadyWeapon && nw != "" && p.ReadyWeapon.GetClassName() == Name(nw);
			if (inHand || Grenades(pmo) > 0) { EventHandler.SendNetworkEvent("rsqtr_nade"); RSQTR_Buzzer.Start(pmo, h, 0.55, 5); }
			else
			{
				RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
				if (Flag("rsqtr_messages", p, false)) pmo.A_Print("Grenades: none", 0, RSQTR_A11y.PrintFont());
			}
			return;
		}
		// A LIT FLARE IS NEVER HOLSTERED (owner 11-05: "A lit flare should not be holstered"): with RSQ FnF's flare lit in the
		// off hand, that hand's grip at any place here does nothing (a short buzz) -- no draw or swap that would take the hand
		// and let it fall, nothing put away. FnF keeps it in the hand there too; it leaves by a throw or a drop elsewhere.
		if (h == 1 && FlareAsk("flare.phase", pmo) == 2)
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (Flag("rsqtr_messages", p, false)) Console.Printf("T_RIG t%d: %s refused, a lit flare is in the off hand", level.maptime, RSQTR_Region.NAMES[r]);
			return;
		}
		if (r == RSQTR_Region.POUCH) return;     // the pouch is Brutal Doom VR's: its reload reads "pouch.at" (no rig action here)
		if (r == RSQTR_Region.WHIP) { WhipPress(pmo, p, h); return; }
		if (r == RSQTR_Region.FLARE) { FlarePress(pmo, p, h); return; }
		Array<String> own;
		Owned(pmo, r, own);
		// THE WHIP AND AN UNLIT FLARE PUT ON AN EMPTY GUN HOLSTER GO TO THEIR OWN (as the saber below): the hand holding
		// one at an empty gun holster puts it home. At a full one the gun is drawn as always (the whip is no gun here,
		// HoldsGun), and the whip -- or the flare, which FnF puts back once the hand is taken -- is home.
		if (IsGunRegion(r) && Content(pmo, r) == "")
		{
			let hw = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
			if (HomeWhip(hw))
			{
				EventHandler.SendNetworkEvent("rsqtr_whip", h, 0);
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
				return;
			}
			if (h == 1 && FlareHolsterOn(p) && FlareAsk("flare.phase", pmo) == 1)
			{
				EventHandler.SendNetworkEvent("rsqff_back");
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
				return;
			}
		}
		// A SABER PUT ANYWHERE GOES TO ITS OWN HOLSTER (the owner, 10-27: "if I try to put the
		// sabers anywhere else, they just jump to their dedicated slots"). Put on an empty holster,
		// the saber goes home instead; on a holster with a gun, the gun is drawn as always and the
		// saber, out of the hand, shows in its own holster (DrawMarkers).
		// "Empty": a gun holster with nothing put in it, a saber spot with no saber of its own.
		bool spotEmpty = IsGunRegion(r) ? Content(pmo, r) == "" : own.Size() == 0;
		let offW = p.OffhandWeapon;
		if (h == 1 && spotEmpty && offW && IsSaber(offW) && IsSecondSaber(offW))
		{
			EventHandler.SendNetworkEvent("ubqs_dual_in");
			pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
			RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			return;
		}
		let mainW = p.ReadyWeapon;
		if (h == 0 && mainW && IsSaber(mainW) && !IsSecondSaber(mainW))
		{
			int home = SaberHome();
			bool itsOwn = r == home || ((r == 0 || r == 1) && Flag("rsqtr_saber_hip", p, false));
			if (!itsOwn && spotEmpty)
			{
				EventHandler.SendNetworkEvent("rsqtr_holster", home);
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
				return;
			}
		}
		// EACH HAND ITS OWN SABER HOLSTER (the owner, 10-29: "offhand grip needs to store and retrieve
		// into its own hand, mainhand grip needs to do the same"). The main saber's holster answers
		// the main hand only, the second saber's the off hand only; the other hand there does nothing.
		if (IsSaberRegion(r) && ((r == SaberHome() && h != 0) || (r == SaberAway() && h != 1)))
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			return;
		}
		// THE SECOND SABER'S HOLSTER: the saber itself takes it out to the off hand or puts it
		// back (its ubqs_dual_out / ubqs_dual_in). The second saber is an off-hand weapon with no key of its
		// own (the owner, 11-01), so this holster is the only way it is put away and drawn.
		if (own.Size() == 1)
		{
			class<Weapon> sc = own[0];
			let sw = sc ? Weapon(pmo.FindInventory(sc)) : null;
			if (sw && IsSaber(sw) && IsSecondSaber(sw))
			{
				bool inHand = p.OffhandWeapon == sw;
				EventHandler.SendNetworkEvent(inHand ? "ubqs_dual_in" : "ubqs_dual_out");
				pmo.A_StartSound(inHand ? "rsqtr/holster" : "rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
				RSQTR_Buzzer.Start(pmo, h, inHand ? 0.55 : 0.65, inHand ? 5 : 6);
				return;
			}
		}
		// EACH HAND ITS OWN GUN (the owner, 10-27: guns move between hands with the engine's own
		// switchhand button). The off hand puts the gun it holds on a holster, or draws a holster's
		// gun into itself; the main hand does the same for itself.
		if (h == 1 && IsGunRegion(r))
		{
			if (OffHoldsGun(pmo))
			{
				EventHandler.SendNetworkEvent("rsqtr_holster_off", r);
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			}
			else if (Content(pmo, r) != "")
			{
				EventHandler.SendNetworkEvent("rsqtr_draw_off", r);
				RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
			}
			else RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			return;
		}
		if (IsGunRegion(r))
		{
			// gun in hand: in it goes (a full holster swaps); hand empty: draw what is there
			if (HoldsGun(pmo))
			{
				EventHandler.SendNetworkEvent("rsqtr_holster", r);
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			}
			else if (Content(pmo, r) != "")
			{
				EventHandler.SendNetworkEvent("rsqtr_draw", r, 0);
				RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
			}
			else
			{
				RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
				if (Flag("rsqtr_messages", p, false)) pmo.A_Print(String.Format("%s: empty", RSQTR_Region.NAMES[r]), 0, RSQTR_A11y.PrintFont());
			}
			return;
		}
		String cur = HeldAs(pmo, p.ReadyWeapon);
		if (cur != "" && own.Find(cur) < own.Size())
		{
			EventHandler.SendNetworkEvent("rsqtr_holster", r);
			RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			return;
		}
		if (own.Size() == 0)
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (Flag("rsqtr_messages", p, false)) pmo.A_Print(String.Format("%s: nothing here", RSQTR_Region.NAMES[r]), 0, RSQTR_A11y.PrintFont());
			return;
		}
		// a saber spot lists one saber at most (Owned): draw it
		EventHandler.SendNetworkEvent("rsqtr_draw", r, 0);
		RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
	}

	// THE WHIP HOLSTER: the whip's own hand (WhipHand) puts it away or draws it; a gun in that hand stays in the inventory
	// (as at the saber's spot). The other hand, or no whip, does nothing.
	private void WhipPress(PlayerPawn pmo, PlayerInfo p, int h)
	{
		let w = WhipOf(pmo);
		bool dbg = Flag("rsqtr_messages", p, false);
		if (!w || h != WhipHand(pmo))
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (dbg) pmo.A_Print(!w ? "Whip: none" : "Whip: the other hand's", 0, RSQTR_A11y.PrintFont());
			return;
		}
		bool inHand = (h == 0 ? p.ReadyWeapon : p.OffhandWeapon) == w;
		EventHandler.SendNetworkEvent("rsqtr_whip", h, inHand ? 0 : 1);
		RSQTR_Buzzer.Start(pmo, h, inHand ? 0.55 : 0.65, inHand ? 5 : 6);
	}

	// THE FLARE HOLSTER: the off hand only (the flare is RSQ FnF's off-hand weapon). Empty of a flare: one comes up, unlit
	// (FnF's take); an unlit flare goes back (FnF's back); a lit one cannot go in (refused; FnF's own grip rule acts).
	private void FlarePress(PlayerPawn pmo, PlayerInfo p, int h)
	{
		bool dbg = Flag("rsqtr_messages", p, false);
		int ph = FlareAsk("flare.phase", pmo);
		if (h != 1 || ph < 0 || ph == 2)
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (dbg) Console.Printf("T_RIG flare holster t%d: refused (hand %d, flare %d)", level.maptime, h, ph);
			return;
		}
		if (ph == 1)
		{
			EventHandler.SendNetworkEvent("rsqff_back");
			RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			if (dbg) Console.Printf("T_RIG flare holster t%d: the unlit flare goes back", level.maptime);
			return;
		}
		if (FlareAsk("flare.count", pmo) <= 0)
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			pmo.A_Print("No flares left", 1);
			return;
		}
		EventHandler.SendNetworkEvent("rsqff_take");
		RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
		if (dbg) Console.Printf("T_RIG flare holster t%d: a flare drawn into the off hand", level.maptime);
	}

	// The sphere's skin (MODELDEF RSQTR_Marker): A blue idle, B green with a hand inside, C-E
	// profiles 2-4 orange, purple, yellow. Colour-blind play (rsqa_colorblind, cb.zs): those five
	// are three or four colours to a dichromat (simulated, the closest pair is 6.1 apart for
	// protanopia), so each vision gets its own five (F-T, tools/gen_cb_skins.py), at least 17.4
	// apart in the vision they are for (as drawn); inside is the series HAVE colour.
	// A stored gun's ammo: 0 green (half a magazine or more), 1 yellow (low, or empty with rounds to reload),
	// 2 red (nothing at all), -1 a gun with no ammo. A gun with a magazine counts its magazine (as RSQ Gun Cards).
	static int AmmoState(Weapon w)
	{
		if (!w || !w.Ammo1) return -1;
		bool mag = w.Ammo2 && w.Ammo2 != w.Ammo1;
		let lo = mag ? w.Ammo2 : w.Ammo1;
		int have = lo.Amount, cap = max(1, lo.MaxAmount);
		int spare = mag ? w.Ammo1.Amount : 0;
		if (have <= 0) return spare > 0 ? 1 : 2;
		return have * 2 >= cap ? 0 : 1;
	}

	// UTILITY PLACES HAVE THEIR OWN COLOUR (owner 11-05 01:07 "utility and off-limit holsters a different colour that we
	// are not using yet"): every place no gun can be holstered in (grenade, keyring, sabers, whip, flare, pouch, FnF's pocket
	// and clip, the cigarette pocket) is magenta FF00FF while idle, whatever the profile -- the colour farthest from the six
	// in use (CIEDE2000 16.7 over a dark wall, drawn as the additive wire is; Accessibility/tools/cvd.py). Colour-blind modes
	// pick a sixth colour for their palette by the same rule (gen_cb_skins.py): protan/deutan 33FF99, tritan CC33CC, high
	// contrast CC3300. A hand inside is the same "inside" colour as a gun holster's. Frames U (20), V W X (21-23).
	const STOWED_SPHERE = 0.4;
	static int MarkerFrame(bool inside, int prof, bool util = false)
	{
		static const int IDLE[] = { 0, 2, 3, 4 };
		static const int CBBASE[] = { 0, 5, 5, 10, 15 };
		static const int CBUTIL[] = { 20, 21, 21, 22, 23 };
		prof = clamp(prof, 1, 4);
		int cb = RSQTR_CB.Mode();
		if (util && !inside) return CBUTIL[cb];
		if (cb) return CBBASE[cb] + (inside ? 0 : prof);
		return inside ? 1 : IDLE[prof - 1];
	}

	// ---- what you see ------------------------------------------------------------------
	// A soft ring at each region while a hand is near it (or always, rsqtr_markers 2),
	// amber with the hand inside; and the weapon last holstered there, as its own
	// pickup sprite, hanging at the region.
	private void DrawMarkers(PlayerPawn pmo, PlayerInfo p)
	{
		int mode = Opt("rsqtr_markers", p, 1);
		if (Flag("rsqtr_edit", p, false)) mode = 2;
		bool icons = Flag("rsqtr_icons", p, true);
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (RSQTR_Region.Retired(r)) continue;
			Vector3 at = RegionAt(pmo, r);
			double rad = RegionRadius(p, r);
			double near = 1e9;
			for (int h = 0; h < 2; h++) near = min(near, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), at));
			// (the keyring is hovered only in edit mode; outside it, "inside" is a hand within its sphere)
			bool inside = hoverR[0] == r || hoverR[1] == r || (r == RSQTR_Region.KEYRING && near <= rad);
			bool live = RegionLive(pmo, r);
			double a = 0;
			if (live && mode > 0)
			{
				if (mode >= 2) a = inside ? 0.7 : 0.25;
				else if (near < rad * 2.5) a = inside ? 0.7 : 0.35 * (1.0 - (near - rad) / (rad * 1.5));
			}
			// AN ITEM STOWED IN IT IS NOT GHOSTED (owner 11-05 01:07 "holstered models are like, see through?"): the additive
			// sphere drawn through the solid item washed it out, so a place showing its item (last tic's: a gun or saber, the
			// coiled whip, a flare, the grenade, the pouch) draws its sphere at STOWED_SPHERE of the alpha.
			// (not the pouch: its 0.10 sphere is far larger than the 10 cm pouch and is meant to be seen)
			bool holds = r != RSQTR_Region.POUCH && ((icon[r] && !icon[r].bINVISIBLE) || (IsGrenadeRegion(r) && nadeShow && !nadeShow.bINVISIBLE));
			if (holds) a *= STOWED_SPHERE;
			if (a > 0.01)
			{
				if (!marker[r]) marker[r] = Actor.Spawn("RSQTR_Marker", at);
				let m = marker[r];
				if (m)
				{
					m.SetOrigin(at, true);
					m.bINVISIBLE = false;
					m.Alpha = clamp(a, 0.0, 1.0);
					// THE PROFILE IN USE SHOWS IN THE COLOUR (the owner, 10-27): idle blue, orange,
					// purple or yellow for profiles 1-4, green with a hand inside. Not by colour
					// alone: a sphere with a hand in it is also brighter and a size larger.
					double s = rad * RSQTR_Body.Upm() * (inside ? 1.15 : 1.0);   // the wireframe sphere has radius 1.0
					m.Scale = (s, s);
					m.frame = MarkerFrame(inside, Opt("rsqtr_profile_active", p, 1), !IsGunRegion(r));
				}
			}
			else if (marker[r]) marker[r].bINVISIBLE = true;

			// THE AMMO LIGHT (owner 2026-10-31, "holster ammo"): with the ring showing, a full holster has a small
			// sphere in its middle: green half full or more, yellow low or needing a reload, red empty. Not by
			// colour alone: an empty one is smaller and blinks.
			String inIt = (live && IsGunRegion(r)) ? Content(pmo, r) : "";
			class<Weapon> pc = inIt;
			let pw = pc ? Weapon(pmo.FindInventory(pc)) : null;
			int nades = (live && IsGrenadeRegion(r)) ? Grenades(pmo) : -1;
			if ((pw || nades >= 0) && a > 0.01 && Flag("rsqtr_ammo_light", p, true) && (nades >= 0 || AmmoState(pw) >= 0))
			{
				int st = nades >= 0 ? (nades >= 2 ? 0 : (nades == 1 ? 1 : 2)) : AmmoState(pw);
				if (!pip[r]) pip[r] = Actor.Spawn("RSQTR_AmmoPip", at);
				let q = pip[r];
				if (q)
				{
					q.SetOrigin(at, true);
					q.frame = st;
					double ps = rad * RSQTR_Body.Upm() * (st == 2 ? 0.18 : 0.26);
					q.Scale = (ps, ps);
					q.bINVISIBLE = st == 2 && (level.maptime / 8) % 2 == 1;
					q.Alpha = clamp(a + 0.2, 0.0, 1.0);
					// THE KIND'S COLOUR (owner 11-02): with RSQ Grenade's kind in hand not the frag, the grenade spot glows in
					// its colour; the count still reads -- empty is the small blinking light, one left pulses slowly
					int kc = nades >= 0 ? KindColour(pmo) : -1;
					if (kc >= 0)
					{
						q.A_SetRenderStyle(q.Alpha, STYLE_AddShaded);
						q.SetShade(kc);
						if (st == 1) q.Alpha *= 0.55 + 0.45 * sin(level.maptime * 9.0);
					}
					else if (q.GetRenderStyle() != STYLE_Add) q.A_SetRenderStyle(q.Alpha, STYLE_Add);
				}
			}
			else if (pip[r]) pip[r].bINVISIBLE = true;
			AmmoCount(pmo, p, r, at, rad, a, pw);

			// WHAT IS STORED THERE: exactly what you put there, nothing chosen for you (the owner,
			// 10-27: "impossible to keep track what is where").
			String held = HeldAs(pmo, p.ReadyWeapon);
			String put = live ? Content(pmo, r) : "";
			if (put == held || (p.OffhandWeapon && put == p.OffhandWeapon.GetClassName())) put = "";
			// ONLY A MEASURED MODEL IS SHOWN ON THE BODY. A weapon not in the fit table has no
			// model of its own here (BD's hand grenades are a flat sprite), and a flat sprite
			// floating at the chest is just a picture by your face (the owner, 10-27, asked
			// three times what the little grenade icons were).
			let fitT = GetFit();
			if (put != "" && fitT.Find(put) < 0) put = "";
			// EACH SABER HAS ITS HOLSTER and shows there whenever it is not in its hand: the main
			// saber in the home holster unless the main hand holds it, the second saber in the
			// other unless the off hand holds it (Owned lists only that one saber per holster).
			if (r == RSQTR_Region.SABER_L || r == RSQTR_Region.SABER_R)
			{
				put = "";
				Array<String> own;
				Owned(pmo, r, own);
				for (int k = 0; k < own.Size(); k++)
				{
					let sw = Weapon(pmo.FindInventory(own[k]));
					if (sw && sw != p.ReadyWeapon && sw != p.OffhandWeapon) { put = own[k]; break; }
				}
				if (put != "" && fitT.Find(put) < 0) put = "";
				// SHOW SABERS (owner 11-04 menu pass): RSQ Saber's own row (ubqs_show, by name; on without it) decides
				if (!Flag("ubqs_show", p, true)) put = "";
			}
			if (r == RSQTR_Region.WHIP || r == RSQTR_Region.FLARE) { DrawStowed(pmo, p, r, at, live); continue; }
			if (r == RSQTR_Region.POUCH) { DrawPouch(pmo, p, at, live); continue; }
			if (icons && live && put != "")
			{
				if (!icon[r]) icon[r] = Actor.Spawn("RSQTR_Icon", at);
				let ic = RSQTR_Icon(icon[r]);
				if (ic)
				{
					double sc = Num("rsqtr_icon_scale", p, 1.0);
					bool backside = r == 4 || r == 5;
					// One size on the body (a pistol's), longer on the back: the butt shows
					// over the shoulder at the edge of your view.
					double metres = sc * (backside ? Num("rsqtr_icon_back_m", p, 0.70) : Num("rsqtr_icon_m", p, 0.25));
					ic.Wear(put, 0.28 * sc, 1.0);     // solid (11-05: at 0.85 Translucent the gun showed its own inside faces)
					double by = (body && body.primed) ? body.yaw : pmo.angle;
					ic.Place(ShowAt(at, r, by, metres));
					Hang(ic, r, by + Num("rsqtr_icon_turn", p, 0), metres, 0.28 * sc);
				}
			}
			else if (icon[r]) icon[r].bINVISIBLE = true;
			if (IsGrenadeRegion(r)) DrawNade(pmo, p, at, live);
		}
		DrawFnFMarkers(pmo, p, mode);
	}

	// EVERY GRAB ZONE ON THE BODY SHOWS THE SPHERE (owner 11-04 19:07: "I would expect all of my holsters to have that
	// spherical fading holster zone"). RSQ FlashFlare's flare pocket and flashlight clip are FnF's own grab zones and FnF
	// draws nothing there, so with both loaded the rig draws its marker at the spot FnF publishes (RSQFF_Service
	// GetDouble "pocket.x/y/z/r" and "clip.x/y/z/r", asked with this body's yaw), with the same switch (rsqtr_markers,
	// edit mode shows all), the same fade and colours as the rig's own places, at FnF's own radius. Green while the off
	// hand (the one that takes from them) is inside. FnF alone draws nothing, as before.
	private void DrawFnFMarkers(PlayerPawn pmo, PlayerInfo p, int mode)
	{
		static const String Z[] = { "pocket", "clip" };
		let it = ServiceIterator.Find("RSQFF_Service");
		let svc = it.Next();
		double by = BodyYaw(pmo);
		for (int k = 0; k < 2; k++)
		{
			double a = 0;
			Vector3 at = (0, 0, 0);
			double rad = 0;
			if (svc && mode > 0)
			{
				String z = Z[k];
				double x = svc.GetDouble(z .. ".x", "", 0, by, pmo);
				rad = svc.GetDouble(z .. ".r", "", 0, by, pmo);
				if (x < 1e8 && rad > 0 && rad < 1e8)
				{
					at = (x, svc.GetDouble(z .. ".y", "", 0, by, pmo), svc.GetDouble(z .. ".z", "", 0, by, pmo));
					double near = 1e9;
					for (int h = 0; h < 2; h++) near = min(near, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), at));
					bool inside = RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 1), at) <= rad;
					if (mode >= 2) a = inside ? 0.7 : 0.25;
					else if (near < rad * 2.5) a = inside ? 0.7 : 0.35 * (1.0 - (near - rad) / (rad * 1.5));
					if (a > 0.01)
					{
						if (!fnfMark[k]) fnfMark[k] = Actor.Spawn("RSQTR_Marker", at);
						let m = fnfMark[k];
						if (m)
						{
							m.SetOrigin(at, true);
							m.bINVISIBLE = false;
							m.Alpha = clamp(a, 0.0, 1.0);
							double s = rad * RSQTR_Body.Upm() * (inside ? 1.15 : 1.0);
							m.Scale = (s, s);
							m.frame = MarkerFrame(inside, Opt("rsqtr_profile_active", p, 1), true);
						}
					}
				}
			}
			if (a <= 0.01 && fnfMark[k]) fnfMark[k].bINVISIBLE = true;
		}
	}

	// ---- THE WHIP AND THE FLARE ON THE BODY (owner 2026-11-03 20:14: "draw the holstered whip/flare on the body as their
	// models when stored, switchable") -------------------------------------------------------------------------------
	// The whip, coiled, while you own it and it is in neither hand (nor being raised); a flare while you carry one (the
	// holster shares FnF's pocket: one in the hand, more in the holster, one still shows). Each is its own mod's class
	// (RSQWP_Stowed, RSQFF_Stowed: their MODELDEF sizes the mesh to the real thing and centres it on the actor), spawned
	// by name and held in icon[] so the mirror copies it. Hung as worn, in the body's frame:
	//   the whip's coil flat against the outside of the hip, the coil facing out (the mesh's coil plane is its own X-Z),
	//     the handle down and toward the back (STOW_WHIP_ROLL leans it a little out at the bottom, as a clip holds it);
	//   the flare upright, cap up, leaning STOW_FLARE_LEAN forward so the cap is toward the hand reaching down.
	// Size: Stored Gun Size (rsqtr_icon_scale) scales both. Left-handed: each is on its own hand's side (Settings) and the
	// whip's handle still points back (the coil is symmetric; the roll is mirrored).
	const STOW_WHIP_ROLL = 8;
	const STOW_FLARE_LEAN = 15;
	private void DrawStowed(PlayerPawn pmo, PlayerInfo p, int r, Vector3 at, bool live)
	{
		bool whip = r == RSQTR_Region.WHIP;
		// SHOW WHIP / SHOW FLARE (owner 11-04 menu pass): the item's own mod's row decides (RSQ Whip's rsqwp_show, RSQ FnF's
		// rsqff_show_flare, read by name; on when that mod has no such row). The rig's old Show ... in Holster rows are gone.
		bool want = live && Flag(whip ? "rsqwp_show" : "rsqff_show_flare", p, true);
		if (want) want = whip ? (WhipOf(pmo) && !WhipInHand(pmo)) : FlareAsk("flare.count", pmo) > 0;
		String cn = whip ? "RSQWP_Stowed" : "RSQFF_Stowed";
		class<Actor> c = cn;
		if (!want || !c)
		{
			if (icon[r]) icon[r].bINVISIBLE = true;
			return;
		}
		if (icon[r] && icon[r].GetClass() != c) { icon[r].Destroy(); icon[r] = null; }
		if (!icon[r]) icon[r] = Actor.Spawn(c, at);
		let a = icon[r];
		if (!a) return;
		double by = (body && body.primed) ? body.yaw : pmo.angle;
		double side = (whip != RSQTR_Body.LeftHanded()) ? -1 : 1;     // +1 the body's left side, -1 its right
		double sc = Num("rsqtr_icon_scale", p, 1.0);
		a.SetOrigin(at, true);
		a.Scale = (sc, sc);
		if (whip) { a.angle = by; a.pitch = 0; a.roll = -side * STOW_WHIP_ROLL; }
		else { a.angle = by; a.pitch = -(90 - STOW_FLARE_LEAN); a.roll = 0; }
		a.bINVISIBLE = false;
	}

	// ---- THE POUCH ON THE BELT (Show Ammo Pouch, rsqtr_pouch_show): a small canvas pouch (models/rsqtr/rtpouch.md3,
	// tools/gen_pouch.py, 5 x 8 x 10 cm) at the pouch place, facing out from the body, and on its flap a light for the
	// gun in the main hand's RESERVE (the ammo a reload takes): green two magazines or more (a gun without a magazine: a
	// quarter of its carry or more), yellow less, red and blinking none, nothing for a gun with no ammo. Held in icon[]
	// (the mirror copies it) and pip[] (the holsters' light).
	const POUCH_LIGHT_M = 0.011;     // the light's radius, metres
	static int ReserveState(Weapon w)
	{
		if (!w || !w.Ammo1) return -1;
		bool mag = w.Ammo2 && w.Ammo2 != w.Ammo1;
		int have = w.Ammo1.Amount;
		int need = mag ? 2 * max(1, w.Ammo2.MaxAmount) : max(1, w.Ammo1.MaxAmount / 4);
		if (have <= 0) return 2;
		return have >= need ? 0 : 1;
	}
	private void DrawPouch(PlayerPawn pmo, PlayerInfo p, Vector3 at, bool live)
	{
		int r = RSQTR_Region.POUCH;
		if (!live || !Flag("rsqtr_pouch_show", p, true))
		{
			if (icon[r]) icon[r].bINVISIBLE = true;
			if (pip[r]) pip[r].bINVISIBLE = true;
			return;
		}
		double by = (body && body.primed) ? body.yaw : pmo.angle;
		if (icon[r] && !(icon[r] is "RSQTR_PouchShow")) { icon[r].Destroy(); icon[r] = null; }
		if (!icon[r]) icon[r] = Actor.Spawn("RSQTR_PouchShow", at);
		let a = icon[r];
		if (a) { a.SetOrigin(at, true); a.angle = by; a.pitch = 0; a.roll = 0; a.bINVISIBLE = false; }
		int st = ReserveState(p.ReadyWeapon);
		if (st < 0) { if (pip[r]) pip[r].bINVISIBLE = true; return; }
		double u = RSQTR_Body.Upm();
		// on the flap, at its front top edge: 1.6 cm out from the pouch's middle, 5.8 cm up (the flap's top is at 5.4), so it
		// shows looking down at your belt (rig frames, 11-03: on the flap's front face it was hidden from above)
		Vector3 lp = at + (cos(by) * 0.016 * u, sin(by) * 0.016 * u, 0.058 * u / RSQTR_Body.Ps());
		if (!pip[r]) pip[r] = Actor.Spawn("RSQTR_AmmoPip", lp);
		let q = pip[r];
		if (!q) return;
		q.SetOrigin(lp, true);
		q.frame = st;
		double ps = POUCH_LIGHT_M * u;      // (red is told apart by its blink, not by a smaller size: on the belt it vanished)
		q.Scale = (ps, ps);
		q.Alpha = 0.95;
		if (q.GetRenderStyle() != STYLE_Add) q.A_SetRenderStyle(q.Alpha, STYLE_Add);
		q.bINVISIBLE = st == 2 && (level.maptime / 8) % 2 == 1;
	}

	// ---- THE GRENADE IN ITS HOLSTER (owner 2026-11-03 17:10: "When I have a grenade in my inventory I should see it in
	// the designated grenade holster") -------------------------------------------------------------------------------
	// Before: the grenade spot drew no picture at all. Only Content() (a gun you put there) is ever shown at a holster,
	// the grenade spot never has one, and the stored-gun picture shows only guns in the fit table (BD's grenade sprite
	// was taken off the body on 10-27). What the spot did draw, its ring and its count light, shows only with a hand
	// within 2.5 radii (Holster Rings: Hand Nearby). So with grenades in the inventory and the hands away: nothing.
	// Now: while you have one or more grenades (Grenades(): BD22's GrenadeAmmo on the Brutal Doom order, RSQ Grenade's
	// RSQGN_Ammo without it; the spot's own count, by name) and none is in either hand, a grenade hangs at the spot,
	// following the torso (RegionAt, as the stored guns). Hidden at 0, in the hand (drawn or being drawn), with the spot
	// off or claimed, or with rsqtr_nade_show off. The mesh is picked by name (RSQTR_NadeShow.Choose).
	// NO COUNT DIGITS here (tried on the rig, 11-03, and taken out): the spot is almost straight under the eyes, so the
	// holster digits' upright billboard is edge-on (2 pixels at 640), a forced-facing one came out a smeared wedge, and
	// a flat one, even at twice the size, was an unreadable blob at 800. The count stays the spot's light (green 2+,
	// yellow 1, red none) and the grenade itself (none shown at 0).
	const NADE_M = 0.13;           // the grenade's height on the belt, metres (x Stored Gun Size), BD's chunky grenade
	static bool NadeInHand(PlayerInfo p)
	{
		String wn = NadeWeapon();      // run-time, as NadeWeapon
		class<Weapon> wc = wn;
		if (!wc || !p) return false;
		if (p.ReadyWeapon && p.ReadyWeapon is wc) return true;
		if (p.OffhandWeapon && p.OffhandWeapon is wc) return true;
		return p.PendingWeapon && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon is wc;
	}
	private void DrawNade(PlayerPawn pmo, PlayerInfo p, Vector3 at, bool live)
	{
		int cnt = live ? Grenades(pmo) : 0;
		if (cnt <= 0 || NadeInHand(p) || !Flag("rsqtr_nade_show", p, true))
		{
			if (nadeShow) nadeShow.bINVISIBLE = true;
			return;
		}
		if (!nadeShow) nadeShow = Actor.Spawn("RSQTR_NadeShow", at);
		let g = RSQTR_NadeShow(nadeShow);
		if (!g) return;
		double by = (body && body.primed) ? body.yaw : pmo.angle;
		g.Show(at, by, NADE_M * Num("rsqtr_icon_scale", p, 1.0), NadeAmmo());
	}

	// HOW A STORED GUN HANGS, the way it is worn (the owner's reference pictures, 10-27:
	// concealed-carry positions, a slung rifle, rifles on a pack). Degrees from the body's
	// heading; an actor's pitch is positive nose-DOWN; a pickup points its muzzle along its
	// own forward axis, lying level with the grip down. For a right-handed player:
	//   hips, saber spots  muzzle down
	//   shoulders          on the back: butt up over the shoulder, muzzle down toward the other hip
	//   chest              cross-draw: muzzle down, butt tilted toward the middle of the chest
	// A left-handed player gets the mirror image. Sprites face you whatever is set.
	static void Hang(RSQTR_Icon ic, int r, double yaw, double metres, double fallback)
	{
		double s = RSQTR_Body.LayoutLeft() ? -1 : 1;   // flips left and right (rsqa_handed, else the engine's)
		double off = 0, pt = 0, rl = 0;               // off: muzzle heading from the body's
		switch (r)
		{
		case 9: case 0: off = 0;   pt = 80; rl = -10; break;  // left hip, left saber: hanging down
		case 10: case 1: off = 0;  pt = 80; rl = 10;  break;  // right hip, right saber
		case 6: off = 0;   pt = 70; rl = 35;  break;  // left chest: butt toward the middle (right hand draws across)
		case 7: off = 0;   pt = 70; rl = -35; break;  // right chest: the mirror
		case 4: off = -90; pt = 65; break;            // left shoulder: muzzle toward the right hip
		default: off = 90;  pt = 65; break;           // right shoulder: toward the left hip
		}
		if (s < 0) { off = -off; rl = -rl; }
		ic.Fit(metres, fallback, yaw + off, pt, rl);
	}

	// Where a stored gun is SHOWN: at its region, except over the shoulders, where it hangs
	// on the back -- behind the region (or it fills your view looking down) and below it,
	// so its butt, not its middle, is where your hand reaches over the shoulder.
	static Vector3 ShowAt(Vector3 at, int r, double yaw, double metres)
	{
		if (r != 4 && r != 5) return at;
		double u = RSQTR_Body.Upm();
		double down = DOWN_SHOW * metres;
		return at - (cos(yaw) * BACK_SHOW * u, sin(yaw) * BACK_SHOW * u, down * u / RSQTR_Body.Ps());
	}
	const BACK_SHOW = 0.12;   // metres behind a shoulder region
	// Below it, as a share of the gun's length: hanging 65 degrees down, its middle is 0.45 of
	// its length below its butt; 0.31 leaves the butt about 0.1 m above the shoulder (0.7 m gun).
	const DOWN_SHOW = 0.31;

	private void HideAll()
	{
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (marker[r]) marker[r].bINVISIBLE = true;
			if (icon[r]) icon[r].bINVISIBLE = true;
			if (pip[r]) pip[r].bINVISIBLE = true;
		}
		for (int k = 0; k < 2; k++) if (fnfMark[k]) fnfMark[k].bINVISIBLE = true;
		if (nadeShow) nadeShow.bINVISIBLE = true;
		for (int k = 0; k < 6; k++) HideAmmo(k);
	}

	// ---- THE AMMO COUNT (owner's pick 18, 2026-10-31; off by default, rsqtr_ammo_count) ------------------------
	// A full gun holster, while its ring shows, carries its gun's rounds as a small number just above the ring:
	// the magazine for a gun that has one (Ammo2, as AmmoState reads it), else its ammo. No panel, no frame: the
	// digits alone, 2.4 cm tall, in the ammo light's colour (green, amber low or needing a reload, red empty).
	// NOT A CANVAS, though that is RSQ_LaserSight's method (sight.zs UpdateReadout): QZD 17.3 draws a canvas texture
	// black in VR (Quest teardown apply/07_WHEEL.md 6.2, measured; measured again here: the quad came up black).
	// So each digit is a billboard sprite of Doom's own small font (TEXTURES RTNM A-J = STCFN048-057) drawn as an
	// additive stencil, laid out across your line of sight; billboards face your eyes on their own.
	const AMMO_DIGITS = 3;
	const AMMO_DIGIT_M = 0.024;   // a digit's height, metres
	transient Actor ammoDig[6 * AMMO_DIGITS];
	static int GunSlot(int r)
	{
		static const int S[] = { 0, 1, -1, -1, 2, 3, 4, 5 };
		return (r >= 0 && r < 8) ? S[r] : -1;
	}
	private void HideAmmo(int k) { for (int i = 0; i < AMMO_DIGITS; i++) if (ammoDig[k * AMMO_DIGITS + i]) ammoDig[k * AMMO_DIGITS + i].bINVISIBLE = true; }
	private void AmmoCount(PlayerPawn pmo, PlayerInfo p, int r, Vector3 at, double rad, double a, Weapon pw)
	{
		int k = GunSlot(r);
		if (k < 0) return;
		int st = pw ? AmmoState(pw) : -1;
		if (!pw || st < 0 || a <= 0.01 || !Flag("rsqtr_ammo_count", p, false)) { HideAmmo(k); return; }
		bool mag = pw.Ammo2 && pw.Ammo2 != pw.Ammo1;
		int rounds = clamp(mag ? pw.Ammo2.Amount : pw.Ammo1.Amount, 0, 999);
		static const int RGB[] = { 0x9CF09C, 0xFFC850, 0xFF5A5A };
		int c = RGB[clamp(st, 0, 2)];
		String txt = String.Format("%d", rounds);
		int n = txt.Length();
		double upm = RSQTR_Body.Upm();
		double hU = AMMO_DIGIT_M * upm * RSQTR_A11y.Text();       // RSQ_Accessibility's Text Size
		double sc = hU / 7.0;                                       // the glyphs are 7 px tall
		Vector3 pos = at + (0, 0, (rad * 1.15) * upm / RSQTR_Body.Ps() + hU * 0.6);
		// across your line of sight, left to right as you look at it
		Vector2 v = pos.xy - pmo.pos.xy;
		double vl = v.Length();
		Vector2 right = vl > 0 ? (v.y, -v.x) / vl : (1.0, 0.0);
		for (int i = 0; i < AMMO_DIGITS; i++)
		{
			int slot = k * AMMO_DIGITS + i;
			if (i >= n) { if (ammoDig[slot]) ammoDig[slot].bINVISIBLE = true; continue; }
			if (!ammoDig[slot]) ammoDig[slot] = Actor.Spawn("RSQTR_AmmoDigit", pos);
			let q = ammoDig[slot];
			if (!q) continue;
			double off = (i - (n - 1) * 0.5) * 8.5 * sc;
			q.SetOrigin(pos + (right.x * off, right.y * off, 0), true);
			q.frame = txt.ByteAt(i) - 48;
			q.Scale = (sc, sc);
			q.A_SetRenderStyle(clamp(a + 0.6, 0.0, 1.0), STYLE_AddShaded);
			q.SetShade(c);
			q.bINVISIBLE = false;
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		hoverR[0] = -1; hoverR[1] = -1;
		if (body) body.primed = false;     // a new map: the torso starts facing where the head faces (RECENTER)
		afterLoad = false;
		if (!e.IsSaveGame) RestoreLoadout();
	}

	// ---- the loadout between levels, and new guns into holsters (owner 2026-10-31) ---------------------
	//
	// KEPT BETWEEN LEVELS (rsqtr_keep): this handler is the level's, so what each holster held went with the
	// level. RSQTR_Loadout (a static handler, it outlives levels) keeps a copy every tic and a new level takes
	// it back. A holster shows a gun only while you own it (Content), so after a death or a pistol start a
	// holster is empty until you have that gun again -- then it is back where you kept it.
	//
	// NEW GUNS TO HOLSTERS (rsqtr_autoholster) is REMOVED (owner 2026-11-07 07:36): holstering by hand is the main way,
	// RSQ Wheel's holster web the remote. The guns each player has are still noted (known), for anything that asks.
	String known[MAXPLAYERS];      // "|class|class|": the guns each player had, to spot a new one
	bool knownSet[MAXPLAYERS];

	private void RestoreLoadout()
	{
		let L = RSQTR_Loadout.Get();
		for (int n = 0; n < MAXPLAYERS; n++) knownSet[n] = false;
		if (!L || !L.have) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (playeringame[n] && !Flag("rsqtr_keep", players[n], true)) continue;
			for (int r = 0; r < RSQTR_Region.N; r++)
			{
				int k = n * RSQTR_Region.N + r;
				if (lastPut[k] == "") { lastPut[k] = L.put[k]; lastPair[k] = L.pair[k]; }
				if (lockCls[k] == "") lockCls[k] = L.lock[k];
			}
		}
	}

	String lastLock(int n, int r) { return LockOn(players[n]) ? lockCls[n * RSQTR_Region.N + r] : ""; }

	private void TickLoadout()
	{
		let L = RSQTR_Loadout.Get();
		if (L)
		{
			for (int k = 0; k < MAXPLAYERS * RSQTR_Region.N; k++) { L.put[k] = lastPut[k]; L.pair[k] = lastPair[k]; L.lock[k] = lockCls[k]; }
			L.have = true;
		}
		if (level.maptime % 5 != 0) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0) continue;
			let pmo = players[n].mo;
			let p = players[n];
			bool seed = !knownSet[n];
			knownSet[n] = true;
			let empty = EmptyHand(pmo);
			for (let it = pmo.Inv; it; it = it.Inv)
			{
				let w = Weapon(it);
				if (!w || !w.Ammo1 || w == empty || IsSaber(w)) continue;
				let d = GetDefaultByType(w.GetClass());
				if (!d || d.bOffhandWeapon) continue;
				String cls = w.GetClassName();
				String tag = "|" .. cls .. "|";
				if (known[n].IndexOf(tag) >= 0) continue;
				known[n] = known[n] .. tag;
			}
		}
	}

	// The rings and icons are this machine's alone and held by transient pointers, so a
	// save carries orphan copies of them: cleared on load (and respawned as needed).
	static void ClearLocalMarks()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
			if (a is "RSQTR_Marker" || a is "RSQTR_Icon" || a is "RSQTR_TorsoPart" || a is "RSQTR_MarinePart" || a is "RSQTR_HelmetPart" || a is "RSQTR_HeldShow" || a is "RSQTR_AmmoDigit"
				|| a.GetClassName() == 'RSQWP_Stowed' || a.GetClassName() == 'RSQFF_Stowed' || a is "RSQTR_CigStowed" || a is "RSQTR_NadeShow" || a is "RSQTR_PouchShow"
				|| a.special2 == RSQTR_MirrorView.MIRROR_MARK) a.Destroy();
	}

	// OnRegister also runs when a save is loaded (a level's handlers get no WorldLoaded
	// then), so it notes it: the first tic clears the orphan rings and icons the save held.
	private transient bool afterLoad;
	override void OnRegister()
	{
		editHand = -1; editRegion = -1;
		hoverR[0] = -1; hoverR[1] = -1;
		afterLoad = true;
		if (body) body.primed = false;     // a loaded save: the torso starts facing where the head faces (RECENTER)
	}
}

// The soft ring that shows a region.
// The ammo light in a full holster (MODELDEF: the wire sphere, green / yellow / red frames A B C).
// THE AMMO COUNT's digit (rsqtr_ammo_count): one glyph of Doom's small font, a billboard, frame = the digit
class RSQTR_AmmoDigit : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "AddShaded";
		Radius 1; Height 1;
	}
	States { Spawn: RTNM A -1 Bright; Stop; }
}

// THE GRENADE IN ITS HOLSTER (rig.zs DrawNade). The mesh by name, first found: BD22 VR Reloaded's grenade
// (models/bd/Grenade/nade.md3; the BD voxel pack has no grenade voxel), else RSQ Grenade's (models/rsqgn/nade.md3, the
// same file, byte for byte), else the grenade ammo's own pickup sprite (BD22's GRND I without BD22 VR). MODELDEF
// RSQTR_NadeShow centres frame 2 (ring and spoon on) on the actor: measured, Grenade/tools/md3info.py on both meshes:
// frame 2's body centre (28.53, -0.02, -1.28), the body 17.01 units tall (-9.73 .. 7.28). Its own model (the wire
// sphere, invisible skin) is only a carrier: A_ChangeModel swaps the mesh and skin in by path, so nothing is linked
// and a missing pk3 only means the next choice.
class RSQTR_NadeShow : Actor
{
	int how;                        // 0 not chosen yet, 1 BD22 VR's mesh, 2 RSQ Grenade's, 3 a sprite, 4 nothing
	String ammoUsed;
	// the mirror's copy (mirror.zs Copy): the same mesh chosen (A_ChangeModel is not copied with the actor)
	void Mimic(RSQTR_NadeShow o) { if (o && !how && o.how) Choose(o.ammoUsed); }
	double sprH;                    // the sprite's height in pixels (3)
	const BODY_H = 17.01;           // the mesh's body height in model units (frame 2)
	const TILT = 35;                // degrees the top leans away from you (pitch, nose down = top out)
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		Radius 1; Height 1;
	}
	States { Spawn: RTGN A -1; Stop; }
	private void Choose(String ammo)
	{
		if (Wads.CheckNumForFullName("models/bd/Grenade/nade.md3") >= 0 && Wads.CheckNumForFullName("models/bd/Grenade/nade.png") >= 0)
		{
			A_ChangeModel(GetClassName(), 0, "models/bd/Grenade", 'nade.md3', 0, "models/bd/Grenade", 'nade.png');
			SetModelFlag(MDL_USEACTORPITCH);
			how = 1;
			return;
		}
		if (Wads.CheckNumForFullName("models/rsqgn/nade.md3") >= 0 && Wads.CheckNumForFullName("models/rsqgn/nade.png") >= 0)
		{
			A_ChangeModel(GetClassName(), 0, "models/rsqgn", 'nade.md3', 0, "models/rsqgn", 'nade.png');
			SetModelFlag(MDL_USEACTORPITCH);
			how = 2;
			return;
		}
		// no mesh: the ammo's pickup sprite, the first visible frame of its Spawn state
		class<Actor> c = ammo;
		let d = c ? GetDefaultByType(c) : null;
		State st = d ? d.SpawnState : null;
		int tnt = GetSpriteIndex('TNT1');
		for (int i = 0; i < 16 && st && st.sprite == tnt; i++) st = st.NextState;
		if (st && st.sprite != tnt)
		{
			sprite = st.sprite; frame = st.Frame;
			TextureID tx = st.GetSpriteTexture(0);
			int w, h;
			[w, h] = TexMan.GetSize(tx);
			sprH = max(1, h);
			how = 3;
			return;
		}
		how = 4;
	}
	void Show(Vector3 at, double yaw, double metres, String ammo)
	{
		ammoUsed = ammo;
		if (!how) Choose(ammo);
		if (how == 4) { bINVISIBLE = true; return; }
		double u = RSQTR_Body.Upm();
		if (how == 3)
		{
			double s = metres * u / sprH;
			Scale = (s, s);
			SetOrigin(at - (0, 0, metres * u * 0.5), true);   // a sprite stands on its origin
		}
		else
		{
			double s = metres * u / BODY_H;
			Scale = (s, s);
			SetOrigin(at, true);                              // centred by MODELDEF
			// ring and spoon toward you, its top leaning out from the belt (TILT): looking down at the buckle you see
			// its side, not just its top
			angle = yaw + 180;
			pitch = TILT;
		}
		bINVISIBLE = false;
	}
}

// THE POUCH ON THE BELT (rig.zs DrawPouch): its mesh, centred, facing out from the body. Local, never in play.
class RSQTR_PouchShow : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States { Spawn: RTGN A -1; Stop; }
}

class RSQTR_AmmoPip : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Add";
	}
	States { Spawn: RSTM A -1; Stop; }
}

// THE LOADOUT BETWEEN LEVELS: a static handler outlives the level, so the rig keeps a copy of every holster
// here each tic and a new level takes it back (rig.zs RestoreLoadout). Cleared on a new game.
class RSQTR_Loadout : StaticEventHandler
{
	String put[MAXPLAYERS * RSQTR_Region.N];
	bool pair[MAXPLAYERS * RSQTR_Region.N];
	String lock[MAXPLAYERS * RSQTR_Region.N];   // the holster locks (rig.zs lockCls)
	bool have;
	static RSQTR_Loadout Get() { return RSQTR_Loadout(StaticEventHandler.Find("RSQTR_Loadout")); }
	override void NewGame()
	{
		for (int k = 0; k < MAXPLAYERS * RSQTR_Region.N; k++) { put[k] = ""; pair[k] = false; lock[k] = ""; }
		have = false;
	}
}

class RSQTR_Marker : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSTM A -1 Bright; Stop; }
}

// A weapon shown by its own pickup sprite: the frame its Spawn state starts on.
// Sprites and voxels show; a pickup drawn by a MODEL shows its sprite instead
// (MODELDEF is keyed to the pickup's own class).
class RSQTR_Icon : Actor
{
	String wearing;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Normal";     // solid (owner 11-05 01:07: "holstered models are like, see through?")
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1; Stop; }

	// Shown as the weapon's own PICKUP, as it looks lying in the world: its sprite,
	// the voxel a voxel pack gives that sprite, or the 3D model a weapon pack binds to
	// it. MODELDEF binds a model to a class exactly (a subclass does not inherit it), so
	// A_ChangeModel borrows the weapon's model definition for this actor -- the way
	// the owner's RS_Holsters showed its stored guns. The frame worn is the first
	// visible state of the pickup's Spawn sequence (Brutal Doom's often start TNT1).
	void Wear(String cls, double sc, double al)
	{
		if (cls != wearing)
		{
			wearing = cls;
			class<Actor> c = cls;
			let d = c ? GetDefaultByType(c) : null;
			State st = d ? d.SpawnState : null;
			int tnt = GetSpriteIndex('TNT1');
			for (int i = 0; i < 16 && st && st.sprite == tnt; i++) st = st.NextState;
			let rig = RSQTR_Rig.Get();
			let fit = rig ? rig.GetFit() : null;
			int at = fit ? fit.Find(cls) : -1;
			if (at >= 0 && fit.spr[at] != "")
			{
				// MEASURED: the frame the table names (the model you hold), drawn by the
				// class it names
				sprite = GetSpriteIndex(Name(fit.spr[at]));
				frame = fit.frn[at];
				A_ChangeModel(Name(fit.holder[at]));
				SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
			}
			else if (st && st.sprite != tnt)
			{
				sprite = st.sprite; frame = st.Frame;
				A_ChangeModel(at >= 0 ? Name(fit.holder[at]) : Name(cls));
				// Pickup models seldom turn with their actor's pitch and roll (they lie on
				// the floor); these do, so the gun can hang as worn. Voxels too.
				SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
			}
			else { sprite = tnt; frame = 0; }
		}
		Scale = (sc, sc);
		Alpha = al;
		int want = al >= 0.999 ? STYLE_Normal : STYLE_Translucent;
		if (GetRenderStyle() != want) A_SetRenderStyle(al, want);
		bINVISIBLE = false;
	}

	Vector3 placed;		// where it was Placed (its middle goes here), for the mirror
	Vector3 cOff;		// its middle in model axes, scaled, when Fit moved it
	bool hasOff;

	void Place(Vector3 at)
	{
		placed = at;
		hasOff = false;
		SetOrigin(at, true);
	}

	// SIZED AND TURNED BY MEASURE (fit.zs): a measured gun is shown `metres` long whatever
	// its pickup's size, turned so its muzzle goes where (a, p, r) says, and moved so its
	// middle is where it was Placed; one not measured keeps its pickup size times
	// `fallback` and its own facing.
	void Fit(double metres, double fallback, double a, double p, double r)
	{
		let rig = RSQTR_Rig.Get();
		let fit = rig ? rig.GetFit() : null;
		int at = fit && wearing != "" ? fit.Find(wearing) : -1;
		if (at < 0)
		{
			Scale = (fallback, fallback);
			angle = a; pitch = p; roll = r;
			return;
		}
		// A squat pickup (a missile pod, a box) is not a long gun: it never grows past a
		// pistol's size, even on the back.
		if (fit.squat[at] > 0.7) metres = min(metres, RSQTR_Rig.Num("rsqtr_icon_m", players[consoleplayer], 0.25));
		double s = metres * RSQTR_Body.Upm() / fit.len[at];
		Scale = (s, s);
		// still backwards in your pack? listed in "Stored guns to turn round" (rsqtr_icon_flip)
		double cy = fit.yaw[at], cp = fit.pitch[at];
		if (RSQTR_Fit.Listed(wearing, players[consoleplayer])) { cy += 180; cp = -cp; }
		double oa, op, orl;
		RSQTR_Fit.Compose(a, p, r, cy, cp, oa, op, orl);
		angle = oa; pitch = op; roll = orl;
		// its middle, not its origin, on the spot it was Placed at (call after Place)
		Vector3 F, L, U;
		[F, L, U] = RSQTR_Fit.Basis(oa, op, orl);
		Vector3 c = fit.Centre(at) * s;
		cOff = c; hasOff = true;
		SetOrigin(pos - (F * c.x + L * c.y + U * c.z), true);
	}
}
