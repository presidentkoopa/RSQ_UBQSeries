// ERMAC'S CIGARETTE (optional tribute, off by default: rsqtr_cig). THE RITUAL (the owner, 2026-11-02):
//
//   "when the cigarette is out we need to have it intercept the use key. with cig in hand we bring to mouth and press
//    use. if we press use before bringing it to mouth or outside of mouth zone, it is flicked away from us. once in
//    mouth, we use zippo in offhand by pressing offhand fire to light it, bring it to cigarette, and we press Use to
//    light the cigarette and start smoking. smoke for 2 seconds, adjustable in menu up to five. cigarette flicks out
//    from mouth, slomo begins."
//
//   0. Grip at the pocket on your left chest (right chest left-handed) with the MAIN hand: the cigarette is in that
//      hand (RSQTR_CigWeapon) and the Zippo in the off hand (RSQTR_ZippoWeapon). Grip at the pocket again: back in.
//   1. FROM HERE ON USE IS THE CIGARETTE'S. Nothing else gets the press: no door, no switch (the engine's use is held
//      off by keeping PlayerInfo.usedown set, p_user.cpp P_CheckUse), no holster, no watch move.
//      Use with the cigarette hand in the MOUTH ZONE (MOUTH_R around Mouth(), in front of the eyes): it goes in the
//      mouth and stays there, following the head; the main hand has its gun back.
//      Use anywhere else: it is FLICKED away from you (a small arc, a tiny ember, the rig's own foley).
//   2. In the mouth: OFF-HAND FIRE flicks the Zippo open and lit (again: shut). Bring its flame to the tip and press
//      Use: it lights and you smoke (a glowing tip, smoke from the tip, a puff now and then). Use with the flame
//      anywhere else does nothing; a cigarette in the mouth is never flicked by Use.
//   3. Smoke for rsqtr_cig_smoke seconds (menu slider, 2 by default, 1 to 5 in half seconds).
//   4. It flicks out of the mouth (the same flick) and you exhale; RSQ_SlowMo starts (its "rsm_pulse" network event,
//      asked by name; without RSQ_SlowMo the event goes nowhere and the ritual ends with the flick).
//   CANCELS: the main hand switched away from the cigarette (another gun, a holster); the off hand taken from the
//   Zippo for a second (another mod or the player); the Cigarettes row or the rig switched off: an unlit cigarette goes
//   back in the pocket. Death: it is gone. A level change: an unlit one goes back in the pocket and the hands get their
//   guns back (RSQTR_CigPack remembers them, since this handler is rebuilt on every map).
//
// The idea is Ermac's: the cigarette, its butt and its smoke come from his Virtual Tactical Vest for Doom VR (its credits
// name him as their modeller; the cigarette's texture is an atlas shared with a Sketchfab cigarette-pack model, its pack
// art blanked here), and the Zippo is the voxel lighter from his ZBlood-VR, credited to him there. tools/gen_handprops.py
// bakes both into Brutal Doom VR's hand. A pocket holds a few (rsqtr_cig_count), refilled on a new level.
//
// NETPLAY: the hands are the console player's alone, so that machine decides and sends one event per action (take, put
// back, to the mouth, flick, the Zippo, light); every machine runs the same steps from them, and the timed steps (the
// smoke, the flick from the mouth, the cancels) from synced state.

class RSQTR_Cig : EventHandler
{
	const POCKET_F = 0.12;
	const POCKET_L = 0.16;
	const POCKET_U = -0.25;
	const POCKET_R = 0.09;
	// THE MOUTH ZONE (metres, measured on the rig 11-02, README): its centre 0.07 forward of the eyes and 0.09 under them
	// (the lips), a 0.15 sphere around it, and only in front of the eyes. The test point is the controller, which holds
	// the cigarette's filter a few centimetres out (the baked pinch, tools/gen_handprops.py): a hand raised to the lips
	// measured 0.05 from the centre, a hand at the chest 0.21 and the resting pose 0.40.
	const MOUTH_F = 0.07;
	const MOUTH_D = 0.09;
	const MOUTH_R = 0.15;
	const TIP_F = 0.07;          // the burning end at the mouth: 7 cm further out, 2 cm lower
	const TIP_D = 0.02;
	// THE FLAME: the Zippo stands in the fist with its top ~5 hand-cm over the controller (gen_handprops.py ZIP_FLOOR +
	// ZIP_H); the flame is over that. The test point is the controller raised FLAME_UP, within FLAME_R of the tip.
	const FLAME_UP = 0.06;
	const FLAME_R = 0.12;
	const ZIP_LIT_TICS = 7;      // the lid opens over 6 tics, then the flame takes (RSQTR_ZippoWeapon Open)
	const ZIP_AWAY_TICS = 12;    // after the tip catches: the Zippo shuts and goes away
	const PUFF_TICS = 30;        // a puff from the mouth while smoking
	// THE FLICK (map units a tic): from the mouth on the rig it first touched down 2.5 m out and came to rest by 3.5 m
	const FLICK_SPEED = 2.6;
	const FLICK_UP = 3.0;
	const BUSY_TICS = 35;        // the off hand without the Zippo this long: the ritual is off
	const SWITCH_TICS = 6;       // the main hand away from the cigarette this long: put back

	const PH_NONE = 0;
	const PH_HAND = 1;           // in the hand
	const PH_MOUTH = 2;          // in the mouth, not lit
	const PH_SMOKE = 3;          // lit, smoking

	// ---- synced --------------------------------------------------------------------
	int  phase[MAXPLAYERS];
	int  phaseTic[MAXPLAYERS];
	bool zipOpen[MAXPLAYERS];
	int  zipTic[MAXPLAYERS];
	int  smokeTics[MAXPLAYERS];  // how long this smoke lasts (rsqtr_cig_smoke when it was lit)
	int  offGone[MAXPLAYERS];    // tics the off hand has been without the Zippo
	int  mainGone[MAXPLAYERS];   // tics the main hand has been away from the cigarette (in the hand)
	bool restore[MAXPLAYERS];    // a level change found the cigarette or the Zippo still in a hand
	String prevMain[MAXPLAYERS], prevOff[MAXPLAYERS];
	Actor mouthProp[MAXPLAYERS];
	int  spitTic[MAXPLAYERS];    // when the last flick from the mouth was (the console player's SlowMo starts on it)

	// ---- local (console player) ----------------------------------------------------
	private transient bool gripWas, useWas, offFireWas;
	private transient int spitSeen;
	private transient Actor pocketMark;

	static RSQTR_Cig Get() { return RSQTR_Cig(EventHandler.Find("RSQTR_Cig")); }

	// The pocket's count lives on the player (RSQTR_CigPack), because an EventHandler is
	// rebuilt on every map and its fields would not carry the count to the next level.
	static int Packs(PlayerPawn pmo) { return pmo ? pmo.CountInv("RSQTR_CigPack") : 0; }

	// Other files: is the cigarette out for this player (Use is the cigarette's)?
	static bool IsOut(int n)
	{
		let c = Get();
		return c && n >= 0 && n < MAXPLAYERS && c.phase[n] != PH_NONE;
	}

	// No OnRegister on purpose: it also runs when a save is loaded, after the synced
	// fields are read back (p_saveg.cpp), and would wipe them. A level's handlers get
	// no WorldLoaded on a load (events.cpp), so this runs for new levels only.
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			phase[i] = PH_NONE; zipOpen[i] = false; mouthProp[i] = null; spitTic[i] = -100; restore[i] = false;
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
			let p = players[i];
			int count = RSQTR_Rig.Opt("rsqtr_cig_count", p, 3);
			let tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack"));
			if (!tok) { pmo.SetInventory("RSQTR_CigPack", count); tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack")); }
			else
			{
				// out at the level change and never lit: back in the pocket
				if (tok.held == PH_HAND || tok.held == PH_MOUTH) tok.Amount++;
				if (RSQTR_Rig.Flag("rsqtr_cig_refill", p, true)) tok.Amount = count;
			}
			if (tok)
			{
				prevMain[i] = tok.prevMain; prevOff[i] = tok.prevOff;
				tok.held = PH_NONE;
			}
			// still in a hand from the last level: the hands get their guns back on the first tic
			restore[i] = (p.ReadyWeapon is "RSQTR_CigWeapon") || (p.PendingWeapon is "RSQTR_CigWeapon") || (p.OffhandWeapon is "RSQTR_ZippoWeapon");
			if (!restore[i])
			{
				pmo.TakeInventory("RSQTR_CigWeapon", 999);
				pmo.TakeInventory("RSQTR_ZippoWeapon", 999);
			}
		}
	}

	// On the left chest for a right-hander and the right chest for a left-hander
	// (RSQTR_Body.LayoutLeft: rsqa_handed, else the engine's), so the main hand reaches across.
	Vector3 Pocket(PlayerPawn pmo)
	{
		double l = RSQTR_Body.LayoutLeft() ? -POCKET_L : POCKET_L;
		let rig = RSQTR_Rig.Get();
		if (rig) return rig.BodyPoint(pmo, POCKET_F, l, POCKET_U);
		RSQTR_Body tmp = new("RSQTR_Body");
		tmp.yaw = pmo.angle; tmp.primed = true;
		return tmp.At(pmo, POCKET_F, l, POCKET_U);
	}

	// Metres forward along where you face, and down, from the eyes, in the HEAD's frame: it turns and nods with the head
	// (map units per metre read live, RSQTR_Body; the head's pitch is the pawn's, positive looking down).
	static Vector3 FromEyes(PlayerPawn pmo, double fwd, double down)
	{
		double u = RSQTR_Body.Upm();
		double hp = clamp(pmo.pitch, -60, 60);
		double horiz = fwd * cos(hp) - down * sin(hp);     // forward along the ground
		double vert = -fwd * sin(hp) - down * cos(hp);     // up
		return Eyes(pmo) + (cos(pmo.angle) * horiz * u, sin(pmo.angle) * horiz * u, vert * u / RSQTR_Body.Ps());
	}
	// YOUR REAL EYES, where the headset is: the room floor plus the headset's height, placed as the engine places the
	// hands (RSQTR_Body.RoomFloor / EyeUnits). Not player.viewz, which is the pawn's fixed eye (41 units, ~1.45 m) and on
	// the rig sat 0.15 m under a 1.6 m headset, which put the mouth at the chin. No headset height: the pawn's eye.
	static Vector3 Eyes(PlayerPawn pmo)
	{
		double hy = pmo.HmdPosition.y;
		if (hy <= 0.3) return RSQTR_Body.Head(pmo);
		return (pmo.pos.x, pmo.pos.y, RSQTR_Body.RoomFloor(pmo) + RSQTR_Body.EyeUnits(pmo, hy));
	}
	// The lips: the centre of the mouth zone, and where the cigarette sits in the mouth.
	static Vector3 Mouth(PlayerPawn pmo) { return FromEyes(pmo, MOUTH_F, MOUTH_D); }
	// The cigarette's burning end at the mouth.
	static Vector3 MouthTip(PlayerPawn pmo) { return FromEyes(pmo, MOUTH_F + TIP_F, MOUTH_D + TIP_D); }

	// How far the main hand is from the mouth zone's centre (metres), and whether it is in the zone.
	static double MouthDist(PlayerPawn pmo) { return RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 0), Mouth(pmo)); }
	static bool InMouthZone(PlayerPawn pmo)
	{
		Vector3 d = RSQTR_Body.Hand(pmo, 0) - Eyes(pmo);
		double fwd = (d.x * cos(pmo.angle) + d.y * sin(pmo.angle)) / RSQTR_Body.Upm();
		return fwd > 0 && MouthDist(pmo) < MOUTH_R;
	}
	// The Zippo's flame (the off controller raised FLAME_UP) to the burning end, metres.
	static double FlameDist(PlayerPawn pmo)
	{
		Vector3 f = RSQTR_Body.Hand(pmo, 1) + (0, 0, FLAME_UP * RSQTR_Body.Upm() / RSQTR_Body.Ps());
		return RSQTR_Body.RoomMetres(f, MouthTip(pmo));
	}
	bool ZipBurning(int n) { return zipOpen[n] && level.maptime - zipTic[n] >= ZIP_LIT_TICS; }

	// ---- the local loop ----------------------------------------------------------------
	override void WorldTick()
	{
		Steps();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) { HideMark(); return; }
		let pmo = p.mo;
		int n = consoleplayer;
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		bool useEdge = useDown && !useWas;
		useWas = useDown;
		if (!RSQTR_Rig.Flag("rsqtr_cig", p, false)) { HideMark(); return; }
		let rig = RSQTR_Rig.Get();
		Vector3 pocket = Pocket(pmo);
		bool msg = RSQTR_Rig.Flag("rsqtr_messages", p, false);

		// the pocket: the main hand's grip takes one or puts it back; Use there takes one only while none is out
		Vector3 hp = RSQTR_Body.Hand(pmo, 0);
		double dp = RSQTR_Body.RoomMetres(hp, pocket);
		double nearest = min(dp, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 1), pocket));
		bool grip = rig && rig.gripDown[n * 2];
		bool gripEdge = grip && !gripWas;
		gripWas = grip;
		bool atPocket = dp < POCKET_R;
		if (atPocket && (gripEdge || (useEdge && phase[n] == PH_NONE)))
		{
			if (phase[n] == PH_NONE)
			{
				if (Packs(pmo) > 0) EventHandler.SendNetworkEvent("rsqtr_cigtake");
				else RSQTR_Buzzer.Start(pmo, 0, 0.2, 3);
				useEdge = false;
			}
			else if (phase[n] == PH_HAND && gripEdge) EventHandler.SendNetworkEvent("rsqtr_cigback");
		}

		// USE IS THE CIGARETTE'S while it is out
		if (useEdge && phase[n] == PH_HAND)
		{
			bool inZone = InMouthZone(pmo);
			if (msg) Console.Printf("T_CIG use in hand: hand %.3f m from the mouth (zone %.2f) -> %s", MouthDist(pmo), MOUTH_R, inZone ? "mouth" : "flick");
			EventHandler.SendNetworkEvent(inZone ? "rsqtr_ciglock" : "rsqtr_cigflick");
		}
		else if (useEdge && phase[n] == PH_MOUTH)
		{
			bool zip = p.OffhandWeapon is "RSQTR_ZippoWeapon";
			double fd = FlameDist(pmo);
			bool ok = zip && ZipBurning(n) && fd < FLAME_R;
			if (msg) Console.Printf("T_CIG use in mouth: zippo %s, flame %.3f m from the tip (reach %.2f) -> %s", !zip ? "not in hand" : (ZipBurning(n) ? "lit" : "shut"), fd, FLAME_R, ok ? "light" : "nothing");
			if (ok) EventHandler.SendNetworkEvent("rsqtr_ciglight");
		}

		// off-hand fire: the Zippo open and lit / shut (not while smoking: it has gone away)
		bool off = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
		bool offEdge = off && !offFireWas;
		offFireWas = off;
		if (offEdge && p.OffhandWeapon is "RSQTR_ZippoWeapon" && (phase[n] == PH_HAND || phase[n] == PH_MOUTH))
			EventHandler.SendNetworkEvent("rsqtr_zipflick");

		// the flick from the mouth: RSQ_SlowMo starts with it (its "rsm_pulse <ms> <depth %>" network event, by name)
		if (spitTic[n] != spitSeen && spitTic[n] == level.maptime)
		{
			spitSeen = spitTic[n];
			if (RSQTR_Rig.Flag("rsqtr_cig_slowmo", p, true))
			{
				int ms = int(RSQTR_Rig.Num("rsqtr_cig_secs", p, 6) * 1000);
				int depth = RSQTR_Rig.Opt("rsqtr_cig_depth", p, 25);
				EventHandler.SendNetworkEvent("rsm_pulse", ms, depth);
				if (msg) Console.Printf("T_CIG slow motion asked: rsm_pulse %d %d", ms, depth);
			}
		}

		ShowMark(pocket, nearest);
	}

	private void ShowMark(Vector3 at, double nearest)
	{
		let p = players[consoleplayer];
		int mode = RSQTR_Rig.Opt("rsqtr_markers", p, 1);
		bool show = mode == 2 || (mode == 1 && nearest < 0.30);
		if (!show) { HideMark(); return; }
		if (!pocketMark) pocketMark = Actor.Spawn("RSQTR_Marker", at);
		if (!pocketMark) return;
		pocketMark.SetOrigin(at, true);
		pocketMark.bINVISIBLE = false;
		pocketMark.Alpha = nearest < POCKET_R ? 0.9 : 0.35;
		pocketMark.Scale = (POCKET_R * RSQTR_Body.Upm(), POCKET_R * RSQTR_Body.Upm());   // the wireframe sphere: radius 1.0
		pocketMark.frame = nearest < POCKET_R ? 1 : 0;
	}
	private void HideMark() { if (pocketMark) pocketMark.bINVISIBLE = true; }

	// ---- every machine ----------------------------------------------------------------
	private void SetPhase(int n, int ph)
	{
		phase[n] = ph; phaseTic[n] = level.maptime; offGone[n] = 0; mainGone[n] = 0;
		let pmo = players[n].mo;
		let tok = pmo ? RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack")) : null;
		if (tok) { tok.held = ph; tok.prevMain = prevMain[n]; tok.prevOff = prevOff[n]; }
	}

	// The hands back as they were: the main hand's gun, the off hand's (or Brutal Doom Quest's empty hand).
	private void MainBack(PlayerPawn pmo, int n)
	{
		class<Weapon> wc = prevMain[n];
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w) w = RSQTR_Rig.EmptyHand(pmo);
		if (w && !(w is "RSQTR_CigWeapon")) pmo.player.PendingWeapon = w;
		else if (pmo.player.ReadyWeapon is "RSQTR_CigWeapon") pmo.PickNewWeapon(null);
	}
	private void OffBack(PlayerPawn pmo, int n)
	{
		let rig = RSQTR_Rig.Get();
		String o = prevOff[n];
		class<Weapon> oc = o;
		if (!oc || !pmo.FindInventory(oc)) o = RSQTR_Rig.OffEmptyName(pmo);
		if (rig && o != "") rig.QueueOff(n, o);
		else { pmo.player.SetPsprite(PSP_OFFHANDWEAPON, null); pmo.player.OffhandWeapon = null; }
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		let p = players[n];
		if (e.Name.Left(9) == "rsqtr_cig" || e.Name.Left(9) == "rsqtr_zip")
			if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_CIG %s t%d phase %d", e.Name, level.maptime, phase[n]);

		if (e.Name == "rsqtr_cigtake")
		{
			if (phase[n] != PH_NONE || Packs(pmo) <= 0) return;
			pmo.TakeInventory("RSQTR_CigPack", 1);
			prevMain[n] = p.ReadyWeapon && !(p.ReadyWeapon is "RSQTR_CigWeapon") ? p.ReadyWeapon.GetClassName() : 'None';
			if (prevMain[n] == "None") prevMain[n] = "";
			prevOff[n] = p.OffhandWeapon && !(p.OffhandWeapon is "RSQTR_ZippoWeapon") ? p.OffhandWeapon.GetClassName() : 'None';
			if (prevOff[n] == "None") prevOff[n] = "";
			if (!pmo.FindInventory("RSQTR_CigWeapon")) pmo.GiveInventory("RSQTR_CigWeapon", 1);
			if (!pmo.FindInventory("RSQTR_ZippoWeapon")) pmo.GiveInventory("RSQTR_ZippoWeapon", 1);
			p.PendingWeapon = Weapon(pmo.FindInventory("RSQTR_CigWeapon"));
			let rig = RSQTR_Rig.Get();
			if (rig) rig.QueueOff(n, "RSQTR_ZippoWeapon");
			zipOpen[n] = false;
			SetPhase(n, PH_HAND);
			p.usedown = true;      // from this tic the engine's use is held off (Steps keeps it so)
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.6);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigback")
		{
			if (phase[n] != PH_HAND) return;
			PutBack(pmo, n);
		}
		else if (e.Name == "rsqtr_ciglock")
		{
			if (phase[n] != PH_HAND) return;
			let c = RSQTR_CigProp(Actor.Spawn("RSQTR_CigProp", Mouth(pmo)));
			if (c) { c.holder = pmo; c.atMouth = true; }
			mouthProp[n] = c;
			MainBack(pmo, n);
			SetPhase(n, PH_MOUTH);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.4);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigflick")
		{
			if (phase[n] != PH_HAND) return;
			Flick(pmo, n, false);
			MainBack(pmo, n);
			EndZippo(pmo, n);
			SetPhase(n, PH_NONE);
		}
		else if (e.Name == "rsqtr_zipflick")
		{
			if (!(p.OffhandWeapon is "RSQTR_ZippoWeapon") || (phase[n] != PH_HAND && phase[n] != PH_MOUTH)) return;
			zipOpen[n] = !zipOpen[n];
			zipTic[n] = level.maptime;
			pmo.A_StartSound(zipOpen[n] ? "rsqtr/zipopen" : "rsqtr/zipclose", CHAN_AUTO, 0, 0.8);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 1, 0.4, 4);
		}
		else if (e.Name == "rsqtr_ciglight")
		{
			if (phase[n] != PH_MOUTH || !ZipBurning(n) || !(p.OffhandWeapon is "RSQTR_ZippoWeapon")) return;
			let c = RSQTR_CigProp(mouthProp[n]);
			if (c) { c.SetLit(); c.Flare(); }
			smokeTics[n] = int(round(clamp(RSQTR_Rig.Num("rsqtr_cig_smoke", p, 2.0), 1.0, 5.0) * TICRATE));
			SetPhase(n, PH_SMOKE);
			pmo.A_StartSound("rsqtr/ciglight", CHAN_AUTO, 0, 0.7);
			pmo.A_StartSound("rsqtr/inhale", CHAN_AUTO, 0, 0.9);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 1, 0.5, 6);
			if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_CIG lit t%d: smoking %d tics (%.1f s)", level.maptime, smokeTics[n], smokeTics[n] / double(TICRATE));
		}
	}

	// An unlit cigarette back in the pocket, the hands as they were.
	private void PutBack(PlayerPawn pmo, int n)
	{
		pmo.GiveInventory("RSQTR_CigPack", 1);
		if (mouthProp[n]) mouthProp[n].Destroy();
		mouthProp[n] = null;
		if (phase[n] == PH_HAND) MainBack(pmo, n);
		EndZippo(pmo, n);
		SetPhase(n, PH_NONE);
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
	}

	// The Zippo shut and out of the off hand (if it is still there).
	private void EndZippo(PlayerPawn pmo, int n)
	{
		if (zipOpen[n]) pmo.A_StartSound("rsqtr/zipclose", CHAN_AUTO, 0, 0.6);
		zipOpen[n] = false;
		let rig = RSQTR_Rig.Get();
		bool queued = rig && rig.offNext[n] == "RSQTR_ZippoWeapon";
		if (queued) rig.offNext[n] = "";
		if (pmo.player.OffhandWeapon is "RSQTR_ZippoWeapon") OffBack(pmo, n);
	}

	// The smoke, the flick from the mouth, the cancels; and tidying the two hand weapons away once they are out of the hands.
	private void Steps()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			let p = players[n];
			let rig = RSQTR_Rig.Get();

			// NO POCKET AT ALL: Brutal Doom clears the player's inventory as a level starts, after WorldLoaded gave the
			// pocket (rig 11-02, the full load order: the pocket was empty and nothing came out). Give it again.
			if (!pmo.FindInventory("RSQTR_CigPack") && pmo.health > 0)
				pmo.SetInventory("RSQTR_CigPack", RSQTR_Rig.Opt("rsqtr_cig_count", p, 3));

			// a level change found them still in a hand: the guns back, once the rig is up
			if (restore[n] && level.maptime > 1)
			{
				restore[n] = false;
				if (p.ReadyWeapon is "RSQTR_CigWeapon" || p.PendingWeapon is "RSQTR_CigWeapon") MainBack(pmo, n);
				if (p.OffhandWeapon is "RSQTR_ZippoWeapon") OffBack(pmo, n);
			}

			if (phase[n] != PH_NONE)
			{
				// USE IS THE CIGARETTE'S: the engine's use (doors, switches) sees the key as already down
				// (P_CheckUse acts on the rising edge only and clears this flag itself on release).
				p.usedown = true;

				if (pmo.health <= 0)
				{
					if (mouthProp[n]) mouthProp[n].Destroy();
					mouthProp[n] = null;
					zipOpen[n] = false;
					SetPhase(n, PH_NONE);
				}
				else if (!RSQTR_Rig.Flag("rsqtr_cig", p, false) || !RSQTR_Rig.Flag("rsqtr_on", p, true))
				{
					if (phase[n] == PH_SMOKE) Spit(pmo, n, false);
					else PutBack(pmo, n);
				}
			}

			int age = level.maptime - phaseTic[n];
			// HOLSTERED / SWITCHED AWAY: the main hand no longer holds or raises the cigarette
			if (phase[n] == PH_HAND)
			{
				let cw = pmo.FindInventory("RSQTR_CigWeapon");
				bool held = cw && (p.ReadyWeapon == cw || p.PendingWeapon == cw);
				mainGone[n] = held ? 0 : mainGone[n] + 1;
				if (mainGone[n] >= SWITCH_TICS) PutBack(pmo, n);
			}
			// THE ZIPPO HAND BUSY: the off hand holds something else (and the rig is not about to raise the Zippo)
			if (phase[n] == PH_HAND || phase[n] == PH_MOUTH)
			{
				bool zipThere = p.OffhandWeapon is "RSQTR_ZippoWeapon";
				bool zipComing = rig && rig.offNext[n] == "RSQTR_ZippoWeapon";
				offGone[n] = (zipThere || zipComing) ? 0 : offGone[n] + 1;
				if (zipOpen[n] && !zipThere) zipOpen[n] = false;
				if (offGone[n] >= BUSY_TICS)
				{
					if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_CIG the off hand is busy: back in the pocket t%d", level.maptime);
					PutBack(pmo, n);
				}
			}
			// SMOKING: the Zippo away, a puff now and then, then the flick from the mouth
			if (phase[n] == PH_SMOKE)
			{
				if (age == ZIP_AWAY_TICS) EndZippo(pmo, n);
				if (age > 0 && age % PUFF_TICS == 0) Puff(pmo, 3, 0.6);
				if (age >= smokeTics[n]) Spit(pmo, n, true);
			}

			// out of the hands: away (never left in a weapon slot)
			if (phase[n] != PH_HAND && !restore[n] && p.ReadyWeapon != pmo.FindInventory("RSQTR_CigWeapon") && p.PendingWeapon != pmo.FindInventory("RSQTR_CigWeapon"))
				pmo.TakeInventory("RSQTR_CigWeapon", 999);
			bool zipNeeded = phase[n] == PH_HAND || phase[n] == PH_MOUTH;
			if (!zipNeeded && !restore[n] && p.OffhandWeapon != pmo.FindInventory("RSQTR_ZippoWeapon") && !(rig && rig.offNext[n] == "RSQTR_ZippoWeapon"))
				pmo.TakeInventory("RSQTR_ZippoWeapon", 999);
		}
	}

	// THE FLICK: a small thrown cigarette, a short arc away from you, a tiny ember, the rig's foley.
	// From the hand (an unlit cigarette, out along the hand, away from the head) or from the mouth (the smoked butt,
	// straight out ahead; it smoulders where it lands and draws monsters, as Ermac's did).
	private void Flick(PlayerPawn pmo, int n, bool fromMouth)
	{
		Vector3 from;
		Vector2 dir;
		if (fromMouth)
		{
			from = MouthTip(pmo);
			dir = (cos(pmo.angle), sin(pmo.angle));
		}
		else
		{
			from = RSQTR_Body.Hand(pmo, 0);
			Vector2 away = from.xy - pmo.pos.xy;
			dir = away.Length() > 2 ? away.Unit() : (cos(pmo.AttackAngle), sin(pmo.AttackAngle));
			// a little of where the hand points, so a flick goes the way the wrist goes
			dir = (dir + (cos(pmo.AttackAngle), sin(pmo.AttackAngle)) * 0.5).Unit();
		}
		let b = RSQTR_Butt(Actor.Spawn(fromMouth ? "RSQTR_Butt" : "RSQTR_FlickedCig", from));
		if (b)
		{
			b.vel = (dir.x * FLICK_SPEED, dir.y * FLICK_SPEED, FLICK_UP) + pmo.vel;
			b.target = pmo;
			b.smoulder = fromMouth;
			b.spin = 24;
			b.angle = atan2(dir.y, dir.x);
			b.Ember();
		}
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
		if (RSQTR_Rig.Flag("rsqtr_messages", players[n], false))
			Console.Printf("T_CIG flick from the %s t%d at (%.0f %.0f %.0f) vel (%.1f %.1f %.1f)", fromMouth ? "mouth" : "hand", level.maptime, from.x, from.y, from.z, b ? b.vel.x : 0., b ? b.vel.y : 0., b ? b.vel.z : 0.);
	}

	// SMOKED: it flicks out of the mouth, you exhale; RSQ_SlowMo starts on this tic (WorldTick, the console player),
	// unless the smoke was cut short (slowmo false).
	private void Spit(PlayerPawn pmo, int n, bool slowmo)
	{
		Flick(pmo, n, true);
		if (mouthProp[n]) mouthProp[n].Destroy();
		mouthProp[n] = null;
		Puff(pmo, 8, 2.0);
		pmo.A_StartSound("rsqtr/exhale", CHAN_AUTO, 0, 0.9);
		EndZippo(pmo, n);
		if (slowmo) spitTic[n] = level.maptime;
		SetPhase(n, PH_NONE);
	}

	// Smoke from the mouth, out where you face.
	private void Puff(PlayerPawn pmo, int count, double size)
	{
		Vector3 m = Mouth(pmo);
		for (int i = 0; i < count; i++)
		{
			let s = Actor.Spawn("RSQTR_Smoke", m);
			if (s)
			{
				s.vel = (cos(pmo.angle) * (0.5 + i * 0.12), sin(pmo.angle) * (0.5 + i * 0.12), 0.12 + i * 0.02);
				s.Scale *= size;
			}
		}
	}
}

// ---- the cigarette and the Zippo in the hands: weapons on the hand's own layer -------------------------------------
// (MODELDEF: Brutal Doom VR's hand with the prop baked in; tools/gen_handprops.py.) Fire does nothing here: the rig's
// handler reads the buttons and acts (cig.zs RSQTR_Cig), so a press never punches or shoots.
class RSQTR_CigWeapon : Weapon
{
	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Tag "Cigarette";
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}
	States
	{
	Spawn:
		RTCW A -1;
		Stop;
	Select:
		RTCW A 1 A_Raise(24);
		Loop;
	Deselect:
		RTCW A 1 A_Lower(24);
		Loop;
	Ready:
		RTCW A 1 A_WeaponReady(WRF_NOFIRE);
		Loop;
	Fire:
		Goto Ready;
	}
}

class RSQTR_ZippoWeapon : Weapon
{
	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Tag "Zippo";
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}
	// the lid follows RSQTR_Cig.zipOpen: shut, opening over 6 tics, then the flame
	action state A_ZipReady(int lit)
	{
		A_WeaponReady(WRF_NOFIRE);
		let c = RSQTR_Cig.Get();
		int n = player ? PlayerPawn(self).PlayerNumber() : -1;
		bool open = c && n >= 0 && c.zipOpen[n];
		if (open && !lit) return ResolveState("Open");
		if (!open && lit) return ResolveState("Shut");
		return ResolveState(null);
	}
	States
	{
	Spawn:
		RTZW A -1;
		Stop;
	Select:
		RTZW A 1 A_Raise(24);
		Loop;
	Deselect:
		RTZW A 1 A_Lower(24);
		Loop;
	Ready:
		RTZW A 1 A_ZipReady(0);
		Loop;
	Open:
		RTZW EEFFGG 1;
	Burn:
		RTZW BB 1 Bright A_ZipReady(1);
		RTZW CC 1 Bright A_ZipReady(1);
		RTZW DD 1 Bright A_ZipReady(1);
		Loop;
	Shut:
		RTZW GGFFEE 1;
		Goto Ready;
	Fire:
		Goto Ready;
	}
}

// ---- the things in your hands -------------------------------------------------------------

// Shared: follows one hand of its holder, turned with that hand.
class RSQTR_HandProp : Actor
{
	PlayerPawn holder;
	int hand;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}

	void Follow(bool upright)
	{
		if (!holder) { Destroy(); return; }
		double yaw = hand == 0 ? holder.AttackAngle : holder.OffhandAngle;
		double pit = hand == 0 ? holder.AttackPitch : holder.OffhandPitch;
		double rol = hand == 0 ? holder.AttackRoll : holder.OffhandRoll;
		Vector3 at = RSQTR_Body.Hand(holder, hand);
		angle = yaw;
		pitch = upright ? 0 : -pit;      // AttackPitch is positive up; an actor's pitch is positive down
		roll = upright ? 0 : rol;
		SetOrigin(at, true);
	}

	// Along the hand: metres forward in the hand's own frame.
	Vector3 AlongHand(double metres)
	{
		double pit = hand == 0 ? holder.AttackPitch : holder.OffhandPitch;
		double c = cos(pit);
		return pos + (cos(angle) * c * metres * 34, sin(angle) * c * metres * 34, sin(pit) * metres * 34 / 1.2);
	}
}

class RSQTR_CigProp : RSQTR_HandProp
{
	bool burning;
	bool atMouth;        // held in the mouth: it follows the head (cig.zs RSQTR_Cig.Mouth), pointing out
	int age;

	// the draw's flare: the ember blazes and throws sparks
	void Flare()
	{
		A_RemoveLight("rsqtr_ember");
		A_AttachLight("rsqtr_ember", DynamicLight.PointLight, "FF7A20", 10, 0, DYNAMICLIGHT.LF_ATTENUATE);
		for (int i = 0; i < 6; i++)
		{
			let s = Actor.Spawn("RSQTR_Smoke", Tip());
			if (s) s.vel = (frandom(-0.2, 0.2), frandom(-0.2, 0.2), frandom(0.2, 0.5));
		}
	}

	// (RSQ_Accessibility's Photosensitive Mode: the ember glows steady, not pulsing)
	void SetLit()
	{
		burning = true; SetStateLabel("Lit");
		if (RSQTR_A11y.Photo()) A_AttachLight("rsqtr_ember", DynamicLight.PointLight, "FF6020", 3, 0, DYNAMICLIGHT.LF_ATTENUATE);
		else A_AttachLight("rsqtr_ember", DynamicLight.PulseLight, "FF6020", 2, 4, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 0), 0.4);
	}

	// The burning end: Ermac's mesh runs 9.5 units along X; at scale 0.3, ~1.7 forward.
	Vector3 Tip() { return !holder ? pos : (atMouth ? RSQTR_Cig.MouthTip(holder) : AlongHand(0.05)); }

	override void Tick()
	{
		if (atMouth)
		{
			if (!holder) { Destroy(); return; }
			angle = holder.angle;
			pitch = 8 + clamp(holder.pitch, -60, 60);   // a little down from where you look, as a cigarette hangs from the lips
			roll = 0;
			SetOrigin(RSQTR_Cig.Mouth(holder), true);
		}
		else Follow(false);
		if (bDestroyed) return;
		Super.Tick();
		if (burning && ++age % 4 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", Tip());
			if (s) s.vel = (frandom(-0.05, 0.05), frandom(-0.05, 0.05), frandom(0.15, 0.35));
		}
	}

	States
	{
	Spawn:
		RSCG A -1;
		Stop;
	Lit:
		RSCG B -1 Bright;
		Stop;
	}
}

class RSQTR_ZippoProp : RSQTR_HandProp
{
	int age;

	// The lid opens over 6 tics, then the flame takes.
	bool Burning() { return age > 7; }
	// The flame sits ~12 units up the mesh (measured: 10.6-14.1); MODELDEF scales it
	// by 0.17, so ~2 map units over the hand.
	const FLAME_UP = 12.0 * 0.17;
	Vector3 Flame() { return pos + (0, 0, FLAME_UP); }

	override void Tick()
	{
		Follow(true);
		if (bDestroyed) return;
		Super.Tick();
		age++;
		if (age == 7)
		{
			A_StartSound("rsqtr/ziplight", CHAN_AUTO, 0, 0.8);
			// RSQ_Accessibility's Photosensitive Mode: a steady flame, not a random flicker
			if (RSQTR_A11y.Photo()) A_AttachLight("rsqtr_zippo", DynamicLight.PointLight, "FFF4A1", 8, 0, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 2));
			else A_AttachLight("rsqtr_zippo", DynamicLight.RandomFlickerLight, "FFF4A1", 7, 10, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 2));
		}
	}

	States
	{
	Spawn:
		RSZP A 1;
		RSZP EEFFGG 1;
	Burn:
		RSZP BBCCDD 1 Bright;
		Loop;
	}
}

// ---- the flicked cigarette: Ermac's butt (from the mouth) or the whole cigarette (from the hand) ------------------
// A short arc, end over end, a tiny ember on it while it flies; then it lies where it lands. The smoked butt
// smoulders there and draws monsters, as Ermac's did; an unlit one just lies there and fades.
class RSQTR_Butt : Actor
{
	bool smoulder;
	double spin;         // degrees a tic end over end while it flies

	Default
	{
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS +BOUNCEONWALLS +BOUNCEONCEILINGS
		+NOTELEPORT +THRUSPECIES +DONTSPLASH
		Radius 2; Height 1;
		Speed 0; Damage 0;
		BounceFactor 0.3; WallBounceFactor 0.25; BounceType "Doom";
		Gravity 0.5;
	}

	// the tiny ember: a small orange light and a spark or two as it goes (steady under Photosensitive Mode)
	void Ember()
	{
		A_AttachLight("rsqtr_flick", DynamicLight.PointLight, "FF6A1A", 2, 0, DYNAMICLIGHT.LF_ATTENUATE);
	}

	virtual class<Actor> LyingClass() { return "RSQTR_ButtLying"; }

	override int SpecialMissileHit(Actor victim) { return 1; }   // it flies through creatures

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (spin != 0) pitch = (pitch + spin) % 360;
		if (level.maptime % 3 == 0)
		{
			let s = Actor.Spawn("RSQTR_Ember", pos);
			if (s) s.vel = (frandom(-0.1, 0.1), frandom(-0.1, 0.1), frandom(0.05, 0.2));
		}
		if (smoulder && level.maptime % 3 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", pos);
			if (s) s.vel = (0, 0, frandom(0.1, 0.3));
		}
	}

	States
	{
	Spawn:
		RSCB A -1 Bright;
		Stop;
	Death:
		TNT1 A 0
		{
			let l = RSQTR_ButtLying(Spawn(LyingClass(), pos));
			if (l) { l.lure = smoulder; l.angle = angle; }
		}
		Stop;
	}
}

// From the hand: the whole (unlit) cigarette (MODELDEF: Ermac's cigarette mesh).
class RSQTR_FlickedCig : RSQTR_Butt
{
	override class<Actor> LyingClass() { return "RSQTR_CigLying"; }
	States
	{
	Spawn:
		RSCF A -1 Bright;
		Stop;
	}
}

class RSQTR_ButtLying : Actor
{
	int countdown;
	bool lure;           // the smoked butt: it smoulders and draws monsters (Ermac's)

	Default
	{
		+SHOOTABLE +NOBLOOD +NOTARGETSWITCH +FRIENDLY +NOTELEPORT +DONTSPLASH
		-COUNTKILL
		Radius 2; Height 1;
		Mass 999999; Health 60;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		countdown = TICRATE * random(10, 30);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || InStateSequence(CurState, FindState("Death"))) return;
		if (--countdown <= 0) { SetStateLabel("Death"); return; }
		if (!lure) return;
		if (level.maptime % 2 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", pos);
			if (s) s.vel = (0, 0, frandom(0.1, 0.3));
		}
		// Ermac's: monsters near it take it for a target, and in the scramble for it
		// they hit each other.
		if (level.maptime % 35 == 0) A_AlertMonsters(200, AMF_TARGETEMITTER | AMF_TARGETNONPLAYER);
	}

	States
	{
	Spawn:
		RSCB A -1;
		Stop;
	Death:
		"####" "#" 0 A_NoBlocking;
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class RSQTR_CigLying : RSQTR_ButtLying
{
	States
	{
	Spawn:
		RSCF A -1;
		Stop;
	}
}

// The ember's spark: Doom's own bullet-puff sprite, tiny, orange-bright, gone in a few tics.
class RSQTR_Ember : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.06;
		Translation "0:255=%[0.00,0.00,0.00]:[1.00,0.45,0.08]";
	}
	States
	{
	Spawn:
		PUFF A 2 Bright;
		PUFF B 2 Bright A_FadeOut(0.3);
		PUFF B 1 Bright A_FadeOut(0.3);
		Wait;
	}
}


// Ermac's smoke: a soft puff that fades in, drifts and thins out.
class RSQTR_Smoke : Actor
{
	Default
	{
		+NOINTERACTION +FORCEXYBILLBOARD +NOTIMEFREEZE +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP
		Alpha 0.0;
		RenderStyle "Translucent";
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_Jump(256, "A", "B", "C", "D");
	A:	RSMK E 0; Goto FadeIn;
	B:	RSMK F 0; Goto FadeIn;
	C:	RSMK G 0; Goto FadeIn;
	D:	RSMK H 0; Goto FadeIn;
	FadeIn:
		"####" "#" 0 A_SetScale(frandom(0.015, 0.03));
	FadeInLoop:
		"####" "#" 1 A_FadeIn(frandom(0.02, 0.03));
		"####" "#" 0 A_JumpIf(Alpha >= 0.2, "FadeOut");
		Loop;
	FadeOut:
		"####" "#" 1 A_FadeOut(frandom(0.003, 0.004));
		"####" "#" 0 A_SetScale(Scale.X - 0.0002, Scale.Y - 0.00005);
		"####" "#" 0 A_JumpIf(Alpha <= 0, "Null");
		Loop;
	}
}

// The pocket's count, carried with the player from level to level.
class RSQTR_CigPack : Inventory
{
	int held;                    // what was out when this was last written (RSQTR_Cig.PH_*), for a level change
	String prevMain, prevOff;    // the guns the hands had before the cigarette came out

	Default
	{
		Inventory.MaxAmount 99;
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.KEEPDEPLETED
	}
}
