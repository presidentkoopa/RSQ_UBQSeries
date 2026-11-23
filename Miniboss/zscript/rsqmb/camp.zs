// ============================================================================
// RSQ_Miniboss -- CAMPING IS PRESSURED (design/BOSS_REWORK.md section 4, its last bullet only). Code only, not run
// (2026-11-23, owner: hold rig checks until we talk).
//
//   CAMPING IS PRESSURED (section 4, its last bullet only; rsqmb_camp): while a fight is on, a player who stays within
//                      rsqmb_camp_radius (128) of one spot for rsqmb_camp_secs (8 s) gets the nearest living thrall sent
//                      straight at him: it targets him, comes on at once (its See state, its target held), shoots less for
//                      CAMP_RUSH tics (it closes in), roars from where it is (its own sight sound, carried far: the cue)
//                      and RSQ SlowMo's edge arrow points at it for a moment. The clock starts again from there. Until
//                      the director exists (section 1, Phase C) this mod does it. No living thrall: nothing is sent.
// ============================================================================

extend class RSQMB_Handler
{
	// ---- CAMPING IS PRESSURED (section 4) ---------------------------------------------------------------------------------
	const CAMP_LOCK = 60;         // its target held this many of its chase steps (Actor.threshold)
	const CAMP_RUSH = 105;        // it shoots far less for this long (3 s): it closes in
	const CAMP_ARROW = 53;        // RSQ SlowMo's edge arrow on it this long (1.5 s)
	int campTic[MAXPLAYERS];      // since when this player has stood within the radius (-1 no fight)
	double campX[MAXPLAYERS], campY[MAXPLAYERS];
	Actor campRush;               // the thrall sent, while it rushes
	int campRushEnd, campArrowEnd;
	double campRushMult;
	bool campInit;
	void CampTick()
	{
		int now = level.maptime;
		if (!campInit) { campInit = true; for (int n = 0; n < MAXPLAYERS; n++) campTic[n] = -1; }
		if (campRush && now >= campArrowEnd && campArrowEnd > 0) { ArrowClear(campRush); campArrowEnd = 0; }
		if (campRush && now >= campRushEnd) { if (campRush.health > 0) campRush.MissileChanceMult = campRushMult; campRush = null; }
		bool on = CI('rsqmb_camp', 1) != 0 && FightOn();
		double rad = clamp(CF('rsqmb_camp_radius', 128), 32, 1024);
		int secs = int(clamp(CF('rsqmb_camp_secs', 8), 2, 60) * TICRATE);
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!on || !playeringame[pn] || !players[pn].mo || players[pn].mo.health <= 0) { campTic[pn] = -1; continue; }
			let pmo = players[pn].mo;
			double dx = pmo.pos.x - campX[pn], dy = pmo.pos.y - campY[pn];
			if (campTic[pn] < 0 || dx * dx + dy * dy > rad * rad) { campTic[pn] = now; campX[pn] = pmo.pos.x; campY[pn] = pmo.pos.y; continue; }
			if (now - campTic[pn] < secs) continue;
			campTic[pn] = now;            // the next after another full stretch
			Actor t = NearestThrall(pmo);
			if (!t) { if (debug) Console.Printf("RSQMB camping: player %d stayed put; no living thrall to send", pn); continue; }
			SendAt(t, pmo);
		}
	}
	Actor NearestThrall(Actor pmo)
	{
		Actor best = null;
		double bd = 1e12;
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done) continue;
			for (int k = 0; k < b.thr.Size() && k < b.thrState.Size(); k++)
			{
				let t = b.thr[k];
				if (!t || t.health <= 0 || b.thrState[k] != RSQMB_Boss.ST_ALIVE || t.bDORMANT) continue;
				double d = pmo.Distance3D(t);
				if (d < bd) { bd = d; best = t; }
			}
		}
		return best;
	}
	// straight at him: its target, its See state, its target held, it shoots less while it closes; its roar from where it is
	void SendAt(Actor t, Actor pmo)
	{
		if (campRush && campRush != t && campRush.health > 0) campRush.MissileChanceMult = campRushMult;
		if (campRush && campArrowEnd > 0) ArrowClear(campRush);
		t.bAMBUSH = false;
		t.target = pmo;
		t.LastHeard = pmo;
		t.threshold = max(t.threshold, CAMP_LOCK);
		t.reactiontime = 0;
		if (t.SeeState) t.SetState(t.SeeState);
		if (campRush != t) campRushMult = t.MissileChanceMult;
		campRush = t;
		t.MissileChanceMult = max(t.MissileChanceMult, 8.0);
		campRushEnd = level.maptime + CAMP_RUSH;
		t.A_StartSound(t.SeeSound, CHAN_AUTO, 0, 1.0, 0.4);
		ArrowAdd(t, ColourOf(t, 0), 1.2);
		campArrowEnd = level.maptime + CAMP_ARROW;
		if (debug) Console.Printf("RSQMB camping t%d: a player stayed within %.0f for %.0f s: %s sent straight at him (%.0f units away)", level.maptime,
			CF('rsqmb_camp_radius', 128), CF('rsqmb_camp_secs', 8), t.GetClassName(), pmo.Distance3D(t));
	}
}
