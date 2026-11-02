// THE HEADLOCK (RSQ Melee). Moved from RSQ Distance Grab's near.zs (its collar code) on 2026-11-01.
//
//   HOLD    the OFF hand's grip on a living monster no heavier than rsqml_headlock_mass, within rsqml_headlock_reach of
//           the palm, holds it frozen in front of the hand for up to rsqml_headlock_secs, so the main hand can punch it.
//           RSQ Score is told ("touch" grab.hold), and Score's "Headlock" combo (grab.hold > hands) pays.
//   SHIELD  Human Shield (an option, off): held as long as the grip is (a minute at most), turned to face away from you.
//           With RSQ Gun Bonsai VR it is the off glove's Human Shield node instead (GBOVR_TREES.md 4.1 E): level 1 that hold;
//           2 it takes the shots meant for you from its side (guard.zs RSQML_Body); 3 those hurt it x1.5.
//   THE GRAPPLER'S NODES (Gun Bonsai VR, the off glove): Heavier Headlock (heavier monsters, + Distance Grab's Iron Grip),
//           Slam (the off hand swung DOWN hard while holding: the monster hits the floor, a shockwave round it),
//           Throw Into (the throw hits harder; Melee's own toss bends onto a monster), Chokehold (a held monster is
//           hurt every second), Headlock Uppercut (gloves.zs: an uppercut on the monster you hold launches it).
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
	int holdStart[MAXPLAYERS];   // the tic the hold began (Chokehold's seconds)
	Actor collar[MAXPLAYERS];
	int collarEnd[MAXPLAYERS], collarPing[MAXPLAYERS];
	int punches[MAXPLAYERS];      // blows the holder has landed on the held monster this hold (extra blood)
	int flinchEnd[MAXPLAYERS];    // the held monster shows its pain frame until this tic (a punch's flinch)
	bool holdInit[MAXPLAYERS];
	int heldSprite[MAXPLAYERS], heldFrame[MAXPLAYERS];   // the frame it was caught in: shown between flinches
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

	// the player's off hand is holding someone (that hand grips: it neither punches nor returns fireballs)
	bool HoldsAny(int n) { return n >= 0 && n < MAXPLAYERS && collar[n] != null; }

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
		// HEAVIER HEADLOCK (Gun Bonsai VR, the off glove): its cap, with Distance Grab's Iron Grip adding on top
		int hhLv = RSQML.GrappleLevel(pmo, "HeavierHeadlock");
		if (hhLv > 0)
		{
			maxMass = max(maxMass, RSQML.Num("HeavierHeadlock.mass", hhLv, 0, 600));
			let gb = RSQML.GB();
			if (gb) maxMass += 100 * gb.GetInt("plevel", "IronGrip", 0, 0, pmo);
		}
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
		bool shield = ShieldOn(pmo);
		collarEnd[n] = level.maptime + (shield ? 60 * TICRATE : int(Num("rsqml_headlock_secs", 3.0) * TICRATE));
		collarPing[n] = 0;
		holdStart[n] = level.maptime;
		punches[n] = 0;
		flinchEnd[n] = 0;
		holdInit[n] = false;
		heldSprite[n] = a.sprite;
		heldFrame[n] = a.frame;
		// the catch's feel: Distance Grab's thud and tick when it is loaded, else a knock in the off hand
		let dg = RSQML.Svc("RSQDG_ThrowService");
		if (!dg || dg.GetInt("headlock.caught", "", n, 0, a) != 1) RSQ_Buzz.Start(pmo, 1, 0.5, 4);
		if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: holding %s (t%d)", a.GetClassName(), level.maptime);
	}

	// HUMAN SHIELD: with Gun Bonsai VR, the off glove's node; without it, the row
	static bool ShieldOn(PlayerPawn pmo)
	{
		if (RSQML.GB()) return RSQML.GrappleLevel(pmo, "HumanShield") > 0;
		return Flag("rsqml_headlock_shield", false);
	}

	// LET GO NOW (Headlock Uppercut): the hold ends and the freeze with it, so the blow can move it this tic
	void LetGo(int n)
	{
		let a = collar[n];
		EndCollar(n);
		if (a) a.freezetics = 0;
	}

	private void EndCollar(int n)
	{
		let a = collar[n];
		collar[n] = null;
		if (!a) return;
		if (a.CurState) { a.sprite = a.CurState.sprite; a.frame = a.CurState.Frame; }   // its own frame again
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
			if (!Hold(n, p.mo, a, hp)) { EndCollar(n); continue; }   // no room for it (a wall at your hand)
			// freezetics, re-asserted every tic before the thinkers run: the monster's Tick returns early (no states,
			// movement or AI) but it KEEPS its blockmap link, so it stays solid and shootable. RSQ HP Bars reads this
			// (a freezetics that stands still, with NOGRAVITY / FORCEINFIGHTING borrowed) as "held".
			a.freezetics = 2;
			Flinch(n, a);
			// CHOKEHOLD (Gun Bonsai VR, the off glove): hurt every second it is held, paid to that glove
			int chLv = RSQML.GrappleLevel(p.mo, "Chokehold");
			if (chLv > 0 && level.maptime > holdStart[n] && (level.maptime - holdStart[n]) % TICRATE == 0)
			{
				RSQML.Touch("choke", p.mo, a);
				a.DamageMobj(RSQML.Blow(p.mo, RSQML.OffGlove(p.mo), a.pos), p.mo, int(RSQML.Num("Chokehold.damage", chLv, 0, 3)), 'Melee', DMG_THRUSTLESS);
				if (!a || a.health <= 0) { EndCollar(n); continue; }
			}
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

	// ---- THE HOLD ITSELF (2026-11-02; the owner's pick "real monster at hand": grabbed by the collar and sucker-punched
	// in the face). The monster itself is moved each tic to the off hand: its face (85 % of its height) at the hand's
	// height, its body just past the hand away from you, facing you (Human Shield: facing away). Never into you: at
	// least your radius + its radius + 2 from your centre. Never into a wall: a trace from your centre at its middle
	// stops it short of one (no room for it there and the hold ends). Moved with SetOrigin(moving), so the renderer
	// interpolates it like anything that moves, eased 60 % of the way a tic so a shaky hand does not shake it. No
	// shrinking, no sprite swap: any monster, no new art.
	const FACE_FRAC = 0.85;
	const EASE = 0.6;

	private bool Hold(int n, PlayerPawn pmo, Actor a, Vector3 hp)
	{
		Vector2 away = hp.xy - pmo.pos.xy;
		double ol = away.Length();
		away = ol > 0.5 ? away / ol : (cos(pmo.angle), sin(pmo.angle));
		double minD = pmo.radius + a.radius + 2.0;
		double d = max(ol + a.radius * 0.5, minD);
		double z = hp.z - a.height * FACE_FRAC;
		// a wall between you and where it would go: it stops short (its radius off the wall)
		FLineTraceData t;
		double midZ = z + a.height * 0.5 - pmo.pos.z;
		if (pmo.LineTrace(VectorAngle(away.x, away.y), d + a.radius, 0, TRF_THRUACTORS, midZ, 0, 0, t) && t.HitType != TRACE_HitNone)
			d = min(d, t.Distance - a.radius - 1.0);
		if (d < minD) return false;
		Vector3 want = (pmo.pos.x + away.x * d, pmo.pos.y + away.y * d, z);
		Vector3 at = holdInit[n] ? a.pos + (want - a.pos) * EASE : want;
		holdInit[n] = true;
		at.z = clamp(at.z, a.floorz, max(a.floorz, a.ceilingz - a.height));
		a.SetOrigin(at, true);
		a.Vel = (0, 0, 0);
		a.Angle = ShieldOn(pmo) ? pmo.Angle : a.AngleTo(pmo);
		return true;
	}

	// THE FLINCH: a punch shows its pain frame for 6 tics -- the first drawn frame of its Pain sequence, put on the
	// frozen monster (its state does not run: none of the pain state's code, Brutal Doom's or anyone's), then the frame
	// it was caught in again. With its pain sound.
	const FLINCH_TICS = 6;
	private void Flinch(int n, Actor a)
	{
		if (level.maptime >= flinchEnd[n])
		{
			// back to the frame it was caught in (the engine's own pain reaction put the frozen monster in its Pain
			// state, which it cannot leave while frozen: without this it would wince for the rest of the hold)
			if (flinchEnd[n] > 0) { a.sprite = heldSprite[n]; a.frame = heldFrame[n]; flinchEnd[n] = 0; }
			return;
		}
		State s = a.FindState("Pain");
		int tnt = Actor.GetSpriteIndex('TNT1');
		for (int i = 0; s && i < 12; i++, s = s.NextState)
		{
			if (s.sprite != tnt && s.Tics != 0) { a.sprite = s.sprite; a.frame = s.Frame; return; }
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
		// SLAM (Gun Bonsai VR, the off glove): the off hand swung DOWN hard while holding drives it into the floor
		int slLv = RSQML.GrappleLevel(pmo, "Slam");
		if (slLv > 0)
		{
			double armM = RSQML.Metres(arm);
			double downM = -arm.z * RSQML.Stretch() / RSQML.UnitsPerMetre();
			if (armM > 0.0001 && downM >= 0.7 * armM && armM * TICRATE >= RSQML.Num("Slam.speed", slLv, 0, 3.0))
			{
				Slam(n, pmo, a, armM * TICRATE, slLv);
				return true;
			}
		}
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
		// THROW INTO (Gun Bonsai VR, the off glove): what it hits in this flight takes more (RSQML_ThrownInto, read by
		// RSQML_Body, so Distance Grab's flight and Melee's own toss both count)
		int tiLv = RSQML.GrappleLevel(pmo, "ThrowInto");
		if (tiLv > 0) RSQML_ThrownInto.Mark(a, pmo, RSQML.Num("ThrowInto.mult", tiLv, 0, 1.25));
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
		// THROW INTO without Distance Grab (whose own aim assist does this there): bent up to BEND degrees onto the nearest
		// monster ahead of the throw
		if (tiLv > 0) a.Vel = BendOntoFoe(pmo, a, a.Vel);
		RSQML_Tossed.Arm(a, pmo, max(1.0, hitKg));
		a.A_StartSound("skeleton/swing", CHAN_AUTO, CHANF_OVERLAP, 0.8);
		RSQ_Buzz.Start(pmo, 1, 0.6, 5);
		if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: tossed %s at %.1f m/s (counted as %.0f kg of its %.0f; hand %.1f m/s)", a.GetClassName(),
			RSQML.Metres(v - pmo.Vel) * TICRATE, kg, realKg, RSQML.Metres(hand) * TICRATE);
		return true;
	}

	// THROW INTO's bend: the throw turned onto the monster nearest its line within BEND degrees and BEND_RANGE
	const BEND = 12.0;
	const BEND_RANGE = 640.0;
	static Vector3 BendOntoFoe(PlayerPawn pmo, Actor a, Vector3 v)
	{
		double sp = v.xy.Length();
		if (sp < 1.0) return v;
		double dir = VectorAngle(v.x, v.y);
		Actor best = null;
		double bestOff = BEND;
		let it = BlockThingsIterator.Create(a, BEND_RANGE);
		while (it.Next())
		{
			let o = it.thing;
			if (o == a || !RSQML.IsFoe(pmo, o) || a.Distance2D(o) > BEND_RANGE) continue;
			double off = Actor.absangle(dir, a.AngleTo(o));
			if (off < bestOff) { bestOff = off; best = o; }
		}
		if (!best) return v;
		double na = a.AngleTo(best);
		if (RSQML.Debug() > 0) { String bn = best.GetClassName(); Console.Printf("RSQML throw into: bent %.1f degrees onto %s", bestOff, bn); }
		return (cos(na) * sp, sin(na) * sp, v.z);
	}

	// SLAM: the held monster is driven into the floor under it -- the toss's blow x Slam.mult, paid to the off glove --
	// and what stands within Slam.radius of it staggers
	private void Slam(int n, PlayerPawn pmo, Actor a, double mps, int lv)
	{
		EndCollar(n);
		a.freezetics = 0;
		a.SetOrigin((a.pos.x, a.pos.y, a.floorz), true);
		a.Vel = (0, 0, 0);
		State pain = a.FindState("Pain");
		if (pain) a.SetState(pain);
		double pct = clamp(Num("rsqml_headlock_weight", 30.0), 1.0, 100.0) / 100.0;
		int dmg = int(0.5 * max(1.0, a.Mass) * pct * mps * mps / RSQML_Tossed.J_PER_POINT * RSQML.Num("Slam.mult", lv, 0, 1.25));
		Weapon off = RSQML.OffGlove(pmo);
		Actor inf = RSQML.Blow(pmo, off, a.pos);
		RSQML.Touch("slam", pmo, a);
		RSQML_Burst.At("RSQML_Burst5", a.pos + (0, 0, 4), 1.0, RSQML_Burst.ByLevel(lv, 3));
		a.A_StartSound("rsqml/fx/thud", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		RSQ_Buzz.Start(pmo, 1, 1.0, 10);
		double r = RSQML.Num("Slam.radius", lv, 0, 1.5) * RSQML.UnitsPerMetre();
		int st = int(RSQML.Num("Slam.stagger", lv, 0, 15));
		int k = 0;
		let it = BlockThingsIterator.Create(a, r);
		while (it.Next())
		{
			let o = it.thing;
			if (o == a || !RSQML.IsFoe(pmo, o) || a.Distance2D(o) > r + o.radius) continue;
			RSQML.Stagger(o, st);
			k++;
		}
		if (RSQML.Debug() > 0) Console.Printf("RSQML slam: %s into the floor at %.1f m/s -> %d, %d staggered round it", a.GetClassName(), mps, dmg, k);
		a.DamageMobj(inf, pmo, max(1, dmg), 'Melee', DMG_THRUSTLESS);
	}

	// HEADLOCK PUNCH EXTRA BLOOD (the owner, 11-01: "first punch 1.3 gore, second 1.6, third and beyond 2.0"):
	// a blow the holder lands on the monster he is holding bleeds again -- the hit's own blood (SpawnBlood +
	// TraceBleed, as the F.E.A.R. window does) -- sized by 0.3 of the blow on the first, 0.6 on the second, and a
	// full second set from the third (the engine scales blood and wall splats by the damage it is given).
	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t || e.Damage <= 0) return;
		let pmo = PlayerPawn(e.DamageSource);
		if (!pmo || !pmo.player) return;
		int n = pmo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || collar[n] != t) return;
		// the flinch (any blow of yours on the monster you hold), then the extra blood
		if (flinchEnd[n] <= level.maptime) t.A_StartSound(t.PainSound, CHAN_VOICE);
		flinchEnd[n] = level.maptime + FLINCH_TICS;
		if (t.health > 0) Flinch(n, t);
		if (t.bNoBlood || !Flag("rsqml_headlock_blood", true)) return;
		if (e.Inflictor && e.Inflictor.GetClassName() == 'RSQML_GloveBlow') return;   // a Chokehold squeeze or a Slam, not a punch
		punches[n]++;
		double extra = punches[n] == 1 ? 0.3 : punches[n] == 2 ? 0.6 : 1.0;
		int amt = max(1, int(e.Damage * extra + 0.5));
		Vector3 at = t.pos + (0, 0, t.height * 0.5);
		t.SpawnBlood(at, pmo.AngleTo(t) + 180, amt);
		t.TraceBleed(amt, pmo);
		if (RSQML.Debug() > 0) Console.Printf("RSQML headlock: punch %d on %s, extra blood (t%d)", punches[n], t.GetClassName(), level.maptime);
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

// THROW INTO (GBOVR_TREES.md 4.1 E): a monster thrown out of the Headlock carries this for its flight; whatever it hits
// (and it) takes Throw Into's multiplier, applied by the thrower's RSQML_Body (guard.zs), so Distance Grab's flight and
// Melee's own toss both count.
class RSQML_ThrownInto : Inventory
{
	PlayerPawn by;
	double mult;
	int untilTic;
	const LIFE = 70;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	static void Mark(Actor mo, PlayerPawn pawn, double mult)
	{
		if (!mo || !pawn) return;
		let t = RSQML_ThrownInto(mo.FindInventory("RSQML_ThrownInto"));
		if (!t) t = RSQML_ThrownInto(mo.GiveInventoryType("RSQML_ThrownInto"));
		if (!t) return;
		t.by = pawn; t.mult = mult; t.untilTic = level.maptime + LIFE;
	}
	// the multiplier for a blow this thrown monster deals for `by`, 0 if none
	static double MultFor(Actor inflictor, Actor by)
	{
		if (!inflictor) return 0;
		let t = RSQML_ThrownInto(inflictor.FindInventory("RSQML_ThrownInto"));
		return (t && t.by == by && level.maptime <= t.untilTic) ? t.mult : 0;
	}
	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner || owner.health <= 0 || level.maptime > untilTic) Destroy();
	}
}
