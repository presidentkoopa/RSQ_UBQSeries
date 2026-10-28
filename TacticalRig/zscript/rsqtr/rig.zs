// RSQ_TacticalRig -- weapons carried on the body.
//
// FOUR GUN HOLSTERS AND TWO SABER SPOTS (the owner's simple rig, 2026-10-27): both hips and
// both shoulders hold one gun each, exactly the one you put there; just below each hip is a
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
	// ELEVEN INDICES, SIX IN USE. The index is a place's identity: its cvars (rsqtr_rN_*) and its
	// position in a saved holster profile. 0 1 hips, 4 5 shoulders, 9 10 saber spots. 2 3 6 7 8
	// (chest, stomach, pectorals, lower back) are RETIRED: never live, no settings; kept as
	// indices so nothing renumbers.
	const N = 11;
	static const String NAMES[] = { "Left hip", "Right hip", "", "", "Left shoulder", "Right shoulder", "", "", "", "Left saber", "Right saber" };
	const SABER_L = 9;
	const SABER_R = 10;
	static bool Retired(int r) { return r == 2 || r == 3 || r == 6 || r == 7 || r == 8; }

	// Defaults, metres from the head in the body frame: forward, left, up, radius (0: retired).
	static const double DF[] = {  0.00,  0.00, 0, 0, -0.08, -0.08, 0, 0, 0,  0.02,  0.02 };
	static const double DL[] = {  0.18, -0.18, 0, 0,  0.18, -0.18, 0, 0, 0,  0.21, -0.21 };
	static const double DU[] = { -0.70, -0.70, 0, 0, -0.10, -0.10, 0, 0, 0, -0.84, -0.84 };
	static const double DR[] = {  0.14,  0.14, 0, 0,  0.14,  0.14, 0, 0, 0,  0.10,  0.10 };
}

class RSQTR_Rig : EventHandler
{
	const STEADY_RANGE = 0.50;    // metres: the engine's own two-hand steadying distance

	// ---- synced state (written by NetworkProcess on every machine) --------------
	bool   gripDown[MAXPLAYERS * 2];
	String lastPut[MAXPLAYERS * RSQTR_Region.N];   // the weapon last holstered there (its icon)
	bool lastPair[MAXPLAYERS * RSQTR_Region.N];    // ...and it went away as a PAIR (one in each hand)
	String offNext[MAXPLAYERS];                     // the off-hand weapon to raise once the main hand has switched
	int offWait[MAXPLAYERS];
	// The last draw from a holster, for a scorer's Quick Draw (RSQTR_RigService
	// "rig.drawtic" / "rig.drawn"). Written in Draw(), which every machine runs from the
	// same network event, so it is the same everywhere. drawTic is level.maptime + 1 (0 = none).
	int drawTic[MAXPLAYERS];
	String drawClass[MAXPLAYERS];

	// ---- local state (console player) -------------------------------------------
	private transient RSQTR_Body body;
	private transient int  hoverR[2];          // region each hand is in, -1 none
	private transient bool pressWas[2];
	private transient bool useWas;
	transient Actor marker[RSQTR_Region.N];   // read by the mirror (mirror.zs)
	transient Actor icon[RSQTR_Region.N];
	private transient int  buzzCool[2];
	private transient int  hoverT[2];          // tics the hand has been in its region
	private transient bool pendPress[2];       // pressed before the dwell was up
	private transient int  editHand, editRegion;   // a region being carried in edit mode
	private transient Vector3 editAt;

	// ui: the grip arrives as raw key events
	ui Array<int> keysMain, keysOff;
	ui String keysMainFrom, keysOffFrom;
	ui bool keyState[2];

	static RSQTR_Rig Get() { return RSQTR_Rig(EventHandler.Find("RSQTR_Rig")); }
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
		f = (d.x * cos(yaw) + d.y * sin(yaw)) / RSQTR_Body.UPM / k;
		l = (-d.x * sin(yaw) + d.y * cos(yaw)) / RSQTR_Body.UPM / k;
		u = d.z * RSQTR_Body.PIXELSTRETCH / RSQTR_Body.UPM / k;
	}

	double RegionRadius(PlayerInfo p, int r)
	{
		Settings(p);
		return cR[r];
	}

	// ---- the saber spots ------------------------------------------------------------
	// The saber classes this player owns that belong at place r. ONE SPOT PER SABER (the owner,
	// 10-27): the main saber's is the left one for a right-handed player (the home spot), the
	// second saber's the right one; swapped when left-handed. Found by class name so the saber
	// need not be loaded. The main saber is also listed on a hip with rsqtr_saber_hip.
	// Gun holsters hold what was put there (Content), not a list.
	static void Owned(PlayerPawn pmo, int r, out Array<String> into)
	{
		into.Clear();
		if (!pmo || !pmo.player) return;
		int home = RSQTR_Body.LeftHanded() ? RSQTR_Region.SABER_R : RSQTR_Region.SABER_L;
		int away = home == RSQTR_Region.SABER_L ? RSQTR_Region.SABER_R : RSQTR_Region.SABER_L;
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
			if (!w || w.bOffhandWeapon || IsSaber(w)) continue;   // the saber is not an empty hand
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
		if (!pmo || pmo.health <= 0) return;
		if (e.Name == "rsqtr_holster_off") { HolsterOff(pmo, e.Args[0]); return; }
		if (e.Name == "rsqtr_draw_off") { DrawOff(pmo, e.Args[0]); return; }
		if (e.Name == "rsqtr_holster") Holster(pmo, e.Args[0]);
		else if (e.Name == "rsqtr_draw") Draw(pmo, e.Args[0], e.Args[1]);
	}

	// HOLSTER PROFILES (the owner, 10-27: "save up to four holster profiles"). Every place's
	// position and size, written into one of this machine's own settings (rsqtr_profile1..4) or
	// read back from it. Format: "f,l,u,rad|..." by place index (a retired index is left empty).
	// Profiles saved before 10-27 carry a fifth field, the old slot list: ignored.
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
		for (int r = 0; r < RSQTR_Region.N && r < places.Size(); r++)
		{
			if (RSQTR_Region.Retired(r)) continue;
			Array<String> f;
			places[r].Split(f, ",");
			if (f.Size() < 4) continue;
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
	// moves around"). Four gun holsters -- both hips, both shoulders -- and the two saber spots.
	// A gun holster holds exactly what you put in it: any gun, one at a time, never chosen for
	// you. Grip a holster with a gun in your hand and the gun goes in (if one was there, you
	// swap: that one comes out); grip a full holster with your hand empty and you draw it; an
	// empty holster with an empty hand does nothing.
	static bool IsGunRegion(int r) { return r == 0 || r == 1 || r == 4 || r == 5; }
	static bool IsSaberRegion(int r) { return r == RSQTR_Region.SABER_L || r == RSQTR_Region.SABER_R; }

	// The gun in gun holster r for player n: what was put there, while you still own it.
	String Content(PlayerPawn pmo, int r)
	{
		if (!pmo || !IsGunRegion(r)) return "";
		String c = lastPut[pmo.PlayerNumber() * RSQTR_Region.N + r];
		if (c == "") return "";
		class<Weapon> wc = c;
		return (wc && pmo.FindInventory(wc)) ? c : "";
	}

	// A real gun in the main hand: not the empty hand (fists / BD22Q's hands), not a saber.
	static bool HoldsGun(PlayerPawn pmo)
	{
		let w = pmo.player.ReadyWeapon;
		if (!w || IsSaber(w)) return false;
		let empty = EmptyHand(pmo);
		return w != empty;
	}

	// A GUN IN THE OFF HAND, put there by the engine's own switchhand (the owner's "move weapon to
	// off hand" button): a weapon whose class is NOT an off-hand weapon by default. Off-hand-only
	// things -- Brutal Doom Quest's hands and its Dual copies, the saber's second hilt, the shield --
	// are not guns the rig moves (Dual is its own key).
	static bool IsMovedGun(Weapon w)
	{
		if (!w || IsSaber(w)) return false;
		let d = GetDefaultByType(w.GetClass());
		return d && !d.bOffhandWeapon;
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
		String cls = w.GetClassName();
		String was = Content(pmo, r);
		for (int k = 0; k < RSQTR_Region.N; k++)
			if (k != r && lastPut[n * RSQTR_Region.N + k] == cls) lastPut[n * RSQTR_Region.N + k] = "";
		lastPut[n * RSQTR_Region.N + r] = cls;
		lastPair[n * RSQTR_Region.N + r] = false;
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
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
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
		bool incomingPair = lastPair[slot];
		lastPut[slot] = cls;
		// A PAIR GOES AWAY TOGETHER. With the gun's own off-hand copy in the other hand (BD22Q's
		// dual wield: RSQ_Off_<gun>, a subclass of the gun flagged OFFHANDWEAPON), both guns go
		// on the holster and the off hand goes back to its empty hand.
		let off = p.OffhandWeapon;
		class<Weapon> wc = cls;
		bool pair = off && wc && off is wc && off.GetClass() != wc;
		lastPair[slot] = pair;
		if (incoming)
		{
			if (IsMovedGun(incoming)) incoming.bOffhandWeapon = false;
			p.PendingWeapon = incoming;
			int mode = Opt("rsqtr_pairs", p, 2);
			let copy = OffCopy(pmo, incoming.GetClass());
			if (copy && (mode == 2 || (mode == 1 && incomingPair))) QueueOff(n, copy.GetClassName());
			else if (pair && mode != 0) QueueOff(n, OffEmptyName(pmo));
			drawTic[n] = level.maptime + 1;
			drawClass[n] = incoming.GetClassName();
		}
		else
		{
			let empty = EmptyHand(pmo);
			if (empty && empty != w) p.PendingWeapon = empty;
			if (pair && Opt("rsqtr_pairs", p, 0) != 0) QueueOff(n, OffEmptyName(pmo));
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
		// DRAWN AS A PAIR (the owner, 10-27: "call up the dual pistol or SMG from that holster"):
		// rsqtr_pairs 2 whenever you own the gun's off-hand copy, 1 only if it went away as a pair,
		// 0 never. The copy follows into the off hand once the main hand has switched.
		int mode = Opt("rsqtr_pairs", p, 2);
		let copy = OffCopy(pmo, wc);
		if (copy && (mode == 2 || (mode == 1 && lastPair[slot]))) QueueOff(n, copy.GetClassName());
		if (IsGunRegion(r)) { lastPut[slot] = ""; lastPair[slot] = false; }
		drawTic[n] = level.maptime + 1;
		drawClass[n] = w.GetClassName();
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

	// What the off hand holds when it is empty: the pack's own hands weapon (BD22Q's RSQ_Hands).
	static String OffEmptyName(PlayerPawn pmo)
	{
		String hn = "RSQ_Hands";        // a run-time lookup: null without Brutal Doom Quest
		class<Weapon> h = hn;
		return h ? hn : "";
	}

	private void QueueOff(int n, String cls)
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
			if (!playeringame[n] || !p.mo || p.mo.health <= 0 || --offWait[n] <= 0) { offNext[n] = ""; continue; }
			if (p.PendingWeapon != WP_NOCHANGE) continue;          // the main hand is still switching
			class<Weapon> c = offNext[n];
			offNext[n] = "";
			if (!c) continue;
			let w = Weapon(p.mo.FindInventory(c));
			if (!w) { p.mo.GiveInventory(c, 1); w = Weapon(p.mo.FindInventory(c)); }
			if (w && p.OffhandWeapon != w) p.PendingWeapon = w;
		}
	}

	// ---- the local loop (console player) ----------------------------------------------
	override void WorldTick()
	{
		TickPairs();
		if (afterLoad) { afterLoad = false; ClearLocalMarks(); }
		if (!migrated) { migrated = true; MigratePlaces(); }
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		if (!body) body = new("RSQTR_Body");
		body.Update(pmo);

		bool on = pmo.health > 0 && Flag("rsqtr_on", p, true);
		if (!on) { HideAll(); return; }

		int n = consoleplayer;
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		bool useEdge = useDown && !useWas;
		bool usePress = Flag("rsqtr_use", p, true);
		bool gripOk = Flag("rsqtr_grip", p, true);

		for (int h = 0; h < 2; h++)
		{
			if (buzzCool[h] > 0) buzzCool[h]--;
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			int r = -1;
			double best = 1e9;
			for (int i = 0; i < RSQTR_Region.N; i++)
			{
				if (!RegionLive(pmo, i)) continue;
				double d = RSQTR_Body.RoomMetres(hp, RegionAt(pmo, i));
				if (d <= RegionRadius(p, i) && d < best) { best = d; r = i; }
			}
			// THE ENGINE'S STEADYING IS NOT A REACH. An off hand within half a metre
			// of the gun with its grip held is holding the gun steady, not a holster.
			if (h == 1 && r >= 0 && gripDown[n * 2 + 1]
				&& RSQTR_Body.RoomMetres(pmo.OffhandPos, pmo.AttackPos) < STEADY_RANGE
				&& CVarOn("vr_two_handed_weapons"))
				r = -1;
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
			bool release = !pressNow && pressWas[h];
			pressWas[h] = pressNow;

			// EDIT MODE (rsqtr_edit): grip in a region carries it with the hand; let go
			// and it stays there, saved to that region's settings.
			if (Flag("rsqtr_edit", p, false))
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
			if (edge && r >= 0) pendPress[h] = true;
			if (!pressNow) pendPress[h] = false;
			if (pendPress[h] && r >= 0 && hoverT[h] >= dwell) { pendPress[h] = false; Press(pmo, p, h, r, hp); }
		}
		useWas = useDown;
		DrawMarkers(pmo, p);
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
	}

	private void SaveEdit(PlayerPawn pmo, PlayerInfo p)
	{
		int r = editRegion;
		double f, l, u;
		BodyOffsets(pmo, editAt, f, l, u);
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
		Array<String> own;
		Owned(pmo, r, own);
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
			int home = RSQTR_Body.LeftHanded() ? RSQTR_Region.SABER_R : RSQTR_Region.SABER_L;
			bool itsOwn = r == home || ((r == 0 || r == 1) && Flag("rsqtr_saber_hip", p, false));
			if (!itsOwn && spotEmpty)
			{
				EventHandler.SendNetworkEvent("rsqtr_holster", home);
				RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
				return;
			}
		}
		// THE SECOND SABER'S HOLSTER: the saber itself takes it out to the off hand or puts it
		// back (its ubqs_dual_out / ubqs_dual_in, the same thing its Dual key does).
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

	// The sphere's skin (MODELDEF RSQTR_Marker): A blue idle, B green with a hand inside, C-E
	// profiles 2-4 orange, purple, yellow. Colour-blind play (rsqa_colorblind, cb.zs): those five
	// are three or four colours to a dichromat (simulated, the closest pair is 6.1 apart for
	// protanopia), so each vision gets its own five (F-T, tools/gen_cb_skins.py), at least 17.4
	// apart in the vision they are for (as drawn); inside is the series HAVE colour.
	static int MarkerFrame(bool inside, int prof)
	{
		static const int IDLE[] = { 0, 2, 3, 4 };
		static const int CBBASE[] = { 0, 5, 5, 10, 15 };
		prof = clamp(prof, 1, 4);
		int cb = RSQTR_CB.Mode();
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
			bool inside = hoverR[0] == r || hoverR[1] == r;
			bool live = RegionLive(pmo, r);
			double a = 0;
			if (live && mode > 0)
			{
				if (mode >= 2) a = inside ? 0.7 : 0.25;
				else if (near < rad * 2.5) a = inside ? 0.7 : 0.35 * (1.0 - (near - rad) / (rad * 1.5));
			}
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
					double s = rad * RSQTR_Body.UPM * (inside ? 1.15 : 1.0);   // the wireframe sphere has radius 1.0
					m.Scale = (s, s);
					m.frame = MarkerFrame(inside, Opt("rsqtr_profile_active", p, 1));
				}
			}
			else if (marker[r]) marker[r].bINVISIBLE = true;

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
			}
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
					ic.Wear(put, 0.28 * sc, 0.85);
					double by = (body && body.primed) ? body.yaw : pmo.angle;
					ic.Place(ShowAt(at, r, by, metres));
					Hang(ic, r, by + Num("rsqtr_icon_turn", p, 0), metres, 0.28 * sc);
				}
			}
			else if (icon[r]) icon[r].bINVISIBLE = true;
		}
	}

	// HOW A STORED GUN HANGS, the way it is worn (the owner's reference pictures, 10-27:
	// concealed-carry positions, a slung rifle, rifles on a pack). Degrees from the body's
	// heading; an actor's pitch is positive nose-DOWN; a pickup points its muzzle along its
	// own forward axis, lying level with the grip down. For a right-handed player:
	//   hips, saber spots  muzzle down
	//   shoulders          on the back: butt up over the shoulder, muzzle down toward the other hip
	// A left-handed player gets the mirror image. Sprites face you whatever is set.
	static void Hang(RSQTR_Icon ic, int r, double yaw, double metres, double fallback)
	{
		double s = RSQTR_Body.LayoutLeft() ? -1 : 1;   // flips left and right (rsqa_handed, else the engine's)
		double off = 0, pt = 0, rl = 0;               // off: muzzle heading from the body's
		switch (r)
		{
		case 9: case 0: off = 0;   pt = 80; rl = -10; break;  // left hip, left saber: hanging down
		case 10: case 1: off = 0;  pt = 80; rl = 10;  break;  // right hip, right saber
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
		double u = RSQTR_Body.UPM;
		double down = DOWN_SHOW * metres;
		return at - (cos(yaw) * BACK_SHOW * u, sin(yaw) * BACK_SHOW * u, down * u / RSQTR_Body.PIXELSTRETCH);
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
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		hoverR[0] = -1; hoverR[1] = -1;
		afterLoad = false;
	}

	// The rings and icons are this machine's alone and held by transient pointers, so a
	// save carries orphan copies of them: cleared on load (and respawned as needed).
	static void ClearLocalMarks()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
			if (a is "RSQTR_Marker" || a is "RSQTR_Icon" || a is "RSQTR_TorsoPart" || a is "RSQTR_MarinePart" || a is "RSQTR_HelmetPart" || a is "RSQTR_HeldShow") a.Destroy();
	}

	// OnRegister also runs when a save is loaded (a level's handlers get no WorldLoaded
	// then), so it notes it: the first tic clears the orphan rings and icons the save held.
	private transient bool afterLoad;
	override void OnRegister()
	{
		editHand = -1; editRegion = -1;
		hoverR[0] = -1; hoverR[1] = -1;
		afterLoad = true;
	}
}

// The soft ring that shows a region.
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
		RenderStyle "Translucent";
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
		double s = metres * RSQTR_Body.UPM / fit.len[at];
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
