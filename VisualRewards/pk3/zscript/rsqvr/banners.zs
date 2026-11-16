// THE ARCADE GOLD BANNERS (owner 2026-11-16 01:50-02:38; design/BANNERS_AND_HUD.md sections 1-4, mockups
// design/mockups/banners/). One banner at a time per player, on the HUD layer in the middle of the view:
//   REVIVE          the gold headline, then the chips: what getting up actually gave
//   LIFEUSED        -1UP: the hot 1UP for a beat, then the minus slams in (red flash, shake), the face turns to OUCH,
//                   greyed, the bands go cold; then the chips
//   BOSSWIN         BOSS DEFEATED! (gold) and TIER UP + the new tier's colour
//   BOSSLOSS        BOSS WINS! (red), TIER DOWN + the colour, NO LEGENDARY
//   LIFEUP          +1UP: a gold flash, spinning rays, the grinning face pops in and wobbles, the 1UP squashes as it lands
//                   and bobs, a white shine sweeps down its bands, sparkles burst; then the badge shrinks and floats up
//                   into RSQ Score's lives at the top, where the new face pops in with a second burst
// THE MOTION (his "particularly lovely"; the mockup's frames are 2 tics): the headline punches in 0.2 -> 1.35 -> 1.0 over
// 8 tics, capped at 1.12 on screen; each chip pops the same way 4 tics after the one before, in reading order, two to a
// row; a hold; everything shrinks to 0.4 and fades over 12 tics. An INVULNERABLE chip blinks, then flies up into the
// invulnerability bar's row (invbar.zs), which flashes in full where it lands and drains from there.
// SIZE AND PLACE: in the headset eye's own units, as RSQ SlowMo's DOWN panel (downhud.zs EyeMap: the HUD is a quad
// vr_hud_scale wide at 1 m; the eye's half-width is EYE_TAN), so the banner is the mockup's size in the eye whatever the
// player's HUD scale; round the gaze. Banner Size (rsqvr_banner_size) and RSQ Accessibility's Text Size scale it.
// VR: quads and text only (Screen.DrawTexture / DrawText); no clip rectangle and no Screen.Dim (neither shows on the
// projected HUD in VR). PHOTOSENSITIVE MODE (RSQ_Accessibility, by name: RSQTHP_A11y): no white flash, no shine, no
// shake, no blink (a steady glow instead), the red flash dropped.
// Rig only, not headset-confirmed.

class RSQVR_Banner play
{
	int pn;                // the player it is for (-1: everyone)
	int moment;
	int t0;                // level.maptime it starts (after the one before it)
	int exitAt, endAt;     // tics after t0
	int invIdx, invLand;   // the INVULNERABLE chip (-1 none) and the tic (after t0) it lands in the bar
	int seed;
	Array<int> ck;         // chip kinds
	Array<String> cnum;    // its big text ("+66", "3S"; "" none)
	Array<String> cword;   // its small text
	Array<int> crgb;       // a tier's swatch colour
	Array<int> cn;         // lives: how many faces
}

class RSQVR_Banners : EventHandler
{
	enum EMoment { M_REVIVE, M_LIFEUSED, M_BOSSWIN, M_BOSSLOSS, M_LIFEUP };
	enum EKind { K_HEALTH, K_ARMOR, K_INVULN, K_MAGS, K_LIVES, K_TIERUP, K_TIERDOWN, K_NOLEG };

	const POP = 8;            // tics a pop takes (4 mockup frames)
	const STEP = 4;           // tics between one chip's pop and the next
	const EXIT = 12;          // tics the shrink and fade take
	const QUEUE = 5;          // banners waiting at most, a player (the next one counts: it starts a tic later)
	const FLY_AT = 68;        // +1UP: the badge leaves for the lives ...
	const LAND_AT = 88;       // ... and lands
	const LIFEUP_END = 120;
	const EYE_TAN = 0.91;     // the eye's half-width as a tangent, measured on the 17.3 rig (SlowMo downhud.zs)
	const MOCK_TAN = 0.0018958; // a mockup px as a tangent: its 800 px frame was a 400 px crop of the 480 px eye (2 x 0.91 x 400 / 480 / 800)

	Array<RSQVR_Banner> list;

	static clearscope RSQVR_Banners Get() { return RSQVR_Banners(EventHandler.Find("RSQVR_Banners")); }

	// =================================================================================================================
	// THE REQUEST (RSQVR_Service "banner"): "<MOMENT>|<kind:value>|..." for objectArg's player (null: everyone)
	static clearscope int MomentOf(String s)
	{
		s = s.MakeUpper();
		if (s == "REVIVE") return M_REVIVE;
		if (s == "LIFEUSED") return M_LIFEUSED;
		if (s == "BOSSWIN") return M_BOSSWIN;
		if (s == "BOSSLOSS") return M_BOSSLOSS;
		if (s == "LIFEUP") return M_LIFEUP;
		return -1;
	}
	// the world tiers (RSQ Monsters RS_BDArt COLOUR, tier 1..13): name and swatch
	static String TierName(int n)
	{
		static const String TN[] = { "", "NORMAL", "GREEN", "BLUE", "PURPLE", "CYAN", "BROWN", "YELLOW", "FIRE BLUE", "GRAY", "RED",
			"ABYSS", "BLACK", "WHITE" };
		return (n >= 1 && n <= 13) ? TN[n] : String.Format("TIER %d", n);
	}
	static int TierRgb(int n)
	{
		static const int TC[] = { 0xB4B4B4, 0xC8A070, 0x3CC846, 0x3C6EFF, 0xAA46DC, 0x28DCE6, 0x965F2D, 0xF0DC28, 0x3C8CFF, 0x969696,
			0xDC2820, 0x3C145A, 0x2A2A2A, 0xF5F5F5 };
		return (n >= 0 && n <= 13) ? TC[n] : 0xB4B4B4;
	}

	int Add(String spec, Actor pawn)
	{
		Array<String> parts;
		spec.Split(parts, "|");
		if (parts.Size() < 1) return 0;
		int m = MomentOf(parts[0]);
		if (m < 0) return 0;
		let b = new("RSQVR_Banner");
		b.pn = (pawn && pawn.player) ? pawn.PlayerNumber() : -1;
		b.moment = m;
		b.invIdx = -1;
		b.seed = level.maptime * 7 + m * 131 + 17;
		for (int i = 1; i < parts.Size(); i++)
		{
			Array<String> kv;
			parts[i].Split(kv, ":");
			if (kv.Size() < 1 || kv[0] == "") continue;
			String k = kv[0].MakeLower();
			String v = kv.Size() > 1 ? kv[1] : "";
			int kind = -1, rgb = 0, n = 0;
			String num = "", word = "";
			if (k == "health") { kind = K_HEALTH; num = (v.Left(1) == "+" ? "" : "+") .. v; word = "HEALTH"; }
			else if (k == "armor" || k == "armour") { kind = K_ARMOR; num = (v.Left(1) == "+" ? "" : "+") .. v; word = "ARMOR"; }
			else if (k == "invuln") { kind = K_INVULN; num = v .. "S"; word = "INVULNERABLE"; }
			else if (k == "mags" || k == "ammo")
			{
				kind = K_MAGS;
				if (v == "" || v ~== "full" || v.ToInt() <= 0) word = "MAGS FULL";
				else { num = "+" .. v; word = "MAGS"; }
			}
			else if (k == "lives") { kind = K_LIVES; n = max(0, v.ToInt()); num = String.Format("%d", n); word = m == M_LIFEUSED ? "LEFT" : "HELD"; }
			else if (k == "tierup" || k == "tierdown")
			{
				kind = k == "tierup" ? K_TIERUP : K_TIERDOWN;
				// "<n>" a world tier (its name and colour), or "<name>" / "<n>@RRGGBB" / "<name>@RRGGBB"
				Array<String> at;
				v.Split(at, "@");
				String tv = at.Size() > 0 ? at[0] : "";
				int tn = tv.ToInt();
				if (tn > 0 || tv == "0") { num = TierName(tn); rgb = TierRgb(tn); }
				else { num = tv.MakeUpper(); rgb = 0xB4B4B4; }
				if (at.Size() > 1 && at[1].Length() == 6) rgb = at[1].ToInt(16);
				word = kind == K_TIERUP ? "TIER UP" : "TIER DOWN";
			}
			else if (k == "nolegendary") { kind = K_NOLEG; word = "NO LEGENDARY"; }
			if (kind < 0) continue;
			b.ck.Push(kind); b.cnum.Push(num.MakeUpper()); b.cword.Push(word); b.crgb.Push(rgb); b.cn.Push(n);
			if (kind == K_INVULN && b.invIdx < 0) b.invIdx = b.ck.Size() - 1;
		}
		Timeline(b);
		// after this player's last banner
		int start = level.maptime + 1, waiting = 0;
		for (int i = 0; i < list.Size(); i++)
		{
			let o = list[i];
			if (!o || (o.pn != b.pn && o.pn >= 0 && b.pn >= 0)) continue;
			start = max(start, o.t0 + o.endAt);
			if (o.t0 > level.maptime) waiting++;
		}
		if (waiting >= QUEUE) return 0;
		b.t0 = start;
		list.Push(b);
		return 1;
	}

	// when each part starts, in tics after t0 (the mockups' frames x 2)
	static clearscope int ChipStart(int moment, int i)
	{
		if (moment == M_LIFEUSED) return 32 + STEP * i;
		if (moment == M_LIFEUP) return 40 + STEP * i;
		return 10 + STEP * i;
	}
	static void Timeline(RSQVR_Banner b)
	{
		int n = b.ck.Size();
		int lastDone = n > 0 ? ChipStart(b.moment, n - 1) + POP : 10;
		b.invLand = b.invIdx >= 0 ? ChipStart(b.moment, b.invIdx) + 36 : -1;
		if (b.moment == M_LIFEUP) { b.exitAt = FLY_AT; b.endAt = LIFEUP_END; return; }
		int base = b.moment == M_LIFEUSED ? 60 : 52;
		b.exitAt = max(base, lastDone + 22);
		if (b.invLand >= 0) b.exitAt = max(b.exitAt, b.invLand + 20);
		b.endAt = b.exitAt + EXIT;
	}

	override void WorldTick()
	{
		for (int i = list.Size() - 1; i >= 0; i--)
			if (!list[i] || level.maptime > list[i].t0 + list[i].endAt + 2) list.Delete(i);
	}

	// THE TEST HOOK (console, sv_cheats on): netevent rsqvr_bntest <n>, n = 0 REVIVE (with invulnerability 3 s), 1 -1UP
	// (5 s), 2 BOSS DEFEATED!, 3 BOSS WINS!, 4 +1UP (and a Score life when RSQ Score is loaded), 5 REVIVE without; or any
	// banner by its spec: netevent "rsqvr_banner:REVIVE|health:66|armor:50"
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqvr_bntest") && e.Name.Left(13) != "rsqvr_banner:") return;
		let ch = CVar.FindCVar("sv_cheats");
		if (!ch || !ch.GetBool()) return;
		if (e.Player < 0 || !playeringame[e.Player] || !players[e.Player].mo) return;
		let mo = players[e.Player].mo;
		if (e.Name.Left(13) == "rsqvr_banner:") { Add(e.Name.Mid(13), mo); return; }
		switch (e.Args[0])
		{
		case 0: GiveInv(mo, 3); Add("REVIVE|health:66|armor:50|invuln:3|mags:full", mo); break;
		case 1: GiveInv(mo, 5); Add("LIFEUSED|health:100|mags:full|invuln:5|lives:2", mo); break;
		case 2: Add("BOSSWIN|tierup:3", mo); break;
		case 3: Add("BOSSLOSS|tierdown:2|nolegendary", mo); break;
		case 4:
		{
			// a Score life: RSQ Score shows its own +1UP for it (next tic, its RunRewardCue); without Score, the banner from here
			let s = ServiceIterator.Find("RS_ScoreService").Next();
			int lives = s ? s.GetInt("givelife", "", 1, 0, mo) : -1;
			if (lives < 0) Add("LIFEUP|lives:1", mo);
			break;
		}
		case 5: Add("REVIVE|health:66|armor:50|mags:full", mo); break;
		}
	}
	static void GiveInv(Actor mo, int secs)
	{
		mo.GiveInventory("PowerInvulnerable", 1);
		let p = Powerup(mo.FindInventory("PowerInvulnerable"));
		if (p) p.EffectTics = secs * TICRATE;
	}

	// =================================================================================================================
	// UI: THE EXCHANGE WITH RSQ SCORE'S LIVES (RSQVR_Service GetIntUI "banner.lives", asked by Score's hud.zs every frame):
	// Score says where its newest life face is drawn and how tall; the answer is how many faces it holds back (a +1UP's
	// badge still on its way there).
	ui double livesX, livesY, livesH;
	ui int livesTic;
	ui int LivesExchange(double x, double y, double h)
	{
		livesX = x; livesY = y; livesH = h; livesTic = level.maptime;
		int hold = 0;
		for (int i = 0; i < list.Size(); i++)
		{
			let b = list[i];
			if (!b || b.moment != M_LIFEUP || !Mine(b)) continue;
			if (level.maptime < b.t0 + LAND_AT) hold++;
		}
		return hold;
	}
	static clearscope bool Mine(RSQVR_Banner b) { return b.pn < 0 || b.pn == consoleplayer; }

	// the banner on screen now for this player (the earliest started), or null
	ui RSQVR_Banner Current()
	{
		RSQVR_Banner best = null;
		for (int i = 0; i < list.Size(); i++)
		{
			let b = list[i];
			if (!b || !Mine(b) || level.maptime < b.t0 || level.maptime > b.t0 + b.endAt) continue;
			if (!best || b.t0 < best.t0) best = b;
		}
		return best;
	}
	// a +1UP's badge in flight or a chip on its way to the bar: the invulnerability bar waits for it
	ui bool InvPending()
	{
		for (int i = 0; i < list.Size(); i++)
		{
			let b = list[i];
			if (b && Mine(b) && b.invIdx >= 0 && level.maptime < b.t0 + b.invLand) return true;
		}
		return false;
	}
	ui int LandTic()
	{
		int best = -1;
		for (int i = 0; i < list.Size(); i++)
		{
			let b = list[i];
			if (b && Mine(b) && b.invIdx >= 0 && level.maptime >= b.t0 + b.invLand) best = max(best, b.t0 + b.invLand);
		}
		return best;
	}

	// =================================================================================================================
	// DRAWING
	ui Font f1, f2;
	ui double gx, gy, m;      // the gaze on the screen, screen px a mockup px
	ui bool photo;

	static ui bool On() { let c = CVar.GetCVar("rsqvr_banners", players[consoleplayer]); return !c || c.GetBool(); }
	static ui double SizeK()
	{
		let c = CVar.GetCVar("rsqvr_banner_size", players[consoleplayer]);
		return clamp((c ? c.GetFloat() : 1.0) * RSQTHP_A11y.Text(), 0.4, 3.0);
	}
	// the HUD in the eye (SlowMo downhud.zs EyeMap, QuestZDoom's getHUDProjection): screen px a unit of tangent, the gaze
	ui void EyeMap()
	{
		double sw = Screen.GetWidth(), shh = Screen.GetHeight();
		let vm = CVar.FindCVar("vr_mode");
		double ptx;
		if (!vm || vm.GetInt() == 0) { ptx = sw * 0.5 / EYE_TAN; gx = sw * 0.5; gy = shh * 0.5; }
		else
		{
			let hs = CVar.FindCVar("vr_hud_scale");
			let hr = CVar.FindCVar("vr_hud_rotate");
			double scale = hs ? max(0.05, hs.GetFloat()) : 0.4;
			double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
			ptx = sw * 0.5 / scale;
			double pty = shh * 0.5 / (scale * ps);
			gx = sw * 0.5;
			gy = shh * 0.5 - tan(hr ? hr.GetFloat() : 0.0) * pty;
		}
		m = MOCK_TAN * ptx * SizeK();
	}

	static ui double PopK(double t, double dur = POP)
	{
		if (t < 0) return 0;
		double u = t / dur;
		if (u < 0.5) return 0.2 + 2.3 * u;
		if (u < 1.0) return 1.35 - 0.7 * (u - 0.5);
		return 1.0;
	}
	static ui double Smooth(double u) { u = clamp(u, 0.0, 1.0); return u * u * (3.0 - 2.0 * u); }
	static ui double Rnd(int seed, int i, int salt)
	{
		int h = seed * 73856093 ^ i * 19349663 ^ salt * 83492791;
		h = (h ^ (h >> 13)) * 1274126177;
		h ^= (h >> 16);
		return (h & 0xFFFF) / 65535.0;
	}
	static ui Color RGBc(int rgb) { return Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255); }

	// ---- primitives ----
	static ui TextureID T(String n) { return TexMan.CheckForTexture(n, TexMan.Type_Any); }
	// a texture by its top left, as it is
	static ui void Tex(String n, double x, double y, double w, double h, double a, int fill = -1, int tint = 0xFFFFFF, bool add = false, int desat = 0)
	{
		TextureID t = T(n);
		if (!t.IsValid() || a <= 0.003 || w <= 0 || h <= 0) return;
		if (fill >= 0)
			Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_FillColor, fill, DTA_Alpha, a);
		else
			Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_Alpha, a,
				DTA_Color, RGBc(tint), DTA_Desaturate, desat, DTA_LegacyRenderStyle, add ? STYLE_Add : STYLE_Translucent);
	}
	// a texture by its centre, turned ang degrees
	static ui void TexC(String n, double cx, double cy, double w, double h, double a, int fill = -1, int tint = 0xFFFFFF, bool add = false, int desat = 0, double ang = 0)
	{
		TextureID t = T(n);
		if (!t.IsValid() || a <= 0.003 || w <= 0 || h <= 0) return;
		if (fill >= 0)
			Screen.DrawTexture(t, false, cx, cy, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true, DTA_Rotate, ang,
				DTA_FillColor, fill, DTA_Alpha, a);
		else
			Screen.DrawTexture(t, false, cx, cy, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true, DTA_Rotate, ang,
				DTA_Alpha, a, DTA_Color, RGBc(tint), DTA_Desaturate, desat, DTA_LegacyRenderStyle, add ? STYLE_Add : STYLE_Translucent);
	}
	// text: top left x, y; px screen px a font px
	static ui void Txt(Font f, int col, String s, double x, double y, double px, double a, int tint = 0xFFFFFF)
	{
		if (a <= 0.003 || px <= 0.001) return;
		double vw = Screen.GetWidth() / px, vh = Screen.GetHeight() / px;
		Screen.DrawText(f, col, x / px, y / px, s, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, a,
			DTA_Color, RGBc(tint));
	}
	// the headline's look: a drop shadow, a dark outline all round, then the ramp
	ui void Headline(String s, double cx, double cy, double px, double a, String colName)
	{
		double w = f1.StringWidth(s) * px, h = f1.GetHeight() * px;
		double x = cx - w * 0.5, y = cy - h * 0.5;
		int ink = Font.FindFontColor("RSQVR_BnInk");
		double o = max(1.0, px * 0.5), sh = px * 0.85;
		Txt(f1, ink, s, x + sh, y + sh, px, a * 0.75);
		for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
			if (dx || dy) Txt(f1, ink, s, x + dx * o, y + dy * o, px, a);
		Txt(f1, Font.FindFontColor(colName), s, x, y, px, a);
	}

	// ---- the chips --------------------------------------------------------------------------------------------------
	// one chip laid out from its left edge x, its middle y, u screen px a mockup px; draws unless measure; returns its width
	ui double Chip(RSQVR_Banner b, int i, double x, double y, double u, double a, bool measure, int glow = 0)
	{
		int kind = b.ck[i];
		String col = "RSQVR_BnAmmo", icon = "";
		bool grey = false;
		switch (kind)
		{
		case K_HEALTH: col = "RSQVR_BnHealth"; icon = "RQVBIH"; break;
		case K_ARMOR: col = "RSQVR_BnArmor"; icon = "RQVBIA"; break;
		case K_INVULN: col = "RSQVR_BnInv"; icon = "RQVBII"; break;
		case K_MAGS: col = "RSQVR_BnAmmo"; icon = "RQVBIM"; break;
		case K_LIVES: grey = b.moment == M_LIFEUSED; col = grey ? "RSQVR_BnGrey" : "RSQVR_BnLife"; break;
		case K_TIERUP: col = "RSQVR_BnUp"; icon = "RQVBIU"; break;
		case K_TIERDOWN: col = "RSQVR_BnDown"; icon = "RQVBID"; break;
		case K_NOLEG: col = "RSQVR_BnDown"; icon = "RQVBID"; break;
		}
		int fc = Font.FindFontColor(col);
		double padX = 14 * u, gap = 10 * u, ih = 28 * u;
		double npx = 4 * u, wpx = 3 * u;            // the number at 4, the word at 3 mockup px a font px (RSSCFN2)
		double fh = f2.GetHeight();
		// the parts' widths
		double wIcon = icon != "" ? ih : 0;
		double faceW = 0, faceH = ih * 1.1;
		int faces = 0;
		TextureID ft = T(grey ? "STFOUCH0" : "STFST01");
		if (kind == K_LIVES)
		{
			faces = min(b.cn[i], 5);
			if (ft.IsValid()) { Vector2 fs = TexMan.GetScaledSize(ft); faceW = faceH * fs.x / max(1.0, fs.y); }
		}
		bool tier = kind == K_TIERUP || kind == K_TIERDOWN;
		String num = tier ? "" : b.cnum[i];
		String word = b.cword[i];
		double wNum = num != "" ? f2.StringWidth(num) * npx : 0;
		double wWord = word != "" ? f2.StringWidth(word) * wpx : 0;
		double wSw = tier ? ih : 0;
		double wTn = tier ? f2.StringWidth(b.cnum[i]) * wpx : 0;
		double cw = 0;
		int parts = 0;
		if (wIcon > 0) { cw += wIcon; parts++; }
		if (faces > 0) { cw += faces * faceW + (faces - 1) * 4 * u; parts++; }
		if (wNum > 0) { cw += wNum; parts++; }
		if (wWord > 0) { cw += wWord; parts++; }
		if (tier) { cw += wSw + wTn; parts += 2; }
		cw += max(0, parts - 1) * gap;
		double w = cw + 2 * padX, h = 44 * u;
		if (measure) return w;
		// the pill: its ends kept, its middle stretched
		Pill(x, y - h * 0.5, w, h, a);
		if (glow > 0) PillGlow(x, y - h * 0.5, w, h, a * glow * 0.01);
		double cx = x + padX;
		int ink = Font.FindFontColor("RSQVR_BnInk");
		if (wIcon > 0) { Tex(icon, cx, y - ih * 0.5, ih, ih, a); cx += wIcon + gap; }
		if (faces > 0)
		{
			for (int k = 0; k < faces; k++)
			{
				double fx = cx + k * (faceW + 4 * u);
				FaceAt(grey ? "STFOUCH0" : "STFST01", fx + faceW * 0.5, y, faceH, a, grey, 0, u * 1.0);
			}
			cx += faces * faceW + (faces - 1) * 4 * u + gap;
		}
		if (wNum > 0)
		{
			Txt(f2, ink, num, cx + npx * 0.5, y - fh * npx * 0.5 + npx * 0.5, npx, a * 0.8);
			Txt(f2, fc, num, cx, y - fh * npx * 0.5, npx, a);
			cx += wNum + gap;
		}
		if (wWord > 0)
		{
			Txt(f2, ink, word, cx + wpx * 0.5, y - fh * wpx * 0.5 + wpx * 0.5, wpx, a * 0.8);
			Txt(f2, fc, word, cx, y - fh * wpx * 0.5, wpx, a);
			cx += wWord + gap;
		}
		if (tier)
		{
			Tex("RQVBSW", cx, y - ih * 0.5, ih, ih, a, -1, b.crgb[i]);
			Tex("RQVBSB", cx, y - ih * 0.5, ih, ih, a);
			cx += wSw + gap;
			// the tier's name in a light tint of its colour (white ramp x the colour, lifted so dark tiers read)
			int rgb = b.crgb[i];
			int lr = 70 + ((rgb >> 16) & 255) * 185 / 255, lg = 70 + ((rgb >> 8) & 255) * 185 / 255, lb = 70 + (rgb & 255) * 185 / 255;
			Txt(f2, ink, b.cnum[i], cx + wpx * 0.5, y - fh * wpx * 0.5 + wpx * 0.5, wpx, a * 0.8);
			Txt(f2, Font.FindFontColor("RSQVR_BnWhite"), b.cnum[i], cx, y - fh * wpx * 0.5, wpx, a, (lr << 16) | (lg << 8) | lb);
		}
		return w;
	}
	static ui void Pill(double x, double y, double w, double h, double a)
	{
		TextureID t = T("RQVBPL");
		if (!t.IsValid() || a <= 0.003) return;
		double cap = min(h * 12.0 / 32.0, w * 0.5);
		Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 0.0, DTA_SrcWidth, 12.0, DTA_Alpha, a);
		if (w > 2 * cap)
			Screen.DrawTexture(t, false, x + cap, y, DTA_DestWidthF, w - 2 * cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 12.0, DTA_SrcWidth, 8.0, DTA_Alpha, a);
		Screen.DrawTexture(t, false, x + w - cap, y, DTA_DestWidthF, cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 20.0, DTA_SrcWidth, 12.0, DTA_Alpha, a);
	}
	// the INVULNERABLE chip's blink: its pill lit in the bar's pale magenta, added
	static ui void PillGlow(double x, double y, double w, double h, double a)
	{
		Tex("RQVBGL", x - h * 0.15, y - h * 0.35, w + h * 0.3, h * 1.7, a, -1, 0xFF80E6, true);
		Tex("RQVBGL", x + w * 0.1, y - h * 0.1, w * 0.8, h * 1.2, a * 0.8, -1, 0xFFE0F8, true);
	}
	// a Doomguy face (the IWAD's own) by its centre, h tall, a black outline a face pixel wide; grey: OUCH greyed
	ui void FaceAt(String n, double cx, double cy, double h, double a, bool grey, double ang, double outlinePx)
	{
		TextureID t = T(n);
		if (!t.IsValid()) return;
		Vector2 s = TexMan.GetScaledSize(t);
		double w = h * s.x / max(1.0, s.y);
		double o = max(1.0, h / max(1.0, s.y));
		for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
			if (dx || dy) TexC(n, cx + dx * o, cy + dy * o, w, h, a, 0x080606, 0xFFFFFF, false, 0, ang);
		if (grey) TexC(n, cx, cy, w, h, a, -1, 0xD2D8E8, false, 255, ang);
		else TexC(n, cx, cy, w, h, a, -1, 0xFFFFFF, false, 0, ang);
	}

	// the chips' places: two to a row under the headline (row 0 at y0, rows rowStep apart), centred on gx; u screen px a
	// mockup px at rest. Answers each chip's centre.
	ui void ChipPlaces(RSQVR_Banner b, double y0, double rowStep, double u, out Array<double> px, out Array<double> py)
	{
		px.Clear(); py.Clear();
		int n = b.ck.Size();
		for (int r = 0; r * 2 < n; r++)
		{
			int a0 = r * 2, a1 = min(n - 1, r * 2 + 1);
			double w0 = Chip(b, a0, 0, 0, u, 1, true);
			double w1 = a1 > a0 ? Chip(b, a1, 0, 0, u, 1, true) : 0;
			double tot = w0 + (a1 > a0 ? w1 + 14 * u : 0);
			double x0 = gx - tot * 0.5;
			px.Push(x0 + w0 * 0.5); py.Push(y0 + r * rowStep);
			if (a1 > a0) { px.Push(x0 + w0 + 14 * u + w1 * 0.5); py.Push(y0 + r * rowStep); }
		}
	}

	// ---- the 1UP badge ----------------------------------------------------------------------------------------------
	// laid out in the "1"'s texels (bp screen px each): the face 0.4 bp a face px, a 1.4 bp gap, [the minus 0.5 bp a px, a
	// 0.8 bp gap], the "1", a 0.4 bp gap, the "UP" 0.4 bp a px, 0.4 bp down from the 1's top. Returns the face's centre.
	ui double, double Badge(double cx, double cy, double bp, double sxk, double syk, double a, bool cold, int shine,
		String face, bool grey, double faceAng, double minusK, double droop)
	{
		String one = cold ? "RQVBOC" : String.Format("RQVBO%d", shine);
		String up = cold ? "RQVBUC" : String.Format("RQVBU%d", shine);
		Vector2 so = TexMan.GetScaledSize(T(one)), su = TexMan.GetScaledSize(T(up)), sm = TexMan.GetScaledSize(T("RQVBMC"));
		TextureID ft = T(face);
		Vector2 sf = (24, 29);
		if (ft.IsValid()) sf = TexMan.GetScaledSize(ft);
		double fh = sf.y * 0.4 * bp, fw = sf.x * 0.4 * bp;
		double oneW = so.x * bp, oneH = so.y * bp, upW = su.x * 0.4 * bp, upH = su.y * 0.4 * bp;
		double mW = minusK > 0 ? sm.x * 0.5 * bp : 0, mGap = minusK > 0 ? 0.8 * bp : 0;
		double total = fw + 1.4 * bp + mW + mGap + oneW + 0.4 * bp + upW;
		double x = cx - total * 0.5 * sxk;
		double fcx = x + fw * 0.5 * sxk;
		FaceAt(face, fcx, cy + droop * 0.6, fh * syk, a, grey, faceAng, 0);
		x += (fw + 1.4 * bp) * sxk;
		if (minusK > 0)
		{
			double mw = sm.x * 0.5 * bp * minusK, mh = sm.y * 0.5 * bp * minusK;
			double mcx = x + mW * 0.5 * sxk;
			TexC("RQVBMC", mcx + bp * 0.5, cy + bp * 0.5, mw * sxk, mh * syk, a * 0.66, 0);
			TexC("RQVBMC", mcx, cy, mw * sxk, mh * syk, a);
			x += (mW + mGap) * sxk;
		}
		double top = cy - oneH * 0.5 * syk + droop;
		Tex(one, x + bp, top + bp, oneW * sxk, oneH * syk, a * 0.66, 0);
		Tex(one, x, top, oneW * sxk, oneH * syk, a);
		x += (oneW + 0.4 * bp) * sxk;
		double ut = top + 0.4 * bp * syk + droop * 0.5;
		Tex(up, x + bp * 0.4, ut + bp * 0.4, upW * sxk, upH * syk, a * 0.66, 0);
		Tex(up, x, ut, upW * sxk, upH * syk, a);
		return fcx, cy;
	}

	// sparkles: n of them from (cx, cy) starting at tic st (mockup anim2 burst), sc the sparkle's mockup px a pixel
	ui void Burst(double t, double cx, double cy, double st, int n, int seed, double sc, bool shine)
	{
		static const int HOTC[] = { 0xFFE000, 0xFFB000, 0xFF8000, 0xF02838, 0xFFFFEB };
		double tf = (t - st) / 2.0;
		if (tf < 0) return;
		for (int i = 0; i < n; i++)
		{
			double ang = Rnd(seed, i, 1) * 360.0, v = 9 + 8 * Rnd(seed, i, 2), life = 10 + int(Rnd(seed, i, 3) * 7);
			if (tf >= life) continue;
			double d = v * tf * (1 - tf / (life * 2.2)) * m;
			int col = HOTC[i % (shine ? 5 : 4)];
			if (photo && col == 0xFFFFEB) col = 0xFFE000;
			double s = 7 * sc * m;
			TexC("RQVBSP", cx + cos(ang) * d, cy + sin(ang) * d * 0.8, s, s, 1 - tf / life, -1, col);
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (automapactive || menuactive != Menu.Off) return;
		photo = RSQTHP_A11y.Photo();
		EyeMap();
		double t = level.maptime + e.FracTic;
		DrawInvBar(t);
		if (!On()) return;
		let b = Current();
		if (!b) return;
		if (!f1) f1 = Font.GetFont("RSQVRBF1");
		if (!f2) f2 = Font.GetFont("RSQVRBF2");
		if (!f1 || !f2) return;
		double bt = t - b.t0;
		double ex = clamp((bt - b.exitAt) / EXIT, 0.0, 1.0);
		double exK = 1.0 - 0.6 * ex, exA = 1.0 - ex;
		double W = Screen.GetWidth();

		// THE PLACE (rig 11-16: the mockups put the top stack at the top of the eye, but in the headset the HUD is a window
		// round the gaze and RSQ Score's stack sits near its middle): the headline at the mockup's place over the gaze, or
		// lower, clear under the whole top stack (the invulnerability bar's row always counted, so nothing jumps when it
		// comes); the chips under the headline at the mockup's distances
		double clear = StackBottom();
		double rowY0, rowStep = 56 * m;
		if (b.moment == M_LIFEUP)
		{
			double cy = max(gy, clear + 80 * m);
			DrawOneUp(b, bt, t, cy);
			rowY0 = cy + 120 * m;
		}
		else if (b.moment == M_LIFEUSED)
		{
			double cy = max(gy - 80 * m, clear + 64 * m);
			DrawMinusOneUp(b, bt, exK, exA, cy);
			rowY0 = cy + 90 * m;
		}
		else
		{
			String hl = b.moment == M_REVIVE ? "REVIVE" : (b.moment == M_BOSSWIN ? "BOSS DEFEATED!" : "BOSS WINS!");
			String col = b.moment == M_BOSSLOSS ? "RSQVR_BnRed" : "RSQVR_BnGold";
			double px = 6 * 0.9 * m;
			double fit = min(1.0, W * 0.92 / max(1.0, f1.StringWidth(hl) * px));
			double k = min(PopK(bt - 2), 1.12) * exK;
			double cy = max(gy - 80 * m, clear + f1.GetHeight() * px * fit * 0.62 + 8 * m);
			Headline(hl, gx, cy, px * fit * k, exA, col);
			rowY0 = cy + 90 * m;
		}

		// the chips: each pops at its own start, two to a row
		int n = b.ck.Size();
		if (n == 0) return;
		double u = 0.85 * m;
		Array<double> cxs, cys;
		ChipPlaces(b, rowY0, rowStep, u, cxs, cys);
		// never wider than the view
		double widest = 0;
		for (int i = 0; i < n; i++) widest = max(widest, abs(cxs[i] - gx) + Chip(b, i, 0, 0, u, 1, true) * 0.5);
		double fit = widest * 2 > W * 0.94 ? W * 0.94 / (widest * 2) : 1.0;
		for (int i = 0; i < n; i++)
		{
			double cs = ChipStart(b.moment, i);
			double ct = bt - cs;
			if (ct < 0) continue;
			double k = PopK(ct) * fit;
			double ccx = gx + (cxs[i] - gx) * fit, ccy = cys[i];
			if (i == b.invIdx)
			{
				// THE HAND-OFF: blink, then fly up into the invulnerability bar's row and land
				if (ct >= 36) continue;
				int glow = 0;
				if (ct >= 20 && ct < 26) glow = photo ? 35 : (((int(ct) / 2) & 1) ? 0 : 100);
				else if (photo && ct >= 20) glow = 35;
				if (ct >= 26)
				{
					double p = Smooth((ct - 26) / 10.0);
					double bx, by, bw, bh;
					[bx, by, bw, bh] = InvRect();
					double tx = bx + bw * 0.5, ty = by + bh * 0.5;
					ccx += (tx - ccx) * p; ccy += (ty - ccy) * p;
					k = fit * (1.0 - 0.6 * p);
				}
				double w = Chip(b, i, 0, 0, u * k, 1, true);
				Chip(b, i, ccx - w * 0.5, ccy, u * k, 1.0, false, glow);
				continue;
			}
			if (b.moment == M_LIFEUP && bt >= FLY_AT) { k *= exK; }
			else k *= exK;
			double w = Chip(b, i, 0, 0, u * k, 1, true);
			Chip(b, i, ccx - w * 0.5, ccy, u * k, exA, false);
		}
	}

	// ---- +1UP (section 4: "a lot of life to it") ----
	ui void DrawOneUp(RSQVR_Banner b, double bt, double t, double cy)
	{
		double cx = gx;
		double bp = 10 * m * 0.9;
		// the gold flash (none in Photosensitive Mode) and the spinning rays
		if (!photo && bt < 6)
		{
			// a burst of light round the badge, kept inside the HUD (its edge would show as a box in the headset)
			double s = min(Screen.GetWidth(), Screen.GetHeight()) * 0.95;
			TexC("RQVBGL", cx, cy, s, s, 0.8 * (1 - bt / 6), -1, 0xFFFADC, true);
		}
		if (bt < 28)
		{
			double R = (80 + bt * 0.5 * 22) * m;
			int fr = (int(bt * 2.0 / 5.0) % 12 + 12) % 12;
			TexC(String.Format("RQVBR%02d", fr), cx, cy, 2 * R, 2 * R, (photo ? 0.4 : 0.67) * (1 - bt / 28.0), -1, 0xFFFFFF, true);
		}
		int shine = 0;
		if (!photo) { int k = (int(bt) / 4) % 7; if (k < 4) shine = k + 1; }
		double ang = 8 * sin(bt * 17.2) * max(0.2, 1 - bt / 60.0);
		if (bt < FLY_AT)
		{
			double kk = PopK(bt - 2, 10);
			if (kk <= 0) return;
			double sxk = kk, syk = kk;
			if (bt >= 10 && bt < 14) { sxk *= 1.2; syk *= 0.8; }
			double y = cy + 6 * m * sin(bt * 12.9);
			Badge(cx, y, bp, sxk, syk, 1.0, false, shine, "STFEVL0", false, ang, 0, 0);
			Burst(bt, cx, cy, 12, 18, b.seed, 3, false);
			return;
		}
		// the float up into the lives (Super Mario Bros.): to RSQ Score's newest face, or up off the top without Score
		bool score = level.maptime - livesTic <= 2 && livesH > 0;
		double tx = score ? livesX : gx, ty = score ? livesY : Screen.GetHeight() * 0.04;
		double faceH0 = 29 * 0.4 * bp;
		double k1 = score ? clamp(livesH / faceH0, 0.05, 1.0) : 0.2;
		if (bt < LAND_AT)
		{
			double p = Smooth((bt - FLY_AT) / double(LAND_AT - FLY_AT));
			double k = 1.0 + (k1 - 1.0) * p;
			// the face is what lands on the slot: the badge's face centre goes to the target
			double fcx0, fcy0;
			[fcx0, fcy0] = BadgeFace(cx, cy, bp);
			double fx = fcx0 + (tx - fcx0) * p, fy = fcy0 + (ty - fcy0) * p;
			double bcx = fx + (cx - fcx0) * k, bcy = fy;
			Badge(bcx, bcy, bp * k, 1, 1, score ? 1.0 : 1.0 - 0.7 * p, false, shine, "STFEVL0", false, ang * (1 - p), 0, 0);
			return;
		}
		Burst(bt, tx, ty, LAND_AT, 12, b.seed + 5, 2, true);
	}
	// where the badge's face sits for a badge centred at (cx, cy) (Badge's layout, the +1UP: no minus)
	ui double, double BadgeFace(double cx, double cy, double bp)
	{
		Vector2 so = TexMan.GetScaledSize(T("RQVBO0")), su = TexMan.GetScaledSize(T("RQVBU0"));
		TextureID ft = T("STFEVL0");
		Vector2 sf = (24, 29);
		if (ft.IsValid()) sf = TexMan.GetScaledSize(ft);
		double fw = sf.x * 0.4 * bp;
		double total = fw + 1.4 * bp + so.x * bp + 0.4 * bp + su.x * 0.4 * bp;
		return cx - total * 0.5 + fw * 0.5, cy;
	}

	// ---- -1UP ----
	ui void DrawMinusOneUp(RSQVR_Banner b, double bt, double exK, double exA, double cy)
	{
		double bp = 10 * m * 0.9 * 0.8;
		double cx = gx;
		double k = min(PopK(bt, POP), 1.12) * exK;
		if (k <= 0) return;
		bool spent = bt >= 8;
		// the red flash and the shake as the minus slams in (neither in Photosensitive Mode)
		if (spent && !photo && bt < 14)
		{
			double s = min(Screen.GetWidth(), Screen.GetHeight()) * 0.95;
			TexC("RQVBGL", cx, cy, s, s, 0.6 * (1 - (bt - 8) / 6.0), -1, 0xFF2828, true);
		}
		double shake = 0;
		if (spent && !photo && bt < 24) shake = (Rnd(b.seed, int(bt) / 2, 9) * 16 - 8) * m * (1 - (bt - 8) / 16.0);
		double mk = 0;
		if (spent) { mk = PopK(bt - 8, 6); if (bt < 12) mk *= 1.6; }
		double droop = bt >= 24 ? min(12.0, (bt - 24) * 0.75) * m : 0;
		Badge(cx + shake, cy, bp, k, k, exA, spent, 0, spent ? "STFOUCH0" : "STFST01", spent, 0, mk, droop);
	}

	// =================================================================================================================
	// THE INVULNERABILITY BAR (design section 5): invbar.zs
}
