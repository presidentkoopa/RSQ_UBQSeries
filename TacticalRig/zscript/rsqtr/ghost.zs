// THE HOLSTER TIP: A GHOST HAND (report rec 6, "teach in context"; 11-08, rig only, not headset-confirmed).
//
// The first time you hold a gun with the Rig, a faint ghost of your hand shows how to holster it: once the main hand
// has held a gun (RSQTR_Rig.HoldsGun) for HOLD_TICS, and while rsqtr_tip_holster is false (this machine's, archived:
// no gun has ever been holstered here by hand), a translucent, fullbright copy of Brutal Doom VR's hand moves from where
// your hand is drawn to the target holster's centre and back, once every LOOP_TICS, and that holster's ring is forced
// visible. It pauses (hidden) while the main hand holds no gun, and it is gone for good the first time ANY gun goes
// into a gun holster by hand (either hand; RSQTR_Rig.NetworkProcess calls ByHand around Holster / HolsterOff).
//
// THE TARGET: the main-hand hip (Right hip; Left hip when left-handed, RSQTR_Body.LeftHanded) if it is empty and
// unassigned or assigned to this gun; else the nearest (to the main hand) empty gun holster unassigned or assigned to
// this gun; none: nothing shows. A holster the Rig would not take a gun into at all (claimed by another mod, or the
// ShieldSaw's shoulder) is not a target.
//
// THE HAND: Brutal Doom 22 VR Reloaded's own FBX hand (models/rsq/fbx/fbx_oh_free_R.md3, skin fbx_hand.png; its
// RSQ_Gunside / Melee_Attacks fist is frame 1), swapped onto a carrier by path (A_ChangeModel), as RSQTR_NadeShow takes
// BD's grenade. The Rig ships no hand of its own: without that file loaded only the target ring lights (11-08: the Rig
// stands alone).
// Its pose is the drawn hand's: RSQTR_HeldShow.Stand's solve (mirrorbody.zs: the HUD hand model's MODELDEF Scale -1 1 1
// and Offset 0 -24 -10 at the controller's pose, redone for a world actor), moved by the loop's share of the way from
// the controller to the ring's centre.
//
// SHOW ME (How To Play, 2026-11-27, owner: "no it works, its confusing my players!!!!!! we need to use it for this how to
// play thing"; design/HOWTOPLAY_BUILD.md): the same ghost hand also plays NAMED MOVES, once each, when the series' How To
// Play asks (a "Show Me" row: RSQTR_RigService GetIntUI / GetStringUI "ghost.demo" <name>, hooks.zs, then the network
// event it names, rig.zs NetworkProcess -> Ask). DEMO_NAMES below; each is a path from the hand to a place on the body
// (a holster's ring, which lights, or a point: the cigarette pocket, the lips, the chest, the watch spot) and back. While
// one plays the holster tip waits; nothing else about the tip changed. "Show On My Body" ("mirror.show" <place>) lights
// that place's rings and stands the mirror up for LIT_TICS (mirror.zs reads litUntil / litPlace).
//
// LOCAL ONLY: the ghost and the ring are this machine's (as the Rig's rings and icons; a subclass of RSQTR_Marker, so a
// load clears it, ClearLocalMarks); the cvar is set only on the machine of the player who holstered.
class RSQTR_Ghost play
{
	const HOLD_TICS = 70;          // 2 s holding a gun before it first shows
	const LOOP_TICS = 52;          // one out-and-back, ~1.5 s
	const HAND_ALPHA = 0.35;
	const RING_ALPHA = 0.35;
	const HAND_PATH = "models/rsq/fbx";
	const HAND_MD3 = "models/rsq/fbx/fbx_oh_free_R.md3";
	const HAND_PNG = "models/rsq/fbx/fbx_hand.png";

	int holdT;                     // tics the main hand has held a gun, without a break
	bool armed;                    // HOLD_TICS reached: from now it shows whenever a gun is held
	bool showing;
	int phase;
	int tgt;
	int lastTic;
	int meshState;                 // 0 not looked yet, 1 there, 2 missing
	RSQTR_GhostHand hand;

	// ---- SHOW ME / SHOW ON MY BODY (How To Play) ----
	static const String DEMO_NAMES[] = { "holster", "draw", "offdraw", "nade", "cig", "mouth", "recenter", "saber", "offsaber", "whip", "flare", "keyring", "watch", "pulse", "shield" };
	enum EDemo { D_HOLSTER, D_DRAW, D_OFFDRAW, D_NADE, D_CIG, D_MOUTH, D_RECENTER, D_SABER, D_OFFSABER, D_WHIP, D_FLARE, D_KEYRING, D_WATCH, D_PULSE, D_SHIELD };
	static const String PLACES[] = { "MOUTH", "LSH", "RSH", "CHEST", "BELT", "LHIP", "RHIP", "OFF", "MAIN", "BOTH" };
	const DEMO_TICS = 70;          // one move: out 0.7 s, held 0.6 s, back 0.7 s
	const DEMO_TICS2 = 105;        // through two places (the cigarette: the pocket, then the lips)
	const LIT_TICS = 350;          // Show On My Body: 10 s of mirror and lit rings
	const LIT_ALPHA = 0.9;
	const WATCH_F = 0.32;          // the watch spot: metres in front of the eyes, toward the main side, under the eyes
	const WATCH_L = 0.06;
	const WATCH_U = -0.22;
	bool demoOn;
	int demoIdx, demoT;
	RSQTR_GhostHand offHand;
	int mask;                      // the moves that can play now, a bit per DEMO_NAMES (Avail, every live tic): the menu reads it
	bool liveNow;                  // the rig ran this tic (alive, Tactical Rig on, VR hands)
	int litPlace, litUntil;        // Show On My Body: PLACES index, lit while level.maptime < litUntil
	int demoMesh;                  // as meshState, for Show Me (kept apart so the tip's own first look is unchanged)

	static bool Done() { let c = CVar.FindCVar("rsqtr_tip_holster"); return !c || c.GetBool(); }
	static bool Dbg(PlayerInfo p) { return RSQTR_Rig.Flag("rsqtr_messages", p, false); }

	// ---- the console player's tic (RSQTR_Rig.WorldTick, after DrawMarkers) ----------------------------------------------
	void Tick(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p)
	{
		bool gap = lastTic > 0 && level.maptime - lastTic > 1;
		lastTic = level.maptime;
		if (gap && showing) Halt(p, "the Rig was off");
		if (litUntil > level.maptime) LightPlace(rig, pmo, p);          // How To Play's Show On My Body
		if (demoOn) { if (showing) Halt(p, "show me"); Demo(rig, pmo, p); return; }   // How To Play's Show Me: the tip waits
		if (Done()) { if (showing) Halt(p, "tip done"); return; }
		if (meshState == 0)
		{
			meshState = (Wads.CheckNumForFullName(HAND_MD3) >= 0 && Wads.CheckNumForFullName(HAND_PNG) >= 0) ? 1 : 2;
			if (meshState == 2 && Dbg(p))
				Console.Printf("T_GHOST t%d: no hand mesh (%s not loaded): the holster tip lights the ring only", level.maptime, HAND_MD3);
		}

		bool gun = RSQTR_Rig.HoldsGun(pmo);
		if (!gun) { holdT = 0; if (showing) Halt(p, "gun not held"); return; }
		if (!armed)
		{
			if (++holdT < HOLD_TICS) return;
			armed = true;
		}
		String cls = GunOf(pmo);
		int r = Target(rig, pmo, cls);
		if (r < 0) { if (showing) Halt(p, String.Format("no empty holster for %s", cls)); return; }
		if (!showing)
		{
			showing = true; phase = 0; tgt = r;
			if (Dbg(p)) Console.Printf("T_GHOST t%d start: %s in the main hand, ghost hand to %s (loop %d tics, alpha %.2f)",
				level.maptime, cls, RSQTR_Region.NAMES[r], LOOP_TICS, HAND_ALPHA);
		}
		else if (r != tgt)
		{
			if (Dbg(p)) Console.Printf("T_GHOST t%d target: %s -> %s (%s)", level.maptime, RSQTR_Region.NAMES[tgt], RSQTR_Region.NAMES[r], cls);
			tgt = r;
		}
		Vector3 at = rig.RegionAt(pmo, r);
		ForceRing(rig, pmo, p, r, at);

		// the loop: out to the ring and back, eased (0 at the hand, 1 at the ring's centre)
		double s = 0.5 - 0.5 * cos(phase * 360.0 / LOOP_TICS);
		Vector3 grip = RSQTR_Body.Hand(pmo, 0);
		if (meshState == 1 && !hand) hand = RSQTR_GhostHand(Actor.Spawn("RSQTR_GhostHand", grip));
		if (hand)
		{
			hand.Pose(pmo, (at - grip) * s);
			hand.liveTo = level.maptime + 1;
		}
		if (phase == LOOP_TICS / 2 && Dbg(p))
			Console.Printf("T_GHOST t%d loop: ghost hand at %s (%.3f m from the hand, ring %.3f m away)", level.maptime,
				RSQTR_Region.NAMES[r], RSQTR_Body.RoomMetres(grip + (at - grip) * s, grip), RSQTR_Body.RoomMetres(at, grip));
		phase = (phase + 1) % LOOP_TICS;
	}

	private void Halt(PlayerInfo p, String why)
	{
		showing = false;
		if (hand) hand.bINVISIBLE = true;
		if (Dbg(p)) Console.Printf("T_GHOST t%d stop: %s", level.maptime, why);
	}

	// the class the held gun goes into a holster as (RSQTR_Rig.WouldRefuse's own: Brutal Doom's two-gun weapon as one)
	static String GunOf(PlayerPawn pmo)
	{
		let w = pmo.player.ReadyWeapon;
		if (!w) return "";
		String cls = RSQTR_Rig.HeldAs(pmo, w);
		String single = RSQTR_Rig.SingleOf(pmo, cls);
		if (single != "" && single != cls) { class<Weapon> sc = single; if (sc) cls = single; }
		return cls;
	}

	static bool Fits(RSQTR_Rig rig, PlayerPawn pmo, String cls, int r)
	{
		if (!RSQTR_Rig.IsGunRegion(r) || !rig.RegionLive(pmo, r) || r == RSQTR_Hooks.ShieldHolster(pmo)) return false;
		if (rig.Content(pmo, r) != "") return false;
		String lock = rig.lockCls[pmo.PlayerNumber() * RSQTR_Region.N + r];
		return lock == "" || lock ~== cls;
	}

	static int Target(RSQTR_Rig rig, PlayerPawn pmo, String cls)
	{
		int hip = RSQTR_Body.LeftHanded() ? 0 : 1;
		if (Fits(rig, pmo, cls, hip)) return hip;
		Vector3 hp = RSQTR_Body.Hand(pmo, 0);
		int best = -1;
		double bd = 1e9;
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (!Fits(rig, pmo, cls, r)) continue;
			double d = RSQTR_Body.RoomMetres(hp, rig.RegionAt(pmo, r));
			if (d < bd) { bd = d; best = r; }
		}
		return best;
	}

	// the target's ring, shown at least at RING_ALPHA whatever Holster Rings says (DrawMarkers has run this tic: a ring
	// it already shows brighter, a rule's flash, is left as it is)
	private void ForceRing(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p, int r, Vector3 at)
	{
		let m = rig.marker[r];
		if (!m) { m = Actor.Spawn("RSQTR_Marker", at); rig.marker[r] = m; }
		if (!m) return;
		if (m.bINVISIBLE)
		{
			bool inside = rig.HoverRegion(0) == r || rig.HoverRegion(1) == r;
			double sz = rig.RegionRadius(p, r) * RSQTR_Body.Upm() * (inside ? 1.15 : 1.0);
			m.frame = RSQTR_Rig.MarkerFrame(inside, RSQTR_Rig.Opt("rsqtr_profile_active", p, 1), false);
			m.Scale = (sz, sz);
			m.Alpha = RING_ALPHA;
			m.SetOrigin(at, true);
			m.bINVISIBLE = false;
		}
		else if (m.Alpha < RING_ALPHA) m.Alpha = RING_ALPHA;
	}

	// ---- SHOW ME / SHOW ON MY BODY (How To Play) -------------------------------------------------------------------------
	clearscope static int DemoIndex(String name)
	{
		for (int i = 0; i < DEMO_NAMES.Size(); i++) if (DEMO_NAMES[i] ~== name) return i;
		return -1;
	}
	clearscope static int PlaceIndex(String name)
	{
		for (int i = 0; i < PLACES.Size(); i++) if (PLACES[i] ~== name) return i;
		return -1;
	}

	// asked from the menu (ui, hooks.zs): what the rig cached last tic, for the console player
	clearscope static bool CanDemo(String name)
	{
		let rig = RSQTR_Rig(EventHandler.Find("RSQTR_Rig"));
		int d = DemoIndex(name);
		return rig && rig.ghost && rig.ghost.liveNow && d >= 0 && (rig.ghost.mask & (1 << d)) != 0;
	}
	clearscope static bool CanLight(String place)
	{
		let rig = RSQTR_Rig(EventHandler.Find("RSQTR_Rig"));
		return rig && rig.ghost && rig.ghost.liveNow && PlaceIndex(place) >= 0;
	}

	// which hand a move is done with: 0 main, 1 off, 2 both
	static int DemoHand(int d)
	{
		if (d == D_RECENTER) return 2;
		if (d == D_OFFDRAW || d == D_OFFSABER || d == D_FLARE || d == D_WATCH || d == D_PULSE || d == D_SHIELD) return 1;
		return 0;
	}

	// the place a move goes to: a region index, -1 a point on the body (no ring), -2 not there now
	static int DemoRegion(RSQTR_Rig rig, PlayerPawn pmo, int d)
	{
		bool lh = RSQTR_Body.LeftHanded();
		int r = -1;
		if (d == D_HOLSTER || d == D_DRAW) r = lh ? 0 : 1;
		else if (d == D_OFFDRAW) r = lh ? 1 : 0;
		else if (d == D_NADE) r = RSQTR_Region.GRENADES;
		else if (d == D_SABER) r = lh ? RSQTR_Region.SABER_L : RSQTR_Region.SABER_R;
		else if (d == D_OFFSABER) r = lh ? RSQTR_Region.SABER_R : RSQTR_Region.SABER_L;
		else if (d == D_WHIP) r = RSQTR_Region.WHIP;
		else if (d == D_FLARE) r = RSQTR_Region.FLARE;
		else if (d == D_KEYRING) r = RSQTR_Region.KEYRING;
		else if (d == D_SHIELD) { r = RSQTR_Hooks.ShieldHolster(pmo); if (r < 0) return -2; return r; }
		else if (d == D_CIG || d == D_MOUTH) return RSQTR_Rig.Flag("rsqtr_cig", pmo.player, false) ? -1 : -2;
		else return -1;    // recenter, watch, pulse: points
		if (!rig.RegionLive(pmo, r)) return -2;
		if ((d == D_HOLSTER || d == D_DRAW || d == D_OFFDRAW) && r == RSQTR_Hooks.ShieldHolster(pmo)) return -2;
		return r;
	}

	// where the move goes (leg 0; the cigarette's leg 1 is the lips)
	static Vector3 DemoAt(RSQTR_Rig rig, PlayerPawn pmo, int d, int leg)
	{
		int r = DemoRegion(rig, pmo, d);
		if (r >= 0) return rig.RegionAt(pmo, r);
		if (d == D_CIG && leg == 0)
		{
			let c = RSQTR_Cig.Get();
			if (c) return c.Pocket(pmo);
		}
		if (d == D_CIG || d == D_MOUTH) return RSQTR_Cig.Mouth(pmo);
		if (d == D_RECENTER) return rig.BodyPoint(pmo, RSQTR_Rig.REC_F, 0, RSQTR_Rig.REC_U);
		// the watch and pulse spot: in front of you, the off wrist a little toward the main side
		bool offLeft = !RSQTR_Body.LeftHanded();
		return rig.BodyPoint(pmo, WATCH_F, offLeft ? WATCH_L : -WATCH_L, WATCH_U);
	}

	// every live tic (rig.zs WorldTick, right after it decides the rig runs): what Show Me can play now
	static void Avail(RSQTR_Rig rig, PlayerPawn pmo, bool on)
	{
		if (!rig.ghost) rig.ghost = new("RSQTR_Ghost");
		let g = rig.ghost;
		g.liveNow = on;
		g.mask = 0;
		if (!on) { g.demoOn = false; g.litUntil = 0; return; }
		if (g.demoMesh == 0) g.demoMesh = (Wads.CheckNumForFullName(HAND_MD3) >= 0 && Wads.CheckNumForFullName(HAND_PNG) >= 0) ? 1 : 2;
		for (int d = 0; d < DEMO_NAMES.Size(); d++)
		{
			int r = DemoRegion(rig, pmo, d);
			if (r == -2) continue;
			if (g.demoMesh != 1 && r < 0) continue;     // no hand mesh: only a move to a ring can show (its ring lights)
			g.mask |= 1 << d;
		}
	}

	// the menu's request (rig.zs NetworkProcess, the console player's own machine)
	void Ask(String what)
	{
		if (what.IndexOf("rsqtr_ghostdemo:") == 0)
		{
			int d = DemoIndex(what.Mid(16));
			if (d < 0 || !(mask & (1 << d))) return;
			demoOn = true; demoIdx = d; demoT = 0;
			if (Dbg(players[consoleplayer])) Console.Printf("T_GHOST t%d show me: %s", level.maptime, DEMO_NAMES[d]);
		}
		else if (what.IndexOf("rsqtr_mirrorshow:") == 0)
		{
			int pl = PlaceIndex(what.Mid(17));
			if (pl < 0 || !liveNow) return;
			litPlace = pl;
			litUntil = level.maptime + LIT_TICS;
			if (Dbg(players[consoleplayer])) Console.Printf("T_GHOST t%d show on my body: %s", level.maptime, PLACES[pl]);
		}
	}

	static double Ease(double x) { x = clamp(x, 0.0, 1.0); return 0.5 - 0.5 * cos(x * 180.0); }

	private void Demo(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p)
	{
		int d = demoIdx;
		bool two = d == D_CIG;
		int len = two ? DEMO_TICS2 : DEMO_TICS;
		if (demoT >= len || d < 0 || d >= DEMO_NAMES.Size())
		{
			demoOn = false;
			if (Dbg(p)) Console.Printf("T_GHOST t%d show me done: %s", level.maptime, d >= 0 && d < DEMO_NAMES.Size() ? DEMO_NAMES[d] : "?");
			return;
		}
		double t = demoT / double(len);
		demoT++;
		int r = DemoRegion(rig, pmo, d);
		Vector3 a = DemoAt(rig, pmo, d, 0);
		if (r >= 0) ForceRing(rig, pmo, p, r, a);
		if (demoMesh != 1) return;
		Vector3 b = two ? DemoAt(rig, pmo, d, 1) : a;
		int hands = DemoHand(d);
		for (int h = 0; h < 2; h++)
		{
			if (hands != 2 && hands != h) continue;
			Vector3 grip = RSQTR_Body.Hand(pmo, h);
			// out, held, back; through two places: out to the first, on to the second, back
			Vector3 at;
			double turn;
			if (!two)
			{
				turn = t < 0.35 ? Ease(t / 0.35) : (t < 0.65 ? 1.0 : Ease((1.0 - t) / 0.35));
				at = grip + (a - grip) * turn;
			}
			else
			{
				if (t < 0.25) at = grip + (a - grip) * Ease(t / 0.25);
				else if (t < 0.35) at = a;
				else if (t < 0.6) at = a + (b - a) * Ease((t - 0.35) / 0.25);
				else if (t < 0.75) at = b;
				else at = b + (grip - b) * Ease((t - 0.75) / 0.25);
				turn = 0;
			}
			if (h == 0)
			{
				if (!hand) hand = RSQTR_GhostHand(Actor.Spawn("RSQTR_GhostHand", grip));
				if (hand) { hand.Pose(pmo, at - grip); hand.liveTo = level.maptime + 1; }
			}
			else
			{
				if (!offHand) offHand = RSQTR_GhostHand(Actor.Spawn("RSQTR_GhostHand", grip));
				if (!offHand) continue;
				// the watch and the pulse turn the wrist: the back of it (watch) or the inside (pulse) to your eyes
				double ya = pmo.OffhandAngle, pi = pmo.OffhandPitch, ro = pmo.OffhandRoll;
				if (d == D_WATCH || d == D_PULSE)
				{
					bool offLeft = !RSQTR_Body.LeftHanded();
					double yt = rig.BodyYaw(pmo) + (offLeft ? -75 : 75);
					double rt = (d == D_WATCH ? 90 : -90) * (offLeft ? 1 : -1);
					ya += Actor.DeltaAngle(ya, yt) * turn;
					pi += (0 - pi) * turn;
					ro += Actor.DeltaAngle(ro, rt) * turn;
				}
				offHand.PoseAt(pmo.OffhandPos, ya, pi, -ro, !RSQTR_Body.LeftHanded(), at - grip);
				offHand.liveTo = level.maptime + 1;
			}
		}
	}

	// Show On My Body: the place's rings lit on the body (the mirror copies them; mirror.zs adds the lips, the pocket and
	// the hands, which have no ring)
	private void LightPlace(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p)
	{
		String pl = PLACES[clamp(litPlace, 0, PLACES.Size() - 1)];
		double by = rig.BodyYaw(pmo);
		Vector3 head = RSQTR_Body.Head(pmo);
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (!rig.RegionLive(pmo, r)) continue;
			bool lit = false;
			if (pl == "LSH") lit = r == 4;
			else if (pl == "RSH") lit = r == 5;
			else if (pl == "CHEST") lit = r == 6 || r == 7;
			else if (pl == "BELT") lit = r == RSQTR_Region.GRENADES || r == RSQTR_Region.KEYRING || r == RSQTR_Region.POUCH;
			else if (pl == "LHIP" || pl == "RHIP")
			{
				bool left = pl == "LHIP";
				if (r == 0 || r == 1) lit = (r == 0) == left;
				else if (r >= RSQTR_Region.SABER_L && r <= RSQTR_Region.FLARE)
				{
					Vector3 v = rig.RegionAt(pmo, r) - head;
					lit = ((v.x * -sin(by) + v.y * cos(by)) > 0) == left;    // left of the torso's middle
				}
			}
			if (lit) LightRing(rig, pmo, p, r);
		}
	}

	private void LightRing(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p, int r)
	{
		Vector3 at = rig.RegionAt(pmo, r);
		let m = rig.marker[r];
		if (!m) { m = Actor.Spawn("RSQTR_Marker", at); rig.marker[r] = m; }
		if (!m) return;
		double sz = rig.RegionRadius(p, r) * RSQTR_Body.Upm() * 1.15;
		m.frame = RSQTR_Rig.MarkerFrame(true, RSQTR_Rig.Opt("rsqtr_profile_active", p, 1), false);
		m.Scale = (sz, sz);
		m.Alpha = LIT_ALPHA;
		m.SetOrigin(at, true);
		m.bINVISIBLE = false;
	}

	// ---- a gun put in a holster by hand (RSQTR_Rig.NetworkProcess, every machine; acts on the console player's only) ----
	// What the gun holsters held before the press, so ByHand can see whether a gun went in.
	static String Snap(RSQTR_Rig rig, int n)
	{
		String s = "";
		for (int r = 0; r < RSQTR_Region.N; r++) s = s .. (RSQTR_Rig.IsGunRegion(r) ? rig.lastPut[n * RSQTR_Region.N + r] : "") .. "|";
		return s;
	}

	static void ByHand(RSQTR_Rig rig, PlayerPawn pmo, String before, bool heldGun, int h)
	{
		if (!heldGun || !pmo || pmo.player != players[consoleplayer] || Done()) return;
		Array<String> was;
		before.Split(was, "|");
		int n = pmo.PlayerNumber();
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (!RSQTR_Rig.IsGunRegion(r)) continue;
			String now = rig.lastPut[n * RSQTR_Region.N + r];
			String old = r < was.Size() ? was[r] : "";
			if (now == "" || now ~== old) continue;
			CVar.FindCVar("rsqtr_tip_holster").SetBool(true);
			if (Dbg(pmo.player))
				Console.Printf("T_GHOST t%d stop: holstered by hand (%s hand): %s into %s; rsqtr_tip_holster set, the tip never shows again",
					level.maptime, h ? "off" : "main", now, RSQTR_Region.NAMES[r]);
			return;
		}
	}
}

// The ghost hand itself: a carrier (the wire sphere with the invisible skin, MODELDEF RSQTR_GhostHand) that wears Brutal
// Doom VR's hand by path. Local, never in play.
class RSQTR_GhostHand : RSQTR_Marker
{
	int liveTo;                    // shown through this tic; hidden after it (the Rig off, the tip stopped)
	bool worn;
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.35;
	}
	States { Spawn: RSTM A -1 Bright; Stop; }

	override void Tick()
	{
		Super.Tick();
		if (level.maptime > liveTo) bINVISIBLE = true;
	}

	// Drawn where the main hand's own model is drawn (RSQTR_HeldShow.Stand, mirrorbody.zs, with the BD hand block's Scale
	// -1 1 1 / Offset 0 -24 -10 from RSQTRLAY), then moved by `move` (map units).
	void Pose(PlayerPawn pmo, Vector3 move)
	{
		PoseAt(pmo.AttackPos, pmo.AttackAngle, pmo.AttackPitch, -pmo.AttackRoll, RSQTR_Body.LeftHanded(), move);
	}

	// The same for any controller pose (at, yaw, pitch, roll as the renderer turns it, i.e. minus the controller's roll);
	// `rev`: it is the left controller, whose model is mirrored. Show Me's off hand comes here with the off controller.
	void PoseAt(Vector3 at, double ya, double pi, double ro, bool rev, Vector3 move)
	{
		if (!worn)
		{
			worn = true;
			A_ChangeModel(GetClassName(), 0, RSQTR_Ghost.HAND_PATH, 'fbx_oh_free_R.md3', 0, RSQTR_Ghost.HAND_PATH, 'fbx_hand.png');
			SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
		}
		Vector3 sc = (-1, 1, 1), ofs = (0, -24, -10);
		// the left controller's model is mirrored: the main hand is the left one when left-handed (Pose, above)
		let cu = CVar.FindCVar("vr_vunits_per_meter"), cw = CVar.FindCVar("vr_weaponScale");
		double cm = (cu ? cu.GetFloat() : 34.0) * 0.01;
		double k = cm * (cw ? cw.GetFloat() : 1.0);
		Vector3 R = RSQTR_HeldShow.Turn(ya, pi, ro, (1, 0, 0)), U = RSQTR_HeldShow.Turn(ya, pi, ro, (0, 1, 0)), B = RSQTR_HeldShow.Turn(ya, pi, ro, (0, 0, 1));
		double sg = sc.x * sc.y < 0 ? -1 : 1;
		Vector3 F = B * -sg;
		Vector3 L = rev ? R * -sg : R * sg;
		Scale = (k, rev ? k : -k);
		angle = atan2(F.y, F.x);
		pitch = -asin(clamp(F.z, -1.0, 1.0));
		Vector3 F0, L0, U0;
		[F0, L0, U0] = RSQTR_Fit.Basis(angle, pitch, 0);
		roll = atan2(L dot U0, L dot L0);
		Vector3 cust = (RSQTR_HeldShow.CVarF("vr_3dweaponOffsetX"), RSQTR_HeldShow.CVarF("vr_3dweaponOffsetY"), RSQTR_HeldShow.CVarF("vr_3dweaponOffsetZ"));
		Vector3 q = (0, 5, 30) + (ofs.x, ofs.z, ofs.y) + (sc.x * -cust.x, sc.z * cust.y, sc.y * cust.z);
		if (rev) q.x = -q.x;
		Vector3 h = RSQTR_HeldShow.Turn(ya, pi, ro, q);
		h.z /= RSQTR_Body.Ps();
		Vector3 hud = at + h * cm;
		Vector3 wrl = (F * ofs.x + U * ofs.z + L * ofs.y) * k;
		SetOrigin(hud - wrl + move, true);
		Alpha = RSQTR_Ghost.HAND_ALPHA;
		bINVISIBLE = false;
	}
}
