// THE BODY IN SLOW MOTION (the owner's picks 25, 26 and 28 from the Quest teardown, 2026-10-31).
// The world slows; you do not -- so your head and hands get to act on what the slowed world sends.
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
// CATCH A SLOWED BULLET (pick 25, off by default; rsqsm_catch). 10_TIME §4.6 "Catching a bullet":
//   with the grip held, an EMPTY off hand (Brutal Doom VR's RSQ_Hands, or nothing) that closes on a
//   slowed enemy round -- this mod's rounds, or a fast small missile (Brutal Doom's tracers) the clock
//   has slowed -- catches it: the round stops at the hand with a metal ting (Brutal Doom's casing
//   ring, weapons/casing1). The test is the capsule between the hand's last two samples against the
//   round's own path (00_CAPABILITIES §1.4: test chords, not points), within rsqsm_catch_m -- see
//   SyncedCatch for why the path runs on into the pawn's box.
//   Held, it rides the hand (OffhandPos; no hand is posed or fitted -- Brutal Doom owns the hand).
//   A FLICK -- the hand's speed past rsqsm_flick m/s, measured in the BODY's frame (the hand relative
//   to the pawn, turned by the pawn's angle, so walking and turning are not flicks) -- throws it
//   along the flick as YOUR bullet at full speed (RSQSM_Thrown: not slowed, credited to you, it hurts
//   what it hits). Letting go of the grip without a flick drops it; it falls and clinks
//   (weapons/casing).
//
// COLOURS DRAIN (pick 28, off by default; rsqsm_drain). 10_TIME §4.5 / apply/05 §6.1: a post-process
//   pass on the scene (GLDEFS HardwareShader PostProcess scene, gldefs.cpp:1514-1529), driven by
//   PPShader (ppshader.zs:3-4) from the clock's eased scale; desaturation only (no vignette, no
//   aberration: §4.5's VR caution). QuestZDoom runs scene post-processing per eye, as
//   RSQ_Accessibility's comfort vignette does with the same route.
//
// NETPLAY: the hand and head poses exist only on the camera player's machine (_BASELINE_FACTS §3),
// so that machine sends them as network events (rsqsm_hand while the hand can catch or holds a round,
// rsqsm_grip, rsqsm_lean) and decides the flick and the let-go (rsqsm_throw / rsqsm_drop); every
// machine catches, throws and drops from synced state.
class RSQSM_Body : EventHandler
{
	// ---- synced ------------------------------------------------------------------------------
	RSQSM_Caught caught[MAXPLAYERS];
	bool grip[MAXPLAYERS];                         // the off hand's grip (rsqsm_grip, sent by InputProcess)
	Array<Actor> passAct;                          // bullets let through a leaning player (bTHRUACTORS set here)
	// Enemy bullets in flight. A missile is not in the blockmap (Projectile sets +NOBLOCKMAP), so a
	// BlockThingsIterator never finds one (measured: the hand sat on a round's line and saw nothing);
	// they are listed as they spawn and pruned as they go.
	Array<Actor> bullets;
	double leanX[MAXPLAYERS], leanY[MAXPLAYERS];   // the lean in map units, 0 = none
	// the off hand as its machine last sent it (rsqsm_hand), and the sample before
	double handX[MAXPLAYERS], handY[MAXPLAYERS], handZ[MAXPLAYERS];
	double handPX[MAXPLAYERS], handPY[MAXPLAYERS], handPZ[MAXPLAYERS];
	int handTic[MAXPLAYERS], handPrevTic[MAXPLAYERS];

	// ---- local (the console player) -------------------------------------------------------------
	private transient ui bool gripKey;
	private transient ui Array<int> gripKeys;
	private transient ui String gripKeysFrom;
	private transient double bx[4], by[4], bz[4];  // the hand in the body's frame, map units, newest first
	private transient int bt[4];                   // the tic of each of those samples
	private transient int hist, armT, tick;
	private transient Vector3 rawHand;
	private transient bool flung, holding;
	private transient bool haveHead;
	private transient double hbx, hbz, pbx, pby;   // the baselines: head (stage, metres), pawn (map)
	private transient int sentLX, sentLY;
	private transient ui bool drainOn, drainSeen;

	const PIXELSTRETCH_DEF = 1.2;

	static RSQSM_Body Get() { return RSQSM_Body(EventHandler.Find("RSQSM_Body")); }

	static bool Dev() { let dv = CVar.FindCVar("developer"); return dv && dv.GetInt() >= 1; }
	static double Ps() { return level.pixelstretch > 0 ? level.pixelstretch : PIXELSTRETCH_DEF; }

	// ---- the grip (raw keys, as RSQ_DistanceGrab reads them: QuestZDoom sends the off-hand grip as
	// KEY_PAD_RTHUMB 443, or KEY_PAD_DPAD_UP 436 while the main grip is held as a shift). Read, never
	// eaten: the series' other grips keep it.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		let me = players[consoleplayer];
		let cv = CVar.GetCVar("rsqsm_catch_keys", me);
		String s = cv ? cv.GetString() : "443 436";
		if (s != gripKeysFrom)
		{
			gripKeysFrom = s;
			gripKeys.Clear();
			Array<String> w;
			s.Split(w, " ", TOK_SKIPEMPTY);
			for (int i = 0; i < w.Size(); i++) gripKeys.Push(w[i].ToInt());
		}
		if (gripKeys.Find(e.KeyScan) >= gripKeys.Size()) return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (down != gripKey)
		{
			gripKey = down;
			EventHandler.SendNetworkEvent("rsqsm_grip", down ? 1 : 0);
		}
		return false;
	}

	// ---- shared tests ------------------------------------------------------------------------------
	static bool OffHandEmpty(PlayerInfo p)
	{
		let w = p.OffhandWeapon;
		if (!w) return true;
		Name cn = w.GetClassName();
		return cn == 'RSQ_Hands';
	}

	static bool CatchOn(PlayerInfo p) { return RSQSM_Clock.CvP("rsqsm_catch", p, 0) != 0; }

	// A slowed enemy bullet: one of this mod's rounds, or a fast small missile (Brutal Doom fires its
	// bullets as speed-50 projectiles; measured 50 -> 12.5 at depth 0.25, HANDOFF) that the clock is
	// slowing now. Fireballs and rockets are not bullets (slow, or wide).
	static bool Catchable(Actor a, RSQSM_Clock clock)
	{
		if (!a || a.bDestroyed || !a.bMISSILE || !a.target || a.target.player) return false;
		if (!clock || !clock.Active() || clock.StoodDown()) return false;
		if (a is "RSQSM_Thrown") return false;
		let r = RSQSM_Round(a);
		if (r) return !Actor.InStateSequence(r.CurState, r.FindState("Death"));
		if (a.radius > 8) return false;
		if (GetDefaultByType(a.GetClass()).Speed < 30) return false;
		return clock.FactorFor(a, a.Speed) < 0.9999;
	}

	// The closest two segments come, in metres (vertical stretched by the pixel ratio, 00_CAP §1.2a).
	static double SegSeg(Vector3 p1, Vector3 q1, Vector3 p2, Vector3 q2)
	{
		double ps = Ps();
		p1.z *= ps; q1.z *= ps; p2.z *= ps; q2.z *= ps;
		Vector3 d1 = q1 - p1, d2 = q2 - p2, r = p1 - p2;
		double a = d1 dot d1, e = d2 dot d2, f = d2 dot r;
		double s = 0, t = 0;
		if (a <= 1e-9 && e <= 1e-9) return (p1 - p2).Length() / 34.0;
		if (a <= 1e-9) t = clamp(f / e, 0.0, 1.0);
		else
		{
			double c = d1 dot r;
			if (e <= 1e-9) s = clamp(-c / a, 0.0, 1.0);
			else
			{
				double b = d1 dot d2;
				double den = a * e - b * b;
				s = den > 1e-9 ? clamp((b * f - c * e) / den, 0.0, 1.0) : 0.0;
				t = (b * s + f) / e;
				if (t < 0) { t = 0; s = clamp(-c / a, 0.0, 1.0); }
				else if (t > 1) { t = 1; s = clamp((b - c) / a, 0.0, 1.0); }
			}
		}
		Vector3 c1 = p1 + d1 * s, c2 = p2 + d2 * t;
		return (c1 - c2).Length() / 34.0;
	}

	// ---- the bullet list ------------------------------------------------------------------------------
	static bool BulletLike(Actor a)
	{
		return a && a.bMISSILE && a.radius <= 8 && GetDefaultByType(a.GetClass()).Speed >= 30 && !(a is "RSQSM_Thrown");
	}
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (BulletLike(a) && !(a.target && a.target.player)) bullets.Push(a);
	}

	// A LOADED GAME STARTS WITH NO LEAN AND NO GRIP. Both are synced, but what keeps them current is this
	// machine's transient record of what it last sent (sentLX / sentLY, gripKey), which a load sets back
	// to nothing: a save made mid-lean came back with the lean stuck on (the head back at its baseline
	// reads "no lean", the same as "nothing sent", so the 0 was never sent; measured on the rig, bugfix
	// pass 10-31: lean (7 0) for good after the load), and a save made with the grip held came back armed.
	// Cleared on this handler's first tic, not in WorldLoaded: on a load WorldLoaded runs BEFORE the saved
	// fields are read back (G_DoLoadGame: G_InitNew, then the level is read), so a reset there was
	// overwritten (measured: still (7 0)). `firstTicDone` is transient, so it is false after a load on every
	// machine alike; on a new level the fields are 0 already.
	private transient bool firstTicDone;

	// ---- every tic ------------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (!firstTicDone) { firstTicDone = true; for (int n = 0; n < MAXPLAYERS; n++) { leanX[n] = 0; leanY[n] = 0; grip[n] = false; } }
		for (int i = bullets.Size() - 1; i >= 0; i--)
			if (!bullets[i] || bullets[i].bDestroyed || !bullets[i].bMISSILE) bullets.Delete(i);
		Synced();
		SyncedCatch();
		LeanPass();
		LocalHead();
		LocalHand();
	}

	// What every machine checks: a held round goes when it may no longer be held.
	private void Synced()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			let c = caught[n];
			if (!c) continue;
			if (c.bDestroyed) { caught[n] = null; continue; }
			if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0 || !CatchOn(players[n]) || !OffHandEmpty(players[n]))
				Drop(n);
		}
	}

	// ---- 26: the lean (local) ---------------------------------------------------------------------------
	private void LocalHead()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		int lx = 0, ly = 0;
		if (pmo.OverrideAttackPosDir && pmo.health > 0 && RSQSM_Clock.Cv("rsqsm_lean", 1) != 0)
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
		if (!victim || !victim.player || RSQSM_Clock.Cv("rsqsm_lean", 1) == 0) return false;
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
		if (RSQSM_Clock.Cv("rsqsm_lean", 1) == 0) return;
		let clock = RSQSM_Clock.Get();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || (leanX[n] == 0 && leanY[n] == 0)) continue;
			let pmo = players[n].mo;
			for (int i = 0; i < bullets.Size(); i++)
			{
				Actor a = bullets[i];
				if (!a || a is "RSQSM_Round" || a.bTHRUACTORS || !Catchable(a, clock)) continue;
				if (level.Vec2Diff(pmo.pos.xy, a.pos.xy).Length() > pmo.radius + a.Speed * 2 + 8) continue;
				if (!LeanDodges(a, pmo)) continue;
				a.bTHRUACTORS = true;
				passAct.Push(a);
			}
		}
	}

	// ---- 25: the hand (local) ----------------------------------------------------------------------------
	private void LocalHand()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		if (!pmo.OverrideAttackPosDir || pmo.health <= 0 || !CatchOn(p)) { hist = 0; return; }
		Vector3 hand = pmo.OffhandPos;
		// A STALE SAMPLE IS NOT A SAMPLE. The pose is written per rendered frame from the pawn's position
		// at that frame; a tic with no frame since the last one reads the very same OffhandPos while the
		// pawn has moved on, so the hand seemed to move against the body by the pawn's step (measured on
		// the rig: a 6 units/tic side-step while holding read as a 6.2 m/s flick). Such tics are skipped,
		// and speeds divide by the tics between real samples.
		bool fresh = hand != rawHand || hist == 0;
		rawHand = hand;
		tick++;

		// the hand in the body's frame (relative to the pawn, turned by its angle), newest first
		if (fresh)
		{
			Vector3 rel = level.Vec3Diff(pmo.pos, hand);
			double ca = cos(-pmo.angle), sa = sin(-pmo.angle);
			for (int i = 3; i > 0; i--) { bx[i] = bx[i - 1]; by[i] = by[i - 1]; bz[i] = bz[i - 1]; bt[i] = bt[i - 1]; }
			bx[0] = rel.x * ca - rel.y * sa; by[0] = rel.x * sa + rel.y * ca; bz[0] = rel.z; bt[0] = tick;
			hist = min(hist + 1, 4);
		}

		let c = caught[consoleplayer];
		let clock = RSQSM_Clock.Get();
		bool armed = grip[consoleplayer] && OffHandEmpty(p) && clock && clock.Active();
		// Every machine is told where the hand is while it can catch or holds a round (the poses exist
		// only here). The catch itself is decided from these on every machine (SyncedCatch), in the same
		// tic as the round's own move -- a decision sent as an event arrived a tic late, after the round
		// had already reached the pawn's box (measured: 12 of 12 rounds hit with the hand on their line).
		if ((c && !c.bDestroyed) || armed)
		{
			Vector3 o = level.Vec3Diff(pmo.pos, hand);
			EventHandler.SendNetworkEvent("rsqsm_hand", int(round(o.x * 16)), int(round(o.y * 16)), int(round(o.z * 16)));
		}
		if (c && !c.bDestroyed)
		{
			// just caught: the swipe that caught it is not a flick (a fresh history, 4 tics' grace)
			if (!holding) { holding = true; armT = 4; hist = 1; }
			if (armT > 0) { armT--; return; }
			if (flung) return;
			// THE FLICK: the fastest of the chords from the newest sample back over the last three
			// real samples, body frame, metres a second
			double best = 0;
			Vector3 bd = (0, 0, 0);
			double ps = Ps();
			for (int k = 1; k < hist; k++)
			{
				Vector3 d = (bx[0] - bx[k], by[0] - by[k], bz[0] - bz[k]);
				int dt = max(1, bt[0] - bt[k]);
				if (dt > 6) break;      // too old to be part of a flick
				double v = (d.x, d.y, d.z * ps).Length() / 34.0 * TICRATE / dt;
				if (v > best) { best = v; bd = d; }
			}
			double need = RSQSM_A11y.Low(RSQSM_Clock.CvP("rsqsm_flick", p, 2.5));
			if (best >= need)
			{
				// back to the map: turn the body-frame chord by the pawn's angle
				double cb = cos(pmo.angle), sb = sin(pmo.angle);
				Vector3 w = (bd.x * cb - bd.y * sb, bd.x * sb + bd.y * cb, bd.z);
				double ang = atan2(w.y, w.x);
				double pit = -atan2(w.z, w.xy.Length());
				flung = true;
				if (Dev()) Console.Printf("RSQ_SlowMo: flick %.2f m/s (needs %.2f) -> thrown, angle %.1f pitch %.1f", best, need, ang, pit);
				EventHandler.SendNetworkEvent("rsqsm_throw", int(round(ang * 100)), int(round(pit * 100)), int(round(best * 100)));
				return;
			}
			if (!grip[consoleplayer])
			{
				flung = true;
				if (Dev()) Console.Printf("RSQ_SlowMo: grip let go, no flick (fastest %.2f m/s, needs %.2f) -> dropped", best, need);
				EventHandler.SendNetworkEvent("rsqsm_drop");
			}
			return;
		}
		flung = false;
		holding = false;
	}

	// CATCHING (every machine, from the streamed hand): an empty off hand with the grip held, the
	// capsule between its last two samples against each slowed enemy bullet's path. The path is where
	// the bullet was last tic to where it will be after this tic's move -- and, when that move takes it
	// into the pawn's box, on through the box: a hand held in front of the face is INSIDE the pawn
	// (radius 16 = 0.47 m), and the engine would stop the bullet at the box's edge before it ever
	// reached the hand.
	private void SyncedCatch()
	{
		let clock = RSQSM_Clock.Get();
		if (!clock || !clock.Active() || clock.StoodDown()) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || caught[n] || !grip[n] || handTic[n] < level.maptime - 1) continue;
			let p = players[n];
			let pmo = p.mo;
			if (!pmo || pmo.health <= 0 || !CatchOn(p) || !OffHandEmpty(p)) continue;
			double reach = RSQSM_A11y.Wide(RSQSM_Clock.CvP("rsqsm_catch_m", p, 0.08));
			Vector3 h1 = (handX[n], handY[n], handZ[n]);
			Vector3 h0 = handPrevTic[n] >= level.maptime - 2 ? (handPX[n], handPY[n], handPZ[n]) : h1;
			Actor best = null;
			double bestD = reach;
			for (int i = 0; i < bullets.Size(); i++)
			{
				Actor a = bullets[i];
				if (!Catchable(a, clock)) continue;
				double sp = a.vel.Length();
				if (level.Vec3Diff(h1, a.pos).Length() > sp * 2 + pmo.radius * 2 + 64) continue;
				Vector3 dir = sp > 0.001 ? a.vel / sp : (0, 0, 0);
				// how far it flies before its box meets the pawn's (horizontal), if it is heading in
				Vector2 toP = level.Vec2Diff(a.pos.xy, pmo.pos.xy);
				double along = sp > 0.001 ? (toP dot dir.xy) / max(dir.xy.Length(), 0.001) : 0;
				double ahead = sp;
				if (along > 0 && along - pmo.radius - a.radius <= sp) ahead = along + pmo.radius;
				double d = SegSeg(h0, h1, a.Prev, a.pos + dir * ahead);
				if (d <= bestD) { best = a; bestD = d; }
			}
			if (best)
			{
				if (Dev()) Console.Printf("RSQ_SlowMo: off hand closed on a %s, %.3f m from the hand's chord", best.GetClassName(), bestD);
				Catch(n, best);
			}
		}
	}

	// ---- the acts (every machine) -----------------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let p = players[n];
		let pmo = p.mo;
		if (e.Name == "rsqsm_lean") { leanX[n] = e.Args[0]; leanY[n] = e.Args[1]; return; }
		if (e.Name == "rsqsm_grip") { grip[n] = e.Args[0] != 0; return; }
		if (!pmo) return;
		if (e.Name == "rsqsm_hand")
		{
			Vector3 o = (e.Args[0], e.Args[1], e.Args[2]) / 16.0;
			Vector3 at = pmo.pos + o;
			if (handTic[n] >= level.maptime - 2) { handPX[n] = handX[n]; handPY[n] = handY[n]; handPZ[n] = handZ[n]; handPrevTic[n] = handTic[n]; }
			else handPrevTic[n] = -100;
			handX[n] = at.x; handY[n] = at.y; handZ[n] = at.z; handTic[n] = level.maptime;
			if (caught[n]) caught[n].holdOfs = o;
		}
		else if (e.Name == "rsqsm_throw") Throw(n, e.Args[0] / 100.0, e.Args[1] / 100.0);
		else if (e.Name == "rsqsm_drop") Drop(n);
	}

	private void Catch(int n, Actor src)
	{
		let p = players[n];
		let pmo = p.mo;
		Vector3 at = (handX[n], handY[n], handZ[n]);
		let c = RSQSM_Caught(Actor.Spawn("RSQSM_Caught", at));
		if (!c) return;
		let r = RSQSM_Round(src);
		if (r)
		{
			c.dmg = r.dmg; c.puff = r.puff; c.DamageType = r.DamageType;
			c.bTHRUGHOST = r.bTHRUGHOST; c.bSPECTRAL = r.bSPECTRAL; c.bFOILINVUL = r.bFOILINVUL;
			c.bPAINLESS = r.bPAINLESS; c.bFORCEPAIN = r.bFORCEPAIN;
		}
		else
		{
			// a missile's own damage, rolled the way its impact would roll it
			c.dmg = max(1, src.GetMissileDamage(7, 1));
			c.puff = "BulletPuff";
			c.DamageType = src.DamageType;
		}
		c.holder = pmo;
		c.holdOfs = level.Vec3Diff(pmo.pos, at);
		c.angle = src.angle;
		c.pitch = src.pitch;
		caught[n] = c;
		c.A_StartSound("weapons/casing1", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		RSQSM_Buzz.Start(pmo, 1, 0.5, 5);
		if (Dev()) Console.Printf("RSQ_SlowMo: caught a %s (damage %d) in the off hand", src.GetClassName(), c.dmg);
		src.Destroy();
	}

	private void Throw(int n, double ang, double pit)
	{
		let c = caught[n];
		let pmo = players[n].mo;
		if (!c || !pmo) return;
		let t = RSQSM_Thrown(Actor.Spawn("RSQSM_Thrown", c.pos));
		if (t)
		{
			t.target = pmo;
			t.angle = ang;
			t.pitch = pit;
			t.dmg = c.dmg; t.puff = c.puff; t.DamageType = c.DamageType;
			t.bTHRUGHOST = c.bTHRUGHOST; t.bSPECTRAL = c.bSPECTRAL; t.bFOILINVUL = c.bFOILINVUL;
			t.bPAINLESS = c.bPAINLESS; t.bFORCEPAIN = c.bFORCEPAIN;
			let clock = RSQSM_Clock.Get();
			t.Speed = clock ? clock.RoundBase() : 56;
			t.maxDist = 4096;
			t.vel = (cos(pit) * cos(ang), cos(pit) * sin(ang), -sin(pit)) * t.Speed;
			t.A_StartSound("rsqsm/whiz2", CHAN_AUTO, 0, 0.7, ATTN_NORM);
			if (Dev()) Console.Printf("RSQ_SlowMo: thrown back, %d damage at %.0f units a tic", t.dmg, t.Speed);
		}
		RSQSM_Buzz.Start(pmo, 1, 0.4, 3);
		c.Destroy();
		caught[n] = null;
	}

	private void Drop(int n)
	{
		let c = caught[n];
		if (!c) return;
		caught[n] = null;
		let s = Actor.Spawn("RSQSM_RoundSpent", c.pos);
		if (s)
		{
			s.angle = c.angle;
			s.vel = (0, 0, -0.5);
			if (c.holder) s.vel = (c.holder.vel.x, c.holder.vel.y, -0.5);
		}
		if (Dev()) Console.Printf("RSQ_SlowMo: dropped the caught round");
		c.Destroy();
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
		if (cv && cv.GetBool() && clock && !stood)
		{
			let dv = CVar.FindCVar("rsm_depth");
			double depth = clamp(dv ? dv.GetFloat() : 0.25, 0.05, 0.95);
			double k = clamp((1.0 - clock.scale) / max(1.0 - depth, 0.05), 0.0, 1.0);
			let ac = CVar.GetCVar("rsqsm_drain_amt", me);
			amt = clamp(ac ? ac.GetFloat() : 0.35, 0.0, 1.0) * k;
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

// A caught round, in the hand. Not slowed (the "rsq" prefix: what you hold runs on your time).
class RSQSM_Caught : Actor
{
	int dmg;
	class<Actor> puff;
	Actor holder;
	Vector3 holdOfs;

	Default
	{
		Radius 1;
		Height 1;
		Scale 0.25;
		RenderStyle "Add";
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTELEPORT
	}

	override void BeginPlay() { Super.BeginPlay(); RSQSM_Round.CBLook(self); if (RSQSM_CB.Mode()) Scale *= 0.25; }

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!holder) { Destroy(); return; }
		SetOrigin(holder.pos + holdOfs, true);
	}

	States { Spawn: RSQR A -1 Bright; Stop; }
}

// A caught round thrown back: your bullet, at full speed (not slowed: the "rsq" prefix), credited
// to you through its target, hurting what it hits as a round does (RSQSM_Round.SpecialMissileHit).
class RSQSM_Thrown : RSQSM_Round
{
}

// A caught round let go: it falls (slowed with the world: the "rsqsm_round" prefix) and clinks.
class RSQSM_RoundSpent : Actor
{
	bool landed;
	int age;

	Default
	{
		Radius 1;
		Height 1;
		Scale 0.25;
		Gravity 0.6;
		RenderStyle "Add";
		+NOBLOCKMAP
		+DROPOFF
		+NOTELEPORT
		+CANNOTPUSH
		+MOVEWITHSECTOR
		+DONTSPLASH
	}

	override void BeginPlay() { Super.BeginPlay(); RSQSM_Round.CBLook(self); if (RSQSM_CB.Mode()) Scale *= 0.25; }

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		age++;
		if (!landed && age > 1 && pos.z <= floorz + 0.5)
		{
			landed = true;
			vel = (0, 0, 0);
			A_StartSound("weapons/casing", CHAN_AUTO, 0, 1.0, ATTN_NORM);
			if (RSQSM_Body.Dev()) Console.Printf("RSQ_SlowMo: the dropped round landed, clink");
		}
		if (landed && age > 210) { A_FadeOut(0.05); }
	}

	States { Spawn: RSQR A -1 Bright; Stop; }
}
