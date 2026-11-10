// RSQ FnF -- THE FLASHLIGHT'S BATTERY (owner 2026-11-06, design/DECISIONS_DEATH_BONES.md 3), Ermac's model (iAmErmac/VR-Flashlight,
// zscript/flashlight.txt, read; credited in CREDITS.txt). Rig only, not headset-confirmed.
//
//   CAPACITY   Battery (min) (rsqff_fl_batt, 3: Ermac's default): minutes of light from full. 0 = it never drains (as Ermac's
//              0). "Battery Never Drains" (rsqff_fl_batt_inf, off) does the same as a switch. Either way no meter is shown.
//   DRAIN      while the flashlight is on, one tic of charge a tic; RECHARGE while it is off, in the hand or on the clip, one
//              tic a tic (Ermac's: a full recharge takes as long as a full drain). Empty while on: it switches itself off
//              with its click; with under a second of light left it does not switch on (the click alone) until it has charged.
//   THE METER  on the flashlight's body, on top behind the head (tools/gen_torch.py meter: torch_meter.md3, its skins
//              meter0..10.png, our own art after Ermac's 10-step LED meter): 10 segments and a round power LED. Step = Ermac's
//              (over 90% 10 ... over 10% 2, else 1); the segments green (7-10), yellow (5-6), orange (3-4), red (1-2); at step
//              1 the LED blinks red (half of each second dark), as his does. Drawn as the overlay layer RSQFF_Torch.METER.
//   LOW        Ermac's dim and flicker, every 35 tics (faster below 20%): at 50% and under the light dims to 90%, x0.7-0.8
//              under 40%, x0.6-0.7 under 30%; under 20% also the spot's inner angle x0.5-0.7 and outer x0.8-0.9, re-rolled
//              every 10-17 tics; under 10% the light x0.4-0.6, inner x0.2-0.4, every 5-10 tics. Over 50%: full. The visible
//              cone fades with the light.
//   KILLS IN THE BEAM refill it: a monster (one that counts as a kill) you kill while it is inside your lit beam (within its reach and its outer angle,
//              in sight of you) gives KILL_REFILL (5%) of a full battery.
//   BONES DROP BATTERY BITS (rsqff_fl_bits, off): with Legion of Bones loaded, a Legion of Bones monster (by class name) you
//              kill drops a battery bit 8% of the time (BIT_CHANCE), or 3 always when it is a LegenDoom legendary or a Champions
//              champion. The bits are RSQ VisualRewards' Kill Rewards bits (its RSQVR_Service "kr.battery", by name; a battery
//              colour of their own): each one picked up refills BIT_REFILL (15%) of a full battery (RSQFF_TorchService
//              "battery.add"). Without VisualRewards no bits drop.
// NETPLAY: the charge is per player, synced (WorldTick and WorldThingDied on every machine; the dim's dice are the play RNG).

class RSQFF_Battery play
{
	const KILL_REFILL = 0.05;
	const BIT_REFILL = 0.15;
	const BIT_CHANCE = 8;
	const BIT_BOOSTED = 3;

	// the battery is in use: a capacity, and Never Drains off
	static bool InUse()
	{
		return RSQFF_Torches.SInt("rsqff_fl_batt", 3) > 0 && RSQFF_Torches.SInt("rsqff_fl_batt_inf", 0) == 0;
	}
	static int CapTics() { return max(1, RSQFF_Torches.SInt("rsqff_fl_batt", 3)) * 60 * TICRATE; }

	// too empty to switch on: under one second of light left (so a press right after it died is refused, not a click on and
	// a click off a tic later)
	static bool Empty(int n)
	{
		let h = RSQFF_Torches.Get();
		return h && InUse() && h.battOk[n] && h.charge[n] * CapTics() < TICRATE;
	}
	static int Permille(int n)
	{
		let h = RSQFF_Torches.Get();
		if (!h || !InUse()) return -1;
		return h.battOk[n] ? int(round(h.charge[n] * 1000)) : 1000;
	}

	// Ermac's step: over 90% 10, over 80% 9 ... over 10% 2, else 1 (empty too)
	static int Step(double c)
	{
		for (int k = 9; k >= 1; k--) if (c > k / 10.0) return k + 1;
		return 1;
	}
	// the meter's frame (0..10, QFFM A..K): -1 no meter (no battery in use). Step 1 blinks: dark (frame 0) half of each second.
	static int Shown(int n)
	{
		let h = RSQFF_Torches.Get();
		if (!h || !InUse()) return -1;
		int st = h.battOk[n] ? Step(h.charge[n]) : 10;
		if (st == 1 && (level.maptime % 35) < 18) return 0;
		return st;
	}

	// THE CHARGE CARRIES OVER (owner 2026-11-09 20:23: "prevent battery from refilling every level"). The handler holding the
	// charge is per level, so the charge also lives on the player as a token (RSQFF_BattKeep, permille + 1; 0 = never
	// stored), which the inventory carries to the next map. A level starts from it; a new game (no token) starts full.
	static double Stored(int n)
	{
		let pmo = playeringame[n] ? players[n].mo : null;
		let k = pmo ? pmo.FindInventory("RSQFF_BattKeep") : null;
		return (k && k.Amount > 0) ? clamp((k.Amount - 1) / 1000.0, 0.0, 1.0) : 1.0;
	}
	static void Store(int n, double c)
	{
		let pmo = playeringame[n] ? players[n].mo : null;
		if (!pmo) return;
		let k = pmo.FindInventory("RSQFF_BattKeep");
		if (!k) k = pmo.GiveInventoryType("RSQFF_BattKeep");
		if (k) k.Amount = 1 + int(round(clamp(c, 0.0, 1.0) * 1000));
	}

	static void Add(int n, double share, String why)
	{
		let h = RSQFF_Torches.Get();
		if (!h || !InUse() || n < 0 || n >= MAXPLAYERS) return;
		if (!h.battOk[n]) { h.battOk[n] = true; h.charge[n] = Stored(n); }
		double was = h.charge[n];
		h.charge[n] = min(1.0, h.charge[n] + share);
		Store(n, h.charge[n]);
		let pmo = playeringame[n] ? players[n].mo : null;
		if (pmo && RSQFF_Torches.Debug(pmo.player))
			Console.Printf("RSQFF battery t%d: player %d +%.0f%% (%s): %.1f%% -> %.1f%%", level.maptime, n, share * 100, why, was * 100, h.charge[n] * 100);
	}

	// every tic, every player: drain, recharge, empty, the dim's dice
	static void Tick(RSQFF_Torches h, PlayerPawn pmo, int n)
	{
		if (!InUse())
		{
			h.dimI[n] = 1.0; h.dimIn[n] = 1.0; h.dimOut[n] = 1.0;
			return;
		}
		if (!h.battOk[n]) { h.battOk[n] = true; h.charge[n] = Stored(n); }
		double step = 1.0 / CapTics();
		bool on = h.phase[n] == RSQFF_Torches.T_ON;
		int was = Step(h.charge[n]);
		if (on) h.charge[n] = max(0.0, h.charge[n] - step);
		else h.charge[n] = min(1.0, h.charge[n] + step);
		Store(n, h.charge[n]);
		bool dbg = RSQFF_Torches.Debug(pmo.player);
		int now = Step(h.charge[n]);
		if (dbg && now != was) Console.Printf("RSQFF battery t%d: player %d %.1f%% (%s): meter step %d", level.maptime, n, h.charge[n] * 100, on ? "draining" : "charging", now);
		if (on && h.charge[n] <= 0)
		{
			if (dbg) Console.Printf("RSQFF battery t%d: player %d EMPTY: the flashlight switches itself off", level.maptime, n);
			h.SetOn(pmo, n, false);
			on = false;
		}
		// Ermac's dim and flicker (flashlight.txt "Dims flashlight a bit when low on battery")
		if (h.flick[n] <= 0) h.flick[n] = 35; else h.flick[n]--;
		int lv = now;
		if (lv >= 6) { h.dimI[n] = 1.0; h.dimIn[n] = 1.0; h.dimOut[n] = 1.0; return; }
		if (h.flick[n] != 0) return;
		double i = 0.9, ii = 1.0, oo = 1.0;
		if (lv < 2)
		{
			i *= frandom[rsqff_batt](0.4, 0.6); ii = frandom[rsqff_batt](0.2, 0.4); oo = frandom[rsqff_batt](0.8, 0.9);
			h.flick[n] = random[rsqff_batt](5, 10);
		}
		else if (lv < 3)
		{
			i *= frandom[rsqff_batt](0.6, 0.7); ii = frandom[rsqff_batt](0.5, 0.7); oo = frandom[rsqff_batt](0.8, 0.9);
			h.flick[n] = random[rsqff_batt](10, 17);
		}
		else if (lv < 4) i *= frandom[rsqff_batt](0.6, 0.7);
		else if (lv < 5) i *= frandom[rsqff_batt](0.7, 0.8);
		h.dimI[n] = i; h.dimIn[n] = ii; h.dimOut[n] = oo;
		if (dbg && on) Console.Printf("RSQFF battery t%d: player %d low (step %d): light x%.2f, inner x%.2f, outer x%.2f", level.maptime, n, lv, i, ii, oo);
	}

	static double, double, double Dim(int n)
	{
		let h = RSQFF_Torches.Get();
		if (!h || !InUse()) return 1.0, 1.0, 1.0;
		return h.dimI[n], h.dimIn[n], h.dimOut[n];
	}

	// Legion of Bones' monsters (LOB_v1.05 decorate, read): its living Double Death copies and every undead
	static bool IsLob(Actor a)
	{
		static const Name LOBS[] = { 'LOBZombieMan', 'LOBShotgunGuy', 'LOBChaingunGuy', 'LOBDoomImp', 'LOBDemon', 'LOBSpectre',
			'LOBLostSoul', 'LOBHellKnight', 'LOBBaronOfHell', 'LOBCacodemon', 'LOBRevenant', 'LOBMancubus', 'LOBArachnotron',
			'LOBArchvile', 'LOBSpiderMastermind', 'SkullZombie', 'SkullShotgunner', 'SkullChaingunner', 'SkeletonImp',
			'SkeletonDemon', 'GhostSpectre', 'DragonSoul', 'SlayerKnight', 'Balrog', 'CacoLich', 'Painbringer', 'PhantomRevenant',
			'PhantomRevenant2', 'Abhorrent', 'Arachnobone', 'Reaper', 'Conqueror', 'RetroSkeleton' };
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass())
		{
			Name cn = c.GetClassName();
			if (cn == 'Actor') break;
			for (int i = 0; i < LOBS.Size(); i++) if (cn == LOBS[i]) return true;
		}
		return false;
	}

	// a monster died: a kill in someone's beam refills that battery; a Legion of Bones kill may drop battery bits
	static void Died(RSQFF_Torches h, WorldEvent e)
	{
		let a = e.Thing;
		// a monster that counts as a kill (Brutal Doom's helpers -- boot smearers, head hitboxes, a dying crawler -- do not)
		if (!a || a.player || !a.bIsMonster || !a.bCountKill || !InUse()) return;
		Actor by = (e.DamageSource && e.DamageSource.player) ? e.DamageSource : ((a.target && a.target.player) ? a.target : null);
		if (!by) return;
		int n = by.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS) return;
		bool dbg = RSQFF_Torches.Debug(by.player);
		// IN THE BEAM: inside its reach and outer angle, from the lens, and in sight
		if (h.phase[n] == RSQFF_Torches.T_ON && h.beamRange[n] > 0)
		{
			Vector3 v = (a.pos + (0, 0, a.height * 0.5)) - h.beamLens[n];
			double d = v.Length();
			double ang = d > 1 ? acos(clamp((v / d) dot h.beamDir[n], -1.0, 1.0)) : 0;
			double slack = d > 1 ? atan(a.radius / d) : 90;
			bool inBeam = d <= h.beamRange[n] + a.radius && ang <= h.beamOuter[n] + slack && by.CheckSight(a, SF_IGNOREVISIBILITY);
			if (inBeam) Add(n, KILL_REFILL, String.Format("a kill in the beam: %s", a.GetClassName()));
			else if (dbg) Console.Printf("RSQFF battery t%d: %s killed outside the beam (%.0f units, %.1f deg off the axis; beam %d units, %.1f deg)", level.maptime, a.GetClassName(), d, ang, h.beamRange[n], h.beamOuter[n]);
		}
		// BONES DROP BATTERY BITS
		if (RSQFF_Torches.SInt("rsqff_fl_bits", 0) <= 0 || !IsLob(a)) return;
		bool boosted = RSQFF_Fire.Boosted(a);
		int num = boosted ? BIT_BOOSTED : (random[rsqff_batt](1, 100) <= BIT_CHANCE ? 1 : 0);
		let it = ServiceIterator.Find("RSQVR_Service");
		Service s;
		Service vr = null;
		while (s = it.Next()) if (s.GetClassName() == 'RSQVR_Service') { vr = s; break; }
		int made = (num > 0 && vr) ? vr.GetInt("kr.battery", "", num, 0, a) : 0;
		if (dbg) Console.Printf("RSQFF battery t%d: Legion of Bones kill %s%s: %d battery bit%s (rolled %d, %s)", level.maptime, a.GetClassName(),
			boosted ? " (legendary / champion)" : "", made, made == 1 ? "" : "s", num, vr ? "RSQ VisualRewards" : "no RSQ VisualRewards: none");
	}
}

// the battery's charge on the player, carried from level to level (RSQFF_Battery.Store / Stored)
class RSQFF_BattKeep : Inventory
{
	Default { Inventory.MaxAmount 1001; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE; }
}
