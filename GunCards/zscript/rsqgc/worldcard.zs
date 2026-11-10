// worldcard.zs -- RSQ Gun Cards: the cards drawn IN THE WORLD (owner 2026-10-31 03:07: "toggle world object
// on / off"). rsqgc_world 1: the same two cards, built from world quads (bb.zs, a copy of the Wheel's billboards) and
// placed at the hand every tic, facing your eye, so no gun model, however big, can cover them. The price: placed once
// a tic, they can trail a fast hand a little. rsqgc_world 0: drawn with the hand (card.zs, side.zs).
//
//   small card  over the wrist, on the firing line: the magazine big, the reserve small
//   full card   on the knuckles-up watch check: beside the wrist, the name, MAGAZINE / RESERVE, Gun Bonsai level,
//               XP and upgrades, in the gun's colour
//   status card the same check with an EMPTY hand (GC5), or with a weapon that has no ammo pile (the world has no item
//               card, items.zs): health big, armour small, the map's keys (held ones in their colour, missing ones
//               grey), other keys, grenades (FillStatus; owner 2026-11-04)

class RSQGC_WorldCard play
{
	const ROWS = 7;
	int hand;
	bool full;
	bool live;          // its quads exist
	bool status;        // showing the status card (FillStatus), not a gun's
	int plate, title, big, small;
	int row[ROWS];
	bool smallOn;       // the small number has something to say (Place gives it the card's alpha, else 0)
	string sig;

	bool Shown() { return live; }

	void Show(Vector3 at, bool isFull)
	{
		Hide();
		full = isFull;
		live = true;
		status = false;
		plate = RSQGC_BB.Add(at, 4, 3, RSQGC_BB.BB_PANEL, 0x808080);
		title = RSQGC_BB.Add(at, 4, 0.6, RSQGC_BB.BB_TEXT, 0xF0F0F0);
		big = RSQGC_BB.Add(at, 2, 1.2, RSQGC_BB.BB_DIGITS, 0xFFFFFF);
		small = RSQGC_BB.Add(at, 1.5, 0.7, RSQGC_BB.BB_DIGITS, 0xC8C8C8);
		for (int i = 0; i < ROWS; i++) row[i] = isFull ? RSQGC_BB.Add(at, 8, 0.6, RSQGC_BB.BB_TEXT, 0xC8C8C8) : 0;
		sig = "";
	}

	void Hide()
	{
		if (!live) return;
		RSQGC_BB.Remove(plate); RSQGC_BB.Remove(title); RSQGC_BB.Remove(big); RSQGC_BB.Remove(small);
		for (int i = 0; i < ROWS; i++) if (row[i]) RSQGC_BB.Remove(row[i]);
		live = false; sig = "";
	}

	// what it says (only when it changed). other: on a Both Guns on One Card small card, the other hand's gun, whose rounds
	// take the small number (as card.zs Draw); shows: the watch card's Watch Card Shows (0 the Weapon card, 2 both on one
	// card; 1, the Status card, is FillStatus)
	void Fill(PlayerPawn pmo, Weapon w, int panelCol, RSQGC_GunCard gc, Weapon other = null, int shows = 0)
	{
		int loaded = RSQGC_GunCard.Loaded(w), reserve = RSQGC_GunCard.Reserve(w);
		bool both = other != null && !full;
		int smallN = both ? RSQGC_GunCard.Loaded(other) : reserve;
		bool bonsai = full && shows == 0 && RSQGC_GunCard.ci("rsqgc_watch_bonsai", 0);
		string s = RSQGC_GunCard.Signature(pmo, w, full ? 8 : 7, panelCol) .. gc.ExtraSig(pmo, hand, w)
			.. String.Format(" o%d v%d gb%d", both ? smallN : -9, shows, bonsai) .. (full && shows == 2 ? gc.StatusSig(pmo) : "");
		bool reload = RSQGC_GunCard.HasMagazine(w) && loaded == 0 && reserve > 0;   // GC3
		if (s == sig) return;
		sig = s;
		RSQGC_BB.Update(plate, 0, panelCol);
		RSQGC_BB.Update(big, max(loaded, 0), loaded == 0 ? 0xFF5A46 : 0xFFFFFF);
		RSQGC_BB.Update(small, max(smallN, 0), 0xC8C8C8);
		smallOn = smallN >= 0;
		if (!full)
		{
			// GC3 RELOAD and GC2 +N take the title here (the world cards' numbers are digits only); on a both-guns card
			// the small number is the other gun's, so no +N (as the hand-drawn card)
			int plus = both ? 0 : gc.PlusNow(hand);
			RSQGC_BB.SetText(title, reload ? "RELOAD" : plus > 0 ? String.Format("+%d", plus) : RSQGC_GunCard.HasMagazine(w) ? "MAG" : "AMMO");
			RSQGC_BB.Update(title, 0, reload ? 0xFF5A46 : plus > 0 ? 0x80E040 : 0xF0F0F0);
			return;
		}
		RSQGC_BB.SetText(title, RSQGC_GunCard.HandTag(hand) .. "  " .. RSQGC_GunCard.NameOf(w));
		Array<string> txt; Array<int> col;
		txt.Push((reload ? "RELOAD" : RSQGC_GunCard.HasMagazine(w) ? "MAGAZINE" : "AMMO") .. (reserve >= 0 ? "        RESERVE" : "")); col.Push(reload ? 0xFF5A46 : 0xC8C8C8);
		if (gc.PlusNow(hand) > 0) { txt.Push(String.Format("PICKED UP +%d", gc.PlusNow(hand))); col.Push(0x80E040); }
		if (shows == 2)
		{
			// BOTH ON ONE CARD (as side.zs Build): health (red at 25 or less) and armour, the map's keys, grenades
			int hp = max(pmo.Health, 0);
			txt.Push(String.Format("HEALTH %d   ARMOUR %d", clamp(hp, 0, 999), clamp(RSQGC_GunCard.ArmorOf(pmo), 0, 999))); col.Push(hp <= 25 ? 0xFF5A46 : 0xF0F0F0);
			KeyRows(pmo, gc, txt, col);
			SetRows(txt, col);
			return;
		}
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) { txt.Push(String.Format("GRENADES %d", gren)); col.Push(0xC8C8C8); }
		txt.Push(String.Format("KILLS %d", gc.KillsWith(w))); col.Push(0xC8C8C8);
		// Gun Bonsai's rows only with Gun Bonsai on Card, as the hand-drawn card (fixed 2026-11-10: always shown here)
		let e = bonsai ? RSQGC_Bonsai.Entry(pmo, w) : null;
		if (e && e.lvl >= 0)
		{
			string bar = "";
			int on = e.permille * 12 / 1000;
			for (int i = 0; i < 12; i++) bar = bar .. (i < on ? "=" : "-");
			txt.Push(String.Format("LV %d  %s", e.lvl, bar)); col.Push(0xFFD678);
			int shown = min(e.names.Size(), max(0, ROWS - txt.Size() - 1));   // room left, one kept for +more
			for (int i = 0; i < shown; i++)
			{
				txt.Push(e.names[i].MakeUpper() .. "  " .. RSQGC_Bonsai.Numeral(e.levels[i]));
				col.Push(e.on[i] ? RSQGC_GunCard.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070);
			}
			if (e.names.Size() > shown) { txt.Push(String.Format("+%d MORE", e.names.Size() - shown)); col.Push(0x9A9A9A); }
		}
		SetRows(txt, col);
	}
	int rowsUsed;

	// the rows' text and colours, as many as there are rows
	private void SetRows(out Array<string> txt, out Array<int> col)
	{
		while (txt.Size() > ROWS) { txt.Pop(); col.Pop(); }
		for (int i = 0; i < ROWS; i++)
		{
			RSQGC_BB.SetText(row[i], i < txt.Size() ? txt[i] : "");
			if (i < txt.Size()) RSQGC_BB.Update(row[i], 0, col[i]);
		}
		rowsUsed = txt.Size();
	}

	// one row per key kind this map has, a held key in its colour and a missing one grey; other keys as KEYS +N; grenades
	private void KeyRows(PlayerPawn pmo, RSQGC_GunCard gc, out Array<string> txt, out Array<int> col)
	{
		bool cards, skulls;
		[cards, skulls] = gc.MapKeys(pmo);
		if (!RSQGC_GunCard.ci("rsqgc_keys", 1)) { cards = false; skulls = false; }
		int mask, others;
		[mask, others] = RSQGC_GunCard.HeldKeys(pmo);
		static const string KNAME[] = { "RED", "YELLOW", "BLUE" };
		static const int KCOL[] = { 0xFF4040, 0xFFE040, 0x4080FF };
		for (int t = 0; t < 6; t++)
		{
			if (t < 3 ? !cards : !skulls) continue;
			bool held = (mask & (1 << t)) != 0;
			txt.Push(KNAME[t % 3] .. (t < 3 ? " KEYCARD" : " SKULL") .. (held ? "" : "  -"));
			col.Push(held ? KCOL[t % 3] : 0x707070);
		}
		if (others > 0) { txt.Push(String.Format("KEYS +%d", others)); col.Push(0xC8C8C8); }
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) { txt.Push(String.Format("GRENADES %d", gren)); col.Push(gren > 0 ? 0xFFB428 : 0x707070); }
	}

	// GC5, the status card (what side.zs BuildStatus draws with the hand): HEALTH big (red at 25 or less), ARMOUR
	// small in blue; one row per key kind this map has, a held key in its colour and a missing one grey; other keys
	// as KEYS +N; grenades. Only when it changed.
	void FillStatus(PlayerPawn pmo, int panelCol, RSQGC_GunCard gc)
	{
		string s = "status" .. gc.StatusSig(pmo);
		if (s == sig) return;
		sig = s;
		int hp = max(pmo.Health, 0), ar = RSQGC_GunCard.ArmorOf(pmo);
		RSQGC_BB.Update(plate, 0, panelCol);
		RSQGC_BB.SetText(title, "HEALTH        ARMOUR");
		RSQGC_BB.Update(title, 0, 0xF0F0F0);
		RSQGC_BB.Update(big, clamp(hp, 0, 999), hp <= 25 ? 0xFF5A46 : 0xFFFFFF);
		RSQGC_BB.Update(small, clamp(ar, 0, 999), 0x6EA0FF);
		smallOn = true;
		Array<string> txt; Array<int> col;
		KeyRows(pmo, gc, txt, col);
		SetRows(txt, col);
	}

	// Placed every tic at the hand, facing the eye. sc: rsqgc_world_scale. up / side: the placement sliders (cm); on the
	// watch card up and side as the card reads (its text's up and its line's right).
	void Place(PlayerPawn pmo, double sc, double up, double side, double alpha, double inCm = 0)
	{
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = RSQGC_GunCard.handPos(pmo, hand);
		Vector3 toEye = (eye - hp).Unit();
		Vector3 right = (toEye.y, -toEye.x, 0);
		if (right.Length() > 0.01) right = right.Unit();
		double u = RSQGC_GunCard.cv("vr_vunits_per_meter", 34) / 100.0;   // map units per cm (0.34 at QuestZDoom's 34 a metre)
		if (!full)
		{
			// over the wrist: up from the hand, toward the eye a little
			Vector3 Fw = RSQGC_GunCard.handDir(pmo, hand);
			// on the stub of the wrist (owner 03:10): behind the grip along the forearm, just above it. NOTE: the engine
			// draws a held gun over the world (hw_models.cpp BeginDrawHUDModel depth range), so where the gun covers
			// the wrist it covers this card too.
			// rsqgc_in: + toward you along the forearm; Left / Right: across your view (fixed 2026-10-31: it moved the
			// card along the forearm, the same as In / Out, and `right` went unused)
			Vector3 c = hp - Fw * (9 + inCm) * u + right * side * u * sc + (0, 0, (3 + up) * u * sc) + toEye * 2 * u;
			Put(plate, c, 5 * sc * u, 4 * sc * u);
			Put(title, c + (0, 0, 1.3 * sc * u), 4.2 * sc * u, 0.7 * sc * u);
			Put(big, c + (0, 0, -0.1 * sc * u), 3.6 * sc * u, 1.6 * sc * u);
			Put(small, c + (0, 0, -1.35 * sc * u), 2.2 * sc * u, 0.8 * sc * u);
		}
		else
		{
			// ON THE BACK OF THE WRIST (owner 03:10): flat on it, its back against the wrist, face out. The hand's
			// four sides are its roll-turned up / right; the back of the hand is the one facing the eye in the
			// knuckles-up watch check. Width runs along the forearm, the text's top away from the eye.
			Vector3 F = RSQGC_GunCard.handDir(pmo, hand);
			double yw = atan2(F.y, F.x), pt = asin(clamp(F.z, -1, 1));
			double rl = hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll;
			Vector3 R0 = (-sin(yw), cos(yw), 0);
			Vector3 U0 = (-cos(yw) * sin(pt), -sin(yw) * sin(pt), cos(pt));
			Vector3 Rr = R0 * cos(rl) + U0 * sin(rl), Ur = U0 * cos(rl) - R0 * sin(rl);
			Vector3 N = Rr; double best = Rr dot toEye;
			if (-(Rr dot toEye) > best) { N = -Rr; best = -(Rr dot toEye); }
			if (Ur dot toEye > best) { N = Ur; best = Ur dot toEye; }
			if (-(Ur dot toEye) > best) { N = -Ur; best = -(Ur dot toEye); }
			Vector3 Wv = F;
			Vector3 Upv = N cross Wv;
			if (Upv dot toEye < 0) { Wv = -Wv; Upv = -Upv; }   // rig: the other way read upside down
			double h = (3.0 + 0.85 * max(rowsUsed, 1)) * sc;
			double w = 11 * sc;
			// over the back of the wrist: behind the grip along the forearm, just off the skin. Watch Card Side / Up move it
			// in the card's own plane, along its line (Wv) and its text's up (Upv) (fixed 2026-11-10: Side slid it along
			// the forearm, flipping with the card, and Up lifted it off the skin)
			Vector3 c = hp - F * 4 * u * sc + N * 2.5 * u * sc + Wv * side * u * sc + Upv * up * u * sc;
			double nyaw = atan2(N.y, N.x), ntilt = asin(clamp(N.z, -1, 1));
			Vector3 Rb = (-sin(nyaw), cos(nyaw), 0);
			Vector3 Ub = (-cos(nyaw) * sin(ntilt), -sin(nyaw) * sin(ntilt), cos(ntilt));
			double roll = atan2(Wv dot Ub, Wv dot Rb);
			double top = (h + 2.4 * sc) / 2 - 0.9 * sc;
			Lay(plate, c, 0, 0, w, h + 2.4 * sc, u, nyaw, ntilt, roll, Wv, Upv, N, 0);
			Lay(title, c, 0, top, w - 1, 0.75 * sc, u, nyaw, ntilt, roll, Wv, Upv, N, 0.05);
			Lay(big, c, -w / 4, top - 1.6 * sc, w / 2.4, 1.6 * sc, u, nyaw, ntilt, roll, Wv, Upv, N, 0.05);
			Lay(small, c, w / 4, top - 1.6 * sc, w / 3.5, 1.0 * sc, u, nyaw, ntilt, roll, Wv, Upv, N, 0.05);
			for (int i = 0; i < ROWS; i++)
				Lay(row[i], c, 0, top - 2.9 * sc - i * 0.85 * sc, w - 1, 0.6 * sc, u, nyaw, ntilt, roll, Wv, Upv, N, 0.05);
		}
		RSQGC_BB.SetAlpha(plate, RSQGC_Glow.NoPanel() ? 0.0 : alpha);   // Material: No Background (owner 11-06)
		RSQGC_BB.SetAlpha(title, alpha); RSQGC_BB.SetAlpha(big, alpha);
		RSQGC_BB.SetAlpha(small, smallOn ? alpha : 0.0);   // Card Opacity and the fade, as the rest (fixed 2026-11-10)
		for (int i = 0; i < ROWS; i++) if (row[i]) RSQGC_BB.SetAlpha(row[i], alpha);
	}
	// a piece on the flat card: (x, y) cm along W and Upv from the card centre, lifted off it by lift cm
	private void Lay(int id, Vector3 c, double x, double y, double w, double h, double u, double yaw, double tilt, double roll, Vector3 Wv, Vector3 Upv, Vector3 N, double lift)
	{
		if (!id) return;
		RSQGC_BB.Orient(id, yaw, tilt, roll);
		RSQGC_BB.Move(id, c + Wv * x * u + Upv * y * u + N * lift);
		RSQGC_BB.Resize(id, w * u, h * u);
	}
	private void Put(int id, Vector3 at, double w, double h)
	{
		if (!id) return;
		RSQGC_BB.Move(id, at);
		RSQGC_BB.Resize(id, w, h);
	}
}
