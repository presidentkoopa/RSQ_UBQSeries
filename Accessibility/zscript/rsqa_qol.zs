// RSQ_Accessibility -- the QoL round (owner's picks AC1-AC8, PICKS_2026-10-31.md "QoL round"; README.md "QoL round").
//
//   AC1  OptionMenuItemRSQAResetSeries  one row runs every LOADED series mod's own "Reset All" (Accessibility kept)
//   AC2  rsqa_rumble_scale              every rumble through RSQA_Buzz scaled; a shared number for the rest
//   AC3  rsqa_seated                    Standing / Seated / Auto, with the measured drop of your eyes (metres)
//   AC4  RSQA_Comfort (MENUDEF preset)  Vignette Medium, Min SlowMo Ease 1 s, Photosensitive Mode in one go
//   AC5  rsqa_vig_knock                 the comfort vignette on a big knockback and on a long fall
//   AC6  rsqa_steady                    Steady Hands: both hands' poses through a 1-euro filter, shared by service
//   AC7  rsqa_slow_taps                 every tap / double-tap window x1.5 (a shared number)
//   AC8  rsqa_cue_wake                  Sound Cues also mark a monster waking or teleporting in out of view
//
// RSQA_Service answers (zscript/rsqa_core.zs):
//   GetIntData("steady", "", pn)                     1 when Steady Hands is on
//   GetDoubleData("steady", comp, pn, hand)          hand 0 main / 1 off; comp x y z (map units, world), angle pitch
//   GetDouble    ("steady", comp, pn, hand)            roll (degrees), dx dy dz (unit aim direction). Off: the raw pose.
//                                                     GetDouble (play) first brings the filter up to this tic.
//   GetIntData("seated", "", pn)                     1 while that player is seated (Seated, or Auto and measured)
//   GetDoubleData("seated.drop", "", pn)             metres your eyes are below standing (0 standing)
//   GetDoubleData("seated.eye" / "stand.eye", "", pn) metres: the seated eyes, the standing reference
//   GetDoubleData("rumble")                          the Rumble Strength multiplier, 0..2
//   GetDoubleData("taps")                            1.5 with Slower Taps, else 1.0

class RSQA_QoL : EventHandler
{
	// ---- AC6 STEADY HANDS -----------------------------------------------------------------------------
	// The 1-euro filter (Casiez, Roussel, Vogel, CHI 2012): a low-pass whose cut-off rises with the speed, so a
	// still hand is smoothed hard and a fast one passes almost untouched. Per tic (35 Hz), per axis, on the hand's
	// offset from the pawn (walking, turning and teleports move the pawn, not the hand). The numbers come from
	// tools/steady_sim.py (3 mm / 6 Hz tremor + 1.5 mm noise, a 0.6 m swing in 5 tics; 0.8 deg tremor, a 60 deg
	// flick in 4 tics): position tremor x0.27 with at most 0.19 tic of lag on the swing; direction x0.28, 0.25 tic.
	const POS_MINCUT = 1.0;     // Hz
	const POS_BETA   = 10.0;    // Hz per m/s
	const ANG_MINCUT = 1.0;     // Hz
	const ANG_BETA   = 0.05;    // Hz per deg/s
	const D_CUT      = 5.0;     // Hz, the speed's own smoothing
	const COMPS = 6;            // x y z angle pitch roll
	const SLOTS = MAXPLAYERS * 2 * COMPS;

	transient double sXh[SLOTS], sXp[SLOTS], sDh[SLOTS];
	transient int    stTic[MAXPLAYERS];
	transient Actor  stMo[MAXPLAYERS];
	transient bool   stInit[MAXPLAYERS];

	static RSQA_QoL Get() { return RSQA_QoL(EventHandler.Find("RSQA_QoL")); }
	static clearscope bool SteadyOn() { return RSQA_Set.I('rsqa_steady', 1) != 0; }

	static clearscope double EuroA(double fc) { return 1.0 / (1.0 + TICRATE / (2.0 * M_PI * fc)); }

	// the raw pose of a hand: 0 main (Attack*), 1 off (Offhand*); position as the offset from the pawn
	static clearscope double Raw(Actor mo, int hand, int c)
	{
		if (hand == 0)
		{
			if (c < 3) { Vector3 d = mo.AttackPos - mo.pos; return c == 0 ? d.x : c == 1 ? d.y : d.z; }
			return c == 3 ? mo.AttackAngle : c == 4 ? mo.AttackPitch : mo.AttackRoll;
		}
		if (c < 3) { Vector3 d = mo.OffhandPos - mo.pos; return c == 0 ? d.x : c == 1 ? d.y : d.z; }
		return c == 3 ? mo.OffhandAngle : c == 4 ? mo.OffhandPitch : mo.OffhandRoll;
	}

	void SteadyTick(int pn)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return;
		let mo = players[pn].mo;
		if (!mo) { stInit[pn] = false; return; }
		if (stInit[pn] && stTic[pn] == level.maptime && stMo[pn] == mo) return;
		bool fresh = !stInit[pn] || stMo[pn] != mo || level.maptime - stTic[pn] > 2 || level.maptime < stTic[pn];
		stTic[pn] = level.maptime; stMo[pn] = mo; stInit[pn] = true;
		double upm = 34.0;
		let c = CVar.FindCVar('vr_vunits_per_meter'); if (c && c.GetFloat() > 1) upm = c.GetFloat();
		double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
		double aD = EuroA(D_CUT);
		for (int hand = 0; hand < 2; hand++)
		{
			for (int k = 0; k < COMPS; k++)
			{
				int i = (pn * 2 + hand) * COMPS + k;
				double r = Raw(mo, hand, k);
				if (k == 3 || k == 5) r = sXp[i] + Actor.DeltaAngle(sXp[i], r);   // unwrapped across +-180
				if (fresh) { sXh[i] = r; sXp[i] = r; sDh[i] = 0; continue; }
				// speed this tic: m/s for position (the up axis also x pixelstretch: 00_CAPABILITIES 1.2a), deg/s for angles
				double sp = (r - sXp[i]) * TICRATE;
				if (k < 2) sp /= upm; else if (k == 2) sp *= ps / upm;
				sDh[i] += aD * (sp - sDh[i]);
				double fc = k < 3 ? POS_MINCUT + POS_BETA * abs(sDh[i]) : ANG_MINCUT + ANG_BETA * abs(sDh[i]);
				sXh[i] += EuroA(fc) * (r - sXh[i]);
				sXp[i] = r;
			}
		}
	}

	// the smoothed (on) or raw (off) pose, any scope: comp x y z angle pitch roll dx dy dz
	clearscope double Steady(int pn, int hand, String comp)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn] || !players[pn].mo) return 0;
		let mo = players[pn].mo;
		hand = hand ? 1 : 0;
		bool on = SteadyOn() && stInit[pn] && stMo[pn] == mo;
		int b = (pn * 2 + hand) * COMPS;
		comp = comp.MakeLower();
		if (comp == "x") return mo.pos.x + Pick(on, b, mo, hand, 0);
		if (comp == "y") return mo.pos.y + Pick(on, b, mo, hand, 1);
		if (comp == "z") return mo.pos.z + Pick(on, b, mo, hand, 2);
		double an = Pick(on, b, mo, hand, 3), pi = Pick(on, b, mo, hand, 4);
		if (comp == "angle") return Actor.Normalize180(an);
		if (comp == "pitch") return pi;
		if (comp == "roll") return Actor.Normalize180(Pick(on, b, mo, hand, 5));
		if (comp == "dx") return cos(an) * cos(pi);
		if (comp == "dy") return sin(an) * cos(pi);
		if (comp == "dz") return -sin(pi);
		return 0;
	}

	private clearscope double Pick(bool on, int b, Actor mo, int hand, int k)
	{
		return on ? sXh[b + k] : Raw(mo, hand, k);
	}

	// ---- AC3 SEATED PLAY ------------------------------------------------------------------------------
	// Your seated eyes are tracked the way RSQ Tactical Rig tracks them (TacticalRig/zscript/rsqtr/body.zs
	// UpdateSeat): the highest the headset has been lately, easing down 2 cm a second, rising at once, and taken
	// straight to the headset once it has stayed 0.20 m below for a second. The standing reference is the
	// measured standing eye height (rsqa_stand_eye, the "Measure Standing Height" row), else the highest steady
	// headset height this session, at least 1.62 m (Tactical Rig's default eyes, rsqtr_eye_m). Auto calls you
	// seated once the eyes have been 0.25 m or more below standing for 2 s, standing once within 0.15 m for 1 s.
	const SEAT_EASE   = 0.02 / 35.0;
	const SEAT_DROP   = 0.20;
	const STAND_DEF   = 1.62;
	const AUTO_SIT    = 0.25;
	const AUTO_STAND  = 0.15;
	transient double seatEye[MAXPLAYERS], highEye[MAXPLAYERS], lastH[MAXPLAYERS];
	transient int    seatLow[MAXPLAYERS], stillTics[MAXPLAYERS], autoTics[MAXPLAYERS];
	transient bool   seated[MAXPLAYERS];

	static clearscope int SeatMode() { return clamp(RSQA_Set.I('rsqa_seated', 2), 0, 2); }

	clearscope double StandEye(int pn)
	{
		double m = RSQA_Set.F('rsqa_stand_eye', 0);
		if (m > 0.5) return m;
		return (pn >= 0 && pn < MAXPLAYERS) ? max(STAND_DEF, highEye[pn]) : STAND_DEF;
	}

	clearscope bool IsSeated(int pn)
	{
		if (pn < 0 || pn >= MAXPLAYERS) return false;
		int m = SeatMode();
		return m == 1 || (m == 2 && seated[pn]);
	}

	clearscope double SeatDrop(int pn)
	{
		if (!IsSeated(pn) || seatEye[pn] <= 0.3) return 0;
		return max(0.0, StandEye(pn) - seatEye[pn]);
	}

	void SeatTick(int pn)
	{
		let mo = playeringame[pn] ? players[pn].mo : null;
		double h = mo ? mo.HmdPosition.y : 0;
		if (h <= 0.3) { seatEye[pn] = 0; seatLow[pn] = 0; return; }   // no headset height read
		seatLow[pn] = h < seatEye[pn] - SEAT_DROP ? seatLow[pn] + 1 : 0;
		if (seatEye[pn] <= 0 || h > seatEye[pn] || seatLow[pn] > TICRATE) { seatEye[pn] = h; seatLow[pn] = 0; }
		else seatEye[pn] = max(h, seatEye[pn] - SEAT_EASE);
		// the standing reference learns your height from a head held steady (3 cm) for a second, never from a hop
		stillTics[pn] = abs(h - lastH[pn]) < 0.03 ? stillTics[pn] + 1 : 0;
		if (abs(h - lastH[pn]) >= 0.03) lastH[pn] = h;
		if (stillTics[pn] >= TICRATE) highEye[pn] = max(highEye[pn], h);
		double below = StandEye(pn) - seatEye[pn];
		bool want = seated[pn] ? below > AUTO_STAND : below >= AUTO_SIT;
		if (want == seated[pn]) autoTics[pn] = 0;
		else if (++autoTics[pn] >= (want ? 2 * TICRATE : TICRATE)) { seated[pn] = want; autoTics[pn] = 0; }
	}

	// "Measure Standing Height": stand up straight and pick the row (MENUDEF: `event rsqa_measure`)
	override void ConsoleProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqa_measure")) return;
		let mo = players[consoleplayer].mo;
		double h = mo ? mo.HmdPosition.y : 0;
		if (h <= 0.5) { Console.Printf("RSQ Accessibility: no headset height to measure"); return; }
		let cv = CVar.FindCVar('rsqa_stand_eye');
		if (cv) cv.SetFloat(h);
		Console.Printf("RSQ Accessibility: standing eye height %.2f m", h);
	}

	// ---- AC5 VIGNETTE ON KNOCKBACK AND LONG FALLS ------------------------------------------------------
	// A knockback is the pawn's speed jumping by more than 8 u/tic in one tic to over 12 u/tic (Doom's own
	// running tops out near 16.7 u/tic but builds 1.6 u/tic a tic at most; a jump adds 8 straight up and stays
	// under 12): a rocket blast, an Arch-vile's toss, being thrown. It holds while you fly, fading. A long fall
	// is falling faster than 10 u/tic (10 tics of free fall at Doom's gravity of 1 u/tic^2, about 1.9 m).
	const KNOCK_DV   = 8.0;
	const KNOCK_MIN  = 12.0;
	const FALL_VZ    = 10.0;
	transient double kPrev, kStr;
	transient int    kTic;

	void KnockTick()
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo || pmo.health <= 0) { kPrev = 0; kStr = 0; return; }
		double v = pmo.vel.Length();
		if (v - kPrev > KNOCK_DV && v > KNOCK_MIN)
		{
			kStr = max(kStr, clamp(0.5 + (v - kPrev - KNOCK_DV) / 16.0, 0.5, 1.0));
			kTic = level.maptime;
			if (RSQA_Set.I('rsqa_debug')) Console.Printf("RSQA knock %d dv=%.1f v=%.1f str=%.2f", level.maptime, v - kPrev, v, kStr);
		}
		kPrev = v;
		if (RSQA_Set.I('rsqa_vig_knock') == 0 || RSQA_Set.Vignette() <= 0) { kStr = 0; return; }
		let h = RSQA_Handler.Get();
		if (!h) return;
		bool flying = !pmo.player.onground || v > 10;
		if (kStr > 0.05 && flying && level.maptime - kTic < 3 * TICRATE) { h.Comfort(consoleplayer, kStr); kStr *= 0.97; }
		else kStr = 0;
		if (!pmo.player.onground && pmo.vel.z < -FALL_VZ)
			h.Comfort(consoleplayer, clamp(0.4 + (-pmo.vel.z - FALL_VZ) / 15.0, 0.4, 1.0));
	}

	// ---- AC8 WAKE AND TELEPORT CUES ---------------------------------------------------------------------
	// Every monster within 1536 units is looked at every 2 tics: one that has just got a target (woken: A_Look
	// sets it) aimed at you, or that has jumped more than 96 units while moving under 20 u/tic (a teleport), or
	// that was spawned beside a teleport fog (a monster teleporting in), is a cue at where it is now: an arrow
	// round the view when it is out of view and a short rumble on that side (RSQA_Handler.Note, kind 3).
	const WAKE_RANGE = 1536.0;
	const WAKE_EVERY = 2;
	transient Array<Actor> wMon;
	transient Array<double> wX, wY, wZ;
	transient Array<int> wAwake;
	transient Array<double> fogX, fogY, fogZ;
	transient Array<int> fogTic;

	static clearscope bool WakeOn()
	{
		return RSQA_Set.I('rsqa_cue_wake') != 0 && (RSQA_Set.CueVisual() || RSQA_Set.CueRumble());
	}

	void Track(Actor m, bool fresh)
	{
		wMon.Push(m); wX.Push(m.pos.x); wY.Push(m.pos.y); wZ.Push(m.pos.z);
		wAwake.Push(m.target ? 1 : 0);
		if (fresh) wAwake[wAwake.Size() - 1] = 2;   // new: checked against the fogs on the next look
	}

	override void WorldLoaded(WorldEvent e)
	{
		wMon.Clear(); wX.Clear(); wY.Clear(); wZ.Clear(); wAwake.Clear();
		fogX.Clear(); fogY.Clear(); fogZ.Clear(); fogTic.Clear();
		for (int i = 0; i < MAXPLAYERS; i++) { stInit[i] = false; autoTics[i] = 0; }
		kPrev = 0; kStr = 0;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next())) if (a.bISMONSTER && a.health > 0) Track(a, false);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		if (a is "TeleportFog")
		{
			fogX.Push(a.pos.x); fogY.Push(a.pos.y); fogZ.Push(a.pos.z); fogTic.Push(level.maptime);
			return;
		}
		if (a.bISMONSTER && !a.player) Track(a, level.maptime > 0);
	}

	void WakeTick()
	{
		// forget fogs older than 4 tics
		for (int i = fogTic.Size() - 1; i >= 0; i--)
			if (level.maptime - fogTic[i] > 4) { fogX.Delete(i); fogY.Delete(i); fogZ.Delete(i); fogTic.Delete(i); }
		if (level.maptime % WAKE_EVERY) return;
		let pmo = players[consoleplayer].mo;
		bool on = WakeOn() && pmo && pmo.health > 0;
		let h = RSQA_Handler.Get();
		bool dbg = RSQA_Set.I('rsqa_debug') != 0;
		for (int i = wMon.Size() - 1; i >= 0; i--)
		{
			let m = wMon[i];
			if (!m || m.health <= 0 || !m.bISMONSTER)
			{
				wMon.Delete(i); wX.Delete(i); wY.Delete(i); wZ.Delete(i); wAwake.Delete(i);
				continue;
			}
			int was = wAwake[i];
			bool awake = m.target != null;
			Vector3 moved = (m.pos.x - wX[i], m.pos.y - wY[i], m.pos.z - wZ[i]);
			wX[i] = m.pos.x; wY[i] = m.pos.y; wZ[i] = m.pos.z;
			wAwake[i] = awake ? 1 : 0;
			if (!on || !h || m.Distance3D(pmo) > WAKE_RANGE) continue;
			String why = "";
			if (was == 2)
			{
				for (int f = 0; f < fogTic.Size(); f++)
					if ((m.pos.xy - (fogX[f], fogY[f])).Length() < 64) { why = "teleported in"; break; }
			}
			else if (was == 0 && awake && m.target == pmo) why = "woke";
			else if (was != 2 && moved.Length() > 96 && m.vel.Length() < 20) why = "teleported";
			if (why == "") continue;
			h.Note(m, m.pos, 3);
			if (dbg) Console.Printf("RSQA wake %d %s %s rel=%.0f", level.maptime, m.GetClassName(), why,
				Actor.DeltaAngle(pmo.angle, pmo.AngleTo(m)));
		}
	}

	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			SteadyTick(pn);
			SeatTick(pn);
		}
		KnockTick();
		WakeTick();
	}
}

// ---- AC1 RESET EVERY SERIES MOD -----------------------------------------------------------------------
// One confirmed row runs each loaded series mod's own "Reset All" row (whatever list that mod keeps, run as the
// mod runs it), found by walking Radiant Silvergun Options and the series pages under it. A mod that is not
// loaded adds no page there, so nothing of it is touched. Pages hidden by Simple menus (rsqa_menus) are walked
// from their full row lists. This page (Accessibility) is not reset: it has its own Reset All.
class OptionMenuItemRSQAResetSeries : OptionMenuItemSafeCommand
{
	OptionMenuItemRSQAResetSeries Init(String label, String prompt = "")
	{
		Super.Init(label, 'none', prompt);
		return self;
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == Menu.MKEY_MBYes)
		{
			int n = RunAll();
			Console.Printf("RSQ Accessibility: %d series mods reset", n);
			return true;
		}
		return Super.MenuEvent(mkey, fromcontroller);
	}

	static int RunAll()
	{
		Array<Name> seen;
		int ran = 0;
		Walk('RSQ_RSOptions', seen, 0, ran);
		return ran;
	}

	static void Walk(Name page, out Array<Name> seen, int depth, out int ran)
	{
		if (depth > 5 || page == 'none' || page == 'RSQA_Options') return;
		for (int i = 0; i < seen.Size(); i++) if (seen[i] == page) return;
		seen.Push(page);
		let desc = OptionMenuDescriptor(MenuDescriptor.GetDescriptor(page));
		if (!desc) return;
		Array<OptionMenuItem> rows;
		let mm = RSQA_MenuMode(StaticEventHandler.Find("RSQA_MenuMode"));
		bool copied = false;
		if (mm) for (int i = 0; i < mm.copies.Size(); i++)
			if (mm.copies[i].menu == page) { rows.Copy(mm.copies[i].rows); copied = true; break; }
		if (!copied) rows.Copy(desc.mItems);
		for (int i = 0; i < rows.Size(); i++)
		{
			let it = rows[i];
			if (!it) continue;
			if (it is "OptionMenuItemSafeCommand")
			{
				if (it is "OptionMenuItemRSQAResetSeries" || !(it.mLabel ~== "Reset All")) continue;
				it.MenuEvent(Menu.MKEY_MBYes, false);   // the row's own confirmed action: its own command, run safe
				Console.Printf("RSQ Accessibility: reset %s", page);
				ran++;
				continue;
			}
			if (it is "OptionMenuItemSubmenu" && !(it is "OptionMenuItemCommand")) Walk(it.GetAction(), seen, depth + 1, ran);
		}
	}
}
