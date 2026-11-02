// THE HEADLOCK (RSQ Melee). Moved from RSQ Distance Grab's near.zs (its collar code) on 2026-11-01.
//
//   HOLD    the OFF hand's grip on a living monster no heavier than rsqml_headlock_mass, within rsqml_headlock_reach of
//           the palm, holds it frozen in front of the hand for up to rsqml_headlock_secs, so the main hand can punch it.
//           RSQ Score is told ("touch" grab.hold), and Score's "Headlock" combo (grab.hold > hands) pays.
//   SHIELD  Human Shield (an option, off): held as long as the grip is (a minute at most), turned to face away from you.
//   THROW   swing the off hand hard while it holds one and it is thrown (the owner's pick 23): across the ground,
//           within 60 degrees of where you face, past rsqml_headlock_throw m/s and then slowing (its peak passed, as a
//           real throw lets go). It counts as rsqml_headlock_weight % of its weight. With RSQ Distance Grab loaded the
//           thrown monster is handed to its throw code (RSQDG_ThrowService "headlock.throw": its strength, weight and
//           boost settings, aim assist, the flight and the impact, exactly as before the move). Without it, a simple
//           toss of Melee's own: Distance Grab's default strength, and an impact by the same joules.
//
// THE GRIP PRESS. QuestZDoom sends the off-hand grip as KEY_PAD_RTHUMB (443), or KEY_PAD_DPAD_UP (436) while the main
// grip is held as a shift (rsqml_keys_off); read raw, as the rig and Distance Grab read it, and EATEN when the Headlock
// takes it. ONE MOD DECIDES: a press is the Headlock's only when a holdable monster is nearer the palm than anything
// Distance Grab's walk-up grab would take, and that hand is not Distance Grab's already (carrying, on a door, in a rig
// holster): RSQDG_ThrowService "near.dist". Distance Grab asks the same question back ("headlock.claim") and stands
// down for that press. Both answers are worked out the same tic from the same state, so they always agree.
//
// NETPLAY: the hand poses exist only on the camera player's machine, so that machine decides and sends one network
// event per press (rsqml_hgrip); the hold is applied from it.
class RSQML_Headlock : StaticEventHandler
{
	bool gripDown[MAXPLAYERS];
	Actor collar[MAXPLAYERS];
	int collarEnd[MAXPLAYERS], collarPing[MAXPLAYERS];
	// the throw: the off hand's last palm and body, the arm's recent top speed (m/s), and its last per-tic movements
	Vector3 cPalm[MAXPLAYERS], cBody[MAXPLAYERS];
	bool cHave[MAXPLAYERS];
	double cPeak[MAXPLAYERS];
	const VWIN = 6;
	Vector3 armRing[VWIN];
	int armAt, armN;

	// local (console player): read by InputProcess
	transient bool ready;
	private transient ui bool eaten, keyState;
	private transient ui Array<int> keysOff;
	private transient ui String keysFrom;

	static RSQML_Headlock Get() { return RSQML_Headlock(StaticEventHandler.Find("RSQML_Headlock")); }

	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope bool Flag(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }

	bool IsHolding(Actor a)
	{
		if (!a) return false;
		for (int n = 0; n < MAXPLAYERS; n++) if (collar[n] == a) return true;
		return false;
	}

	// ---- input --------------------------------------------------------------------------------------------------
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		let cv = CVar.GetCVar("rsqml_keys_off", players[consoleplayer]);
		String s = cv ? cv.GetString() : "443 436";
		if (s != keysFrom)
		{
			keysFrom = s;
			keysOff.Clear();
			Array<String> w;
			s.Split(w, " ", TOK_SKIPEMPTY);
			for (int i = 0; i < w.Size(); i++) keysOff.Push(w[i].ToInt());
		}
		if (keysOff.Find(e.KeyScan) >= keysOff.Size()) return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (keyState == down) return eaten;
		keyState = down;
		if (down)
		{
			eaten = ready;
			if (eaten) EventHandler.SendNetworkEvent("rsqml_hgrip", 1);
			return eaten;
		}
		bool was = eaten;
		eaten = false;
		if (was) EventHandler.SendNetworkEvent("rsqml_hgrip", 0);
		return was;
	}

	// ---- which monster the off palm could hold, and whether the press is ours ------------------------------------
	static bool RigBusy(PlayerPawn pmo)
	{
		let rit = ServiceIterator.Find("RSQTR_RigService");
		Service rs;
		while (rs = rit.Next())
			if (rs.GetInt("rig.region", "", 1, 0, pmo) >= 0) return true;
		return false;
	}

	// the nearest holdable living monster to the off palm, and its distance (map units: the palm to its cylinder, the
	// vertical x pixelstretch, as Distance Grab measures its walk-up grab)
	static Actor, double FindMonster(PlayerPawn pmo)
	{
		if (!Flag("rsqml_headlock", true)) return null, -1;
		Vector3 hp; bool ok;
		[hp, ok] = RSQML_Hands.Pos(pmo, 1);
		if (!ok) return null, -1;
		double nearU = Num("rsqml_headlock_reach", 0.30) * RSQML.UnitsPerMetre();
		double maxMass = Num("rsqml_headlock_mass", 400.0);
		double ps = RSQML.Stretch();
		Actor best = null;
		double bestD = 1e9;
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z, 128, nearU + 8, false);
		while (it.Next())
		{
			Actor a = it.thing;
			if (!a || a == pmo || a.player || !a.bISMONSTER || a.Health <= 0) continue;
			if (!a.bSHOOTABLE || a.bBOSS || a.bNOINTERACTION || a.Mass > maxMass) continue;
			Vector2 dxy = a.Pos.xy - hp.xy;
			double hz = max(0.0, dxy.Length() - a.Radius);
			double vz = 0;
			if (hp.z < a.Pos.z) vz = a.Pos.z - hp.z;
			else if (hp.z > a.Pos.z + a.Height) vz = hp.z - (a.Pos.z + a.Height);
			double d = sqrt(hz * hz + (vz * ps) ** 2);
			if (d > nearU || d >= bestD) continue;
			best = a;
			bestD = d;
		}
		return best, best ? bestD : -1;
	}

	// IS THIS PRESS THE HEADLOCK'S (the console player's off hand), worked out now. Distance Grab asks it too.
	bool ClaimNow(PlayerPawn pmo)
	{
		if (!pmo || pmo.health <= 0 || pmo.PlayerNumber() != consoleplayer) return false;
		if (gripDown[consoleplayer]) return true;
		if (RigBusy(pmo)) return false;     // holsters first
		Actor m; double dm;
		[m, dm] = FindMonster(pmo);
		if (!m) return false;
		let dg = RSQML.Svc("RSQDG_ThrowService");
		if (!dg) return true;
		int dd = dg.GetInt("near.dist", "", 1, 0, pmo);
		if (dd == -2) return false;         // that hand is Distance Grab's already
		return dd < 0 || dm < dd;
	}

	// ---- the loop -----------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		TickCollars();
		let p = players[consoleplayer];
		ready = p && p.mo && ClaimNow(p.mo);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqml_hgrip") return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		if (e.Args[0] == 0) { gripDown[n] = false; if (collar[n]) EndCollar(n); return; }
		gripDown[n] = true;
		if (pmo.health <= 0) return;
		Actor a; double d;
		[a, d] = FindMonster(pmo);
		if (a) StartCollar(n, a);
	}

	// ---- HOLD ---------------------------------------------------------------------------------------------------
	private void StartCollar(int n, Actor a)
	{
		if (collar[n]) EndCollar(n);
		let pmo = players[n].mo;
		collar[n] = a;
		// THE FLAGS IT BORROWS are remembered on the monster itself (RSQML_Held: saved with it), so a save taken mid-hold
		// gives them back on the first tic after the load (this handler is static and remembers nothing across one).
		let tok = RSQML_Held(a.FindInventory("RSQML_Held"));
		if (!tok)
		{
			tok = RSQML_Held(a.GiveInventoryType("RSQML_Held"));
			if (tok) { tok.noGrav = a.bNOGRAVITY; tok.infight = a.bFORCEINFIGHTING; }
		}
		a.bNOGRAVITY = true;
		// NOT bTHRUACTORS (Distance Grab's D-notes): with it the shield eats every pellet and lets every fireball through
		// (PIT_CheckThing ORs both actors' MF2_THRUACTORS before anything else; a hitscan never reads the victim's).
		// FORCEINFIGHTING: on a NoInfighting map a monster's missile would pass a held monster (CanAttackHurt); borrowed
		// and handed back like NOGRAVITY.
		a.bFORCEINFIGHTING = true;
		a.Vel = (0, 0, 0);
		cHave[n] = false;
		cPeak[n] = 0;
		armN = 0;
		bool shield = Flag("rsqml_headlock_shield", false);
		collarEnd[n] = level.maptime + (shield ? 60 * TICRATE : int(Num("rsqml_headlock_secs", 3.0) * TICRATE));
		collarPing[n] = 0;
		// the catch's feel: Distance Grab's thud and tick when it is loaded, else a knock in the off hand
		let dg = RSQML.Svc("RSQDG_ThrowService");
		if (!dg || dg.GetInt("headlock.caught", "", n, 0, a) != 1) RSQ_Buzz.Start(pmo, 1, 0.5, 4);
		if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: holding %s (t%d)", a.GetClassName(), level.maptime);
	}

	private void EndCollar(int n)
	{
		let a = collar[n];
		collar[n] = null;
		if (!a) return;
		let tok = RSQML_Held(a.FindInventory("RSQML_Held"));
		if (tok) tok.GiveBack();
		// nothing to unfreeze: freezetics counts itself down (p_mobj.cpp), so letting go IS the release
	}

	private void TickCollars()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			let a = collar[n];
			if (!a) continue;
			let p = players[n];
			if (!playeringame[n] || !p.mo || p.mo.health <= 0 || a.Health <= 0 || level.maptime >= collarEnd[n] || !gripDown[n]) { EndCollar(n); continue; }
			Vector3 hp; bool ok;
			[hp, ok] = RSQML_Hands.Pos(p.mo, 1);
			if (!ok) hp = (p.mo.pos.x, p.mo.pos.y, p.mo.player.viewz - 8);
			if (n == consoleplayer && ok && ThrowSwing(n, p, a, hp)) continue;
			Vector3 fw = RSQML_Hands.Dir(p.mo, 1);
			Vector3 at = hp + fw * (a.Radius + 6.0);
			at.z -= a.Height * 0.5;
			if (RSQML.Metres(at - a.Pos) > 1.5) { EndCollar(n); continue; }   // torn away
			if (!a.TryMove(at.xy, true)) { }
			a.SetZ(max(a.floorz, at.z));
			a.Vel = (0, 0, 0);
			if (Flag("rsqml_headlock_shield", false)) a.Angle = p.mo.Angle;
			// freezetics, re-asserted every tic before the thinkers run: the monster's Tick returns early (no states,
			// movement or AI) but it KEEPS its blockmap link, so it stays solid and shootable. RSQ HP Bars reads this
			// (a freezetics that stands still, with NOGRAVITY / FORCEINFIGHTING borrowed) as "held".
			a.freezetics = 2;
			// RSQ Score: "grab.hold" touched it (kept alive every 2 s so its 3 s chain gap never breaks it)
			if (level.maptime >= collarPing[n])
			{
				collarPing[n] = level.maptime + 70;
				let sit = ServiceIterator.Find("RS_ScoreService");
				Service s;
				while (s = sit.Next()) s.GetInt("touch", "grab.hold", n, 0, a);
			}
		}
	}

	// ---- THROWING THE MONSTER YOU HOLD --------------------------------------------------------------------------
	// The off palm's speed: its movement against the body's, each tic, the fastest 2-tic average of the last VWIN
	// (Distance Grab's PalmVelocity rule, owner pick 24: a 1-tic delta carries twice the jitter, and the maximum of a
	// noisy set turns that into an over-read). Map units a tic, in the world.
	Vector3 PalmVel()
	{
		Vector3 best = (0, 0, 0);
		double bl = -1;
		for (int i = 0; i + 1 < armN; i++)
		{
			int a = (armAt - i + VWIN * 4) % VWIN, b = (armAt - i - 1 + VWIN * 4) % VWIN;
			Vector3 v = (armRing[a] + armRing[b]) * 0.5;
			double l = RSQML.Metres(v);
			if (l > bl) { bl = l; best = v; }
		}
		return best;
	}

	private bool ThrowSwing(int n, PlayerInfo p, Actor a, Vector3 hp)
	{
		let pmo = p.mo;
		Vector3 arm = (0, 0, 0);
		if (cHave[n])
		{
			arm = (hp - cPalm[n]) - (pmo.Pos - cBody[n]);
			if (arm.Length() > 64.0) arm = (0, 0, 0);    // moved, not swung
			armAt = (armAt + 1) % VWIN;
			armRing[armAt] = arm;
			if (armN < VWIN) armN++;
		}
		cPalm[n] = hp;
		cBody[n] = pmo.Pos;
		cHave[n] = true;
		double need = Num("rsqml_headlock_throw", 3.0);
		if (need <= 0) return false;
		double nowMps = RSQML.Metres(arm) * TICRATE;
		Vector2 face = (cos(pmo.Angle), sin(pmo.Angle));
		double across = arm.xy.Length();
		if (!(across > 0.001 && (arm.xy dot face) > 0.5 * across)) nowMps = 0;
		cPeak[n] = max(cPeak[n] * 0.85, nowMps);
		if (cPeak[n] < need || nowMps >= cPeak[n] * 0.6) return false;
		cPeak[n] = 0;

		Vector3 hand = PalmVel();
		double pct = clamp(Num("rsqml_headlock_weight", 30.0), 1.0, 100.0);
		EndCollar(n);
		// let go of the freeze NOW, not in two tics: a frozen actor's Tick returns before it moves
		a.freezetics = 0;
		// stunned for the flight: its Pain, so it is not mid-attack in the air (and its pain sound is the yelp)
		State pain = a.FindState("Pain");
		if (pain) a.SetState(pain);

		// RSQ DISTANCE GRAB LOADED: its throw, as before the move (its strength, weight and boost settings, aim assist,
		// the body's run, the flight, the impact and the whoosh). The monster's Vel carries the hand's.
		let dg = RSQML.Svc("RSQDG_ThrowService");
		a.Vel = hand;
		if (dg && dg.GetInt("headlock.throw", "", n, pct, a) == 1)
		{
			if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: threw %s through Distance Grab (hand %.1f m/s)", a.GetClassName(), RSQML.Metres(hand) * TICRATE);
			return true;
		}
		// WITHOUT IT, MELEE'S OWN TOSS, with Distance Grab's default numbers (its CVARINFO): strength 1.0
		// (rsqdg_throw_scale), the arm 30 kg (rsqdg_arm_kg), boost 2.5 (rsqdg_throw_boost); the monster's kilograms
		// are its Doom Mass (Distance Grab's mass.zs falls back to it for a monster). Same blow as before the move: the
		// impact counts the weight that gives the full-weight throw's energy.
		double realKg = max(1.0, a.Mass);
		double kg = realKg * pct / 100.0;
		double armKg = 30.0;
		Vector3 v = hand * (armKg / (armKg + kg)) * 2.5 + pmo.Vel;
		a.Vel = v;
		double hitKg = realKg * ((armKg + kg) / (armKg + realKg)) ** 2;
		RSQML_Tossed.Arm(a, pmo, max(1.0, hitKg));
		a.A_StartSound("skeleton/swing", CHAN_AUTO, CHANF_OVERLAP, 0.8);
		RSQ_Buzz.Start(pmo, 1, 0.6, 5);
		if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: tossed %s at %.1f m/s (counted as %.0f kg of its %.0f; hand %.1f m/s)", a.GetClassName(),
			RSQML.Metres(v - pmo.Vel) * TICRATE, kg, realKg, RSQML.Metres(hand) * TICRATE);
		return true;
	}

	override void WorldUnloaded(WorldEvent e) { for (int n = 0; n < MAXPLAYERS; n++) { if (collar[n]) EndCollar(n); gripDown[n] = false; } }
	// a save loaded or a new map: nothing is held (the borrowed flags come back through RSQML_Held)
	override void WorldLoaded(WorldEvent e) { for (int n = 0; n < MAXPLAYERS; n++) { collar[n] = null; gripDown[n] = false; } }
}

// THE FLAGS A HELD MONSTER LENDS, kept on it (saved with it). Given back when the hold ends, or on its first tic that
// no hold claims it (after a load: the static handler holds nothing).
class RSQML_Held : Inventory
{
	bool noGrav, infight;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	void GiveBack()
	{
		if (owner) { owner.bNOGRAVITY = noGrav; owner.bFORCEINFIGHTING = infight; }
		Destroy();
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let h = RSQML_Headlock.Get();
		if (!owner || !h || !h.IsHolding(owner)) GiveBack();
	}
}

// MELEE'S OWN TOSS LANDING (no Distance Grab): what the thrown monster hits while it flies -- a wall, or a body --
// takes the impact AND SO DOES IT: kinetic energy over 15 joules a point, nothing under 3 m/s (Distance Grab's
// rsqdg_throw_j and rsqdg_throw_min defaults, its throw.zs Impact rule). Paid to the thrower.
class RSQML_Tossed : Inventory
{
	PlayerPawn by;
	double kg;
	int left;
	Vector3 lastVel;
	const WINDOW = 70;
	const J_PER_POINT = 15.0;
	const MIN_MPS = 3.0;

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	static void Arm(Actor mo, PlayerPawn pawn, double kg)
	{
		let s = RSQML_Tossed(mo.FindInventory("RSQML_Tossed"));
		if (!s) s = RSQML_Tossed(mo.GiveInventoryType("RSQML_Tossed"));
		if (!s) return;
		s.by = pawn; s.kg = kg; s.left = WINDOW; s.lastVel = mo.Vel;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0 || left <= 0) { Destroy(); return; }
		left--;
		double mps = RSQML.Metres((lastVel.x, lastVel.y, 0)) * TICRATE;   // across the ground: a wall or a body stops that, a fall is not an impact
		Actor body = mo.BlockingMobj;
		bool hit = (mo.MovementBlockingLine || (body && body != by && body.bShootable)) && mps >= MIN_MPS;
		if (!hit)
		{
			if (mo.pos.z <= mo.floorz && mo.Vel.xy.Length() < 1.0) { Destroy(); return; }   // landed and stopped
			lastVel = mo.Vel;
			return;
		}
		int dmg = int(0.5 * kg * mps * mps / J_PER_POINT);
		if (RSQML.Debug() > 0) { String bn = "a wall"; if (body) bn = body.GetClassName(); Console.Printf("RSQML headlock toss: %s hit %s at %.1f m/s -> %d", mo.GetClassName(), bn, mps, dmg); }
		mo.A_StartSound("rsqml/smash", CHAN_AUTO, 0, 0.8);
		if (body && body != by && body.bShootable && body.health > 0) body.DamageMobj(mo, by, dmg, 'Melee');
		if (mo && mo.health > 0) mo.DamageMobj(mo, by, dmg, 'Melee');
		Destroy();
	}
}
