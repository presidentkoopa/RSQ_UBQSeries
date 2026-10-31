// wr_q_worldcard.zs -- RSQ Wheel: the gun cards drawn IN THE WORLD (owner 2026-10-31 03:07: "toggle world object
// on / off"). wr_card_world 1: the same two cards, built from the ring's own billboards (wr_q_shim.zs) and placed at
// the hand every tic, facing your eye, so no gun model, however big, can cover them. The price: placed once a tic,
// they can trail a fast hand a little. wr_card_world 0: drawn with the hand (wr_q_card.zs, wr_q_side.zs).
//
//   small card  over the wrist, on the firing line: the magazine big, the reserve small
//   full card   on the knuckles-up watch check: beside the wrist, the name, MAGAZINE / RESERVE, Gun Bonsai level,
//               XP and upgrades, in the gun's colour

class wr_WorldCard play
{
	const ROWS = 7;
	int hand;
	bool full;
	int group, plate, title, big, small;
	int row[ROWS];
	string sig;

	bool Shown() { return group != 0; }

	void Show(Vector3 at, bool isFull)
	{
		Hide();
		full = isFull;
		group = wr_BB.AddBillboardGroup(at);
		plate = wr_BB.AddBillboardPersistent(at, 4, 3, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_PANEL, 0, 0x808080, wr_BB.BBFL_NOHIT);
		title = wr_BB.AddBillboardPersistent(at, 4, 0.6, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_TEXT, 0, 0xF0F0F0, wr_BB.BBFL_NOHIT, 0, "");
		big = wr_BB.AddBillboardPersistent(at, 2, 1.2, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_DIGITS, 0, 0xFFFFFF, wr_BB.BBFL_NOHIT);
		small = wr_BB.AddBillboardPersistent(at, 1.5, 0.7, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_DIGITS, 0, 0xC8C8C8, wr_BB.BBFL_NOHIT);
		wr_BB.SetBillboardGroup(plate, group); wr_BB.SetBillboardGroup(title, group);
		wr_BB.SetBillboardGroup(big, group); wr_BB.SetBillboardGroup(small, group);
		for (int i = 0; i < ROWS; i++)
		{
			row[i] = isFull ? wr_BB.AddBillboardPersistent(at, 8, 0.6, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_TEXT, 0, 0xC8C8C8, wr_BB.BBFL_NOHIT, 0, "") : 0;
			if (row[i]) wr_BB.SetBillboardGroup(row[i], group);
		}
		sig = "";
	}

	void Hide()
	{
		if (!group) return;
		wr_BB.RemoveBillboard(plate); wr_BB.RemoveBillboard(title); wr_BB.RemoveBillboard(big); wr_BB.RemoveBillboard(small);
		for (int i = 0; i < ROWS; i++) if (row[i]) wr_BB.RemoveBillboard(row[i]);
		wr_BB.RemoveBillboardGroup(group);
		group = 0; sig = "";
	}

	// what it says (only when it changed)
	void Fill(PlayerPawn pmo, Weapon w, int panelCol)
	{
		int loaded = wr_GunCard.Loaded(w), reserve = wr_GunCard.Reserve(w);
		string s = wr_DetailTemplates.Signature(pmo, w, null, full ? 8 : 7, panelCol);
		if (s == sig) return;
		sig = s;
		wr_BB.UpdateBillboard(plate, 0, panelCol);
		wr_BB.UpdateBillboard(big, max(loaded, 0), loaded == 0 ? 0xFF5A46 : 0xFFFFFF);
		wr_BB.UpdateBillboard(small, max(reserve, 0), 0xC8C8C8);
		wr_BB.SetBillboardAlpha(small, reserve >= 0 ? 1.0 : 0.0);
		if (!full) { wr_BB.SetBillboardText(title, wr_GunCard.HasMagazine(w) ? "MAG" : "AMMO"); return; }
		wr_BB.SetBillboardText(title, wr_DetailTemplates.HandTag(hand) .. "  " .. wr_DetailTemplates.NameOf(w));
		Array<string> txt; Array<int> col;
		txt.Push(wr_GunCard.HasMagazine(w) ? (reserve >= 0 ? "MAGAZINE        RESERVE" : "MAGAZINE") : "AMMO"); col.Push(0xC8C8C8);
		let e = WR_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			string bar = "";
			int on = e.permille * 12 / 1000;
			for (int i = 0; i < 12; i++) bar = bar .. (i < on ? "=" : "-");
			txt.Push(String.Format("LV %d  %s", e.lvl, bar)); col.Push(0xFFD678);
			int shown = min(e.names.Size(), ROWS - 3);
			for (int i = 0; i < shown; i++)
			{
				txt.Push(e.names[i].MakeUpper() .. "  " .. WR_Bonsai.Numeral(e.levels[i]));
				col.Push(e.on[i] ? wr_DetailTemplates.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070);
			}
			if (e.names.Size() > shown) { txt.Push(String.Format("+%d MORE", e.names.Size() - shown)); col.Push(0x9A9A9A); }
		}
		for (int i = 0; i < ROWS; i++)
		{
			wr_BB.SetBillboardText(row[i], i < txt.Size() ? txt[i] : "");
			if (i < txt.Size()) wr_BB.UpdateBillboard(row[i], 0, col[i]);
		}
		rowsUsed = txt.Size();
	}
	int rowsUsed;

	// Placed every tic at the hand, facing the eye. sc: wr_card_world_scale. up / side: the placement sliders (cm).
	void Place(PlayerPawn pmo, double sc, double up, double side, double alpha)
	{
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = wr_Rig.handPos(pmo, hand);
		Vector3 toEye = (eye - hp).Unit();
		Vector3 right = (toEye.y, -toEye.x, 0);
		if (right.Length() > 0.01) right = right.Unit();
		double u = 1.0 / 2.54;   // ~ map units per cm at 34 u/m is 0.34; work in units: 1 unit ~ 2.9 cm
		u = 0.34;
		if (!full)
		{
			// over the wrist: up from the hand, toward the eye a little
			Vector3 Fw = wr_Rig.handDir(pmo, hand);
			// on the stub of the wrist (owner 03:10): behind the grip along the forearm, just above it. NOTE: the engine
			// draws a held gun over the world (hw_models.cpp BeginDrawHUDModel depth range), so where the gun covers
			// the wrist it covers this card too.
			Vector3 c = hp - Fw * (9 + side) * u + (0, 0, (3 + up) * u * sc) + toEye * 2 * u;
			wr_BB.SetBillboardGroupOrigin(group, c);
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
			Vector3 F = wr_Rig.handDir(pmo, hand);
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
			wr_BB.SetBillboardGroupOrigin(group, c);
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
		wr_BB.SetBillboardAlpha(plate, alpha);
		wr_BB.SetBillboardAlpha(title, alpha); wr_BB.SetBillboardAlpha(big, alpha);
		for (int i = 0; i < ROWS; i++) if (row[i]) wr_BB.SetBillboardAlpha(row[i], alpha);
	}
	// a piece on the flat card: (x, y) cm along W and Upv from the card centre, lifted off it by lift cm
	private void Lay(int id, Vector3 c, double x, double y, double w, double h, double u, double yaw, double tilt, double roll, Vector3 Wv, Vector3 Upv, Vector3 N, double lift)
	{
		if (!id) return;
		wr_BB.OrientBillboard(id, yaw, tilt, wr_BB.BBF_FIXED);
		wr_BB.RollBillboard(id, roll);
		wr_BB.MoveBillboard(id, c + Wv * x * u + Upv * y * u + N * lift);
		wr_BB.ResizeBillboard(id, w * u, h * u);
	}
	private void Put(int id, Vector3 at, double w, double h, double fwd)
	{
		if (!id) return;
		wr_BB.MoveBillboard(id, at);
		wr_BB.ResizeBillboard(id, w, h);
	}
}
