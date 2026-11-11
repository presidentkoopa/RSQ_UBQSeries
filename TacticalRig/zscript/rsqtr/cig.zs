// ERMAC'S CIGARETTE (optional tribute, off by default: rsqtr_cig). THE RITUAL (the owner, 2026-11-02 / 11-03, final):
//
//   0. "Cigarettes" on. Grip at the pocket on your left chest (right chest left-handed) with the MAIN hand: the
//      cigarette is in that hand (RSQTR_CigWeapon) and the Zippo in the off hand (RSQTR_ZippoWeapon). Main grip at the
//      pocket again: back in.
//   1. FROM HERE ON USE IS THE CIGARETTE'S. Nothing else gets the press: no door, no switch (the engine's use is held
//      off by keeping PlayerInfo.usedown set, p_user.cpp P_CheckUse), no holster, no watch move.
//      Use with the cigarette at the lips (the MOUTH ZONE: lips to just under the chin, the controller or the drawn
//      filter; InMouthZone), or up to GRACE_TICS after it left the zone: it goes in the mouth and stays there, following
//      the head; the main hand has its gun back. Use anywhere else: it is FLICKED away. Entering the zone gives a cue: a
//      glow at the drawn tip, a light tick in that hand, a soft sound. The main grip at the mouth takes an unlit
//      cigarette back out of the mouth into that hand.
//   2. LIGHTING IS THE ZIPPO'S OWN TRIGGER (owner 11-03): bring the Zippo's flame to the cigarette's tip (in the mouth)
//      and press OFF-HAND FIRE there: it lights and you smoke (a glowing tip, smoke from the tip, a puff now and then).
//      In reach the cue shows again (the glow at the tip, a tick in the off hand). Off-hand fire with the Zippo away
//      from the tip only flicks it open / shut. Use plays no part in lighting. Off-hand fire is read from the command
//      and also caught as the key going down (InputProcess, a tap shorter than a tic); nothing in the series eats it
//      while the Zippo is in the hand (RSQ Whip's OffFree never counts the Zippo as an empty hand).
//   3. Smoke for rsqtr_cig_smoke seconds (1 to 5). Use while smoking ends it early.
//   4. It flicks out of the mouth and you exhale; RSQ_SlowMo starts (its "rsm_pulse" network event, asked by name).
//
// THE MOUTH CIGARETTE, ALWAYS IN THE SAME PLACE IN THE VIEW (owner 11-03: "it never is in the same place in the face,
// I can't see it from the headset"). It is placed every tic from the eyes in the head's own frame: the pawn's place
// at the headset's height (Eyes, as the engine places the camera: hw_openxrdevice.cpp / gl_openvr.cpp GetViewShift),
// the head's yaw and pitch (no pitch clamp: until 11-03 a look past 60 degrees left it behind), never from where the
// hand was at the Use press. It sat 7 cm forward and 9 cm under the eyes, 52 degrees under the view's centre: past
// the lower edge of a headset's view (about 45-50 degrees), so only a sliver ever showed, and where depended on the
// smallest nod. It now sits rsqtr_cig_mouth_f forward and rsqtr_cig_mouth_d down ("Mouth Cigarette Forward / Down",
// 0.12 / 0.07 m, in Reset All), tilted MOUTH_TILT up: the lit tip about 21 degrees under the centre, bottom-centre
// of the view; it sticks out further than a real one would. Smoke rises from the tip into view. The flame's light zone
// follows it. The engine gives ZScript no headset roll, so a sideways head tilt is not taken out (it moves the
// cigarette a centimetre or two sideways in the view).
//
// THE END, ANY END (owner 11-03, final): a weapon switch of either hand (wheel, keys, next / prev, slot), switchhand,
// a holster press, another mod switching, death, a level change, Cigarettes off, the flick, the smoke done. In the SAME
// TIC: the ritual ends, the Zippo leaves the off hand (StripOff, its queued raise dropped), an unlit cigarette goes back
// in the pocket (refunded), a lit one is flicked (by a switch or a holster: as smoked, the slow motion starts; owner
// 11-11). Then:
//   - THE MAIN HAND gets what the player switched to: the switch is carried out, one press. The engine's own switch
//     (a slot key, the wheel, another mod) stands; a next / prev key from the cigarette, which is in no slot so the
//     engine finds nothing (player.zs PickNextWeapon), is worked out from the gun the hand had before (NextFrom); a
//     holster press does what it does with the hands as they are (rig.zs Press: draw, put away, swap). With no switch
//     (the flick, the smoke done, Cigarettes off) the main hand keeps or gets back its gun.
//   - THE OFF HAND gets the off-hand copy of that gun if you own one (Brutal Doom VR's RSQ_Off_<gun>, rig.zs OffCopy,
//     as its Dual key would), otherwise the empty off hand (Brutal Doom VR's RSQ_Hands; nothing on plain Doom 2, which
//     has no off-hand fist). A gun the switch itself put in the off hand (switchhand, an off-hand holster draw) stays.
//     The off hand is raised in the same tic as the main hand's switch starts (RaiseOff, as BringUpWeapon does).
//   A per-tic net (Steps): with no cigarette out, the Zippo leaves any hand at once and a cigarette left in the main
//   hand gives way to its gun; neither stays in the inventory. The cigarette and the Zippo are never guns to the rig
//   (no throw, no holster: rig.zs HoldsGun / IsMovedGun).
//
// Played and confirmed working in the headset (owner, 2026-11-03). Since then, rig only: the pulse's name for SlowMo
// (rsqtr_cigslowmo, 0.99a bug 43).

// The idea is Ermac's: the cigarette, its butt and its smoke come from his Virtual Tactical Vest for Doom VR (its credits
// name him as their modeller; the cigarette's texture is an atlas shared with a Sketchfab cigarette-pack model, its pack
// art blanked here), and the Zippo is the voxel lighter from his ZBlood-VR, credited to him there. tools/gen_handprops.py
// bakes both into Brutal Doom VR's hand. A pocket holds a few (rsqtr_cig_count); it does NOT refill on a new level
// (owner 11-09: cigarettes are precious; Refill Each Level brings that back): earn them (RSQ Score, minibosses, DOWN).
//
// NETPLAY: the hands are the console player's alone, so that machine decides and sends one event per action (take, put
// back, to the mouth, flick, the Zippo, light); every machine runs the same steps from them, and the timed steps (the
// smoke, the flick from the mouth, the cancels) from synced state.

class RSQTR_Cig : EventHandler
{
	const POCKET_F = 0.12;
	const POCKET_L = 0.16;
	const POCKET_U = -0.25;
	const POCKET_R = 0.08;     // 0.09 until 11-05: just past the cigarettes standing in it (farthest point 0.068-0.076 m, rtcig.md3 measured)
	// WHERE THE CIGARETTE SITS IN THE MOUTH (the prop's centre; metres forward of the eyes and under them, in the head's
	// frame): the "Mouth Cigarette Forward / Down" sliders, rsqtr_cig_mouth_f / _d (MouthF / MouthD). Ermac's mesh at
	// MODELDEF scale 0.3 runs 0.034 m behind that centre (the filter) to 0.050 m ahead (the burning end;
	// tools/measure_handprops.py). Until 11-03 it was 0.07 / 0.09, out of a headset's view.
	const MOUTH_F = 0.12;
	const MOUTH_D = 0.07;
	const MOUTH_TILT = 5.0;      // degrees the cigarette points up from where you look
	const TIP_LEN = 0.050;       // the centre to the burning end (measured, above)
	const FILTER_LEN = 0.034;    // the centre to the filter
	// THE MOUTH ZONE (11-02, after the owner's headset: "i can't get it in my mouth"). A capsule in the HEAD's frame (it
	// turns and nods with the headset): from the lips (ZONE_A: 0.04 forward of the eyes, 0.06 under them) to just under
	// the chin (ZONE_B: 0.08 forward, 0.19 under), ZONE_R round that line (x rsqtr_cig_mouth, Mouth Zone Size). With a
	// real hand at the lips the controller is a palm's width below and in front of them (near the chin or lower), and
	// the cigarette is drawn at the controller (its filter 0.5 cm forward, 2.8 left, 1.3 up of it), so BOTH the
	// controller and the drawn filter are tested and the nearer counts. Measured on the rig (README): lips, chin and
	// just below are in; the chest (0.30 under the eyes) and the pocket are out.
	const ZONE_AF = 0.04;
	const ZONE_AD = 0.06;
	const ZONE_BF = 0.08;
	const ZONE_BD = 0.19;
	const ZONE_R = 0.08;
	const GRACE_TICS = 10;       // a Use up to 0.3 s after the cigarette left the zone still puts it in the mouth
	const GRACE_DWELL = 3;       // ...if it had been in the zone at least this many tics (a swing through does not count)
	// THE DRAWN PROPS, MEASURED FROM THE MESHES (tools/measure_handprops.py: the baked md3 through the engine's own
	// hand-model transform, r_data/models.cpp RenderHUDModel). md3 cm in the hand mesh's space; HandPoint turns them
	// into the world. The cigarette's filter and burning end (rtcig_h.md3), the Zippo's flame centre (rtzipfl_h.md3).
	const CIGF_X = 6.38;  const CIGF_Y = 2.73;  const CIGF_Z = 6.21;
	const CIGT_X = 13.93; const CIGT_Y = 6.13;  const CIGT_Z = 7.36;
	const FLAME_X = 4.86; const FLAME_Y = 0.67; const FLAME_Z = 8.31;
	// THE LIGHT: the drawn flame within FLAME_R of the cigarette in the mouth (anywhere from its middle to the burning
	// end). The flame is drawn 1 cm behind, 0.7 toward the inside and 3.5 cm over the off controller (it was guessed at
	// 6 cm over until 11-02).
	const FLAME_R = 0.10;        // (0.13 until 11-03, when Use lit it; now the off-hand trigger itself lights it there)
	const USE_DEBOUNCE = 6;      // tics: a second Use edge this soon after one is the same press (key event + command)
	const ZIP_LIT_TICS = 7;      // the lid opens over 6 tics, then the flame takes (RSQTR_ZippoWeapon Open)
	const ZIP_SHUT_TICS = 12;    // after the tip catches: the Zippo shuts (it stays in the off hand until the end)
	const PUFF_TICS = 30;        // a puff from the mouth while smoking
	// THE FLICK (map units a tic): from the mouth on the rig it first touched down 2.5 m out and came to rest by 3.5 m
	const FLICK_SPEED = 2.6;
	const FLICK_UP = 3.0;
	const SWITCH_GRACE = 2;      // tics a hand may differ from what the ritual gave it before that is a switch (rule A)
	const KEY_TICS = 2;          // a switch key's end waits this long, so the engine's own switch is already under way and
	                             // the hands' restore overrides it (otherwise it would go through after the end)

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
	int  godUntil[MAXPLAYERS];   // Smoker (Gun Bonsai VR): untouchable until this tic, through the flick's slow motion
	bool godWas[MAXPLAYERS];     // what bINVULNERABLE was before we set it (an invulnerability sphere keeps its own)
	int  swGone[MAXPLAYERS];     // tics the hands have differed from what the ritual gave them (rule A)
	bool zipSeen[MAXPLAYERS];    // the Zippo has reached the off hand since the cigarette came out
	String mainWant[MAXPLAYERS]; // in the mouth / smoking: the gun the ritual gave the main hand back
	int  exitTic[MAXPLAYERS];    // the last end of the ritual (the exit's log)
	String exitWhy[MAXPLAYERS];
	int  keyEnd[MAXPLAYERS];     // a weapon switch key went down (level.maptime + 1): the end follows KEY_TICS later
	bool restore[MAXPLAYERS];    // a level change found the cigarette or the Zippo still in a hand
	String prevMain[MAXPLAYERS], prevOff[MAXPLAYERS];
	Actor mouthProp[MAXPLAYERS];
	int  spitTic[MAXPLAYERS];    // when the last flick from the mouth was (the console player's SlowMo starts on it)
	int  keyTic[MAXPLAYERS];     // when a key bound to +use last went down (InputProcess, below)
	int  offKeyTic[MAXPLAYERS];  // when a key bound to +oh_attack last went down, the Zippo in the hand (InputProcess)
	int  keyDir[MAXPLAYERS];     // the switch key that went down: 1 next, -1 previous, 0 a slot or another
	int  keyHand[MAXPLAYERS];    // ...and its hand (QuestZDoom's "weapnext 1": the off hand)
	bool offDue[MAXPLAYERS];     // the ritual ended: the off hand still to get its gun's copy or the empty hand (ResolveOff)
	int  offDueTic[MAXPLAYERS];  // when it ended (the exit's log, and a give-up)

	// ---- local (console player) ----------------------------------------------------
	private transient bool gripWas, useWas, offFireWas;
	private transient int spitSeen, keySeen, useActTic, offKeySeen, offActTic;
	private transient Actor pocketMark, cue;
	private transient bool cueWas;           // the cigarette (or the flame) was in reach last tic
	private transient int zoneIn, zoneLeft;  // tics in the zone; the tic it last left it
	private transient int zoneLeftDwell;     // how long it had been in before it left

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
			phase[i] = PH_NONE; zipOpen[i] = false; zipSeen[i] = false; swGone[i] = 0; mainWant[i] = ""; offDue[i] = false; exitTic[i] = 0;
			mouthProp[i] = null; spitTic[i] = -100; restore[i] = false; cigScoreMark[i] = -1;
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
			let p = players[i];
			int count = (RSQTR_Rig.Opt("rsqtr_cig_count", p, 3) + max(RSQTR_Rig.Gb(p, 'ChainSmoker'), 0));
			let tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack"));
			if (!tok) { pmo.SetInventory("RSQTR_CigPack", RSQTR_CigKeep.Left(i, count)); tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack")); }
			else
			{
				// out at the level change and never lit: back in the pocket
				if (tok.held == PH_HAND || tok.held == PH_MOUTH) tok.Amount++;
				if (RSQTR_Rig.Flag("rsqtr_cig_refill", p, false)) tok.Amount = count;
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

	// Other files: the main hand is at the cigarette pocket and the pocket is live (rig.zs: a press there is no gun throw).
	static bool AtPocket(PlayerPawn pmo)
	{
		let c = Get();
		if (!c || !pmo || !pmo.player || !RSQTR_Rig.Flag("rsqtr_cig", pmo.player, false)) return false;
		return RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 0), c.Pocket(pmo)) < POCKET_R;
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
		double hp = clamp(pmo.pitch, -89, 89);             // (clamped at 60 until 11-03: a steeper look left it behind)
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
	// The cigarette in the mouth: its centre, burning end and filter (the head's frame, tilted MOUTH_TILT up).
	static double MouthF(PlayerPawn pmo) { return clamp(RSQTR_Rig.Num("rsqtr_cig_mouth_f", pmo.player, MOUTH_F), 0.03, 0.30); }
	static double MouthD(PlayerPawn pmo) { return clamp(RSQTR_Rig.Num("rsqtr_cig_mouth_d", pmo.player, MOUTH_D), -0.05, 0.15); }
	static Vector3 Mouth(PlayerPawn pmo) { return FromEyes(pmo, MouthF(pmo), MouthD(pmo)); }
	static Vector3 MouthTip(PlayerPawn pmo) { return FromEyes(pmo, MouthF(pmo) + TIP_LEN * cos(MOUTH_TILT), MouthD(pmo) - TIP_LEN * sin(MOUTH_TILT)); }
	static Vector3 MouthFilter(PlayerPawn pmo) { return FromEyes(pmo, MouthF(pmo) - FILTER_LEN * cos(MOUTH_TILT), MouthD(pmo) + FILTER_LEN * sin(MOUTH_TILT)); }

	// A POINT OF A PROP DRAWN IN A HAND: md3 cm (mx, my, mz) of the baked hand prop, through the engine's hand-model
	// transform (tools/measure_handprops.py, from r_data/models.cpp RenderHUDModel and MODELDEF Scale -1 1 1 / Offset 0
	// -24 -10): in the controller's frame forward ws*mx - 6, left +-ws*my (the off hand is mirrored), up ws*mz - 5 cm,
	// then turned by the hand's yaw, pitch and roll as the engine turns the model (GetHandTransform).
	// The turn is the renderer's own, as RSQ_LaserSight's hand.zs HudPoint does it (rig-proven there): GL axes (x, y up,
	// z), the hand's yaw AttackAngle about y (the hand points AttackAngle + 90 in the map), pitch AttackPitch about x,
	// roll -AttackRoll about z; map = (x, -z, y / pixelstretch) x vr_vunits_per_meter. The model point in that frame
	// (cm): (-ws*my, ws*mz - 10, -ws*mx - 24) + (0, 5, 30), x mirrored on the off hand (GetWeaponTransform).
	static Vector3 HandPoint(PlayerPawn pmo, int h, double mx, double my, double mz)
	{
		let wsv = CVar.FindCVar("vr_weaponScale");
		double ws = wsv ? wsv.GetFloat() : 1.02;
		Vector3 v = (-ws * my, ws * mz - 10 + 5, -ws * mx - 24 + 30) * 0.01;
		let cs = CVar.FindCVar("vr_control_scheme");
		bool rightHanded = !cs || cs.GetInt() < 10;
		int idx = (h == 1) ? (rightHanded ? 0 : 1) : (rightHanded ? 1 : 0);
		Weapon w = h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
		if (idx == 0 && !(w && w.bNoAutoReverse)) v.x = -v.x;
		double yw = h == 0 ? pmo.AttackAngle : pmo.OffhandAngle;
		double pt = h == 0 ? pmo.AttackPitch : pmo.OffhandPitch;
		double rl = -(h == 0 ? pmo.AttackRoll : pmo.OffhandRoll);
		v = (v.x * cos(rl) - v.y * sin(rl), v.x * sin(rl) + v.y * cos(rl), v.z);
		v = (v.x, v.y * cos(pt) - v.z * sin(pt), v.y * sin(pt) + v.z * cos(pt));
		v = (v.x * cos(yw) + v.z * sin(yw), v.y, -v.x * sin(yw) + v.z * cos(yw));
		double vu = RSQTR_Body.Upm();
		return RSQTR_Body.Hand(pmo, h) + (vu * v.x, -vu * v.z, vu * v.y / RSQTR_Body.Ps());
	}
	static Vector3 CigFilter(PlayerPawn pmo) { return HandPoint(pmo, 0, CIGF_X, CIGF_Y, CIGF_Z); }
	static Vector3 CigTip(PlayerPawn pmo) { return HandPoint(pmo, 0, CIGT_X, CIGT_Y, CIGT_Z); }
	static Vector3 Flame(PlayerPawn pmo) { return HandPoint(pmo, 1, FLAME_X, FLAME_Y, FLAME_Z); }

	// Metres from a point to the zone's axis (lips to under the chin, in the head's frame).
	static double ZoneDist(PlayerPawn pmo, Vector3 pt)
	{
		return SegDist(pt, FromEyes(pmo, ZONE_AF, ZONE_AD), FromEyes(pmo, ZONE_BF, ZONE_BD));
	}
	// Room metres from pt to the segment a-b (map points).
	static double SegDist(Vector3 pt, Vector3 a, Vector3 b)
	{
		double ps = RSQTR_Body.Ps(), upm = RSQTR_Body.Upm();
		Vector3 ab = b - a, ap = pt - a;
		ab = (ab.x, ab.y, ab.z * ps) / upm;
		ap = (ap.x, ap.y, ap.z * ps) / upm;
		double ll = ab dot ab;
		double t = ll > 0 ? clamp((ap dot ab) / ll, 0.0, 1.0) : 0.0;
		return (ap - ab * t).Length();
	}
	static double ZoneRadius(PlayerPawn pmo) { return ZONE_R * clamp(RSQTR_Rig.Num("rsqtr_cig_mouth", pmo.player, 1.0), 0.5, 1.5); }
	// The cigarette in the main hand against the zone: the nearer of the controller and the drawn filter (metres).
	static double MouthDist(PlayerPawn pmo) { return min(ZoneDist(pmo, RSQTR_Body.Hand(pmo, 0)), ZoneDist(pmo, CigFilter(pmo))); }
	static bool InMouthZone(PlayerPawn pmo) { return MouthDist(pmo) < ZoneRadius(pmo); }
	// The main controller alone against the zone (pulling an unlit cigarette back out of the mouth with the main hand).
	static bool HandAtMouth(PlayerPawn pmo) { return ZoneDist(pmo, RSQTR_Body.Hand(pmo, 0)) < ZoneRadius(pmo); }
	// Other files: a main-hand grip here now pulls the unlit cigarette out of the mouth (rig.zs: so it is no gun throw).
	static bool PullAtMouth(PlayerPawn pmo)
	{
		let c = Get();
		int n = pmo ? pmo.PlayerNumber() : -1;
		return c && n >= 0 && n < MAXPLAYERS && c.phase[n] == PH_MOUTH && HandAtMouth(pmo);
	}
	// The Zippo's drawn flame to the cigarette in the mouth (its burning half: the centre to the burning end), metres.
	static double FlameDist(PlayerPawn pmo) { return SegDist(Flame(pmo), Mouth(pmo), MouthTip(pmo)); }
	// The flame in reach of the tip: off-hand fire there lights it (cig.zs top, step 2).
	static bool FlameAtTip(PlayerPawn pmo) { return FlameDist(pmo) < FLAME_R; }
	bool ZipBurning(int n) { return zipOpen[n] && level.maptime - zipTic[n] >= ZIP_LIT_TICS; }

	// ---- the local loop ----------------------------------------------------------------
	// MORE CIGARETTES (owner 11-05): RSQ Score's score earns one every rsqtr_cig_score points, and killing a miniboss (RSQ
	// Miniboss, "wasboss") fills the pocket; never past the Pack Size. Both by name: nothing happens without those mods.
	int cigScoreMark[MAXPLAYERS];
	private void CigEarn()
	{
		if (level.maptime % 35) return;
		Service sc = null;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let p = players[n];
			int step = RSQTR_Rig.Opt("rsqtr_cig_score", p, 0);
			if (step <= 0 || !RSQTR_Rig.Flag("rsqtr_cig", p, false)) { cigScoreMark[n] = -1; continue; }
			if (!sc) { sc = ServiceIterator.Find("RS_ScoreService").Next(); if (!sc) return; }
			int score = sc.GetInt("score", "", 0, 0, p.mo);
			if (score < 0) continue;
			int bucket = score / step;
			if (cigScoreMark[n] < 0 || bucket < cigScoreMark[n]) { cigScoreMark[n] = bucket; continue; }
			if (bucket > cigScoreMark[n]) { CigGive(p.mo, bucket - cigScoreMark[n], "score"); cigScoreMark[n] = bucket; }
		}
	}
	void CigGive(PlayerPawn pmo, int add, String why)
	{
		if (!pmo || add <= 0) return;
		let p = pmo.player;
		int cap = (RSQTR_Rig.Opt("rsqtr_cig_count", p, 3) + max(RSQTR_Rig.Gb(p, 'ChainSmoker'), 0));
		let tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack"));
		if (!tok) { pmo.SetInventory("RSQTR_CigPack", 0); tok = RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack")); }
		if (!tok) return;
		int was = tok.Amount;
		tok.Amount = min(cap, tok.Amount + add);
		if (tok.Amount > was && RSQTR_Rig.Flag("rsqtr_messages", p, false))
			Console.Printf("T_RIG cigarettes +%d (%s): %d of %d", tok.Amount - was, why, tok.Amount, cap);
	}
	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bISMONSTER) return;
		let it = ServiceIterator.Find("RSQMB_Service");
		let ms = it.Next();
		if (!ms || ms.GetInt("wasboss", "", 0, 0, a) != 1) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let p = players[n];
			if (!RSQTR_Rig.Flag("rsqtr_cig", p, false) || !RSQTR_Rig.Flag("rsqtr_cig_boss", p, true)) continue;
			CigGive(players[n].mo, 99, "miniboss");
		}
	}

	override void WorldTick()
	{
		Steps();
		CigEarn();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) { HideMark(); HideCue(); HidePack(); return; }
		let pmo = p.mo;
		int n = consoleplayer;
		// USE, EDGE-BASED: the rising edge of the key in this tic's command OR the unmodified one the input built
		// (original_cmd), so a mod that clears BT_USE from the command for its own reasons cannot eat the press; the
		// edge state is kept every tic, before anything can return early.
		// A TAP SHORTER THAN A TIC never reaches the command at all: G_BuildTiccmd (g_game.cpp) only asks whether Use is
		// held when it builds (FButtonStatus.bDown), so a press and release between two builds is lost -- more likely when
		// the frame rate drops and several tics run per frame. So the key going down is caught too, as an input event
		// (InputProcess: any key bound to +use, the controller's included), and counts as a press; one press is acted on
		// once (USE_DEBOUNCE), whichever of the two arrives first.
		bool useDown = ((p.cmd.buttons | p.original_cmd.buttons) & BT_USE) != 0;
		bool useEdge = useDown && !useWas;
		useWas = useDown;
		bool keyEdge = keyTic[n] != keySeen && keyTic[n] >= level.maptime - 1;
		keySeen = keyTic[n];
		if (keyEdge && !useEdge && useDown) keyEdge = false;          // the command already holds it: the same press
		if ((useEdge || keyEdge) && level.maptime - useActTic <= USE_DEBOUNCE) useEdge = keyEdge = false;
		if (keyEdge && !useEdge && RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_CIG t%d Use caught as a key press (not in the command: a tap shorter than a tic)", level.maptime);
		useEdge = useEdge || keyEdge;
		if (useEdge) useActTic = level.maptime;
		if (!RSQTR_Rig.Flag("rsqtr_cig", p, false)) { HideMark(); HideCue(); HidePack(); return; }
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

		// THE ZONE, every tic the cigarette is in the hand: the cue on entering, and the grace after leaving
		bool zipIn = p.OffhandWeapon is "RSQTR_ZippoWeapon";
		bool inZone = false;
		double zd = 9;
		if (phase[n] == PH_HAND)
		{
			zd = MouthDist(pmo);
			inZone = zd < ZoneRadius(pmo);
			if (inZone) zoneIn++;
			else if (zoneIn > 0) { zoneLeft = level.maptime; zoneLeftDwell = zoneIn; zoneIn = 0; }
		}
		else zoneIn = 0;

		// USE IS THE CIGARETTE'S while it is out
		if (useEdge && phase[n] == PH_HAND)
		{
			bool grace = !inZone && zoneLeftDwell >= GRACE_DWELL && level.maptime - zoneLeft <= GRACE_TICS;
			bool toMouth = inZone || grace;
			if (msg) Console.Printf("T_CIG use in hand t%d: %.3f m from the zone's axis (radius %.3f)%s -> %s", level.maptime, zd, ZoneRadius(pmo), grace ? String.Format(", left it %d tics ago (grace)", level.maptime - zoneLeft) : "", toMouth ? "mouth" : "flick");
			EventHandler.SendNetworkEvent(toMouth ? "rsqtr_ciglock" : "rsqtr_cigflick");
			zoneLeftDwell = 0;
		}
		else if (useEdge && phase[n] == PH_MOUTH)
		{
			// in the mouth, Use does nothing: lighting is the Zippo's trigger (below)
			if (msg) Console.Printf("T_CIG use in mouth t%d -> nothing (the Zippo's trigger lights it)", level.maptime);
		}
		else if (useEdge && phase[n] == PH_SMOKE)
		{
			// smoking: Use flicks it out now (the end of the smoke, slow motion as usual)
			if (msg) Console.Printf("T_CIG use while smoking t%d -> flicked out now", level.maptime);
			EventHandler.SendNetworkEvent("rsqtr_cigspit");
		}

		// the main hand's grip at the mouth: an unlit cigarette back out of the mouth into that hand
		if (gripEdge && phase[n] == PH_MOUTH && HandAtMouth(pmo))
		{
			if (msg) Console.Printf("T_CIG main grip at the mouth t%d -> back to the hand", level.maptime);
			EventHandler.SendNetworkEvent("rsqtr_cigunmouth");
		}

		// THE ZIPPO'S TRIGGER (off-hand fire; owner 11-03). In the mouth with the flame at the cigarette's tip: it lights.
		// Anywhere else (in the hand or the mouth): the Zippo flicks open and lit / shut. Not while smoking. The rising
		// edge of the command's button, or the key going down (InputProcess: a tap shorter than a tic), once a press.
		bool off = ((p.cmd.buttons | p.original_cmd.buttons) & BT_OFFHANDATTACK) != 0;
		bool offEdge = off && !offFireWas;
		offFireWas = off;
		bool offKey = offKeyTic[n] != offKeySeen && offKeyTic[n] >= level.maptime - 1;
		offKeySeen = offKeyTic[n];
		if (offKey && !offEdge && off) offKey = false;                 // the command already holds it: the same press
		if ((offEdge || offKey) && level.maptime - offActTic <= USE_DEBOUNCE) offEdge = offKey = false;
		offEdge = offEdge || offKey;
		if (offEdge) offActTic = level.maptime;
		bool flameIn = phase[n] == PH_MOUTH && zipIn && FlameAtTip(pmo);
		if (offEdge && zipIn && (phase[n] == PH_HAND || phase[n] == PH_MOUTH))
		{
			if (msg) Console.Printf("T_CIG off-hand fire t%d: %s, flame %.3f m from the cigarette's tip (reach %.2f) -> %s", level.maptime, phase[n] == PH_MOUTH ? "in the mouth" : "in the hand", phase[n] == PH_MOUTH ? FlameDist(pmo) : 9.0, FLAME_R, flameIn ? "light" : (zipOpen[n] ? "shut" : "open"));
			EventHandler.SendNetworkEvent(flameIn ? "rsqtr_ciglight" : "rsqtr_zipflick");
		}

		// THE CUE, before the press: the cigarette in the mouth zone (Use puts it in), or in the mouth the Zippo's flame
		// at its tip (off-hand fire lights it) -- a small glow at the burning end, a light tick in that hand and a soft
		// stock sound as it comes into reach
		bool cueNow = inZone || flameIn;
		if (cueNow && !cueWas)
		{
			RSQTR_Buzzer.Start(pmo, inZone ? 0 : 1, 0.15, 2);
			pmo.A_StartSound("misc/i_pkup", CHAN_AUTO, CHANF_LOCAL, 0.3);
			if (msg) Console.Printf("T_CIG cue on t%d: %s", level.maptime, inZone ? String.Format("in the mouth zone (%.3f m of %.3f)", zd, ZoneRadius(pmo)) : String.Format("flame at the tip (%.3f m)", FlameDist(pmo)));
		}
		cueWas = cueNow;
		if (cueNow) ShowCue(inZone ? CigTip(pmo) : MouthTip(pmo));
		else HideCue();

		// the flick from the mouth: RSQ_SlowMo starts with it (its "rsm_pulse <ms> <depth %>" network event, by name)
		if (spitTic[n] != spitSeen && spitTic[n] == level.maptime)
		{
			spitSeen = spitTic[n];
			if (RSQTR_Rig.Flag("rsqtr_cig_slowmo", p, true))
			{
				int ms = int(SmokeSecs(p) * 1000);
				int depth = RSQTR_Rig.Opt("rsqtr_cig_depth", p, 25);
				EventHandler.SendNetworkEvent("rsm_pulse", ms, depth);
				// the pulse's name for RSQ SlowMo (its clock.zs, as RSQ Melee's rsqml_fear names the shove's): this pulse is the
				// smoke, whatever Gun Bonsai VR's Smoker made its length (0.99a bug 43). Nothing else reads it; alone it is inert.
				// arg 3: Move at Full Speed While Smoking (owner 11-05: "allow player movement at full speed during smoking-induced
				// bullet time"); an older SlowMo ignores it
				EventHandler.SendNetworkEvent("rsqtr_cigslowmo", ms, depth, RSQTR_Rig.Flag("rsqtr_cig_move", p, true) ? 1 : 0);
				if (msg) Console.Printf("T_CIG slow motion asked: rsm_pulse %d %d", ms, depth);
			}
		}

		ShowMark(pocket, nearest);
		ShowPack(pmo, p, pocket);
	}

	// THE CIGARETTES IN THE POCKET, ON THE BODY (owner 2026-11-03 20:51: "the torso rig will need to always show cigarette
	// (when enabled), whip, grenade, sabers, shieldsaw"). With Cigarettes on, while the pocket holds any (RSQTR_CigPack),
	// up to PACK_SHOWN of them stand in it, filter end up, poking PACK_UP above the pocket's centre, side by side PACK_GAP
	// apart across the chest, following the torso (Pocket: the rig's body). Ermac's cigarette mesh, unlit (RSQTR_CigStowed).
	// One in the hand or mouth is not in the pocket: only the pocket's count is shown. Off with Show Cigarettes in Pocket
	// (rsqtr_cig_show), the rig off, or out of VR (the rig's own rule: no controllers, no rig).
	const PACK_SHOWN = 3;
	const PACK_UP = 0.035;
	const PACK_GAP = 0.014;
	transient Actor packShow[PACK_SHOWN];      // read by the mirror (mirror.zs)
	private void ShowPack(PlayerPawn pmo, PlayerInfo p, Vector3 pocket)
	{
		int cnt = Packs(pmo);
		if (cnt <= 0 || !RSQTR_Rig.Flag("rsqtr_cig_show", p, true) || !RSQTR_Rig.Flag("rsqtr_on", p, true) || !pmo.OverrideAttackPosDir) { HidePack(); return; }
		let rig = RSQTR_Rig.Get();
		double by = rig ? rig.BodyYaw(pmo) : pmo.angle;
		double u = RSQTR_Body.Upm();
		int shown = min(cnt, PACK_SHOWN);
		for (int k = 0; k < PACK_SHOWN; k++)
		{
			if (k >= shown) { if (packShow[k]) packShow[k].bINVISIBLE = true; continue; }
			if (!packShow[k]) packShow[k] = Actor.Spawn("RSQTR_CigStowed", pocket);
			let a = packShow[k];
			if (!a) continue;
			double side = (k - (shown - 1) * 0.5) * PACK_GAP * u;
			a.SetOrigin(pocket + (-sin(by) * side, cos(by) * side, PACK_UP * u / RSQTR_Body.Ps()), true);
			a.angle = by;
			a.pitch = 90;            // nose (the burning end) down: the filter up, out of the pocket
			a.roll = 0;
			a.bINVISIBLE = false;
		}
	}
	private void HidePack() { for (int k = 0; k < PACK_SHOWN; k++) if (packShow[k]) packShow[k].bINVISIBLE = true; }

	// RIG CLUTTER (owner 11-08): the pocket's ring follows every ring's rules (rig.zs RingAlpha): Holster Rings as drawn
	// (RingMode: "Always" only while moving holsters), the Hand Nearby fade at POCKET_R, shown only to a hand that can act
	// here (the main hand: take one, or put the one in it back) and faint unless it is that hand's nearest ring. Its own
	// 0.30 m / 0.9 / 0.35 rule before 11-08 is gone.
	private void ShowMark(Vector3 at, double nearest)
	{
		let p = players[consoleplayer];
		let rig = RSQTR_Rig.Get();
		if (!rig || !p.mo) { HideMark(); return; }
		int inMask = 0;
		for (int h = 0; h < 2; h++) if (RSQTR_Body.RoomMetres(RSQTR_Body.Hand(p.mo, h), at) < POCKET_R) inMask |= 1 << h;
		double a = rig.RingAlpha(p.mo, RSQTR_Rig.RingMode(p), RSQTR_Rig.RK_CIG, at, POCKET_R, inMask);
		if (packShow[0] && !packShow[0].bINVISIBLE) a *= RSQTR_Rig.STOWED_SPHERE;   // not drawn through the cigarettes (11-05)
		if (a <= 0.01) { HideMark(); return; }
		if (!pocketMark) pocketMark = Actor.Spawn("RSQTR_ItemMarker", at);   // an item spot: a wire diamond (rig.zs, 11-08)
		if (!pocketMark) return;
		pocketMark.SetOrigin(at, true);
		pocketMark.bINVISIBLE = false;
		pocketMark.Alpha = clamp(a, 0.0, 1.0);
		pocketMark.Scale = (POCKET_R * RSQTR_Body.Upm(), POCKET_R * RSQTR_Body.Upm());   // the wireframe sphere: radius 1.0
		pocketMark.frame = RSQTR_Rig.MarkerFrame(inMask != 0, RSQTR_Rig.Opt("rsqtr_profile_active", p, 1), true);   // a utility place's colour (11-05)
	}
	private void HideMark() { if (pocketMark) pocketMark.bINVISIBLE = true; }

	private void ShowCue(Vector3 at)
	{
		if (!cue) cue = Actor.Spawn("RSQTR_Cue", at);
		if (!cue) return;
		cue.SetOrigin(at, true);
	}
	private void HideCue() { if (cue) cue.Destroy(); cue = null; cueWas = false; }

	// THE USE KEY AS AN INPUT EVENT, while the cigarette is out (see WorldTick: a tap shorter than a tic): a key whose
	// binding holds +use going down sends one network event. The key is never eaten; the engine sees it as always.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown) return false;
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || phase[consoleplayer] == PH_NONE) return false;
		String b = Bindings.GetBinding(e.KeyScan);
		b = b.MakeLower();
		if (b.IndexOf("+use") >= 0) EventHandler.SendNetworkEvent("rsqtr_cigkey");
		// the Zippo's trigger, as a key (WorldTick: a tap shorter than a tic never reaches the command)
		if (b.IndexOf("+oh_attack") >= 0) EventHandler.SendNetworkEvent("rsqtr_cigoffkey");
		// A WEAPON SWITCH KEY ENDS IT. Caught as the key goes down, because the engine's own switch often does nothing
		// here: the cigarette and the Zippo are in no weapon slot, so "weapnext" from the cigarette (or "weapnext 1" from
		// the Zippo) finds no next weapon (player.zs PickNextWeapon) and the hands would never change. The end works the
		// next / previous gun out itself (NextFrom). A switch that does go through is caught by Steps as well; whichever
		// comes first ends it once. Args: 2, the direction (1 next, -1 previous, 0 other), the hand.
		else if (b.IndexOf("weapnext") >= 0 || b.IndexOf("weapprev") >= 0 || b.IndexOf("switchhand") >= 0 || b.IndexOf("slot ") >= 0)
		{
			int dir = b.IndexOf("weapnext") >= 0 ? 1 : (b.IndexOf("weapprev") >= 0 ? -1 : 0);
			int hand = (dir != 0 && (b.IndexOf("weapnext 1") >= 0 || b.IndexOf("weapprev 1") >= 0)) ? 1 : 0;
			EventHandler.SendNetworkEvent("rsqtr_cigend", 2, dir, hand);
		}
		return false;
	}

	// ---- every machine ----------------------------------------------------------------
	private void SetPhase(int n, int ph)
	{
		phase[n] = ph; phaseTic[n] = level.maptime; swGone[n] = 0; keyEnd[n] = 0;
		let pmo = players[n].mo;
		let tok = pmo ? RSQTR_CigPack(pmo.FindInventory("RSQTR_CigPack")) : null;
		if (tok) { tok.held = ph; tok.prevMain = prevMain[n]; tok.prevOff = prevOff[n]; }
	}

	static bool IsProp(Weapon w) { return w && (w is "RSQTR_CigWeapon" || w is "RSQTR_ZippoWeapon"); }
	static String WName(Weapon w) { return w ? String.Format("%s", w.GetClassName()) : "nothing"; }

	// The off hand let go of whatever it holds, at once (no psprite left behind to draw it).
	private static void StripOff(PlayerInfo p)
	{
		p.SetPsprite(PSP_OFFHANDWEAPON, null);
		p.OffhandWeapon = null;
	}

	// THE ZIPPO GOES, THIS TIC: out of the off hand (or a cigarette switchhand carried there), its queued raise
	// dropped, a prop the engine was about to raise into the off hand dropped. Never left waiting on a queue.
	private void ZipGone(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		let rig = RSQTR_Rig.Get();
		if (rig && rig.offNext[n] ~== "RSQTR_ZippoWeapon") rig.offNext[n] = "";
		if (p.PendingWeapon != WP_NOCHANGE && IsProp(p.PendingWeapon) && p.PendingWeapon.bOffhandWeapon) p.PendingWeapon = WP_NOCHANGE;
		if (IsProp(p.OffhandWeapon)) StripOff(p);
		if (zipOpen[n]) pmo.A_StartSound("rsqtr/zipclose", CHAN_AUTO, 0, 0.6);
		zipOpen[n] = false;
	}

	// The gun the main hand had before the cigarette came out (prevMain), else the empty hand.
	private Weapon RefGun(PlayerPawn pmo, int n)
	{
		class<Weapon> wc = prevMain[n];
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w || IsProp(w)) w = RSQTR_Rig.EmptyHand(pmo);
		return IsProp(w) ? null : w;
	}

	// A gun the off hand carried before the cigarette (the engine's switchhand flags it OFFHANDWEAPON) is a main-hand
	// gun again once it is in no hand: otherwise the next / previous gun skips it and a slot key raises it into the off
	// hand.
	private void UnflagPrevOff(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		class<Weapon> oc = prevOff[n];
		let ow = oc ? Weapon(pmo.FindInventory(oc)) : null;
		if (ow && ow != p.OffhandWeapon && ow != p.PendingWeapon && RSQTR_Rig.IsMovedGun(ow)) ow.bOffhandWeapon = false;
	}

	// THE NEXT / PREVIOUS GUN a switch key asked for, from the gun the main hand has (in the mouth) or had before the
	// cigarette (in the hand): the cigarette is in no slot, so the engine's own weapnext from it finds nothing. The
	// engine's own pick (player.zs PickNextWeapon / PickPrevWeapon), asked as if that gun were up.
	private Weapon NextFrom(PlayerPawn pmo, int n, int dir)
	{
		let p = pmo.player;
		Weapon ref = (p.ReadyWeapon && !IsProp(p.ReadyWeapon)) ? p.ReadyWeapon : RefGun(pmo, n);
		let was = p.ReadyWeapon;
		let pw = p.PendingWeapon;
		p.ReadyWeapon = ref;
		p.PendingWeapon = WP_NOCHANGE;
		Weapon t = dir > 0 ? pmo.PickNextWeapon(0) : pmo.PickPrevWeapon(0);
		p.ReadyWeapon = was;
		p.PendingWeapon = pw;
		return (t && !IsProp(t)) ? t : ref;
	}

	// THE MAIN HAND AT THE END: the gun the switch picked (target), else a switch already under way in that hand (the
	// engine's, the wheel's, another mod's, a holster draw), else the gun it holds (in the mouth), else the gun it had
	// before the cigarette, else the empty hand. mainWant is what the main hand is now to hold (Switched).
	private Weapon MainTo(PlayerPawn pmo, int n, Weapon target)
	{
		let p = pmo.player;
		let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
		bool pendMain = pend && !pend.bOffhandWeapon;
		Weapon w = (target && !IsProp(target)) ? target : null;
		if (!w && pendMain && !IsProp(pend)) w = pend;
		if (!w && p.ReadyWeapon && !IsProp(p.ReadyWeapon)) w = p.ReadyWeapon;
		if (!w) w = RefGun(pmo, n);
		if (w && IsProp(w)) w = null;
		if (w)
		{
			if (p.OffhandWeapon == w) StripOff(p);
			if (RSQTR_Rig.IsMovedGun(w)) w.bOffhandWeapon = false;
			if (p.ReadyWeapon != w) p.PendingWeapon = w;
			else if (pendMain) p.PendingWeapon = WP_NOCHANGE;
			mainWant[n] = w.GetClassName();
			return w;
		}
		if (IsProp(p.ReadyWeapon) || (pendMain && IsProp(pend))) pmo.PickNewWeapon(null);
		let nw = p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon ? p.PendingWeapon : p.ReadyWeapon;
		mainWant[n] = nw && !IsProp(nw) ? String.Format("%s", nw.GetClassName()) : "";
		return nw && !IsProp(nw) ? nw : null;
	}

	// An off-hand weapon up into the off hand NOW, as the engine's BringUpWeapon does it (player.zs), so it need not wait
	// for the main hand's switch to finish (PendingWeapon is one field for both hands). While the engine is steadying
	// the gun with the off grip (SteamVR), the rig's queue holds it until the grip is let go (rig.zs TickPairs).
	private void RaiseOff(PlayerPawn pmo, int n, Weapon w)
	{
		let p = pmo.player;
		if (!w || !w.bOffhandWeapon || p.OffhandWeapon == w) return;
		if ((p.WeaponState & WF_TWOHANDSTABILIZED) != 0)
		{
			let rig = RSQTR_Rig.Get();
			if (rig) rig.QueueOff(n, w.GetClassName());
			return;
		}
		p.OffhandWeapon = w;
		let psp = p.GetPSprite(PSP_OFFHANDWEAPON);
		if (psp) psp.y = WEAPONBOTTOM;
		w.PlayUpSound(pmo);
		p.SetPsprite(PSP_OFFHANDWEAPON, w.GetUpState());
	}

	// THE OFF HAND AT THE END (owner 11-03): the off-hand copy of the main hand's gun if you own one (Brutal Doom VR's
	// RSQ_Off_<gun>, rig.zs OffCopy), else the empty off hand (RSQ_Hands; nothing on plain Doom 2). A gun the switch put
	// in the off hand itself (switchhand, an off-hand holster draw queued by the rig, another mod) stays: that is the
	// switch, carried out. Every tic from the end until it is done (the main hand's gun known).
	private void ResolveOff(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		let rig = RSQTR_Rig.Get();
		if (pmo.health <= 0 || level.maptime - offDueTic[n] > 2 * TICRATE) { offDue[n] = false; return; }
		if (rig && rig.offNext[n] != "" && !(rig.offNext[n] ~== "RSQTR_ZippoWeapon")) { offDue[n] = false; return; }
		let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
		if (pend && pend.bOffhandWeapon && !IsProp(pend)) { offDue[n] = false; return; }
		if (IsProp(p.OffhandWeapon)) StripOff(p);
		if (p.OffhandWeapon) { offDue[n] = false; return; }
		Weapon main = (pend && !pend.bOffhandWeapon && !IsProp(pend)) ? pend : p.ReadyWeapon;
		if (!main || IsProp(main)) return;                   // the main hand's gun not known yet: next tic
		offDue[n] = false;
		if (main.bTwoHanded) return;
		Weapon want = RSQTR_Rig.OffCopy(pmo, main.GetClass());
		if (!want)
		{
			String en = RSQTR_Rig.OffEmptyName(pmo);
			class<Weapon> ec = en;
			if (ec)
			{
				want = Weapon(pmo.FindInventory(ec));
				if (!want) { pmo.GiveInventory(ec, 1); want = Weapon(pmo.FindInventory(ec)); }
			}
		}
		if (want) RaiseOff(pmo, n, want);
	}

	// BOTH HANDS AT THE END, the Zippo gone this tic: every end of the ritual comes through here.
	private void HandsBack(PlayerPawn pmo, int n, Weapon target = null, String why = "")
	{
		ZipGone(pmo, n);
		UnflagPrevOff(pmo, n);
		MainTo(pmo, n, target);
		offDue[n] = true;
		offDueTic[n] = level.maptime;
		zipSeen[n] = false;
		exitTic[n] = level.maptime;
		exitWhy[n] = why;
		if (RSQTR_Rig.Flag("rsqtr_messages", pmo.player, false)) ExitLog(pmo, n, "the end");
	}

	// The exit as the hands have it (rsqtr_messages): the end's tic, the tic after, and once the off hand is done.
	private void ExitLog(PlayerPawn pmo, int n, String when)
	{
		let p = pmo.player;
		let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
		Console.Printf("T_CIG exit t%d (%s%s%s): main %s%s | off %s%s", level.maptime, when, exitWhy[n] != "" ? ": " : "", exitWhy[n],
			WName(p.ReadyWeapon), (pend && !pend.bOffhandWeapon) ? " -> " .. WName(pend) : "",
			WName(p.OffhandWeapon), (pend && pend.bOffhandWeapon) ? " -> " .. WName(pend) : "");
	}

	// A switch, a holster, another mod: the ritual ends (unlit: the pocket, lit: flicked) and the switch is carried out
	// (target: the gun a switch key picked; null: whatever the switch already started, MainTo).
	// A LIT ONE IS A FINISHED SMOKE (owner 2026-11-11 13:54: "switching weapons does not end slowmo, holstering does not
	// end slomo ... i don't want anything ending cig slmo except Quick/Dead ... or Death"): it flicks out of the mouth and
	// the slow motion starts as if smoked (Spit with slowmo), while the hands get what the switch or the holster asked for.
	private void EndBySwitch(PlayerPawn pmo, int n, String why, Weapon target = null)
	{
		if (phase[n] == PH_NONE) return;
		if (RSQTR_Rig.Flag("rsqtr_messages", players[n], false)) Console.Printf("T_CIG end t%d: %s -> %s", level.maptime, why, phase[n] == PH_SMOKE ? "flicked (lit): smoked, the slow motion starts" : "back in the pocket (unlit)");
		if (phase[n] == PH_SMOKE) Spit(pmo, n, true, target, why);
		else PutBack(pmo, n, target, why);
	}

	// What differs between the hands and what the ritual gave them ("" nothing), and whether it ends it at once (a
	// switch of the main hand, a prop in the wrong hand) or after SWITCH_GRACE (the off hand). The main hand holds or
	// raises the cigarette (in the hand) or the gun the ritual gave back (mainWant, in the mouth / smoking); the off hand
	// holds or raises the Zippo, or, until the Zippo first gets there, still holds what it held.
	private String, bool Switched(PlayerInfo p, int n)
	{
		let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
		let ready = p.ReadyWeapon, off = p.OffhandWeapon;
		bool pendMain = pend && !pend.bOffhandWeapon;
		bool pendOff = pend && pend.bOffhandWeapon;
		if (off is "RSQTR_CigWeapon") return "the cigarette was moved to the off hand (switchhand)", true;
		if (ready is "RSQTR_ZippoWeapon" || (pendMain && pend is "RSQTR_ZippoWeapon")) return "the Zippo was moved to the main hand (switchhand)", true;
		// the main hand
		if (phase[n] == PH_HAND)
		{
			if (pendMain && !(pend is "RSQTR_CigWeapon")) return "the main hand switching to " .. WName(pend), true;
			if (!pendMain && !(ready is "RSQTR_CigWeapon")) return "the main hand holding " .. WName(ready), true;
		}
		else
		{
			String want = mainWant[n];
			if (pendMain && !(want != "" && pend.GetClassName() == Name(want)) && !(want == "" && !IsProp(pend))) return "the main hand switching to " .. WName(pend), true;
			if (!pendMain && ((want != "" && !(ready && ready.GetClassName() == Name(want))) || (want == "" && IsProp(ready)))) return "the main hand holding " .. WName(ready), true;
		}
		// the off hand
		if (pendOff && !(pend is "RSQTR_ZippoWeapon")) return "the off hand switching to " .. WName(pend), true;
		if (off is "RSQTR_ZippoWeapon") return "", false;
		if (pendOff) return "", false;                // the Zippo on its way up
		let rig = RSQTR_Rig.Get();
		if (rig && rig.offNext[n] ~== "RSQTR_ZippoWeapon") return "", false;
		if (zipSeen[n]) return "the off hand holding " .. WName(off) .. " instead of the Zippo", false;
		String was = prevOff[n];
		bool same = was == "" ? !off : (off && off.GetClassName() == Name(was));
		if (!same) return "the off hand switched to " .. WName(off) .. " before the Zippo came", false;
		return "", false;
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

		if (e.Name == "rsqtr_cigkey") { keyTic[n] = level.maptime; return; }
		if (e.Name == "rsqtr_cigoffkey") { offKeyTic[n] = level.maptime; return; }
		if (e.Name == "rsqtr_cigtake")
		{
			if (phase[n] != PH_NONE || Packs(pmo) <= 0) return;
			pmo.TakeInventory("RSQTR_CigPack", 1);
			// what the hands hold, or are about to (a gun still on its way back from the last cigarette counts)
			let rig = RSQTR_Rig.Get();
			Weapon pm = p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon && !p.PendingWeapon.bOffhandWeapon ? p.PendingWeapon : p.ReadyWeapon;
			prevMain[n] = pm && !IsProp(pm) ? String.Format("%s", pm.GetClassName()) : "";
			String po = p.OffhandWeapon && !IsProp(p.OffhandWeapon) ? String.Format("%s", p.OffhandWeapon.GetClassName()) : "";
			if (rig && rig.offNext[n] != "" && !(rig.offNext[n] ~== "RSQTR_ZippoWeapon")) po = rig.offNext[n];
			prevOff[n] = po;
			if (!pmo.FindInventory("RSQTR_CigWeapon")) pmo.GiveInventory("RSQTR_CigWeapon", 1);
			if (!pmo.FindInventory("RSQTR_ZippoWeapon")) pmo.GiveInventory("RSQTR_ZippoWeapon", 1);
			p.PendingWeapon = Weapon(pmo.FindInventory("RSQTR_CigWeapon"));
			if (rig) rig.QueueOff(n, "RSQTR_ZippoWeapon");
			zipOpen[n] = false; zipSeen[n] = false; mainWant[n] = "";
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
		else if (e.Name == "rsqtr_cigend")
		{
			// a holster pressed by either hand's grip (rig.zs Press: the press then does what it does with the hands as they
			// are -- draw, put away, swap -- in the events after this one), or a weapon switch key (InputProcess: the end
			// waits KEY_TICS for the engine's own switch, Steps)
			if (e.Args[0] == 2)
			{
				if (phase[n] != PH_NONE && keyEnd[n] == 0) { keyEnd[n] = level.maptime + 1; keyDir[n] = e.Args[1]; keyHand[n] = e.Args[2]; }
			}
			else EndBySwitch(pmo, n, e.Args[0] == 1 ? "the off hand's grip at a holster" : "the main hand's grip at a holster");
		}
		else if (e.Name == "rsqtr_ciglock")
		{
			if (phase[n] != PH_HAND) return;
			if (mouthProp[n]) mouthProp[n].Destroy();
			let c = RSQTR_CigProp(Actor.Spawn("RSQTR_CigProp", Mouth(pmo)));
			if (c) { c.holder = pmo; c.atMouth = true; }
			mouthProp[n] = c;
			MainTo(pmo, n, null);
			SetPhase(n, PH_MOUTH);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.4);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigflick")
		{
			if (phase[n] != PH_HAND) return;
			Flick(pmo, n, false);
			HandsBack(pmo, n, null, "flicked from the hand");
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
		else if (e.Name == "rsqtr_cigunmouth")
		{
			// an unlit cigarette back out of the mouth into the main hand (the main hand's grip at the mouth); from
			// there the flick and the pocket work as before. The guns to give back stay the ones from before it came out.
			if (phase[n] != PH_MOUTH) return;
			if (mouthProp[n]) mouthProp[n].Destroy();
			mouthProp[n] = null;
			if (!pmo.FindInventory("RSQTR_CigWeapon")) pmo.GiveInventory("RSQTR_CigWeapon", 1);
			p.PendingWeapon = Weapon(pmo.FindInventory("RSQTR_CigWeapon"));
			SetPhase(n, PH_HAND);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.4);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigspit")
		{
			if (phase[n] != PH_SMOKE) return;
			Spit(pmo, n, true, null, "Use while smoking");
		}
		else if (e.Name == "rsqtr_ciglight")
		{
			// the Zippo's trigger with its flame at the tip (WorldTick decides, the console player's hands): it lights. A
			// shut Zippo flicks open as it does
			if (phase[n] != PH_MOUTH || !(p.OffhandWeapon is "RSQTR_ZippoWeapon")) return;
			if (!zipOpen[n]) { zipOpen[n] = true; zipTic[n] = level.maptime; pmo.A_StartSound("rsqtr/zipopen", CHAN_AUTO, 0, 0.8); }
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

	// An unlit cigarette back in the pocket (the count refunded), the Zippo gone, the hands as the end gives them.
	private void PutBack(PlayerPawn pmo, int n, Weapon target = null, String why = "back in the pocket")
	{
		pmo.GiveInventory("RSQTR_CigPack", 1);
		if (mouthProp[n]) mouthProp[n].Destroy();
		mouthProp[n] = null;
		HandsBack(pmo, n, target, why);
		SetPhase(n, PH_NONE);
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
	}

	// The smoke, the flick from the mouth, the cancels and the ends; and tidying the two hand weapons away.
	private void Steps()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			let p = players[n];
			let rig = RSQTR_Rig.Get();
			bool msg = RSQTR_Rig.Flag("rsqtr_messages", p, false);

			// NO POCKET AT ALL: Brutal Doom clears the player's inventory as a level starts, after WorldLoaded gave the
			// pocket (rig 11-02, the full load order: the pocket was empty and nothing came out). Give it again -- with
			// what he had left (RSQTR_CigKeep), not a full pack: CIGARETTES ARE PRECIOUS (owner 2026-11-09 21:39). A full
			// pack only on a new game, or with Refill Each Level on.
			if (!pmo.FindInventory("RSQTR_CigPack") && pmo.health > 0)
			{
				int full = RSQTR_Rig.Opt("rsqtr_cig_count", p, 3) + max(RSQTR_Rig.Gb(p, 'ChainSmoker'), 0);
				pmo.SetInventory("RSQTR_CigPack", RSQTR_Rig.Flag("rsqtr_cig_refill", p, false) ? full : RSQTR_CigKeep.Left(n, full));
			}
			// remember what is in the pocket, for the next level (above)
			let kt = pmo.FindInventory("RSQTR_CigPack");
			if (kt) RSQTR_CigKeep.Note(n, kt.Amount);

			// Smoker's untouchable spell over: the flag back to what it was
			if (godUntil[n] > 0 && (level.maptime >= godUntil[n] || pmo.health <= 0))
			{
				pmo.bINVULNERABLE = godWas[n];
				godUntil[n] = 0;
			}

			// a level change found them still in a hand: the guns back, once the rig is up
			if (restore[n] && level.maptime > 1)
			{
				restore[n] = false;
				HandsBack(pmo, n, null, "a level change");
			}

			if (phase[n] != PH_NONE)
			{
				// USE IS THE CIGARETTE'S: the engine's use (doors, switches) sees the key as already down
				// (P_CheckUse acts on the rising edge only and clears this flag itself on release).
				p.usedown = true;

				if (pmo.health <= 0)
				{
					// dead: gone, and the hands told to give their guns back (a mod that revives you raises those, never
					// the cigarette or the Zippo)
					if (mouthProp[n]) mouthProp[n].Destroy();
					mouthProp[n] = null;
					HandsBack(pmo, n, null, "death");
					SetPhase(n, PH_NONE);
				}
				else if (!RSQTR_Rig.Flag("rsqtr_cig", p, false) || !RSQTR_Rig.Flag("rsqtr_on", p, true))
				{
					if (phase[n] == PH_SMOKE) Spit(pmo, n, false, null, "Cigarettes off");
					else PutBack(pmo, n, null, "Cigarettes off");
				}
			}

			// ANY SWITCH ENDS IT: the hands against what the ritual gave them. A switch of the main hand, or a prop in the
			// wrong hand, ends it at once; an off hand that differs, after SWITCH_GRACE; a switch key that the engine did
			// not carry out (the next / previous gun from the cigarette), KEY_TICS after the key, with the gun it asked for.
			if (phase[n] != PH_NONE)
			{
				if (p.OffhandWeapon is "RSQTR_ZippoWeapon") zipSeen[n] = true;
				String why; bool now;
				[why, now] = Switched(p, n);
				swGone[n] = why == "" ? 0 : swGone[n] + 1;
				if (now || swGone[n] >= SWITCH_GRACE) EndBySwitch(pmo, n, why);
				else if (keyEnd[n] > 0 && level.maptime - (keyEnd[n] - 1) >= KEY_TICS)
				{
					let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
					bool pendMain = pend && !pend.bOffhandWeapon && !IsProp(pend);
					Weapon t = (!pendMain && keyHand[n] == 0 && keyDir[n] != 0) ? NextFrom(pmo, n, keyDir[n]) : null;
					String kw = keyDir[n] > 0 ? "next weapon" : (keyDir[n] < 0 ? "previous weapon" : "slot / switch");
					EndBySwitch(pmo, n, String.Format("a weapon switch key (%s, %s hand) -> %s", kw, keyHand[n] ? "off" : "main", t ? WName(t) : "the switch already made"), t);
				}
				// the Zippo not up yet and no longer queued (the rig's queue gives up after 2 s): ask again
				else if (why == "" && !zipSeen[n] && rig && rig.offNext[n] == "" && !(p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon is "RSQTR_ZippoWeapon"))
					rig.QueueOff(n, "RSQTR_ZippoWeapon");
			}

			int age = level.maptime - phaseTic[n];
			// SMOKING: the Zippo shuts once the tip has caught (it stays in the hand), a puff now and then, then the flick
			if (phase[n] == PH_SMOKE)
			{
				if (age == ZIP_SHUT_TICS && zipOpen[n]) { zipOpen[n] = false; pmo.A_StartSound("rsqtr/zipclose", CHAN_AUTO, 0, 0.6); }
				if (age > 0 && age % PUFF_TICS == 0) Puff(pmo, 3, 0.6);
				if (age >= smokeTics[n]) Spit(pmo, n, true, null, "smoked");
			}

			// UNLIT CIGARETTE GOES AWAY (owner, 11-05: "if the cigarette is not lit within seven seconds after being in the
			// mouth, it goes away"): in the mouth, unlit, for rsqtr_cig_unlit_secs (level.maptime tics, as the smoke is
			// timed) -> it drops from the mouth, used up as a smoked one is (the pocket's count went down when it came out
			// and is not given back), the Zippo goes and the hands get their guns back. No slow motion, no smoulder.
			if (phase[n] == PH_MOUTH && RSQTR_Rig.Flag("rsqtr_cig_unlit", p, true)
				&& age >= clamp(RSQTR_Rig.Opt("rsqtr_cig_unlit_secs", p, 7), 3, 20) * TICRATE)
			{
				if (msg) Console.Printf("T_CIG t%d unlit in the mouth for %d tics -> gone (used up)", level.maptime, age);
				Flick(pmo, n, true, false);
				if (mouthProp[n]) mouthProp[n].Destroy();
				mouthProp[n] = null;
				HandsBack(pmo, n, null, "unlit too long");
				SetPhase(n, PH_NONE);
			}

			// THE NET, EVERY TIC: with no cigarette out, the Zippo leaves any hand at once (and any queue), and a cigarette
			// still up in the main hand with no switch away under way gives way to the hand's gun.
			if (phase[n] == PH_NONE && !restore[n] && pmo.health > 0)
			{
				let pend = p.PendingWeapon != WP_NOCHANGE ? p.PendingWeapon : null;
				bool pendMainReal = pend && !pend.bOffhandWeapon && !IsProp(pend);
				bool zipStray = IsProp(p.OffhandWeapon) || (pend && IsProp(pend)) || (rig && rig.offNext[n] ~== "RSQTR_ZippoWeapon") || (p.ReadyWeapon is "RSQTR_ZippoWeapon" && !pendMainReal);
				bool cigStray = IsProp(p.ReadyWeapon) && !pendMainReal;
				if (zipStray || cigStray)
				{
					if (msg) Console.Printf("T_CIG t%d no cigarette out but %s / %s (pending %s) in the hands: cleared", level.maptime, WName(p.ReadyWeapon), WName(p.OffhandWeapon), WName(pend));
					exitWhy[n] = "the net";
					ZipGone(pmo, n);
					if (pend && IsProp(pend)) p.PendingWeapon = WP_NOCHANGE;
					if (cigStray || p.ReadyWeapon is "RSQTR_ZippoWeapon") MainTo(pmo, n, null);
					offDue[n] = true; offDueTic[n] = level.maptime;
				}
			}

			// DEAD: the dead do not switch weapons, so a cigarette or Zippo would stay drawn in the dead hands (seen with
			// RSQ Melee and Gun Bonsai VR loaded, 11-03): their layers go, every tic (something there sets them again)
			if (pmo.health <= 0)
			{
				let ws = p.FindPSprite(PSP_WEAPON), os = p.FindPSprite(PSP_OFFHANDWEAPON);
				if (ws && IsProp(Weapon(ws.Caller))) p.SetPsprite(PSP_WEAPON, null);
				if (os && IsProp(Weapon(os.Caller))) p.SetPsprite(PSP_OFFHANDWEAPON, null);
			}

			// the off hand's gun at the end (its copy of the main hand's gun, or the empty off hand)
			if (offDue[n])
			{
				ResolveOff(pmo, n);
				if (!offDue[n] && msg) ExitLog(pmo, n, "off hand done");
			}
			if (msg && exitTic[n] > 0 && level.maptime == exitTic[n] + 1) ExitLog(pmo, n, "the tic after");

			// out of the hands: out of the inventory (never left in a weapon slot, never drawn)
			let cw = pmo.FindInventory("RSQTR_CigWeapon");
			if (cw && phase[n] != PH_HAND && !restore[n] && p.ReadyWeapon != cw && p.PendingWeapon != cw && p.OffhandWeapon != cw)
				pmo.TakeInventory("RSQTR_CigWeapon", 999);
			let zw = pmo.FindInventory("RSQTR_ZippoWeapon");
			bool zipComing = rig && rig.offNext[n] ~== "RSQTR_ZippoWeapon";
			if (zw && (phase[n] == PH_NONE || pmo.health <= 0) && !restore[n] && p.OffhandWeapon != zw && p.ReadyWeapon != zw && p.PendingWeapon != zw && !zipComing)
				pmo.TakeInventory("RSQTR_ZippoWeapon", 999);
		}
	}

	// THE FLICK: a small thrown cigarette, a short arc away from you, a tiny ember, the rig's foley.
	// From the hand (an unlit cigarette, out along the hand, away from the head) or from the mouth (the smoked butt,
	// straight out ahead; it smoulders where it lands and draws monsters, as Ermac's did).
	private void Flick(PlayerPawn pmo, int n, bool fromMouth, bool lit = true)
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
			// (the hand points AttackAngle + 90 in the map: hw_vrmodes.cpp writes viewYaw - 90)
			double ha = pmo.AttackAngle + 90;
			Vector2 away = from.xy - pmo.pos.xy;
			dir = away.Length() > 2 ? away.Unit() : (cos(ha), sin(ha));
			// a little of where the hand points, so a flick goes the way the wrist goes
			dir = (dir + (cos(ha), sin(ha)) * 0.5).Unit();
		}
		// (an unlit one out of the mouth, Unlit Cigarette Goes Away: the whole cigarette, which lies there and fades)
		let b = RSQTR_Butt(Actor.Spawn(fromMouth && lit ? "RSQTR_Butt" : "RSQTR_FlickedCig", from));
		if (b)
		{
			b.vel = (dir.x * FLICK_SPEED, dir.y * FLICK_SPEED, FLICK_UP) + pmo.vel;
			b.target = pmo;
			b.smoulder = fromMouth && lit;
			b.spin = 24;
			b.angle = atan2(dir.y, dir.x);
			b.Ember();
		}
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
		if (RSQTR_Rig.Flag("rsqtr_messages", players[n], false))
			Console.Printf("T_CIG flick from the %s t%d at (%.0f %.0f %.0f) vel (%.1f %.1f %.1f)", fromMouth ? "mouth" : "hand", level.maptime, from.x, from.y, from.z, b ? b.vel.x : 0., b ? b.vel.y : 0., b ? b.vel.z : 0.);
	}

	// SMOKED: it flicks out of the mouth, you exhale, the Zippo goes and the hands are as they were; RSQ_SlowMo starts on
	// this tic (WorldTick, the console player), unless slowmo is false (Cigarettes turned off mid-smoke). A switch or a
	// holster mid-smoke counts as smoked (EndBySwitch, owner 11-11).
	private void Spit(PlayerPawn pmo, int n, bool slowmo, Weapon target = null, String why = "smoked")
	{
		Flick(pmo, n, true);
		if (mouthProp[n]) mouthProp[n].Destroy();
		mouthProp[n] = null;
		Puff(pmo, 8, 2.0);
		pmo.A_StartSound("rsqtr/exhale", CHAN_AUTO, 0, 0.9);
		HandsBack(pmo, n, target, why);
		if (slowmo) spitTic[n] = level.maptime;
		// SMOKER (Gun Bonsai VR; owner, 11-03: "extend given slowmo and also allow godmode during it"): for the flick's slow
		// motion nothing can hurt you. Levels 1-3; without the patch, or at 0, the smoke is as the rows say.
		if (slowmo && RSQTR_Rig.Gb(pmo.player, 'Smoker') >= 1 && RSQTR_Rig.Flag("rsqtr_cig_slowmo", pmo.player, true))
		{
			if (godUntil[n] <= 0) godWas[n] = pmo.bINVULNERABLE;
			godUntil[n] = level.maptime + int(SmokeSecs(pmo.player) * TICRATE);
			pmo.bINVULNERABLE = true;
		}
		SetPhase(n, PH_NONE);
	}
	// how long the flick's slow motion runs: the Smoke Slow-Mo Seconds row (15 by default, owner 11-11), +2 s a Smoker
	// level (15 -> 17, 19, 21)
	static double SmokeSecs(PlayerInfo p)
	{
		return clamp(RSQTR_Rig.Num("rsqtr_cig_secs", p, 15), 5.0, 30.0) + 2.0 * max(RSQTR_Rig.Gb(p, 'Smoker'), 0);
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
			pitch = clamp(holder.pitch, -89, 89) - RSQTR_Cig.MOUTH_TILT;   // a little up from where you look, so its tip shows
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

// THE CUE (local, the console player's): a small steady glow where the cigarette would catch -- at the drawn burning end
// while the cigarette is in the mouth zone, at the tip in the mouth while the lit flame is in reach. Doom's bullet-puff
// sprite, tiny and orange, with a faint light.
class RSQTR_Cue : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.05;
		Translation "0:255=%[0.00,0.00,0.00]:[1.00,0.55,0.15]";
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		A_AttachLight("rsqtr_cue", DynamicLight.PointLight, "FF8030", 3, 0, DYNAMICLIGHT.LF_ATTENUATE);
	}
	States
	{
	Spawn:
		PUFF A -1 Bright;
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
// A cigarette standing in the pocket (RSQTR_Cig.ShowPack): Ermac's mesh, unlit, turned by the actor. Local, never in play.
class RSQTR_CigStowed : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States { Spawn: RSCG A -1; Stop; }
}

// CIGARETTES ARE PRECIOUS (owner 2026-11-09 21:39): what is left in each player's pocket, remembered across level
// changes outside the inventory (Brutal Doom empties it as a level starts). Static, so it outlives a level; cleared on a
// new game, when the pocket starts full. Every machine writes the same numbers (from the synced inventory).
class RSQTR_CigKeep : StaticEventHandler
{
	int cigsLeft[MAXPLAYERS];
	bool known[MAXPLAYERS];
	override void NewGame() { for (int i = 0; i < MAXPLAYERS; i++) { cigsLeft[i] = 0; known[i] = false; } }
	static void Note(int n, int amt)
	{
		let k = RSQTR_CigKeep(StaticEventHandler.Find("RSQTR_CigKeep"));
		if (k && n >= 0 && n < MAXPLAYERS) { k.cigsLeft[n] = amt; k.known[n] = true; }
	}
	// what player n had left, or full when nothing is known (a new game)
	static int Left(int n, int full)
	{
		let k = RSQTR_CigKeep(StaticEventHandler.Find("RSQTR_CigKeep"));
		return (k && n >= 0 && n < MAXPLAYERS && k.known[n]) ? k.cigsLeft[n] : full;
	}
}

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
