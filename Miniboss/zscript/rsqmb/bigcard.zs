// ============================================================================
// RSQ_Miniboss -- THE BIG BOSS ARRIVAL CARD (design/BIG_BOSS.md 11 "Arrival"; mockup design/mockups/big_boss_tyrant/
// tyrant_arrival_v2_real.gif; owner 2026-11-23 07:5x: "Build as mockup"). Code only, not run.
//
//   WHEN            a Big Boss fight arriving (bossfight.zs StartArrival, not a quiet retry): its landing waits
//                   rsqmb_big_card_secs (3.3 s) longer, and the landing's slow motion and dark (SlowMo's slowest, Glow In The
//                   Dark's black) are stretched over it, so the world stands nearly still while the card shows.
//   THE CARD        drawn on the HUD over a dimmed world, House of the Dead's look: grid paper; the Big Boss drawn in ink from
//                   its own sprite (its silhouette, revealed top to bottom; the mockup's edge-traced sketch cannot be made
//                   from a sprite at run time); its weak points circled one after another (the wind-up's own layout,
//                   telegraph.zs MakeWeakPoints; Benellus' ghost guns at his sides) with lines to WEAK POINT; then the black
//                   plate with the red edge: its name in gold, slammed in; its kind and EX tier; HP counting up to all its
//                   lives together (bigfix.zs's life health x its lives, as it will be bound). It grows in, holds, and slides
//                   up and out.
//   THE DROP-IN     the moment it is bound (telegraph.zs RSQMB_Tele.Make): a quake, the slam's sound and five pentagram
//                   lines of fire cracking out over the floor, with a shock ring (RSQMB_SlamLines: sight only, no damage).
//   Row: Big Boss Arrival Card (rsqmb_big_card), Card Length (rsqmb_big_card_secs). Photosensitive Mode: no slam flash.
// ============================================================================

extend class RSQMB_Handler
{
	// the card on its way (play sets, the HUD reads)
	int cardStart, cardEnd, cardHP, cardTier;
	String cardName, cardKind, cardCls;
	Array<double> cardSX, cardSY;
	bool cardSlamDue;

	static clearscope bool CardOn() { return CI('rsqmb_big_card', 1) != 0; }
	static int CardTics() { return int(clamp(CF('rsqmb_big_card_secs', 3.3), 1.0, 8.0) * TICRATE); }

	// bossfight.zs StartArrival: a Big Boss's card, its landing put back by the card's length. Answers the tics added.
	int CardPlan(class<Actor> cls, int tier)
	{
		if (!cls || !CardOn()) return 0;
		int len = CardTics();
		cardStart = level.maptime + CHAMP_LEAD;
		cardEnd = cardStart + len;
		cardCls = cls.GetClassName();
		cardTier = tier;
		cardSX.Clear(); cardSY.Clear();
		String n = cardCls;
		// the name, the kind and the weak points (telegraph.zs MakeWeakPoints' layouts; BIG_BOSS.md 11-15)
		if (n ~== "RS_BlackCybieEX") { cardName = "OBSIDIAN TYRANT"; cardKind = "HELL SMITH"; CardPts(0, 0.86, -0.8, 0.55, 0.8, 0.62); }
		else if (n ~== "RS_BlackImpEX") { cardName = "IMP WARLORD"; cardKind = "SMOKING BLACK IMP"; CardPts(0, 0.9, -0.85, 0.55, 0.85, 0.55); }
		else if (n ~== "RS_BlackRevenantEX") { cardName = "THE BLACK KNIGHT"; cardKind = "BLACK REVENANT"; CardPts(0, 0.92, 0.75, 0.6, -0.75, 0.52); }
		else if (n ~== "RS_BlackFatsoEX") { cardName = "THE THING FROM THE BOG"; cardKind = "BLACK MANCUBUS"; CardPts(0, 0.42, 0, 0.86, 0.7, 0.72); }
		else if (n ~== "RS_WhiteSGEX") { cardName = "BENELLUS"; cardKind = "GOD OF SHOTGUNS, ANGRIER"; CardPts(0, 0.8, -1.25, 0.45, 1.25, 0.45); }
		else { cardName = BossNameOfClass(cls).MakeUpper(); cardKind = "BIG BOSS"; CardPts(0, 0.88, -0.6, 0.6, 0.6, 0.38); }
		// HP: all its lives as it will be bound (bigfix.zs BigLifeHP's rule, from its default health)
		let def = GetDefaultByType(cls);
		int spawn = def ? max(1, def.Health) : 1000;
		double ttk = clamp(CF('rsqmb_big_ttk', 60), 30, 180), dps = 0;
		bool any = false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			double v = DpsOf(players[pn].mo);
			if (v > 0) { dps += v; any = true; }
		}
		int life = any ? int(min(dps * ttk, 2e8)) : spawn;
		life = max(life, max(1, spawn / 2));
		cardHP = int(min(double(life) * clamp(CI('rsqmb_lives', 3), 1, 9), 2e9));
		cardSlamDue = true;
		if (debug) Console.Printf("RSQMB BIG BOSS CARD t%d: %s (%s, EX-%d, HP %d), %d tics; its landing put back as long", level.maptime, cardName, cardKind, tier, cardHP, len);
		return len;
	}
	void CardPts(double x0, double y0, double x1, double y1, double x2, double y2)
	{
		cardSX.Push(x0); cardSY.Push(y0); cardSX.Push(x1); cardSY.Push(y1); cardSX.Push(x2); cardSY.Push(y2);
	}

	// RSQMB_Tele.Make: the Big Boss is down: the drop-in (once a card)
	void CardSlam(Actor mb)
	{
		if (!cardSlamDue || !mb) return;
		cardSlamDue = false;
		mb.A_Quake(RSQMB_A11y.Photo() ? 3 : 7, 24, 0, 1536, "");
		mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		mb.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.8, ATTN_NORM);
		let s = RSQMB_SlamLines(Actor.Spawn("RSQMB_SlamLines", (mb.pos.xy, mb.floorz), NO_REPLACE));
		if (s) s.angle = mb.angle;
		if (debug) Console.Printf("RSQMB BIG BOSS t%d: %s drops in (quake, five pentagram lines)", level.maptime, mb.GetClassName());
	}

	// ---- the card on the HUD (hud.zs RenderOverlay, first) --------------------------------------------------------------
	ui void CardDraw(RenderEvent e)
	{
		if (cardEnd <= 0) return;
		double t = level.maptime + e.FracTic;
		if (t < cardStart || t > cardEnd + 10) return;
		double len = max(1, cardEnd - cardStart);
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		// the world dims (and stays nearly still: the slow motion)
		double dk = clamp((t - cardStart) / 8.0, 0.0, 1.0) * clamp((cardEnd + 10 - t) / 10.0, 0.0, 1.0);
		Screen.Dim(Color(255, 20, 20, 22), 0.6 * dk, 0, 0, int(sw), int(sh));
		// the card: grows in over 6 tics, slides up and out over the last 8
		double age = t - cardStart;
		double grow = 0.6 + 0.4 * clamp(age / 6.0, 0.0, 1.0);
		double cw = min(sw * 0.66, sh * 1.2) * grow, ch = cw * 500.0 / 760.0;
		double slideK = clamp((t - (cardEnd - 8)) / 8.0, 0.0, 1.0);
		double x0 = (sw - cw) * 0.5, y0 = sh * 0.18 - slideK * (sh * 0.18 + ch + 20);
		if (y0 + ch < 0) return;
		double prog = clamp((age - 6) / (len * 0.82), 0.0, 1.0);
		double plateY = y0 + ch * 0.644;
		// paper and grid
		Screen.Dim(Color(255, 214, 212, 198), 1.0, int(x0), int(y0), int(cw), int(plateY - y0));
		double g = cw / 760.0 * 24.0;
		for (double gx = x0; gx < x0 + cw; gx += g) Screen.DrawThickLine(int(gx), int(y0), int(gx), int(plateY), 1, Color(255, 170, 172, 160), 255);
		for (double gy = y0; gy < plateY; gy += g) Screen.DrawThickLine(int(x0), int(gy), int(x0 + cw), int(gy), 1, Color(255, 170, 172, 160), 255);
		// the Big Boss in ink, revealed top to bottom
		double sx0 = x0 + cw * 0.06, sy0 = y0 + ch * 0.03, sbw = cw * 0.38, sbh = plateY - sy0 - ch * 0.03;
		class<Actor> cls = cardCls;
		let def = cls ? GetDefaultByType(cls) : null;
		double ix = sx0, iy = sy0, iw = sbw, ih = sbh;
		if (def && def.SpawnState)
		{
			TextureID tex; bool flip; Vector2 sc;
			[tex, flip, sc] = def.SpawnState.GetSpriteTexture(0);
			if (tex.IsValid())
			{
				Vector2 ts = TexMan.GetScaledSize(tex);
				double k = min(sbw / max(1.0, ts.x), sbh / max(1.0, ts.y));
				iw = ts.x * k; ih = ts.y * k;
				ix = sx0 + (sbw - iw) * 0.5; iy = sy0 + (sbh - ih);
				double cut = iy + ih * clamp(prog / 0.35, 0.0, 1.0);
				Screen.DrawTexture(tex, false, ix, iy, DTA_DestWidthF, iw, DTA_DestHeightF, ih, DTA_FillColor, Color(255, 40, 40, 38),
					DTA_ClipBottom, int(cut), DTA_Alpha, 0.92, DTA_TopLeft, true);
			}
		}
		// WEAK POINT and the circles, one after another, each with its line to the words
		double wx = x0 + cw * 0.5, wy = y0 + ch * 0.25;
		double fh = ch * 0.09;
		if (prog > 0.62)
		{
			double fs = fh / max(1, BigFont.GetHeight());
			Screen.DrawText(BigFont, Font.CR_BLACK, wx, wy - fh * 0.5, "WEAK POINT", DTA_ScaleX, fs, DTA_ScaleY, fs);
		}
		double r = ih * 0.085;
		for (int i = 0; i < cardSX.Size(); i++)
		{
			double u = (prog - 0.4 - i * 0.08) / 0.1;
			if (u <= 0) continue;
			u = min(1.0, u);
			double cx = ix + iw * 0.5 + cardSX[i] * iw * 0.42, cy = iy + ih * (1.0 - cardSY[i]);
			int segs = 28, n = int(ceil(segs * u));
			for (int k = 0; k < n; k++)
			{
				double a0 = 360.0 * k / segs, a1 = 360.0 * min(k + 1, segs * u) / segs;
				Screen.DrawThickLine(int(cx + cos(a0) * r), int(cy + sin(a0) * r), int(cx + cos(a1) * r), int(cy + sin(a1) * r), max(2.0, cw / 380.0), Color(255, 30, 30, 28), 255);
			}
			if (u >= 1.0) Screen.DrawThickLine(int(cx + r * 0.7), int(cy - r * 0.7), int(wx - 6), int(wy), max(1.0, cw / 500.0), Color(255, 30, 30, 28), 255);
		}
		// the plate: black, its red edge, the name slammed in gold, the kind and tier, HP counting up
		Screen.Dim(Color(255, 16, 12, 12), 1.0, int(x0), int(plateY), int(cw), int(y0 + ch - plateY));
		Screen.DrawThickLine(int(x0), int(plateY), int(x0 + cw), int(plateY), max(2.0, cw / 190.0), Color(255, 200, 30, 24), 255);
		if (prog > 0.7)
		{
			double ns = 1.0;
			int step = min(3, int((prog - 0.7) * len * 0.82));
			if (step == 0) ns = 1.5; else if (step == 1) ns = 1.25; else if (step == 2) ns = 1.08; else ns = 1.0;
			double nh = ch * 0.12 * ns;
			double fs = nh / max(1, BigFont.GetHeight());
			double nw = BigFont.StringWidth(cardName) * fs;
			if (nw > cw - 24) { fs *= (cw - 24) / nw; nw = cw - 24; }
			Screen.DrawText(BigFont, Font.CR_GOLD, x0 + (cw - nw) * 0.5, plateY + ch * 0.05, cardName, DTA_ScaleX, fs, DTA_ScaleY, fs);
		}
		if (prog > 0.8)
		{
			String kind = String.Format("%s  TYPE EX-%d", cardKind, cardTier);
			double fs = ch * 0.045 / max(1, SmallFont.GetHeight());
			Screen.DrawText(SmallFont, Font.CR_WHITE, x0 + cw * 0.03, y0 + ch - ch * 0.1, kind, DTA_ScaleX, fs, DTA_ScaleY, fs);
		}
		if (prog > 0.84)
		{
			double u = clamp((prog - 0.84) / 0.14, 0.0, 1.0);
			int v = int(round(cardHP * u / 10.0)) * 10;
			String hp = "HP " .. CommaNum(v);
			double fs = ch * 0.08 / max(1, BigFont.GetHeight());
			double w = BigFont.StringWidth(hp) * fs;
			Screen.DrawText(BigFont, Font.CR_RED, x0 + cw - w - cw * 0.03, y0 + ch - ch * 0.13, hp, DTA_ScaleX, fs, DTA_ScaleY, fs);
		}
		// the frame
		int fw = int(max(2.0, cw / 250.0));
		Screen.DrawThickLine(int(x0), int(y0), int(x0 + cw), int(y0), fw, Color(255, 90, 90, 84), 255);
		Screen.DrawThickLine(int(x0), int(y0 + ch), int(x0 + cw), int(y0 + ch), fw, Color(255, 90, 90, 84), 255);
		Screen.DrawThickLine(int(x0), int(y0), int(x0), int(y0 + ch), fw, Color(255, 90, 90, 84), 255);
		Screen.DrawThickLine(int(x0 + cw), int(y0), int(x0 + cw), int(y0 + ch), fw, Color(255, 90, 90, 84), 255);
	}

	static clearscope String CommaNum(int v)
	{
		String s = String.Format("%d", v), o = "";
		int n = s.Length();
		for (int i = 0; i < n; i++)
		{
			o = o .. s.Mid(i, 1);
			int left = n - 1 - i;
			if (left > 0 && left % 3 == 0) o = o .. ",";
		}
		return o;
	}
}

// THE DROP-IN: five pentagram lines of fire cracking out over the floor from where it landed, and a shock ring (sight only)
class RSQMB_SlamLines : Actor
{
	int age;
	Default { +NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +NOTONAUTOMAP; RenderStyle "None"; }
	override void Tick()
	{
		if (isFrozen()) return;
		age++;
		if (age > 30) { Destroy(); return; }
		double a = age < 20 ? 1.0 : 1.0 - (age - 20) / 10.0;
		double reach = min(420.0, age * 38.0);
		for (int k = 0; k < 5; k++)
		{
			double ang = angle + 90 + k * 72.0;
			for (double d = 16; d < reach; d += 12)
				A_SpawnParticle(0xFF4614, SPF_FULLBRIGHT, 3, 7, 0, cos(ang) * d, sin(ang) * d, 2, 0, 0, 0, 0, 0, 0, a);
		}
		if (age < 8 && !RSQMB_A11y.Photo())
		{
			double r = 40 + age * 45;
			for (int k = 0; k < 48; k++)
				A_SpawnParticle(0xFFC878, SPF_FULLBRIGHT, 2, 8, 0, cos(k * 7.5) * r, sin(k * 7.5) * r, 4, 0, 0, 0, 0, 0, 0, 1.0 - age / 8.0);
		}
	}
	States { Spawn: TNT1 A -1; Stop; }
}
