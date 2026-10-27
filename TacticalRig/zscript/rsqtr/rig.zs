// RSQ_TacticalRig -- weapons carried on the body.
//
// SIX REGIONS, ONE WEAPON CLASS EACH (the owner's layout, 2026-10-26):
//   hip L, hip R          slot 2 (pistols, small arms)
//   chest diagonal        slot 3 (shotguns)
//   chest / low back      slot 4 (rifles, chainguns)
//   over L, over R shoulder  slot 5 and up (heavy weapons)
// A region holds every weapon you own of its class. Reach there and grip (or press
// Use): the one weapon comes to your hand, or, with several, a small RADIAL opens
// round your hand and you move toward the one you want and let go. Reach there
// with that class already in your hand and it goes back on the body (your hand is
// left empty: the fist).
//
// Credit: the tactical vest and the cigarette are Ermac's ideas (his Virtual
// Tactical Vest for Doom VR). This is a new implementation for stock QuestZDoom
// 17.3 that reads the real hand poses, keeps the rig on the body rather than the
// head, and carries a whole arsenal per region.
//
// NETPLAY: the hand poses exist only for the camera player, so the console player's
// machine decides (hover, press, radial) and sends one network event per ACTION;
// every machine applies it from the same inventory, so the worlds agree. Feedback
// (markers, icons, rumble, sound) is local.

class RSQTR_Region
{
	const N = 6;
	static const String NAMES[] = { "Left hip", "Right hip", "Chest", "Chest (rifle)", "Left shoulder", "Right shoulder" };

	// Defaults, metres from the head in the body frame: forward, left, up, radius.
	static const double DF[] = {  0.00,  0.00,  0.15,  0.15, -0.08, -0.08 };
	static const double DL[] = {  0.18, -0.18,  0.00,  0.00,  0.18, -0.18 };
	static const double DU[] = { -0.70, -0.70, -0.38, -0.58, -0.10, -0.10 };
	static const double DR[] = {  0.14,  0.14,  0.12,  0.12,  0.14,  0.14 };

	// Does a weapon in Doom slot s belong in region r? The two shoulders split the
	// heavy weapons, because Brutal Doom alone owns fourteen of them (measured with
	// BD22 + BD22Q, `give all`): slots 5-6 (launchers, plasma, rail) over the left,
	// slots 7 and up (BFGs, nukes, flamers) and slot 0 (grenades) over the right.
	static bool Takes(int r, int s)
	{
		switch (r)
		{
		case 0: case 1: return s == 2;
		case 2: return s == 3;
		case 3: return s == 4;
		case 4: return s == 5 || s == 6;
		default: return s >= 7 || s == 0;
		}
	}
}

class RSQTR_Rig : EventHandler
{
	const RADIAL_MAX = 10;
	const RADIAL_R = 0.10;        // metres: the ring of choices round the hand
	const RADIAL_DEAD = 0.035;    // metres: inside this nothing is picked
	const RADIAL_CANCEL = 0.30;   // metres: pull away this far and the radial closes
	const STEADY_RANGE = 0.50;    // metres: the engine's own two-hand steadying distance

	// ---- synced state (written by NetworkProcess on every machine) --------------
	bool   gripDown[MAXPLAYERS * 2];
	String lastPut[MAXPLAYERS * RSQTR_Region.N];   // the weapon last holstered there (its icon)

	// ---- local state (console player) -------------------------------------------
	private transient RSQTR_Body body;
	private transient int  hoverR[2];          // region each hand is in, -1 none
	private transient bool pressWas[2];
	private transient bool useWas;
	private transient int  radialHand, radialRegion;   // -1 when closed
	private transient Vector3 radialAt;
	private transient int  radialPick;
	private transient Array<String> radialItems;
	private transient Actor marker[6];
	private transient Actor icon[6];
	private transient Actor ricon[RADIAL_MAX];
	private transient int  buzzCool[2];
	private transient int  hoverT[2];          // tics the hand has been in its region
	private transient bool pendPress[2];       // pressed before the dwell was up
	private transient int  editHand, editRegion;   // a region being carried in edit mode
	private transient Vector3 editAt;

	// ui: the grip arrives as raw key events
	ui Array<int> keysMain, keysOff;
	ui String keysMainFrom, keysOffFrom;
	ui bool keyState[2];

	static RSQTR_Rig Get() { return RSQTR_Rig(EventHandler.Find("RSQTR_Rig")); }
	int HoverRegion(int h) const { return (h == 0 || h == 1) ? hoverR[h] : -1; }
	bool HandBusy(int h) const { return (h == 0 || h == 1) && (hoverR[h] >= 0 || radialHand == h); }

	// ---- settings ----------------------------------------------------------------
	static double Num(String n, PlayerInfo p, double d) { let c = CVar.GetCVar(n, p); return c ? c.GetFloat() : d; }
	static int Opt(String n, PlayerInfo p, int d) { let c = CVar.GetCVar(n, p); return c ? c.GetInt() : d; }
	static bool Flag(String n, PlayerInfo p, bool d) { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }

	// Where region r is, in the world, for this player.
	Vector3 RegionAt(PlayerPawn pmo, int r)
	{
		let p = pmo.player;
		double f = Num(String.Format("rsqtr_r%d_f", r), p, RSQTR_Region.DF[r]);
		double l = Num(String.Format("rsqtr_r%d_l", r), p, RSQTR_Region.DL[r]);
		double u = Num(String.Format("rsqtr_r%d_u", r), p, RSQTR_Region.DU[r]);
		if (r == 3 && Flag("rsqtr_rifle_back", p, false)) { f = -0.15; l = 0.0; u = -0.62; }
		if (editHand >= 0 && editRegion == r && pmo.player == players[consoleplayer]) return editAt;
		return BodyPoint(pmo, f, l, u);
	}

	// Any point on the body (metres, body frame): the cigarette pocket uses it too.
	// Scaled to the player: the defaults are for an eye height of 1.62 m (a ~1.75 m
	// person); after "Measure my height" every offset scales by your eye height over
	// that, so a short and a tall player both find the hips at their own hips.
	const REF_EYE = 1.62;
	static double BodyScale(PlayerInfo p)
	{
		double eye = Num("rsqtr_eye_m", p, 0);
		return eye > 0.8 ? clamp(eye / REF_EYE, 0.7, 1.3) : 1.0;
	}

	Vector3 BodyPoint(PlayerPawn pmo, double f, double l, double u)
	{
		double k = BodyScale(pmo.player);
		f *= k; l *= k; u *= k;
		if (body && body.primed) return body.At(pmo, f, l, u);
		RSQTR_Body tmp = new("RSQTR_Body");
		tmp.yaw = pmo.angle; tmp.primed = true;
		return tmp.At(pmo, f, l, u);
	}

	// The other way: a world point as body-frame metres (unscaled), for edit mode.
	void BodyOffsets(PlayerPawn pmo, Vector3 at, out double f, out double l, out double u)
	{
		double yaw = (body && body.primed) ? body.yaw : pmo.angle;
		Vector3 d = at - RSQTR_Body.Head(pmo);
		double k = BodyScale(pmo.player);
		f = (d.x * cos(yaw) + d.y * sin(yaw)) / RSQTR_Body.UPM / k;
		l = (-d.x * sin(yaw) + d.y * cos(yaw)) / RSQTR_Body.UPM / k;
		u = d.z * RSQTR_Body.PIXELSTRETCH / RSQTR_Body.UPM / k;
	}

	double RegionRadius(PlayerInfo p, int r)
	{
		return Num(String.Format("rsqtr_r%d_rad", r), p, RSQTR_Region.DR[r]) * Num("rsqtr_reach", p, 1.0) * BodyScale(p);
	}

	// ---- what the body carries ---------------------------------------------------
	// Every weapon this player owns that belongs in region r, in inventory order (the
	// same order on every machine). Off-hand utilities (the shield, the Force hand,
	// empty-hand fillers: CHEATNOTWEAPON), powered-up twins and slot-1 melee stay off.
	static void Owned(PlayerPawn pmo, int r, out Array<String> into)
	{
		into.Clear();
		if (!pmo || !pmo.player) return;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || w.bCHEATNOTWEAPON || w.bPOWERED_UP || w.bOffhandWeapon || w.Amount <= 0) continue;
			// UltraBadassQuestSaber's hilt is slot 1, but it clips to either hip
			// (rsqtr_saber_hip), found by class name so the saber need not be loaded.
			if (IsSaber(w))
			{
				if ((r == 0 || r == 1) && Flag("rsqtr_saber_hip", pmo.player, true)) into.Push(w.GetClassName());
				continue;
			}
			bool found; int slot, idx;
			[found, slot, idx] = pmo.player.weapons.LocateWeapon(w.GetClass());
			if (!found) slot = w.SlotNumber;
			if (slot < 0 || slot == 1) continue;
			if (RSQTR_Region.Takes(r, slot)) into.Push(w.GetClassName());
		}
	}

	static bool IsSaber(Weapon w)
	{
		String n = w.GetClassName();
		n = n.MakeLower();
		return n.IndexOf("ubqs_saber") == 0;
	}

	// The weapon an empty hand holds: a slot-1 weapon you own, the fist rather than
	// the chainsaw (the higher SelectionOrder: Doom picks the chainsaw first).
	// rsqtr_empty names one explicitly.
	static Weapon EmptyHand(PlayerPawn pmo)
	{
		String want = "";
		let cv = CVar.GetCVar("rsqtr_empty", pmo.player);
		if (cv) want = cv.GetString();
		if (want != "")
		{
			class<Weapon> wc = want;
			if (wc) { let w = Weapon(pmo.FindInventory(wc)); if (w) return w; }
		}
		Weapon best = null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			// CHEATNOTWEAPON is allowed here: Brutal Doom's own fists (Melee_Attacks, slot 1,
			// SelectionOrder 3700) are one; otherwise the axe or the DSweap won.
			if (!w || w.bOffhandWeapon || IsSaber(w)) continue;   // the saber is not an empty hand
			bool found; int slot, idx;
			[found, slot, idx] = pmo.player.weapons.LocateWeapon(w.GetClass());
			if (!found || slot != 1) continue;
			if (!best || w.SelectionOrder > best.SelectionOrder) best = w;
		}
		return best;
	}

	// ---- input: the grips ----------------------------------------------------------
	// QuestZDoom sends the off-hand grip as KEY_PAD_RTHUMB (443), or KEY_PAD_DPAD_UP
	// (436) while the main grip is held as a shift; the main grip is a key of its own
	// (KEY_PAD_LTRIGGER, 446) only when vr_secondary_button_mappings is off. Both lists
	// are cvars, so another layout is a menu change, not a code change.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		let me = players[consoleplayer];
		Refresh("rsqtr_keys_main", "446", me, keysMain, keysMainFrom);
		Refresh("rsqtr_keys_off", "443 436", me, keysOff, keysOffFrom);
		bool down = e.Type == InputEvent.Type_KeyDown;
		for (int h = 0; h < 2; h++)
		{
			bool mine = h == 0 ? keysMain.Find(e.KeyScan) < keysMain.Size() : keysOff.Find(e.KeyScan) < keysOff.Size();
			if (!mine) continue;
			if (keyState[h] == down) continue;
			keyState[h] = down;
			EventHandler.SendNetworkEvent("rsqtr_grip", h, down ? 1 : 0);
		}
		return false;   // never eaten: the grip keeps everything else it does
	}

	private ui void Refresh(String cvn, String def, PlayerInfo me, out Array<int> keys, out String from)
	{
		let cv = CVar.GetCVar(cvn, me);
		String s = cv ? cv.GetString() : def;
		if (s == from) return;
		from = s;
		keys.Clear();
		Array<String> w;
		s.Split(w, " ", TOK_SKIPEMPTY);
		for (int i = 0; i < w.Size(); i++) keys.Push(w[i].ToInt());
	}

	// ---- actions (every machine) -----------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (e.Name == "rsqtr_grip")
		{
			int h = e.Args[0];
			if (h == 0 || h == 1) gripDown[n * 2 + h] = e.Args[1] != 0;
			return;
		}
		if (e.Name == "rsqtr_calib")
		{
			// The headset's own height above the room floor. Measured on the machine
			// that owns the headset and stored in that player's own setting.
			if (n == consoleplayer && pmo)
			{
				double eye = pmo.HmdPosition.y;
				if (eye > 0.8 && eye < 2.3)
				{
					CVar.FindCVar("rsqtr_eye_m").SetFloat(eye);     // this machine's own setting (GetCVar with a player is that player's copy)
					pmo.A_Print(String.Format("Tactical Rig: eye height %.2f m (rig scaled %.0f%%)", eye, 100 * clamp(eye / REF_EYE, 0.7, 1.3)));
				}
				else pmo.A_Print("Tactical Rig: stand up straight and try again (no headset height read)");
			}
			return;
		}
		if (!pmo || pmo.health <= 0) return;
		if (e.Name == "rsqtr_holster") Holster(pmo, e.Args[0]);
		else if (e.Name == "rsqtr_draw") Draw(pmo, e.Args[0], e.Args[1]);
	}

	// Put the main hand's weapon back on the body at region r; the hand goes empty.
	private void Holster(PlayerPawn pmo, int r)
	{
		if (r < 0 || r >= RSQTR_Region.N) return;
		let p = pmo.player;
		let w = p.ReadyWeapon;
		if (!w) return;
		Array<String> own;
		Owned(pmo, r, own);
		String cls = w.GetClassName();
		if (own.Find(cls) == own.Size()) return;   // not this region's class: refused
		let empty = EmptyHand(pmo);
		if (empty && empty != w) p.PendingWeapon = empty;
		lastPut[pmo.PlayerNumber() * RSQTR_Region.N + r] = cls;
		pmo.A_StartSound("rsqtr/holster", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// Bring the idx-th weapon of region r to the main hand.
	private void Draw(PlayerPawn pmo, int r, int idx)
	{
		if (r < 0 || r >= RSQTR_Region.N) return;
		Array<String> own;
		Owned(pmo, r, own);
		if (idx < 0 || idx >= own.Size()) return;
		class<Weapon> wc = own[idx];
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w) return;
		let p = pmo.player;
		if (p.ReadyWeapon != w) p.PendingWeapon = w;
		int slot = pmo.PlayerNumber() * RSQTR_Region.N + r;
		if (lastPut[slot] == own[idx]) lastPut[slot] = "";
		pmo.A_StartSound("rsqtr/draw", CHAN_AUTO, CHANF_LOCAL, 0.8);
	}

	// ---- the local loop (console player) ----------------------------------------------
	override void WorldTick()
	{
		if (afterLoad) { afterLoad = false; ClearLocalMarks(); }
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		if (!body) body = new("RSQTR_Body");
		body.Update(pmo);

		bool on = pmo.health > 0 && Flag("rsqtr_on", p, true);
		if (!on) { CloseRadial(); HideAll(); return; }

		int n = consoleplayer;
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		bool useEdge = useDown && !useWas;
		bool usePress = Flag("rsqtr_use", p, true);
		bool gripOk = Flag("rsqtr_grip", p, true);

		for (int h = 0; h < 2; h++)
		{
			if (buzzCool[h] > 0) buzzCool[h]--;
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			int r = -1;
			double best = 1e9;
			for (int i = 0; i < RSQTR_Region.N; i++)
			{
				if (!RegionLive(pmo, i)) continue;
				double d = RSQTR_Body.RoomMetres(hp, RegionAt(pmo, i));
				if (d <= RegionRadius(p, i) && d < best) { best = d; r = i; }
			}
			// THE ENGINE'S STEADYING IS NOT A REACH. An off hand within half a metre
			// of the gun with its grip held is holding the gun steady, not a holster.
			if (h == 1 && r >= 0 && gripDown[n * 2 + 1]
				&& RSQTR_Body.RoomMetres(pmo.OffhandPos, pmo.AttackPos) < STEADY_RANGE
				&& CVarOn("vr_two_handed_weapons"))
				r = -1;
			if (r != hoverR[h])
			{
				if (r >= 0 && buzzCool[h] <= 0) { RSQTR_Buzzer.Start(pmo, h, 0.18, 3); buzzCool[h] = 10; }
				hoverR[h] = r;
				hoverT[h] = 0;
				pendPress[h] = false;
			}
			else if (r >= 0) hoverT[h]++;

			bool gripNow = gripOk && gripDown[n * 2 + h];
			bool pressNow = gripNow || (usePress && useDown && (h == 0 || hoverR[0] < 0));
			bool edge = pressNow && !pressWas[h] && (gripNow || useEdge);
			bool release = !pressNow && pressWas[h];
			pressWas[h] = pressNow;

			// EDIT MODE (rsqtr_edit): grip in a region carries it with the hand; let go
			// and it stays there, saved to that region's settings.
			if (Flag("rsqtr_edit", p, false))
			{
				if (editHand == h)
				{
					editAt = hp;
					if (release) { SaveEdit(pmo, p); RSQTR_Buzzer.Start(pmo, h, 0.5, 5); }
				}
				else if (edge && r >= 0 && editHand < 0)
				{
					editHand = h; editRegion = r; editAt = hp;
					RSQTR_Buzzer.Start(pmo, h, 0.4, 4);
				}
				continue;
			}
			else if (editHand >= 0) editHand = -1;

			if (radialHand == h)
			{
				TickRadial(pmo, p, h, hp, release);
				continue;
			}
			// A hand passing through a region does not act on it: the press counts once
			// the hand has been there rsqtr_dwell tics (a press a moment early waits).
			int dwell = Opt("rsqtr_dwell", p, 3);
			if (edge && r >= 0) pendPress[h] = true;
			if (!pressNow) pendPress[h] = false;
			if (pendPress[h] && r >= 0 && hoverT[h] >= dwell) { pendPress[h] = false; Press(pmo, p, h, r, hp); }
		}
		useWas = useDown;
		DrawMarkers(pmo, p);
	}

	private void SaveEdit(PlayerPawn pmo, PlayerInfo p)
	{
		int r = editRegion;
		double f, l, u;
		BodyOffsets(pmo, editAt, f, l, u);
		CVar.FindCVar(String.Format("rsqtr_r%d_f", r)).SetFloat(f);
		CVar.FindCVar(String.Format("rsqtr_r%d_l", r)).SetFloat(l);
		CVar.FindCVar(String.Format("rsqtr_r%d_u", r)).SetFloat(u);
		if (r == 3) CVar.FindCVar("rsqtr_rifle_back").SetBool(false);   // a placed rifle region is where you put it
		pmo.A_Print(String.Format("%s: %.2f forward, %.2f left, %.2f up", RSQTR_Region.NAMES[r], f, l, u));
		editHand = -1; editRegion = -1;
	}

	static bool CVarOn(String name)
	{
		let cv = CVar.FindCVar(name);
		return cv && cv.GetBool();
	}

	// A region another mod has claimed right now answers here (rig.slot service,
	// hooks.zs); a claimed region is not ours to act on.
	bool RegionLive(PlayerPawn pmo, int r)
	{
		return !RSQTR_Hooks.Claimed(pmo, r);
	}

	private void Press(PlayerPawn pmo, PlayerInfo p, int h, int r, Vector3 hp)
	{
		Array<String> own;
		Owned(pmo, r, own);
		let w = p.ReadyWeapon;
		String cur = "";
		if (w) cur = w.GetClassName();
		if (cur != "" && own.Find(cur) < own.Size())
		{
			EventHandler.SendNetworkEvent("rsqtr_holster", r);
			RSQTR_Buzzer.Start(pmo, h, 0.55, 5);
			return;
		}
		if (own.Size() == 0)
		{
			RSQTR_Buzzer.Start(pmo, h, 0.12, 2);
			if (Flag("rsqtr_messages", p, false)) pmo.A_Print(String.Format("%s: nothing here", RSQTR_Region.NAMES[r]));
			return;
		}
		if (own.Size() == 1)
		{
			EventHandler.SendNetworkEvent("rsqtr_draw", r, 0);
			RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
			return;
		}
		OpenRadial(pmo, h, r, hp, own);
	}

	// ---- the radial -----------------------------------------------------------------
	private void OpenRadial(PlayerPawn pmo, int h, int r, Vector3 hp, Array<String> own)
	{
		radialHand = h; radialRegion = r; radialAt = hp; radialPick = -1;
		radialItems.Clear();
		for (int i = 0; i < own.Size() && i < RADIAL_MAX; i++) radialItems.Push(own[i]);
		pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, CHANF_LOCAL, 0.6);
		RSQTR_Buzzer.Start(pmo, h, 0.30, 3);
	}

	private void CloseRadial()
	{
		radialHand = -1; radialRegion = -1; radialPick = -1;
		for (int i = 0; i < RADIAL_MAX; i++) if (ricon[i]) ricon[i].bINVISIBLE = true;
	}

	// The ring sits round where the hand opened it, in the plane facing the head:
	// item i at angle 90 - i * 360/n (the first at the top, then clockwise).
	private Vector3 RadialSpot(PlayerPawn pmo, int i, int n)
	{
		Vector3 toHead = RSQTR_Body.Head(pmo) - radialAt;
		double yaw = VectorAngle(toHead.x, toHead.y);
		Vector3 right = (sin(yaw), -cos(yaw), 0);      // the viewer's right, seen from the head
		Vector3 up = (0, 0, 1);
		double a = 90.0 - i * 360.0 / n;
		double rx = cos(a) * RADIAL_R, ry = sin(a) * RADIAL_R;
		return radialAt + (right.x * rx * RSQTR_Body.UPM, right.y * rx * RSQTR_Body.UPM, ry * RSQTR_Body.UPM / RSQTR_Body.PIXELSTRETCH);
	}

	private void TickRadial(PlayerPawn pmo, PlayerInfo p, int h, Vector3 hp, bool release)
	{
		int n = radialItems.Size();
		if (n == 0 || RSQTR_Body.RoomMetres(hp, radialAt) > RADIAL_CANCEL) { CloseRadial(); return; }
		// The pick: the item whose direction the hand has moved toward, once it has
		// moved more than the dead zone.
		int pick = -1;
		if (RSQTR_Body.RoomMetres(hp, radialAt) > RADIAL_DEAD)
		{
			double bestD = 1e9;
			for (int i = 0; i < n; i++)
			{
				double d = RSQTR_Body.RoomMetres(hp, RadialSpot(pmo, i, n));
				if (d < bestD) { bestD = d; pick = i; }
			}
		}
		if (pick != radialPick)
		{
			if (pick >= 0) RSQTR_Buzzer.Start(pmo, h, 0.22, 2);
			radialPick = pick;
		}
		// Icons: each weapon's own pickup sprite, the picked one larger.
		for (int i = 0; i < RADIAL_MAX; i++)
		{
			if (i >= n) { if (ricon[i]) ricon[i].bINVISIBLE = true; continue; }
			if (!ricon[i]) ricon[i] = Actor.Spawn("RSQTR_Icon", RadialSpot(pmo, i, n));
			let ic = RSQTR_Icon(ricon[i]);
			if (!ic) continue;
			ic.Wear(radialItems[i], i == radialPick ? 0.55 : 0.32, i == radialPick ? 1.0 : 0.6);
			ic.Place(RadialSpot(pmo, i, n));
		}
		if (release)
		{
			if (radialPick >= 0)
			{
				// The region's list may have changed since it opened; send the class's
				// index as it stands now.
				Array<String> own;
				Owned(pmo, radialRegion, own);
				int idx = own.Find(radialItems[radialPick]);
				if (idx < own.Size())
				{
					EventHandler.SendNetworkEvent("rsqtr_draw", radialRegion, idx);
					RSQTR_Buzzer.Start(pmo, h, 0.65, 6);
				}
			}
			CloseRadial();
		}
	}

	// ---- what you see ------------------------------------------------------------------
	// A soft ring at each region while a hand is near it (or always, rsqtr_markers 2),
	// amber with the hand inside; and the weapon last holstered there, as its own
	// pickup sprite, hanging at the region.
	private void DrawMarkers(PlayerPawn pmo, PlayerInfo p)
	{
		int mode = Opt("rsqtr_markers", p, 1);
		if (Flag("rsqtr_edit", p, false)) mode = 2;
		bool icons = Flag("rsqtr_icons", p, true);
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			Vector3 at = RegionAt(pmo, r);
			double rad = RegionRadius(p, r);
			double near = 1e9;
			for (int h = 0; h < 2; h++) near = min(near, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), at));
			bool inside = hoverR[0] == r || hoverR[1] == r;
			bool live = RegionLive(pmo, r);
			double a = 0;
			if (live && mode > 0)
			{
				if (mode >= 2) a = inside ? 0.7 : 0.25;
				else if (near < rad * 2.5) a = inside ? 0.7 : 0.35 * (1.0 - (near - rad) / (rad * 1.5));
			}
			if (a > 0.01)
			{
				if (!marker[r]) marker[r] = Actor.Spawn("RSQTR_Marker", at);
				let m = marker[r];
				if (m)
				{
					m.SetOrigin(at, true);
					m.bINVISIBLE = false;
					m.Alpha = clamp(a, 0.0, 1.0);
					double s = rad * RSQTR_Body.UPM;   // the wireframe sphere has radius 1.0
					m.Scale = (s, s);
					m.frame = inside ? 1 : 0;      // blue idle, green with a hand inside
				}
			}
			else if (marker[r]) marker[r].bINVISIBLE = true;

			// WHAT IS STORED THERE, always shown: the weapon last put there if you still
			// own it, otherwise the first weapon of that region you own; never the one in
			// your hand.
			String held = "";
			if (p.ReadyWeapon) held = p.ReadyWeapon.GetClassName();
			String put = lastPut[consoleplayer * RSQTR_Region.N + r];
			Array<String> own;
			Owned(pmo, r, own);
			if (put == "" || put == held || own.Find(put) == own.Size())
			{
				put = "";
				for (int k = 0; k < own.Size(); k++) if (own[k] != held) { put = own[k]; break; }
			}
			if (icons && live && put != "")
			{
				if (!icon[r]) icon[r] = Actor.Spawn("RSQTR_Icon", at);
				let ic = RSQTR_Icon(icon[r]);
				if (ic) { ic.Wear(put, 0.28 * Num("rsqtr_icon_scale", p, 1.0), 0.85); ic.Place(at); }
			}
			else if (icon[r]) icon[r].bINVISIBLE = true;
		}
	}

	private void HideAll()
	{
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (marker[r]) marker[r].bINVISIBLE = true;
			if (icon[r]) icon[r].bINVISIBLE = true;
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		radialHand = -1; radialRegion = -1;
		hoverR[0] = -1; hoverR[1] = -1;
		afterLoad = false;
	}

	// The rings and icons are this machine's alone and held by transient pointers, so a
	// save carries orphan copies of them: cleared on load (and respawned as needed).
	static void ClearLocalMarks()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
			if (a is "RSQTR_Marker" || a is "RSQTR_Icon") a.Destroy();
	}

	// OnRegister also runs when a save is loaded (a level's handlers get no WorldLoaded
	// then), so it notes it: the first tic clears the orphan rings and icons the save held.
	private transient bool afterLoad;
	override void OnRegister()
	{
		editHand = -1; editRegion = -1;
		radialHand = -1; radialRegion = -1;
		hoverR[0] = -1; hoverR[1] = -1;
		afterLoad = true;
	}
}

// The soft ring that shows a region.
class RSQTR_Marker : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSTM A -1 Bright; Stop; }
}

// A weapon shown by its own pickup sprite: the frame its Spawn state starts on.
// Sprites and voxels show; a pickup drawn by a MODEL shows its sprite instead
// (MODELDEF is keyed to the pickup's own class).
class RSQTR_Icon : Actor
{
	String wearing;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Translucent";
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1; Stop; }

	// Shown as the weapon's own PICKUP, as it looks lying in the world: its sprite,
	// the voxel a voxel pack gives that sprite, or the 3D model a weapon pack binds to
	// it. MODELDEF binds a model to a class exactly (a subclass does not inherit it), so
	// A_ChangeModel borrows the weapon's model definition for this actor -- the way
	// the owner's RS_Holsters showed its stored guns. The frame worn is the first
	// visible state of the pickup's Spawn sequence (Brutal Doom's often start TNT1).
	void Wear(String cls, double sc, double al)
	{
		if (cls != wearing)
		{
			wearing = cls;
			class<Actor> c = cls;
			let d = c ? GetDefaultByType(c) : null;
			State st = d ? d.SpawnState : null;
			int tnt = GetSpriteIndex('TNT1');
			for (int i = 0; i < 16 && st && st.sprite == tnt; i++) st = st.NextState;
			if (st && st.sprite != tnt)
			{
				sprite = st.sprite; frame = st.Frame;
				A_ChangeModel(Name(cls));
			}
			else { sprite = tnt; frame = 0; }
		}
		Scale = (sc, sc);
		Alpha = al;
		bINVISIBLE = false;
	}

	void Place(Vector3 at)
	{
		SetOrigin(at, true);
	}
}
