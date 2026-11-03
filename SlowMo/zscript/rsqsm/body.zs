// THE BODY IN SLOW MOTION (the owner's picks 26 and 28 from the Quest teardown, 2026-10-31).
// The world slows; you do not -- so your head gets to act on what the slowed world sends.
// (Pick 25, catching a slowed bullet in the off hand, was removed on the owner's word, 2026-11-02.)
//
// LEAN OUT OF A BULLET'S PATH (pick 26, on by default; rsqsm_lean). 10_TIME §4.6: "a successful lean is a
//   gate, not a hit test." QuestZDoom moves the pawn with the head (hw_openxrdevice.cpp:665-687: the
//   head's room-scale delta is run through P_XYMovement every frame), so a lean already carries the
//   pawn's box with it; what the box does not know is that the BODY stayed where it was. The lean is
//   the head's offset from a running baseline of HmdPosition (actor.zs:277, metres, stage space,
//   written per frame: hw_vrmodes.cpp:445); its direction in the map is the pawn's own displacement
//   over the same window, used only when the two agree (so walking with the stick, which moves the
//   pawn and not the head, is never a lean). A slowed enemy round that touches you then MISSES if it
//   passes on the side you leaned away from, further from your centre than your radius less the lean
//   (a 1:1 transfer, §4.6's "honest mapping"). A round at your new centre still hits.
//
// COLOURS DRAIN (pick 28, off by default; rsqsm_drain). 10_TIME §4.5 / apply/05 §6.1: a post-process
//   pass on the scene (GLDEFS HardwareShader PostProcess scene, gldefs.cpp:1514-1529), driven by
//   PPShader (ppshader.zs:3-4) from the clock's eased scale; desaturation only (no vignette, no
//   aberration: §4.5's VR caution). QuestZDoom runs scene post-processing per eye, as
//   RSQ_Accessibility's comfort vignette does with the same route.
//
// NETPLAY: the head pose exists only on the camera player's machine (_BASELINE_FACTS §3), so that
// machine sends the lean as a network event (rsqsm_lean); every machine applies it from synced state.
class RSQSM_Body : EventHandler
{
	// ---- synced ------------------------------------------------------------------------------
	Array<Actor> passAct;                          // bullets let through a leaning player (bTHRUACTORS set here)
	// Enemy bullets in flight. A missile is not in the blockmap (Projectile sets +NOBLOCKMAP), so a
	// BlockThingsIterator never finds one (measured: the hand sat on a round's line and saw nothing);
	// they are listed as they spawn and pruned as they go.
	Array<Actor> bullets;
	double leanX[MAXPLAYERS], leanY[MAXPLAYERS];   // the lean in map units, 0 = none

	// ---- local (the console player) -------------------------------------------------------------
	private transient bool haveHead;
	private transient double hbx, hbz, pbx, pby;   // the baselines: head (stage, metres), pawn (map)
	private transient int sentLX, sentLY;
	private transient ui bool drainOn, drainSeen;

	static RSQSM_Body Get() { return RSQSM_Body(EventHandler.Find("RSQSM_Body")); }

	static bool Dev() { let dv = CVar.FindCVar("developer"); return dv && dv.GetInt() >= 1; }

	// ---- shared tests ------------------------------------------------------------------------------
	// A slowed enemy bullet: one of this mod's rounds, or a fast small missile (Brutal Doom fires its
	// bullets as speed-50 projectiles; measured 50 -> 12.5 at depth 0.25, HANDOFF) that the clock is
	// slowing now. Fireballs and rockets are not bullets (slow, or wide).
	static bool SlowedBullet(Actor a, RSQSM_Clock clock)
	{
		if (!a || a.bDestroyed || !a.bMISSILE || !a.target || a.target.player) return false;
		if (!clock || !clock.Active() || clock.StoodDown()) return false;
		let r = RSQSM_Round(a);
		if (r) return !Actor.InStateSequence(r.CurState, r.FindState("Death"));
		if (a.radius > 8) return false;
		if (GetDefaultByType(a.GetClass()).Speed < 30) return false;
		return clock.FactorFor(a, a.Speed) < 0.9999;
	}

	// ---- the bullet list ------------------------------------------------------------------------------
	static bool BulletLike(Actor a)
	{
		return a && a.bMISSILE && a.radius <= 8 && GetDefaultByType(a.GetClass()).Speed >= 30;
	}
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (BulletLike(a) && !(a.target && a.target.player)) bullets.Push(a);
	}

	// A LOADED GAME STARTS WITH NO LEAN. It is synced, but what keeps it current is this machine's
	// transient record of what it last sent (sentLX / sentLY), which a load sets back to nothing: a save
	// made mid-lean came back with the lean stuck on (the head back at its baseline reads "no lean", the
	// same as "nothing sent", so the 0 was never sent; measured on the rig, bugfix pass 10-31: lean (7 0)
	// for good after the load).
	// Cleared on this handler's first tic, not in WorldLoaded: on a load WorldLoaded runs BEFORE the saved
	// fields are read back (G_DoLoadGame: G_InitNew, then the level is read), so a reset there was
	// overwritten (measured: still (7 0)). `firstTicDone` is transient, so it is false after a load on every
	// machine alike; on a new level the fields are 0 already.
	private transient bool firstTicDone;

	// ---- every tic ------------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (!firstTicDone) { firstTicDone = true; for (int n = 0; n < MAXPLAYERS; n++) { leanX[n] = 0; leanY[n] = 0; } }
		for (int i = bullets.Size() - 1; i >= 0; i--)
			if (!bullets[i] || bullets[i].bDestroyed || !bullets[i].bMISSILE) bullets.Delete(i);
		LeanPass();
		LocalHead();
	}

	// ---- 26: the lean (local) ---------------------------------------------------------------------------
	private void LocalHead()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		int lx = 0, ly = 0;
		if (pmo.OverrideAttackPosDir && pmo.health > 0 && RSQSM_Clock.LeanOn(consoleplayer))
		{
			double hx = pmo.HmdPosition.x, hz = pmo.HmdPosition.z;
			double k = 1.0 / max(1.0, RSQSM_Clock.Cv("rsqsm_lean_secs", 2.0) * TICRATE);
			if (!haveHead) { haveHead = true; hbx = hx; hbz = hz; pbx = pmo.pos.x; pby = pmo.pos.y; }
			double lean = (hx - hbx, hz - hbz).Length();               // metres, the head off its baseline
			Vector2 dw = (pmo.pos.x - pbx, pmo.pos.y - pby);          // map units, the pawn off its baseline
			double dwm = dw.Length() / 34.0;
			bool stick = p.cmd.forwardmove != 0 || p.cmd.sidemove != 0;
			if (!stick && lean >= RSQSM_Clock.Cv("rsqsm_lean_m", 0.06) && dwm >= lean * 0.5 && dwm <= lean * 1.5)
			{
				lx = int(round(dw.x));
				ly = int(round(dw.y));
			}
			hbx += (hx - hbx) * k; hbz += (hz - hbz) * k;
			pbx += (pmo.pos.x - pbx) * k; pby += (pmo.pos.y - pby) * k;
			// a teleport or a respawn is not a lean
			if (dw.Length() > 64) { pbx = pmo.pos.x; pby = pmo.pos.y; }
		}
		else haveHead = false;
		if (lx != sentLX || ly != sentLY)
		{
			sentLX = lx; sentLY = ly;
			EventHandler.SendNetworkEvent("rsqsm_lean", lx, ly);
		}
	}

	// The gate (every machine): true = this bullet misses this leaning player. A round asks it from its
	// hit (RSQSM_Round.SpecialMissileHit); other slowed bullets are let through by LeanPass.
	bool LeanDodges(Actor round, Actor victim, bool quiet = false)
	{
		if (!victim || !victim.player || !RSQSM_Clock.LeanOn(victim.PlayerNumber())) return false;
		int n = victim.PlayerNumber();
		Vector2 leanV = (leanX[n], leanY[n]);
		if (leanV.Length() < 1) return false;
		Vector2 dir = round.vel.xy;
		if (dir.Length() < 0.001) dir = (cos(round.angle), sin(round.angle));
		dir = dir.Unit();
		Vector2 rel = level.Vec2Diff(victim.pos.xy, round.pos.xy);
		double side = dir.x * rel.y - dir.y * rel.x;       // which side of you the round passes, and how far
		double across = dir.x * leanV.y - dir.y * leanV.x; // which side you leaned to, across its path
		if (side * across >= 0) return false;              // it is on your side: the lean took you into it
		bool dodged = abs(side) > max(0.0, victim.radius - abs(across));
		if (dodged && !quiet && Dev()) Console.Printf("RSQ_SlowMo: leaned out of a %s (lean %.1f across its path, it passed %.1f off centre, radius %.0f)", round.GetClassName(), abs(across), abs(side), victim.radius);
		return dodged;
	}

	// Slowed bullets that are not this mod's rounds (Brutal Doom's tracers) have no hit of ours to ask,
	// so near a leaning player each one the gate lets by passes through actors (bTHRUACTORS: both actors'
	// flags are OR'd before any other collision test, p_map.cpp:1409-1410) until it is past, then gets
	// its flag back. Only within a body's length of the player, so nothing else is passed through.
	private void LeanPass()
	{
		for (int i = passAct.Size() - 1; i >= 0; i--)
		{
			Actor a = passAct[i];
			if (!a || a.bDestroyed) { passAct.Delete(i); continue; }
			bool keep = false;
			for (int n = 0; n < MAXPLAYERS; n++)
				if (playeringame[n] && players[n].mo && level.Vec2Diff(players[n].mo.pos.xy, a.pos.xy).Length() < players[n].mo.radius + a.Speed * 2 + 8
					&& LeanDodges(a, players[n].mo, true)) keep = true;
			if (!keep) { a.bTHRUACTORS = false; passAct.Delete(i); }
		}
		let clock = RSQSM_Clock.Get();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || (leanX[n] == 0 && leanY[n] == 0) || !RSQSM_Clock.LeanOn(n)) continue;
			let pmo = players[n].mo;
			for (int i = 0; i < bullets.Size(); i++)
			{
				Actor a = bullets[i];
				if (!a || a is "RSQSM_Round" || a.bTHRUACTORS || !SlowedBullet(a, clock)) continue;
				if (level.Vec2Diff(pmo.pos.xy, a.pos.xy).Length() > pmo.radius + a.Speed * 2 + 8) continue;
				if (!LeanDodges(a, pmo)) continue;
				a.bTHRUACTORS = true;
				passAct.Push(a);
			}
		}
	}

	// ---- the lean arrives (every machine) ---------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		if (e.Name == "rsqsm_lean") { leanX[n] = e.Args[0]; leanY[n] = e.Args[1]; }
	}

	// ---- 28: the colour drain (local, drawn per frame) --------------------------------------------------
	override void RenderOverlay(RenderEvent e)
	{
		let me = players[consoleplayer];
		let clock = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		// THE PASS IS THE RENDERER'S, NOT THE LEVEL'S: PPShader's switch outlives this handler (one global
		// list, gl_postprocessshader.cpp:43). A level change, a load or a death's restart mid slow motion
		// made a new handler that thought it was off and never turned it off: the colours stayed drained
		// at full speed for good (measured on the rig, bugfix pass 10-31). The first frame of each handler
		// switches it off; the lines below switch it back on if slow motion is running.
		if (!drainSeen) { drainSeen = true; drainOn = false; PPShader.SetEnabled("RSQSM_Drain", false); }
		double amt = 0;
		let cv = CVar.GetCVar("rsqsm_drain", me);
		let yv = CVar.FindCVar("rsm_yield");
		bool stood = clock && clock.rival && (!yv || yv.GetBool());
		bool matrix = RSQSM_Clock.MatrixOn();	// MATRIX (Gun Bonsai VR): the full drain while slowed, whatever the row says
		if (((cv && cv.GetBool()) || matrix) && clock && !stood)
		{
			double depth = clamp(clock.curDepth > 0 ? clock.curDepth : 0.25, 0.05, 0.95);	// Deeper's, under the patch
			double k = clamp((1.0 - clock.scale) / max(1.0 - depth, 0.05), 0.0, 1.0);
			let ac = CVar.GetCVar("rsqsm_drain_amt", me);
			double a = clamp(ac ? ac.GetFloat() : 0.35, 0.0, 1.0);
			if (matrix) a = max(a, 0.85);
			amt = a * k;
		}
		if (amt <= 0.003)
		{
			if (drainOn) { PPShader.SetEnabled("RSQSM_Drain", false); drainOn = false; }
			return;
		}
		PPShader.SetUniform1f("RSQSM_Drain", "rsqsmDrain", amt);
		if (!drainOn) { PPShader.SetEnabled("RSQSM_Drain", true); drainOn = true; }
	}
}
