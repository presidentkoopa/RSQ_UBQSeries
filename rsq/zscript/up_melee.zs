// ANY MELEE WEAPON'S UPGRADE PATH (Gun Bonsai's own Cleave, Dark Harvest, Shield, Sweep and
// Swiftness are left as they are). The rewards are for how you move.

// The per-player bookkeeping these need: how fast the head is moving, the two sabers'
// alternation, and the melee kills that make a big moment.
class RSQ_MeleeHandler : EventHandler
{
	// the head, physically: HmdPosition is the headset in its own tracking space, in metres
	// (hw_vrmodes.cpp SetUp copies it raw), so differencing it is the body's real motion and
	// never the stick's. Written by the renderer for the console player only.
	double headX[MAXPLAYERS], headY[MAXPLAYERS], headZ[MAXPLAYERS];
	int headTic[MAXPLAYERS];
	double headMps[MAXPLAYERS];
	double simHeadMps[MAXPLAYERS];   // a probe may stand in for the headset (headless testing)
	bool simHead[MAXPLAYERS];
	// Dual Harmony
	int dualLastSaber[MAXPLAYERS];   // 1 main saber, 2 off-hand saber
	int dualLastTic[MAXPLAYERS];
	int dualStack[MAXPLAYERS];
	// Adrenaline
	Array<int> killTic, killPn;      // recent melee kills (parallel)
	int pulseReady[MAXPLAYERS];
	int execTic[MAXPLAYERS];         // the last Executioner kill

	static RSQ_MeleeHandler Get() { return RSQ_MeleeHandler(EventHandler.Find("RSQ_MeleeHandler")); }

	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			if (simHead[pn]) { headMps[pn] = simHeadMps[pn]; continue; }
			let pmo = players[pn].mo;
			Vector3 h = pmo.HmdPosition;
			double mps = 0;
			if (h != (0, 0, 0) && headTic[pn] == level.maptime - 1)
			{
				// horizontal only: index 1 is the height in the headset's own frame
				double dx = h.x - headX[pn], dz = h.z - headZ[pn];
				mps = (dx, dz).Length() * TICRATE;
				if (mps > 8.0) mps = 0;   // a recentre, not a lunge
			}
			// a little memory, so the tic the blow lands still sees the step that carried it
			headMps[pn] = max(mps, headMps[pn] * 0.8);
			headX[pn] = h.x; headY[pn] = h.y; headZ[pn] = h.z;
			headTic[pn] = level.maptime;
		}
	}

	// Dual Harmony: called after every saber cut (WorldThingDamaged sees it land)
	override void WorldThingDamaged(WorldEvent e)
	{
		if (!e.Inflictor || !e.DamageSource || !e.DamageSource.player) return;
		String n = e.Inflictor.GetClassName();
		if (!RSQM.IsSaberName(n)) return;
		int pn = e.DamageSource.PlayerNumber();
		int which = (n ~== "UBQS_SaberOff") ? 2 : 1;
		int now = level.maptime;
		if (dualLastSaber[pn] == which && now - dualLastTic[pn] <= 8) { dualLastTic[pn] = now; return; }   // the same cut
		if (dualLastSaber[pn] != 0 && dualLastSaber[pn] != which && now - dualLastTic[pn] <= 26) dualStack[pn] = min(dualStack[pn] + 1, 5);
		else dualStack[pn] = 0;
		dualLastSaber[pn] = which;
		dualLastTic[pn] = now;
	}

	// what the NEXT cut by this saber would stack to (ModifyDamage runs before the cut lands)
	int DualStackFor(int pn, String saberName)
	{
		int which = (saberName ~== "UBQS_SaberOff") ? 2 : 1;
		int now = level.maptime;
		if (dualLastSaber[pn] == which && now - dualLastTic[pn] <= 8) return dualStack[pn];
		if (dualLastSaber[pn] != 0 && dualLastSaber[pn] != which && now - dualLastTic[pn] <= 26) return min(dualStack[pn] + 1, 5);
		return 0;
	}

	// Adrenaline: true when this kill makes a big moment
	bool MeleeKill(int pn, Actor target, bool executed)
	{
		int now = level.maptime;
		int mine = 0;
		for (int i = killTic.Size() - 1; i >= 0; i--)
		{
			if (now - killTic[i] > 105) { killTic.Delete(i); killPn.Delete(i); continue; }
			if (killPn[i] == pn) mine++;
		}
		killTic.Push(now); killPn.Push(pn); mine++;
		if (now < pulseReady[pn]) return false;
		bool big = executed || mine >= 3 || (target && target.GetSpawnHealth() >= 400);
		if (big)
		{
			pulseReady[pn] = now + 105;
			for (int i = killTic.Size() - 1; i >= 0; i--) if (killPn[i] == pn) { killTic.Delete(i); killPn.Delete(i); }
		}
		return big;
	}
}

// LUNGE: the faster your head is travelling when the blow lands, the harder it hits.
class RSQ_Upgrade_Lunge : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return info && info.IsMelee(); }
	static double Mult(uint lv, double mps) { return 1.0 + 0.15 * lv * clamp(mps - 0.5, 0.0, 3.0); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let h = RSQ_MeleeHandler.Get();
		if (!h || !pawn || !pawn.player) return damage;
		return damage * Mult(level, h.headMps[pawn.PlayerNumber()]);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("per", AsPercent(0.15 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 3.5)));
	}
}

// EXECUTIONER: a staggered monster with little left dies to the next melee hit.
class RSQ_Upgrade_Executioner : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return info && info.IsMelee(); }
	static double Share(uint lv) { return min(0.10 + 0.05 * lv, 0.5); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!Monster(target) || target.bBoss) return damage;
		if (target.health > target.GetSpawnHealth() * Share(level) || !RSQM.Staggered(target)) return damage;
		target.A_StartSound("rsq/execute", CHAN_AUTO, 0, 1.0);
		let h = RSQ_MeleeHandler.Get();
		if (h && pawn && pawn.player) h.execTic[pawn.PlayerNumber()] = gametic;   // Adrenaline: an execution
		return max(damage, target.health + 1);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("share", AsPercent(Share(level)));
	}
}

// ADRENALINE: melee kills that make a big moment -- three inside three seconds, a big monster,
// an execution -- fire a short slow-motion pulse through RSQ SlowMo (rsm_pulse, by name).
class RSQ_Upgrade_Adrenaline : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return info && info.IsMelee(); }
	static int Ms(uint lv) { return min(300 + 150 * lv, 1500); }
	static int Depth(uint lv) { return min(35 + 5 * lv, 60); }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target)
	{
		let h = RSQ_MeleeHandler.Get();
		if (!h || !pawn) return;
		int pn = pawn.PlayerNumber();
		bool executed = h.execTic[pn] == gametic;
		// AND IT CHARGES SLOWMO'S METER: 4 points a melee kill per level (RSQ SlowMo's
		// RSQSM_Service "adrenaline.add", found by name; nothing when SlowMo or its meter is off)
		RSQM.Charge(4 * level);
		if (h.MeleeKill(pn, target, executed)) RSQM.Pulse(pawn, Ms(level), Depth(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", string.format("%.2fs", Ms(level) / 1000.0));
	}
}
