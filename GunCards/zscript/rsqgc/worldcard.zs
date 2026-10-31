// worldcard.zs -- RSQ Gun Cards: the cards drawn IN THE WORLD (owner 2026-10-31 03:07: "toggle world object
// on / off"). rsqgc_world 1: the same two cards, built from world quads (bb.zs, a copy of the Wheel's billboards) and
// placed at the hand every tic, facing your eye, so no gun model, however big, can cover them. The price: placed once
// a tic, they can trail a fast hand a little. rsqgc_world 0: drawn with the hand (card.zs, side.zs).
//
//   small card  over the wrist, on the firing line: the magazine big, the reserve small
//   full card   on the knuckles-up watch check: beside the wrist, the name, MAGAZINE / RESERVE, Gun Bonsai level,
//               XP and upgrades, in the gun's colour

class RSQGC_WorldCard play
{
	const ROWS = 7;
	int hand;
	bool full;
	bool live;          // its quads exist
	int plate, title, big, small;
	int row[ROWS];
	string sig;

	bool Shown() { return live; }

	void Show(Vector3 at, bool isFull)
	{
		Hide();
		full = isFull;
		live = true;
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

	// what it says (only when it changed)
	void Fill(PlayerPawn pmo, Weapon w, int panelCol, RSQGC_GunCard gc)
	{
		int loaded = RSQGC_GunCard.Loaded(w), reserve = RSQGC_GunCard.Reserve(w);
		string s = RSQGC_GunCard.Signature(pmo, w, full ? 8 : 7, panelCol) .. gc.ExtraSig(pmo, hand, w);
		bool reload = RSQGC_GunCard.HasMagazine(w) && loaded == 0 && reserve > 0;   // GC3
		if (s == sig) return;
		sig = s;
		RSQGC_BB.Update(plate, 0, panelCol);
		RSQGC_BB.Update(big, max(loaded, 0), loaded == 0 ? 0xFF5A46 : 0xFFFFFF);
		RSQGC_BB.Update(small, max(reserve, 0), 0xC8C8C8);
		RSQGC_BB.SetAlpha(small, reserve >= 0 ? 1.0 : 0.0);
		if (!full)
		{
			// GC3 RELOAD and GC2 +N take the title here (the world cards' numbers are digits only)
			int plus = gc.PlusNow(hand);
			RSQGC_BB.SetText(title, reload ? "RELOAD" : plus > 0 ? String.Format("+%d", plus) : RSQGC_GunCard.HasMagazine(w) ? "MAG" : "AMMO");
			RSQGC_BB.Update(title, 0, reload ? 0xFF5A46 : plus > 0 ? 0x80E040 : 0xF0F0F0);
			return;
		}
		RSQGC_BB.SetText(title, RSQGC_GunCard.HandTag(hand) .. "  " .. RSQGC_GunCard.NameOf(w));
		Array<string> txt; Array<int> col;
		txt.Push((reload ? "RELOAD" : RSQGC_GunCard.HasMagazine(w) ? "MAGAZINE" : "AMMO") .. (reserve >= 0 ? "        RESERVE" : "")); col.Push(reload ? 0xFF5A46 : 0xC8C8C8);
		if (gc.PlusNow(hand) > 0) { txt.Push(String.Format("PICKED UP +%d", gc.PlusNow(hand))); col.Push(0x80E040); }
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) { txt.Push(String.Format("GRENADES %d", gren)); col.Push(0xC8C8C8); }
		txt.Push(String.Format("KILLS %d", gc.KillsWith(w))); col.Push(0xC8C8C8);
		let e = RSQGC_Bonsai.Entry(pmo, w);
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
		for (int i = 0; i < ROWS; i++)
		{
			RSQGC_BB.SetText(row[i], i < txt.Size() ? txt[i] : "");
			if (i < txt.Size()) RSQGC_BB.Update(row[i], 0, col[i]);
		}
		rowsUsed = txt.Size();
	}
	int rowsUsed;

	// Placed every tic at the hand, facing the eye. sc: rsqgc_world_scale. up / side: the placement sliders (cm).
	void Place(PlayerPawn pmo, double sc, double up, double side, double alpha, double inCm = 0)
	{
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = RSQGC_GunCard.handPos(pmo, hand);
		Vector3 toEye = (eye - hp).Unit();
		Vector3 right = (toEye.y, -toEye.x, 0);
		if (right.Length() > 0.01) right = right.Unit();
		double u = 1.0 / 2.54;   // ~ map units per cm at 34 u/m is 0.34; work in units: 1 unit ~ 2.9 cm
		u = 0.34;
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
						Put(plate, c, 5 * sc * u, 4 * sc * u, 0);
			Put(title, c + (0, 0, 1.3 * sc * u), 4.2 * sc * u, 0.7 * sc * u, 0.05);
			Put(big, c + (0, 0, -0.1 * sc * u), 3.6 * sc * u, 1.6 * sc * u, 0.05);
			Put(small, c + (0, 0, -1.35 * sc * u), 2.2 * sc * u, 0.8 * sc * u, 0.05);
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
			// over the back of the wrist: behind the grip along the forearm, just off the skin
			Vector3 c = hp - F * (4 + side) * u * sc + N * (2.5 + up) * u * sc;
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
		RSQGC_BB.SetAlpha(plate, alpha);
		RSQGC_BB.SetAlpha(title, alpha); RSQGC_BB.SetAlpha(big, alpha);
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
	private void Put(int id, Vector3 at, double w, double h, double fwd)
	{
		if (!id) return;
		RSQGC_BB.Move(id, at);
		RSQGC_BB.Resize(id, w, h);
	}
}
