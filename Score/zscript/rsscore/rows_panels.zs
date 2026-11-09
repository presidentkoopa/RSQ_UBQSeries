// ============================================================================
// THE PANEL ROWS (2026-11-09, design/SCORE_EXPANSION.md D: "Virtual Cop / Time Crisis, panels 1, 2"). Two rows about
// reading a monster's attack, and the one handler that watches attacks for them. Written by reading only: nothing here
// has been run (owner's rule for this batch).
//
//   JUSTICE SHOT  (Counterplay) your gun kills a monster in its attack wind-up, before the attack leaves it
//   READ IT       (Counterplay) a monster's shot flew at you and missed you by a little, and you kill whoever fired it
//                 within 3 s
//
// HOW "WINDING UP" IS READ, for every monster set (stock Doom, Brutal Doom, RSQ Monsters' CH and MG sets), from what the
// engine itself does, not from state names:
//   IN AN ATTACK  the engine's own flag JUSTATTACKED: A_Chase sets it when it sends the monster into its missile
//                 attack and clears it at the next A_Chase (p_enemy.cpp A_DoChase), so it is true from the moment the
//                 attack begins until the monster walks again, WHEREVER its Missile state jumps -- Brutal Doom's
//                 monsters leave "Missile" for their own attack states at once (melee.zs Counter's note, measured on
//                 the rig), and CH monsters jump to their own labels too (Monsters/zscript/monsters/imp RS_Imp.zs:
//                 Missile -> IceWeave, HM, Missile2). A melee attack sets no flag, so the stock test is kept beside it:
//                 the monster's state is inside its Missile or Melee sequence (RS_Melee.InAttack). MG monsters are
//                 stock-shaped (RS_MGMonsters.zs: Missile / Melee with A_FaceTarget, A_Chase), both tests see them.
//   NOT YET FIRED no shot has left it in the last FIRED tics: no missile that can hurt (GetMissileDamage > 0: Brutal
//                 Doom's fireball trails and wind-up sparks deal nothing and are not shots), no RSQ SlowMo round (its
//                 slowed bullets, RSQSM_Round, which carry their own damage), and no hitscan (WorldHitscanPreFired,
//                 which the engine calls before the trace, so a miss counts as fired too).
//   NOT REELING   not in its Pain sequence (a pained monster keeps JUSTATTACKED until it chases again).
// LIMITS, said plainly: a monster that fired less than a second ago and has begun a NEW attack does not pay (its last
// shot is still "lately"); a hitscan another mod cancels before the event reaches Score is not seen as fired; a Lost
// Soul's charge is its attack but fires nothing, so killing one mid-charge pays; a Brutal Doom melee lunge that leaves
// the Melee sequence at once is not seen (melee sets no flag). An attack made of a script with no A_Chase (a boss
// script, an ACS attack) is not seen at all.
// ============================================================================

class RS_PanelSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_RowPanel_JusticeShot");
		into.Push("RS_RowPanel_ReadIt");
	}
}

// THE WATCHER: what monsters fire, and which of their shots aimed at a player missed him by a little.
class RS_ScorePanels : EventHandler
{
	// every monster's last shot (a damaging missile, a SlowMo round, a hitscan), for Justice Shot
	Array<Actor> fV;
	Array<int> fTic;
	// Read It: monster shots in flight aimed at a player, the last point each was seen at, and how close it came
	Array<Actor> rsShot, rsFrom;
	Array<int> rsPn, rsTic, rsHurt;
	Array<double> rsNear, rsX, rsY, rsZ;
	// shots dodged: who fired, at whom, when
	Array<Actor> dgFrom;
	Array<int> dgPn, dgTic;

	const NEAR = 48.0;          // map units from the body's edge (1.5 m): a shot that passed this close was dodged
	const SHOT_LIFE = 350;      // a shot still flying after 10 s is forgotten
	const DODGE_KEEP = 105;     // Read It's window: 3 s from the dodge
	const MAXSHOTS = 64;
	const MAXFIRED = 128;

	static RS_ScorePanels Get() { return RS_ScorePanels(EventHandler.Find("RS_ScorePanels")); }

	private void NoteFired(Actor m)
	{
		if (!m) return;
		for (int i = fV.Size() - 1; i >= 0; i--)
			if (!fV[i] || fV[i] == m) { fV.Delete(i); fTic.Delete(i); }
		if (fV.Size() >= MAXFIRED) { fV.Delete(0); fTic.Delete(0); }
		fV.Push(m); fTic.Push(level.maptime);
	}

	// did this monster fire (any shot) in the last `tics` tics
	static bool FiredWithin(Actor m, int tics)
	{
		let h = Get();
		if (!h || !m) return false;
		for (int i = h.fV.Size() - 1; i >= 0; i--) if (h.fV[i] == m) return level.maptime - h.fTic[i] <= tics;
		return false;
	}

	// tics since monster m's shot at player pn was dodged, or -1
	static int DodgedAge(Actor m, int pn)
	{
		let h = Get();
		if (!h || !m) return -1;
		for (int i = h.dgFrom.Size() - 1; i >= 0; i--)
			if (h.dgFrom[i] == m && h.dgPn[i] == pn) return level.maptime - h.dgTic[i];
		return -1;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let m = e.Thing;
		if (!m || !m.bMissile) return;
		let src = m.target;
		if (!src || src.player || !src.bIsMonster || src.bFriendly) return;
		bool round = m.GetClassName() == 'RSQSM_Round';
		if (!round && m.GetMissileDamage(0, 1) <= 0) return;   // a trail, a spark, gore: not a shot
		NoteFired(src);
		let aim = src.target;
		if (!aim || !aim.player || aim.health <= 0) return;
		if (rsShot.Size() >= MAXSHOTS) DropShot(0);
		rsShot.Push(m); rsFrom.Push(src); rsPn.Push(aim.PlayerNumber()); rsTic.Push(level.maptime); rsHurt.Push(0);
		rsNear.Push(1e9); rsX.Push(m.pos.x); rsY.Push(m.pos.y); rsZ.Push(m.pos.z);
	}

	// a monster's bullet, before its trace (a miss is a shot too)
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let sh = e.Thing;
		if (sh && !sh.player && sh.bIsMonster && !sh.bFriendly) NoteFired(sh);
		return false;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let p = e.Thing;
		if (!p || !p.player || !e.Inflictor) return;
		for (int i = 0; i < rsShot.Size(); i++) if (rsShot[i] == e.Inflictor) { rsHurt[i] = 1; return; }
	}

	override void WorldTick()
	{
		for (int k = rsShot.Size() - 1; k >= 0; k--)
		{
			let m = rsShot[k];
			int pn = rsPn[k];
			PlayerPawn pmo = null;
			if (pn >= 0 && pn < MAXPLAYERS && playeringame[pn]) pmo = players[pn].mo;
			// sent back or knocked aside (its shooter is no longer its owner): the return rows' business, not a dodge
			if (m && m.bMissile && m.target != rsFrom[k]) { DropShot(k); continue; }
			Vector3 prev = (rsX[k], rsY[k], rsZ[k]);
			if (m && pmo) rsNear[k] = min(rsNear[k], Gap(prev, m.pos, pmo));
			if (m) { rsX[k] = m.pos.x; rsY[k] = m.pos.y; rsZ[k] = m.pos.z; }
			bool flying = m && m.bMissile;
			if (flying && level.maptime - rsTic[k] <= SHOT_LIFE) continue;
			// it burst or is gone: a dodge if it came near and never hurt him, and he and its shooter still live
			let from = rsFrom[k];
			if (!flying && rsHurt[k] == 0 && rsNear[k] <= NEAR && from && from.health > 0 && pmo && pmo.health > 0) NoteDodge(from, pn);
			DropShot(k);
		}
		if ((level.maptime % 35) == 0)
			for (int i = dgFrom.Size() - 1; i >= 0; i--)
				if (!dgFrom[i] || level.maptime - dgTic[i] > DODGE_KEEP) { dgFrom.Delete(i); dgPn.Delete(i); dgTic.Delete(i); }
	}

	private void NoteDodge(Actor from, int pn)
	{
		for (int i = dgFrom.Size() - 1; i >= 0; i--)
			if (!dgFrom[i] || (dgFrom[i] == from && dgPn[i] == pn)) { dgFrom.Delete(i); dgPn.Delete(i); dgTic.Delete(i); }
		if (dgFrom.Size() >= 32) { dgFrom.Delete(0); dgPn.Delete(0); dgTic.Delete(0); }
		dgFrom.Push(from); dgPn.Push(pn); dgTic.Push(level.maptime);
		if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: Read It armed: %s's shot dodged by player %d", from.GetClassName(), pn);
	}

	private void DropShot(int k)
	{
		rsShot.Delete(k); rsFrom.Delete(k); rsPn.Delete(k); rsTic.Delete(k); rsHurt.Delete(k);
		rsNear.Delete(k); rsX.Delete(k); rsY.Delete(k); rsZ.Delete(k);
	}

	// how close the shot's path a -> b came to the player's body: the nearest point of the segment to his axis across
	// the ground, its height there against his height, less his radius (map units; 0 or less: it went through him)
	static double Gap(Vector3 a, Vector3 b, Actor p)
	{
		Vector2 d = b.xy - a.xy;
		Vector2 c = p.pos.xy;
		double len2 = d dot d;
		double t = len2 > 0.0001 ? clamp(((c - a.xy) dot d) / len2, 0.0, 1.0) : 0.0;
		Vector3 q = a + (b - a) * t;
		double across = (q.xy - c).Length();
		double dz = 0;
		if (q.z < p.pos.z) dz = p.pos.z - q.z;
		else if (q.z > p.pos.z + p.height) dz = q.z - (p.pos.z + p.height);
		return sqrt(across * across + dz * dz) - p.radius;
	}
}

// D1 JUSTICE SHOT: your gun kills a monster in its attack wind-up, before the attack leaves it (Virtual Cop's justice
// shot, Time Crisis's shot before the flash). A gun shot of yours only: a melee blow into an attack is Counter's (melee.zs).
// A big moment on a monster of 700+ base (an Arch-vile mid-spell, a Baron).
class RS_RowPanel_JusticeShot : RS_ScoreBonus
{
	const MULT = 0.4;
	const FIRED = 35;           // a shot of its own inside the last second: it has fired
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Justice Shot"; }
	static bool Winding(Actor v)
	{
		if (!v || v.bSkullFly || RS_Melee.InPain(v)) return false;
		if (!v.bJustAttacked && !RS_Melee.InAttack(v)) return false;
		return !RS_ScorePanels.FiredWithin(v, FIRED);
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !ev.victim) return 0.0;
		if (RS_Physical.ShotKind(ev) == RS_Physical.SHOT_NONE) return 0.0;
		return Winding(ev.victim) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0 && ev.victimSpawnHealth >= 700; }
}

// D2 READ IT: a monster's shot at you passed within 1.5 m and never hurt you (you read it and moved: a step, a lean, a
// shootdodge), and you kill the monster that fired it within 3 s. Any killing blow of yours.
class RS_RowPanel_ReadIt : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Read It"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !ev.victim || ev.killerNum < 0) return 0.0;
		int t = RS_ScorePanels.DodgedAge(ev.victim, ev.killerNum);
		return (t >= 0 && t <= RS_ScorePanels.DODGE_KEEP) ? MULT : 0.0;
	}
}
