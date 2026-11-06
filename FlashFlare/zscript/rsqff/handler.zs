// RSQ FlashFlare -- THE HANDS AND THE BUDGET.
//
// IN VR (rig only, not headset-confirmed):
//   1. TAKE: reach the OFF hand across to the pocket on your chest (main-hand side) and grip: a flare is in that hand,
//      unlit, cap on. The main hand keeps its gun. Grip there again with an unlit flare: it goes back in the pocket.
//   2. STRIKE: flick the flare hand sharply DOWN (rsqff_strike m/s, 1.4), as you would strike the cap on a road flare; or
//      pull that hand's trigger (rsqff_light_by: Strike / Trigger / Strike or Trigger). It catches with a burst of sparks,
//      sputters for about two-thirds of a second, then burns.
//   3. HOLD it up to light the way. Its light follows the burning end you see.
//   4. THROW, AS RSQ GRENADE THROWS (owner 11-05 05:14: "still cannot throw flare, needs to throw like grenade does"):
//      the flare hand's TRIGGER is your hold on it. Squeeze it (the squeeze that lit it counts), swing, and LET GO while
//      the hand moves faster than rsqff_swing (2 m/s): it leaves at the hand's own speed and direction (RSQ Grenade
//      hand.zs's release, measure and launch, copied here), tumbles, bounces and lies burning. Let go with the hand still:
//      it stays in your hand. The grip does nothing to a lit flare (owner 11-06: "Trigger only"): no throw, no drop.
//   5. It burns rsqff_burn seconds (60) in the hand or on the floor, then dies away; burnt out in the hand, the hand lets
//      the spent flare fall.
// Put away any other way (another mod or key takes the off hand, death, a new level): an unlit flare goes back in the
// pocket; a lit one falls where the hand was, still burning.
//
// THE OTHER MODS, BY NAME (nothing here links against them):
//   RSQ Tactical Rig: the pocket hangs on its body ("body.yaw", RSQTR_BodyService) so it turns with its holsters; while
//     the off hand is in one of its places ("rig.region") the grip is the rig's, never the pocket's.
//   Brutal Doom 22 VR Reloaded: when the flare leaves the off hand it gets BD22's empty hands back (RSQ_Hands) if it had
//     them; its Hand Skin Tone tones the hand holding the flare (MODELDEF.txt).
//
// NETPLAY, the series' way: the hands are read on the console player's machine only; what they decide travels as network
// events (rsqff_take, rsqff_back, rsqff_light, rsqff_at / rsqff_v / rsqff_throw, rsqff_drop). The burn, the light budget and
// everything after run from synced state on every machine.

class RSQFF_Handler : EventHandler
{
	const WIN = 7;            // tics of hand history (RSQ Grenade's / Distance Grab's window)
	const SPUTTER = 24;       // tics it sputters after the strike
	const STRIKE_HOLD = 3;    // tics a strike waits with RSQ Tactical Rig loaded (a reach to a holster is no strike)
	const PH_NONE = 0;
	const PH_UNLIT = 1;
	const PH_LIT = 2;

	// ---- synced (every machine) ----
	int phase[MAXPLAYERS];
	RSQFF_HeldLight carrier[MAXPLAYERS];
	String prevOff[MAXPLAYERS];
	int takeTic[MAXPLAYERS];
	int takeWant[MAXPLAYERS];         // a take asked for while the engine steadies the gun (level.maptime + 1), done when it lets go
	bool gripDown[MAXPLAYERS];
	int trigKeyTic[MAXPLAYERS];       // when a key bound to +oh_attack last went down with a flare out (InputProcess)
	bool trigKeyHeld[MAXPLAYERS];     // ...and whether it is still down (its key-up sent too: the grenade's release needs it)
	Vector3 throwAt[MAXPLAYERS], throwVel[MAXPLAYERS];
	Array<RSQFF_Burner> lit;          // every burning flare, oldest first (the light budget)
	int lightsPeak;

	// ---- the console player's hands (local) ----
	private transient bool gripPrev, trigPrev;
	private transient int waitUntil, strikeQuiet, strikeAt, trigKeySeen, refusedAt;
	private transient double myBodyYaw;
	private transient bool bodyPrimed;
	private transient Vector3 lastRel[2], rawHand[2];
	private transient bool primed[2], framePrimed, wasSame;
	private transient double frameYaw, lastAngle, lastHandYaw[2];
	private transient int quietTics;
	private transient Vector3 samples[2 * WIN];
	private transient int sampleAt[2];
	// ui: the grip arrives as raw key events
	private ui Array<int> keysOff;
	private ui String keysFrom;
	private ui bool keyState;
	private ui bool trigKeyState;     // the +oh_attack key as this machine last sent it

	static RSQFF_Handler Get() { return RSQFF_Handler(EventHandler.Find("RSQFF_Handler")); }

	static bool On() { let c = CVar.FindCVar("rsqff_on"); return !c || c.GetBool(); }
	static bool PFlag(PlayerInfo p, String n, bool d) { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }
	static double PNum(PlayerInfo p, String n, double d) { let c = CVar.GetCVar(n, p); return c ? c.GetFloat() : d; }
	static double SNum(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool Debug(PlayerInfo p) { return p && PFlag(p, "rsqff_debug", false); }

	static bool IsLit(int n)
	{
		let h = Get();
		return h && n >= 0 && n < MAXPLAYERS && h.phase[n] == PH_LIT;
	}

	static int BurnTics() { return int(clamp(SNum("rsqff_burn", 60), 5, 900) * TICRATE); }

	// ================================================================ input (ui)
	// The off-hand grip as raw keys (RSQ Tactical Rig's way): QuestZDoom sends it as KEY_PAD_RTHUMB (443), or
	// KEY_PAD_DPAD_UP (436) while the main grip is held as a shift. Never eaten.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		// THE OFF-HAND TRIGGER AS A KEY TOO (torch.zs's way, 11-05): BD22 VR's own off hand can clear it from the command,
		// and a tap shorter than a tic never reaches it, so the key going down counts as well (a flare out only)
		// 11-05 05:14: its key-UP is sent as well, so letting go of the trigger is seen even when the command never held it
		if (consoleplayer >= 0 && consoleplayer < MAXPLAYERS)
		{
			bool kd = e.Type == InputEvent.Type_KeyDown;
			if ((kd && phase[consoleplayer] != PH_NONE) || (!kd && trigKeyState))
			{
				String b = Bindings.GetBinding(e.KeyScan);
				if (b.MakeLower().IndexOf("+oh_attack") >= 0)
				{
					trigKeyState = kd;
					EventHandler.SendNetworkEvent("rsqff_tkey", kd ? 1 : 0);
				}
			}
		}
		let me = players[consoleplayer];
		let cv = CVar.GetCVar("rsqff_keys_off", me);
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
		if (down == keyState) return false;
		keyState = down;
		EventHandler.SendNetworkEvent("rsqff_grip", down ? 1 : 0);
		return false;
	}

	// a menu opened with the trigger key down never sees its key-up: let it go here, so the hold is never stuck
	override void UiTick()
	{
		if (trigKeyState && menuactive != Menu.Off) { trigKeyState = false; EventHandler.SendNetworkEvent("rsqff_tkey", 0); }
	}

	// ================================================================ events (every machine)
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		if (e.Name == "rsqff_grip") { gripDown[n] = e.Args[0] != 0; return; }
		if (e.Name == "rsqff_tkey") { trigKeyHeld[n] = e.Args[0] != 0; if (trigKeyHeld[n]) trigKeyTic[n] = level.maptime; return; }
		if (e.Name == "rsqff_take") { takeWant[n] = level.maptime + 1; return; }
		if (e.Name == "rsqff_back") { Back(pmo, n, true); return; }
		if (e.Name == "rsqff_light") { Light(pmo, n, e.Args[0]); return; }
		if (e.Name == "rsqff_at") { throwAt[n] = (e.Args[0], e.Args[1], e.Args[2]) / 8.0; return; }
		if (e.Name == "rsqff_v") { throwVel[n] = (e.Args[0], e.Args[1], e.Args[2]) / 100.0; return; }
		if (e.Name == "rsqff_throw") { Release(pmo, n, throwAt[n], throwVel[n], e.Args[0] / 100.0, "thrown"); return; }
	}

	// the flare into the off hand (one from the pocket)
	private void Take(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		if (phase[n] != PH_NONE || pmo.health <= 0 || pmo.CountInv("RSQFF_Ammo") <= 0) return;
		let cur = p.OffhandWeapon;
		prevOff[n] = (cur && !(cur is "RSQFF_Held")) ? String.Format("%s", cur.GetClassName()) : "";
		pmo.TakeInventory("RSQFF_Ammo", 1);
		let w = Weapon(pmo.FindInventory("RSQFF_Held"));
		if (!w) { pmo.GiveInventory("RSQFF_Held", 1); w = Weapon(pmo.FindInventory("RSQFF_Held")); }
		if (!w) return;
		RaiseOff(p, w);
		phase[n] = PH_UNLIT;
		takeTic[n] = level.maptime;
		pmo.A_StartSound("rsqff/take", CHAN_AUTO, CHANF_LOCAL, 0.5);
		RSQFF_Buzzer.Start(pmo, 1, 0.25, 3);
		if (Debug(p)) Console.Printf("RSQFF take t%d: a flare in the off hand (had %s), %d left in the pocket", level.maptime, prevOff[n] == "" ? "nothing" : prevOff[n], pmo.CountInv("RSQFF_Ammo"));
	}

	// an unlit flare back in the pocket (refund); the off hand gets back what it had
	private void Back(PlayerPawn pmo, int n, bool sound)
	{
		if (phase[n] != PH_UNLIT) return;
		phase[n] = PH_NONE;
		pmo.GiveInventory("RSQFF_Ammo", 1);
		OffBack(pmo, n);
		if (sound) pmo.A_StartSound("rsqff/take", CHAN_AUTO, CHANF_LOCAL, 0.5);
		if (Debug(pmo.player)) Console.Printf("RSQFF back t%d: in the pocket again (%d)", level.maptime, pmo.CountInv("RSQFF_Ammo"));
	}

	private void Light(PlayerPawn pmo, int n, int how)
	{
		if (phase[n] != PH_UNLIT) return;
		phase[n] = PH_LIT;
		let c = RSQFF_HeldLight(Actor.Spawn("RSQFF_HeldLight", RSQFF_Geo.Tip(pmo)));
		if (c)
		{
			c.held = true;
			c.target = pmo;
			c.Ignite(BurnTics(), SPUTTER);
			lit.Push(c);
		}
		carrier[n] = c;
		if (SNum("rsqff_sound", 1) > 0) pmo.A_StartSound("rsqff/strike", CHAN_AUTO, 0, 0.8);
		RSQFF_Buzzer.Start(pmo, 1, 0.6, 6);
		if (Debug(pmo.player)) Console.Printf("RSQFF light t%d: struck by %s, burns %d s", level.maptime, how == 1 ? "the trigger" : "a flick", BurnTics() / TICRATE);
	}

	// a lit flare leaves the hand: thrown, dropped, or let fall when the hand is taken; it burns on as RSQFF_Flare
	private void Release(PlayerPawn pmo, int n, Vector3 at, Vector3 v, double ms, String why)
	{
		if (phase[n] != PH_LIT) return;
		phase[n] = PH_NONE;
		let c = carrier[n];
		carrier[n] = null;
		// RSQ Grenade hand.zs Throw: a hand never further than an arm's length, and a hand through a wall leaves from where
		// the wall stops it (a missile ignores the player who threw it, so starting inside the player is fine)
		Vector3 mid = pmo.Pos + (0, 0, pmo.Height * 0.6);
		if ((at - mid).Length() > 96) at = mid;
		Vector3 dv = at - mid;
		double dl = dv.Length();
		if (dl > 0.5)
		{
			FLineTraceData tr;
			pmo.LineTrace(VectorAngle(dv.x, dv.y), dl, -atan2(dv.z, dv.xy.Length()), TRF_THRUACTORS, mid.z - pmo.pos.z, 0, 0, tr);
			if (tr.HitType != TRACE_HitNone && tr.Distance < dl) at = mid + dv / dl * max(0, tr.Distance - 4);
		}
		let f = RSQFF_Flare(Actor.Spawn("RSQFF_Flare", at, NO_REPLACE));
		if (f)
		{
			f.target = pmo;
			f.ownerNum = n;
			f.vel = v;
			Vector3 ax = RSQFF_Geo.InVR(pmo) ? RSQFF_Geo.Axis(pmo) : (cos(pmo.angle), sin(pmo.angle), 0);
			f.angle = atan2(ax.y, ax.x);
			f.pitch = -asin(clamp(ax.z, -1, 1));
			if (c) { f.TakeOver(c); if (c.spent) f.Spend(); }
			else f.Ignite(BurnTics(), 0);
			int k = c ? lit.Find(c) : lit.Size();
			if (k < lit.Size()) lit[k] = f; else lit.Push(f);
		}
		if (c) c.Destroy();
		OffBack(pmo, n);
		if (ms > 0) RSQFF_Buzzer.Start(pmo, 1, 0.4, 4);
		if (Debug(pmo.player)) Console.Printf("RSQFF %s t%d at (%.0f %.0f %.0f), %.2f m/s, vel (%.1f %.1f %.1f) a tic", why, level.maptime, at.x, at.y, at.z, ms, v.x, v.y, v.z);
	}

	// An off-hand weapon up into the off hand NOW, as the engine's BringUpWeapon does it (RSQ Tactical Rig cig.zs RaiseOff).
	static void RaiseOff(PlayerInfo p, Weapon w)
	{
		if (!w || !w.bOffhandWeapon || p.OffhandWeapon == w) return;
		p.OffhandWeapon = w;
		let psp = p.GetPSprite(PSP_OFFHANDWEAPON);
		if (psp) psp.y = WEAPONBOTTOM;
		p.SetPsprite(PSP_OFFHANDWEAPON, w.GetUpState());
	}

	// the off hand gets back what it had before the flare: that weapon, else Brutal Doom 22 VR's empty hands (RSQ_Hands,
	// by name), else nothing (plain Doom has no off-hand fist)
	private void OffBack(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		bool ours = p.OffhandWeapon is "RSQFF_Held";
		if (!ours && p.OffhandWeapon) { prevOff[n] = ""; return; }   // something else took the hand already: it stays
		p.SetPSprite(RSQFF_Held.EMBER, null);
		Weapon want = null;
		class<Weapon> pc = prevOff[n];
		if (pc) want = Weapon(pmo.FindInventory(pc));
		if (!want)
		{
			String hn = "RSQ_Hands";      // a String: a quoted class name would be resolved when the script compiles
			class<Weapon> hc = hn;
			if (hc) want = Weapon(pmo.FindInventory(hc));
		}
		prevOff[n] = "";
		if (want && want.bOffhandWeapon) { p.OffhandWeapon = null; RaiseOff(p, want); return; }
		p.SetPsprite(PSP_OFFHANDWEAPON, null);
		p.OffhandWeapon = null;
	}

	// ================================================================ every tic
	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			Keep(players[n].mo, n);
		}
		Budget();
		let me = players[consoleplayer];
		if (me && me.mo && On()) Hands(me.mo);
	}

	// the held flare's state against what the hand really holds; the light kept at the drawn burning end
	private void Keep(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		// THE TAKE WAITS FOR THE ENGINE'S TWO-HAND STEADYING: the off grip with the hands under 0.5 m apart (the pocket is
		// across the chest, near the gun hand) latches it on the grip's rising edge (QuestZDoom VrInputDefault.cpp) and
		// hides whatever the off hand holds until the grip is let go (hw_weapon.cpp); an off-hand weapon raised meanwhile
		// can arrive invisible (RSQ Tactical Rig's finding). So the flare comes up the tic the grip lets go (2 s at most).
		if (takeWant[n] > 0)
		{
			if (level.maptime - takeWant[n] > 2 * TICRATE) takeWant[n] = 0;
			else if ((p.WeaponState & WF_TWOHANDSTABILIZED) == 0) { takeWant[n] = 0; Take(pmo, n); }
		}
		if (phase[n] == PH_NONE)
		{
			// a flare left in the off hand with no state (a level change, a load from before): out of the hand, refunded
			if (p.OffhandWeapon is "RSQFF_Held") { phase[n] = PH_UNLIT; Back(pmo, n, false); }
			return;
		}
		bool inHand = p.OffhandWeapon is "RSQFF_Held";
		bool gone = !inHand || pmo.health <= 0 || !On();
		if (gone)
		{
			if (phase[n] == PH_UNLIT) Back(pmo, n, false);
			else Release(pmo, n, carrier[n] ? carrier[n].pos : pmo.pos + (0, 0, pmo.height * 0.5), pmo.vel, 0, "let fall");
			return;
		}
		if (phase[n] != PH_LIT) return;
		let c = carrier[n];
		if (!c) { phase[n] = PH_NONE; OffBack(pmo, n); return; }
		if (RSQFF_Geo.InVR(pmo)) c.SetOrigin(RSQFF_Geo.Tip(pmo), true);
		else c.SetOrigin(pmo.Vec3Angle(12, pmo.angle - 25, pmo.height * 0.6), true);
		// burnt out in the hand: the spent flare falls
		if (c.spent) Release(pmo, n, c.pos, pmo.vel, 0, "burnt out in the hand");
	}

	// THE LIGHT BUDGET: at most rsqff_cap flares give light at once. One more lit: the oldest lying flare goes dark (over
	// half a second) and burns on as flame and sparks only; a flare in a hand is the last to go dark. One burns out: the
	// one that went dark last lights again.
	private void Budget()
	{
		int cap = clamp(int(SNum("rsqff_cap", 3)), 0, 32);
		int live = 0;
		for (int i = lit.Size() - 1; i >= 0; i--)
		{
			let b = lit[i];
			if (!b || b.bDestroyed || b.spent) { lit.Delete(i); continue; }
			if (!b.dark) live++;
		}
		while (live > cap)
		{
			int pick = -1;
			for (int i = 0; i < lit.Size() && pick < 0; i++) if (!lit[i].dark && !lit[i].held) pick = i;
			for (int i = 0; i < lit.Size() && pick < 0; i++) if (!lit[i].dark) pick = i;
			if (pick < 0) break;
			lit[pick].GoDark();
			live--;
			let me = players[consoleplayer];
			if (Debug(me)) Console.Printf("RSQFF budget t%d: cap %d, the oldest (lit t%d) goes dark", level.maptime, cap, lit[pick].litTic);
		}
		// a light freed (one burnt out): the flare that went dark last gets its light back
		while (live < cap)
		{
			int pick = -1;
			for (int i = lit.Size() - 1; i >= 0 && pick < 0; i--) if (lit[i].dark) pick = i;
			if (pick < 0) break;
			lit[pick].dark = false;
			lit[pick].darkFade = 0;
			live++;
		}
		lightsPeak = max(lightsPeak, live);
		let me = players[consoleplayer];
		if (Debug(me) && level.maptime % TICRATE == 0 && lit.Size() > 0)
		{
			int on = 0;
			for (int i = 0; i < lit.Size(); i++) if (lit[i].lightOn) on++;
			Console.Printf("RSQFF lights t%d: %d burning, %d giving light (cap %d, radius %d%s), peak %d", level.maptime, lit.Size(), on, cap,
				int(SNum("rsqff_radius", 140)), SNum("rsqff_subdued", 0) > 0 ? " subdued" : "", lightsPeak);
		}
	}

	// ================================================================ the console player's hands
	private void Hands(PlayerPawn pmo)
	{
		let p = pmo.player;
		int n = consoleplayer;
		Sample(pmo);
		bool grip = gripDown[n];
		bool gripEdge = grip && !gripPrev;
		bool gripUp = !grip && gripPrev;
		gripPrev = grip;
		// the command's button OR the original command's (BD22 VR's off hand can clear it from cmd), or the key itself
		bool cmdTrig = ((p.cmd.buttons | p.original_cmd.buttons) & BT_OFFHANDATTACK) != 0;
		bool trig = cmdTrig || trigKeyHeld[n];
		bool trigEdge = trig && !trigPrev;
		bool trigUp = !trig && trigPrev;      // RSQ Grenade hand.zs:648: the hold let go
		trigPrev = trig;
		bool tkey = trigKeyTic[n] != trigKeySeen && trigKeyTic[n] >= level.maptime - 1;
		trigKeySeen = trigKeyTic[n];
		if (tkey && !trigEdge && trigPrev) tkey = false;  // the command or the key already held it: the same press
		trigEdge = trigEdge || tkey;
		if (!RSQFF_Geo.InVR(pmo) || pmo.health <= 0) return;
		if (level.maptime < waitUntil) return;
		bool dbg = Debug(p);

		double by = BodyYaw(pmo);
		Vector3 pk = RSQFF_Geo.Pocket(pmo, by);
		double d = RSQFF_Geo.Metres(pmo, RSQFF_Geo.Pos(pmo, 1) - pk);
		bool inRig = RigHasHand(pmo);
		bool nearPocket = d <= clamp(PNum(p, "rsqff_pocket_r", 0.11), 0.04, 0.4);
		bool atPocket = nearPocket && !inRig;

		if (phase[n] == PH_NONE)
		{
			strikeAt = 0;
			if (gripEdge && atPocket)
			{
				if (pmo.CountInv("RSQFF_Ammo") > 0) { Send("rsqff_take"); Wait(6); }
				else
				{
					pmo.A_Print("No flares left", 1);
					if (dbg) Console.Printf("RSQFF take t%d: the pocket is empty", level.maptime);
				}
			}
			else if (gripEdge && dbg) Console.Printf("RSQFF grip t%d: off hand %.2f m from the pocket (needs %.2f)%s", level.maptime, d, PNum(p, "rsqff_pocket_r", 0.11), RigHasHand(pmo) ? ", in a Tactical Rig place" : "");
			return;
		}

		double ms; Vector3 v;
		[ms, v] = Peak(pmo, 1);

		if (phase[n] == PH_UNLIT)
		{
			if (gripEdge && atPocket) { Send("rsqff_back"); Wait(6); return; }
			int by_ = clamp(int(PNum(p, "rsqff_light_by", 2)), 0, 2);
			if (by_ != 0 && trigEdge) { strikeAt = 0; Send("rsqff_light", 1); Wait(4); ClearSamples(); return; }
			// A REACH DOWN TO A HOLSTER IS NO STRIKE (11-03, RSQ Tactical Rig's flare holster on the hip): an unlit flare
			// carried down to the hip to put it back is a fast downward move, and on the rig it read as a 12 m/s strike
			// and lit the flare on its way in. With the rig loaded a strike waits STRIKE_HOLD tics; if the off hand is in
			// one of the rig's places by then (or during), it was a reach, not a strike: dropped, and strikes are ignored
			// for the hand-history window after (WIN), so the same move is not read again. Without the rig: at once.
			bool rig = RigLoaded();
			if (strikeAt > 0 && RigHasHand(pmo))
			{
				strikeAt = 0;
				strikeQuiet = level.maptime + WIN;
				if (dbg) Console.Printf("RSQFF strike t%d: not a strike, the hand went into a Tactical Rig place", level.maptime);
			}
			if (strikeAt > 0 && level.maptime >= strikeAt) { strikeAt = 0; Send("rsqff_light", 0); Wait(4); ClearSamples(); return; }
			if (by_ != 1 && level.maptime - takeTic[n] > 8 && strikeAt <= 0 && level.maptime >= strikeQuiet)
			{
				// the strike: the fastest recent swing mostly DOWN and fast enough
				double down = -v.z * RSQFF_Geo.Ps(pmo) / RSQFF_Geo.Vu() * TICRATE;
				double need = clamp(PNum(p, "rsqff_strike", 1.4), 0.5, 6.0);
				if (down >= need && down >= 0.6 * ms)
				{
					if (dbg) Console.Printf("RSQFF strike t%d: %.2f m/s down (%.2f m/s in all, needs %.2f down)%s", level.maptime, down, ms, need, rig ? ", lit in a moment unless it was a reach to a holster" : "");
					if (rig && RigHasHand(pmo)) { strikeQuiet = level.maptime + WIN; if (dbg) Console.Printf("RSQFF strike t%d: not a strike, the hand is in a Tactical Rig place", level.maptime); }
					else if (rig) strikeAt = level.maptime + STRIKE_HOLD;
					else { Send("rsqff_light", 0); Wait(4); ClearSamples(); }
				}
			}
			return;
		}
		strikeAt = 0;

		// LIT. THE THROW IS RSQ GRENADE'S (hand.zs:709-727; owner 11-05 05:14: "still cannot throw flare, needs to throw like
		// grenade does"). The cause it fixes: until now only a trigger PRESS while swinging threw (and a grip); the press
		// comes as the swing starts, with the hand still slow, so it was "no throw", and the LET-GO a grenade throws on was
		// never read at all. Now, as the grenade: the flare hand's trigger is your hold on it; let go of it while the hand
		// moves at rsqff_swing or more and it is thrown at the swing's speed and direction (the fastest 2-tic window of the
		// last 7 tics, measured against the body: Sample / Peak below), with the grenade's launch (LaunchVel); let go with
		// the hand still and it stays in your hand (the grenade cooks there; a flare is already burning). A trigger press
		// does nothing more (the grenade's squeeze). This path asks nothing of the pocket or the Tactical Rig: a let-go
		// trigger is a throw wherever the hand is, as the grenade's is.
		double need = clamp(PNum(p, "rsqff_swing", 2.0), 0.5, 8.0);
		Vector3 at = RSQFF_Geo.Tip(pmo) - RSQFF_Geo.Axis(pmo) * 4.0;
		if (trigUp)
		{
			if (dbg) Console.Printf("RSQFF release t%d: swing %.2f m/s (throws from %.2f)", level.maptime, ms, need);
			if (ms >= need)
			{
				SendThrow(at, LaunchVel(pmo, v), ms);
				Wait(6);
			}
			return;
		}
		// THE TRIGGER ONLY (owner 11-06: "Trigger only", exactly like the grenade): the grip does nothing to a lit flare --
		// no throw, no drop. Until 11-06 a grip press with the hand still dropped it at your feet, and a hand closing round
		// the flare to wind up does exactly that, so the trigger's let-go never had a flare to throw. A lit flare leaves
		// the hand by a throw, burning out, or something else taking the hand (death, a new level, another off-hand
		// weapon: it falls burning). It is never put away (owner 11-05).
	}

	// WHAT LEAVES THE HAND for a hand velocity v (map units a tic): RSQ Grenade hand.zs LaunchVel (RS_Grenade's flight),
	// without its Gun Bonsai VR nodes: the hand's own velocity times Throw Strength, a lift of Arc times its speed across
	// the ground (a hard throw arcs more than a gentle one), and the run you were in carried on with it.
	static Vector3 LaunchVel(PlayerPawn pmo, Vector3 v)
	{
		let p = pmo.player;
		Vector3 tv = v * clamp(PNum(p, "rsqff_throw", 1.0), 0.2, 4.0);
		tv.z += tv.xy.Length() * clamp(PNum(p, "rsqff_lift", 0.35), 0.0, 1.5);
		return tv + pmo.vel;
	}

	private void Send(String nm, int a = 0) { EventHandler.SendNetworkEvent(nm, a); }
	private void Wait(int tics) { waitUntil = level.maptime + tics; }

	private void SendThrow(Vector3 at, Vector3 tv, double ms)
	{
		EventHandler.SendNetworkEvent("rsqff_at", int(at.x * 8), int(at.y * 8), int(at.z * 8));
		EventHandler.SendNetworkEvent("rsqff_v", int(tv.x * 100), int(tv.y * 100), int(tv.z * 100));
		EventHandler.SendNetworkEvent("rsqff_throw", int(ms * 100));
	}

	private bool RigLoaded() { return ServiceIterator.Find("RSQTR_RigService").Next() != null; }

	// RSQ Tactical Rig's off hand in one of its places: the grip is the rig's (asked by name; 0 without the rig)
	private bool RigHasHand(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service s;
		while (s = it.Next()) if (s.GetInt("rig.region", "", 1, 0, pmo) >= 0) return true;
		return false;
	}

	// THE BODY'S YAW: RSQ Tactical Rig's body when it is loaded (so the pocket turns with its holsters); else our own:
	// it turns with every snap or stick turn (the tracking space's yaw, measured by the sampler below) and eases under the
	// head while you look ahead, never while you look down at your chest.
	private double BodyYaw(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_BodyService");
		Service s;
		while (s = it.Next())
		{
			double y = s.GetDouble("body.yaw", "", 0, 0, pmo);
			if (y != 999) return y;
		}
		if (!bodyPrimed) { myBodyYaw = pmo.angle; bodyPrimed = true; }
		if (pmo.pitch < 20) myBodyYaw += Actor.DeltaAngle(myBodyYaw, pmo.angle) * 0.04;
		return myBodyYaw;
	}
	// THE YAW THE POCKET IS DRAWN AT (stowed.zs, Show Flare): the body BodyYaw last gave for the console player (no easing
	// step here); another player's: the rig's body when it is loaded, else where he faces
	double ShownYaw(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_BodyService");
		Service s;
		while (s = it.Next())
		{
			double y = s.GetDouble("body.yaw", "", 0, 0, pmo);
			if (y != 999) return y;
		}
		return (pmo.player == players[consoleplayer] && bodyPrimed) ? myBodyYaw : pmo.angle;
	}

	// ================================================================ the hand's speed (RSQ Grenade hand.zs Sample / Peak)
	// Each tic the hand's step relative to the pawn, in the tracking space's frame (snap and stick turns turn the pawn AND
	// both hands' yaws together; a head turn turns the pawn alone), so walking and turning are no swing.
	private void Sample(PlayerPawn pmo)
	{
		bool same = pmo.AttackPos == pmo.OffhandPos && pmo.AttackAngle == pmo.OffhandAngle && pmo.AttackPitch == pmo.OffhandPitch;
		bool collapsed = same && !wasSame;
		wasSame = same;
		double ang = pmo.Angle;
		double hy0 = pmo.AttackAngle, hy1 = pmo.OffhandAngle;
		if (framePrimed)
		{
			double dA = Actor.Normalize180(ang - lastAngle);
			double d0 = Actor.Normalize180(hy0 - lastHandYaw[0]);
			double d1 = Actor.Normalize180(hy1 - lastHandYaw[1]);
			bool followed = abs(d0 - dA) < 1.5 && abs(d1 - dA) < 1.5;
			if (abs(dA) > 0.01 && followed)
			{
				frameYaw = Actor.Normalize180(frameYaw + dA);
				myBodyYaw += dA;     // our own body turns with the tracking space
			}
			if (abs(dA) > 0.5 && !followed) quietTics = 2;
		}
		else { frameYaw = ang; framePrimed = true; }
		lastAngle = ang;
		lastHandYaw[0] = hy0;
		lastHandYaw[1] = hy1;
		for (int h = 0; h < 2; h++)
		{
			// 11-05: the frame's hand carried to where the body is this tic, against the body at the view's height
			// (RSQFF_HandSync, tools/handsync; PCVR-aware: OpenVR hangs the hands off the frame's eye), as Distance Grab and
			// RSQ Melee measure a swing. The raw field still tells a frame with no new pose (stale).
			Vector3 raw = RSQFF_Geo.Pos(pmo, h);
			bool stale = raw == rawHand[h];
			rawHand[h] = raw;
			Vector3 now = RSQFF_HandSync.Fix(pmo, raw, h);
			if (stale && !collapsed)
			{
				samples[h * WIN + sampleAt[h]] = (0, 0, 0);
				sampleAt[h] = (sampleAt[h] + 1) % WIN;
				continue;
			}
			Vector3 off = now - RSQFF_HandSync.Body(pmo);
			Vector2 flat = Actor.RotateVector(off.xy, -frameYaw);
			Vector3 rel = (flat.x, flat.y, off.z);
			Vector3 step = rel - lastRel[h];
			bool good = primed[h] && !same && quietTics <= 0 && RSQFF_Geo.Metres(pmo, step) < 1.0;
			samples[h * WIN + sampleAt[h]] = good ? step : (0, 0, 0);
			sampleAt[h] = (sampleAt[h] + 1) % WIN;
			lastRel[h] = rel;
			primed[h] = !collapsed;
		}
		if (quietTics > 0) quietTics--;
	}

	// the off hand's history forgotten (the strike's flick is no throw: a grip let go just after lighting read it as one)
	private void ClearSamples() { for (int i = 0; i < WIN; i++) samples[WIN + i] = (0, 0, 0); }

	private double, Vector3 Peak(PlayerPawn pmo, int h)
	{
		Vector3 best = (0, 0, 0);
		double bestM = 0;
		for (int i = 0; i < WIN; i++)
		{
			if (i == sampleAt[h]) continue;
			int j = (i + WIN - 1) % WIN;
			Vector3 v = (samples[h * WIN + i] + samples[h * WIN + j]) * 0.5;
			double m = RSQFF_Geo.Metres(pmo, v);
			if (m > bestM) { bestM = m; best = v; }
		}
		Vector2 w = Actor.RotateVector(best.xy, frameYaw);
		return bestM * TICRATE, (w.x, w.y, best.z);
	}

	// ================================================================ start, pocket, boxes
	override void PlayerEntered(PlayerEvent e) { Equip(e.PlayerNumber, false); }
	override void PlayerRespawned(PlayerEvent e) { Equip(e.PlayerNumber, true); }

	// START WITH: at a new game, and after a death. A death without netplay restarts the map with a new player whose inventory
	// is the class's own (RSQFF_Given goes too), so PlayerEntered fills the pocket again (rig, 11-03: 1 left, died with Start
	// With set to 3, back to 3; the owner, 11-03 20:38: "flares come back after death"). A respawn in place (netplay, or a map
	// that allows it) may keep RSQFF_Given, so PlayerRespawned fills it too.
	private void Equip(int n, bool respawn)
	{
		Migrate();
		let pmo = players[n].mo;
		if (!pmo || !On()) return;
		bool first = !pmo.FindInventory("RSQFF_Given");
		if (!first && !respawn) return;
		if (first) pmo.GiveInventory("RSQFF_Given", 1);
		int want = clamp(int(SNum("rsqff_start", 2)), 0, 24);
		if (pmo.CountInv("RSQFF_Ammo") < want) pmo.SetInventory("RSQFF_Ammo", want);
	}

	// SETTINGS VERSION (rsqff_cfgver, the series' way: RSQ Tactical Rig's rsqtr_cfgver, the Wheel's wr_cfgver). A saved
	// setting outlives a new default, so one still at its OLD default is moved to the new one, once.
	//   1 (owner 11-03 20:26: "start with 2"): Start With 4 -> 2.
	//   2 (owner 11-05 05:14: "needs to throw like grenade does"): RSQ Grenade's throw numbers, Throw Strength 1.25 -> 1.0,
	//     Arc 0.25 -> 0.35.
	const CFG_VERSION = 2;
	private transient bool migrated;
	private void Migrate()
	{
		if (migrated) return;
		migrated = true;
		let ver = CVar.FindCVar("rsqff_cfgver");
		if (!ver || ver.GetInt() >= CFG_VERSION) return;
		if (ver.GetInt() < 1)
		{
			let st = CVar.FindCVar("rsqff_start");
			if (st && st.GetInt() == 4) st.SetInt(2);
		}
		if (ver.GetInt() < 2)
		{
			let th = CVar.FindCVar("rsqff_throw");
			if (th && abs(th.GetFloat() - 1.25) < 0.001) th.SetFloat(1.0);
			let li = CVar.FindCVar("rsqff_lift");
			if (li && abs(li.GetFloat() - 0.25) < 0.001) li.SetFloat(0.35);
		}
		ver.SetInt(CFG_VERSION);
	}

	override void WorldLoaded(WorldEvent e)
	{
		Migrate();
		if (e.IsSaveGame || e.IsReopen || !On()) return;
		// THE POCKET (rsqff_pocket, off): topped up at each new level
		if (SNum("rsqff_pocket", 0) > 0)
		{
			int want = clamp(int(SNum("rsqff_pocket_n", 4)), 1, 24);
			for (int n = 0; n < MAXPLAYERS; n++)
				if (playeringame[n] && players[n].mo && players[n].mo.CountInv("RSQFF_Ammo") < want) players[n].mo.SetInventory("RSQFF_Ammo", want);
		}
		Scatter();
	}

	// BOXES IN THE LEVELS, saegiru's way (the UAC Survival Pack's randomuac.acs, parsed: beside each item lying in the
	// level a roll of random(0, 125); 0-5 drops a box of flares, up to uac_flareamt a map), once per new map. The box
	// lies 15 units to the item's south (the pack's y - 15), or on the item if that spot is in a wall. Deterministic in
	// netplay (the same items, the same synced random table). Not on a save or a revisited hub map.
	private void Scatter()
	{
		if (SNum("rsqff_scatter", 1) <= 0) return;
		int cap = clamp(int(SNum("rsqff_boxes", 2)), 0, 16);
		Array<Inventory> items;
		let it = ThinkerIterator.Create("Inventory");
		Inventory i;
		while (i = Inventory(it.Next())) if (!i.Owner && i.bSpecial && !(i is "RSQFF_Ammo")) items.Push(i);
		int got = 0;
		for (int j = 0; j < items.Size() && got < cap; j++)
		{
			if (random[RSQFF_Scatter](0, 125) > 5) continue;
			let a = Actor.Spawn("RSQFF_Box", items[j].pos + (0, -15, 0), ALLOW_REPLACE);
			if (!a) continue;
			if (!a.TestMobjLocation()) a.SetOrigin(items[j].pos, false);
			a.angle = random[RSQFF_Scatter](0, 359);
			got++;
		}
		let me = players[consoleplayer];
		if (Debug(me)) Console.Printf("RSQFF scatter %s: %d items rolled, %d boxes of flares (cap %d)", level.MapName, items.Size(), got, cap);
	}
}

// WHAT FnF IS DOING, FOR ANY MOD THAT ASKS BY NAME (RSQ Tactical Rig's flare holster, 11-03). intArg: the player.
//   GetInt("flare.phase", "", player)   the flare in that player's off hand: 0 none, 1 unlit, 2 lit (-1 FnF off)
//   GetInt("flare.count", "", player)   flares carried (the pocket's, which the rig's flare holster shares)
// To take one or put an unlit one back, send FnF's own network events "rsqff_take" / "rsqff_back" (the rig does): they
// do exactly what a grip at the pocket does, from the same synced state on every machine.
// WHERE FnF's GRAB ZONES ARE (RSQ Tactical Rig draws its holster sphere there, owner 11-04 19:07). objectArg: the pawn,
// doubleArg: the body's yaw to hang them by (the asker's; FnF follows the rig's body anyway).
//   GetDouble("pocket.x" / ".y" / ".z", "", 0, yaw, pawn)  the flare pocket's centre, map units; ".r" its grab radius in
//   metres (rsqff_pocket_r). "clip.*" the same for the flashlight clip (rsqff_fl_clip_r). 1e9 when that zone is off
//   (FnF off, Flashlight off) or the pawn is not in VR.
class RSQFF_Service : Service
{
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let pmo = PlayerPawn(objectArg);
		if (!pmo || !RSQFF_Geo.InVR(pmo) || request.Length() < 3) return 1e9;
		String axis = request.Mid(request.Length() - 1);
		String zone = request.Left(request.Length() - 2);
		Vector3 at;
		double r;
		if (zone == "pocket")
		{
			if (!RSQFF_Handler.On()) return 1e9;
			at = RSQFF_Geo.Pocket(pmo, doubleArg);
			r = clamp(RSQFF_Handler.PNum(pmo.player, "rsqff_pocket_r", 0.11), 0.04, 0.4);
		}
		else if (zone == "clip")
		{
			if (!RSQFF_Torches.FlOn()) return 1e9;
			at = RSQFF_Torches.Clip(pmo, doubleArg);
			r = clamp(RSQFF_Torches.LNum("rsqff_fl_clip_r", 0.12), 0.04, 0.4);
		}
		else return 1e9;
		if (axis == "x") return at.x;
		if (axis == "y") return at.y;
		if (axis == "z") return at.z;
		if (axis == "r") return r;
		return 1e9;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// RSQ Distance Grab threw a flare into a monster (its throw.zs Strike, which did the impact's damage itself): the
		// monster is the flare's tracer, intArg the thrower. FnF only sets it on fire (fire.zs: Brutal Doom, the kinds that burn).
		if (request == "flare.hit")
		{
			let f = RSQFF_Flare(objectArg);
			if (!f || !f.tracer) return 0;
			Actor src = (intArg >= 0 && intArg < MAXPLAYERS && playeringame[intArg]) ? players[intArg].mo : null;
			RSQFF_Fire.Hit(f, f.tracer, src, false, !f.spent);
			f.tracer = null;
			return 1;
		}
		if (intArg < 0 || intArg >= MAXPLAYERS || !playeringame[intArg] || !players[intArg].mo) return -1;
		if (request == "flare.count") return players[intArg].mo.CountInv("RSQFF_Ammo");
		if (request == "flare.phase")
		{
			let h = RSQFF_Handler.Get();
			if (!h || !RSQFF_Handler.On()) return -1;
			return h.phase[intArg];
		}
		return -1;
	}
}
