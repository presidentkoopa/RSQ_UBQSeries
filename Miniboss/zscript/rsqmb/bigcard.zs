// ============================================================================
// RSQ_Miniboss -- THE BIG BOSS ARRIVAL CARD (design/BIG_BOSS.md 11 "Arrival"; mockup design/mockups/big_boss_tyrant/
// tyrant_arrival_v2_real.gif; owner 2026-11-23 07:5x: "Build as mockup"). EVERY Big Boss has its own card (owner
// 2026-11-25: "all big bosses need an arrival card with their weak points like house of the dead"): all 18 of the pool
// shown on the rig 2026-11-25 (name, kind, HP, its three weak points circled where the fight puts them; outputs
// bigboss_cards_1/2.png). Rig only, not headset-confirmed.
//
//   WHEN            a Big Boss fight arriving (bossfight.zs StartArrival, not a quiet retry): its landing waits
//                   rsqmb_big_card_secs (3.3 s) longer, and the landing's slow motion and dark (SlowMo's slowest, Glow In The
//                   Dark's black) are stretched over it, so the world stands nearly still while the card shows.
//   THE CARD        drawn on the HUD over a dimmed world, House of the Dead's look: grid paper; the Big Boss drawn in ink from
//                   its own sprite (its silhouette, revealed top to bottom; the mockup's edge-traced sketch cannot be made
//                   from a sprite at run time); its weak points circled one after another (the wind-up's own layout,
//                   telegraph.zs MakeWeakPoints, at the spots telegraph.zs Place puts them: side x its radius to its own
//                   right, up x its height, measured on its sprite by the sprite's offsets and scale; Benellus' ghost
//                   guns, which appear beside YOU, off his sides) with lines to WEAK POINT; then the black
//                   plate with the red edge: its name in gold, slammed in; its kind and EX tier; HP counting up to all its
//                   lives together (bigfix.zs's life health x its lives, as it will be bound). It grows in, holds, and slides
//                   up and out.
//   THE DROP-IN     the moment it is bound (telegraph.zs RSQMB_Tele.Make): a quake, the slam's sound and five pentagram
//                   lines of fire cracking out over the floor, with a shock ring (RSQMB_SlamLines: sight only, no damage).
//   Row: Big Boss Arrival Card (rsqmb_big_card), Card Length (rsqmb_big_card_secs).
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
		CardWho(cls, cardName, cardKind);
		CardLayout(n, cardSX, cardSY);
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
	// EVERY BIG BOSS'S OWN CARD (owner 2026-11-25: "all big bosses need an arrival card with their weak points like house
	// of the dead"). Its name: the five built Big Bosses' own (BIG_BOSS.md 11-15); every other EX boss by the name its
	// monster carries (RSQ Monsters' port of Colourful Hell / Plus: its Tag, EX_BOSS_DOSSIER.md), its kind the colour and
	// the family. An EX boss not listed (a new one): its Tag, else the Boss bar's name; its kind BIG BOSS.
	static void CardWho(class<Actor> cls, out String nm, out String kd)
	{
		String n = cls ? cls.GetClassName() : 'None';
		let k = RSQMB_BigKit.Lookup(n);         // bigkit.zs: its own kit names it
		if (k && k.Card() != "") { nm = k.Card(); kd = k.Kind() != "" ? k.Kind() : "BIG BOSS"; return; }
		static const String CC[] = { "RS_BlackCybieEX", "RS_BlackImpEX", "RS_BlackRevenantEX", "RS_BlackFatsoEX", "RS_WhiteSGEX",
			"RS_BlackZombieEX", "RS_BlackCGuyEX", "RS_BlackCacoEX", "RS_WhiteLSoulEX", "RS_BlackHKEX", "RS_BlackSPEX",
			"RS_BlackSpectreEX", "RS_WhiteSPEX", "RS_BlackArchEX", "RS_WhiteArchEX", "RS_WhiteCybieEX", "RS_WhiteMindES",
			"RS_WhiteSPFusion" };
		static const String CN[] = { "OBSIDIAN TYRANT", "IMP WARLORD", "THE BLACK KNIGHT", "THE THING FROM THE BOG", "BENELLUS",
			"PLAYER X", "WARFACE", "SHOCKMASTER", "THE VENGEFUL SOUL", "TERMINATOR MK II",
			"MACROSS MISSILE SWARM", "THE BACKSTABBER UNSILENCED", "WHITE HOT SPIDER", "NOCTIS", "PURIFIER",
			"CYBERTRON", "EVERLASTING WHITE SPIDEY", "WHITE SPIDER OF TERROR" };
		static const String CK[] = { "HELL SMITH", "SMOKING BLACK IMP", "BLACK REVENANT", "BLACK MANCUBUS", "GOD OF SHOTGUNS",
			"BLACK ZOMBIEMAN", "BLACK CHAINGUNNER", "BLACK CACODEMON", "WHITE LOST SOUL", "BLACK HELL KNIGHT", "BLACK ARACHNOTRON",
			"BLACK SPECTRE", "WHITE ARACHNOTRON", "BLACK ARCH-VILE", "WHITE ARCH-VILE", "WHITE CYBERDEMON", "WHITE SPIDER MASTERMIND",
			"WHITE ARACHNOTRON" };
		for (int i = 0; i < CC.Size(); i++) if (n ~== CC[i]) { nm = CN[i]; kd = CK[i]; return; }
		let d = cls ? GetDefaultByType(cls) : null;
		String tag = d ? d.GetTag("") : "";
		nm = tag != "" && !(tag ~== n) ? tag.MakeUpper() : BossNameOfClass(cls).MakeUpper();
		kd = "BIG BOSS";
	}
	// ITS WEAK POINTS ON THE CARD: the fight's own layout, point for point (telegraph.zs MakeWeakPoints: across as a share of
	// its radius, + its own right; up as a share of its height). Keep the two in step. Benellus' second and third are
	// his ghost guns, which appear beside YOU: on the card they stand off his sides (CardDraw).
	static void CardLayout(String n, Array<double> sx, Array<double> sy)
	{
		sx.Clear(); sy.Clear();
		let k = RSQMB_BigKit.Lookup(n);         // bigkit.zs: its own weak points, as its first life places them
		if (k) { k.Points(1, sx, sy); if (sx.Size() > 0) return; }
		if (n ~== "RS_BlackCybieEX")         CardPts(sx, sy, 0, 0.86, -0.8, 0.55, 0.8, 0.62);      // head, both forge arms
		else if (n ~== "RS_BlackImpEX")      CardPts(sx, sy, 0, 0.9, -0.85, 0.55, 0.85, 0.55);     // head, the two charge orbs
		else if (n ~== "RS_BlackRevenantEX") CardPts(sx, sy, 0, 0.92, 0.75, 0.6, -0.75, 0.52);     // helmet, sword arm, shield arm
		else if (n ~== "RS_BlackFatsoEX")    CardPts(sx, sy, 0, 0.42, 0, 0.86, 0.7, 0.72);         // belly, head, shoulder
		else if (n ~== "RS_WhiteSGEX")       CardPts(sx, sy, 0, 0.8, -1, 0, 1, 0);                 // his face; the ghost guns
		else                                 CardPts(sx, sy, 0, 0.88, -0.6, 0.6, 0.6, 0.38);       // every other Big Boss
	}
	static void CardPts(Array<double> sx, Array<double> sy, double x0, double y0, double x1, double y1, double x2, double y2)
	{
		sx.Push(x0); sy.Push(y0); sx.Push(x1); sy.Push(y1); sx.Push(x2); sy.Push(y2);
	}

	// RSQMB_Tele.Make: the Big Boss is down: the drop-in (once a card)
	void CardSlam(Actor mb)
	{
		if (!cardSlamDue || !mb) return;
		cardSlamDue = false;
		mb.A_Quake(7, 24, 0, 1536, "");
		mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		mb.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.8, ATTN_NORM);
		let s = RSQMB_SlamLines(Actor.Spawn("RSQMB_SlamLines", (mb.pos.xy, mb.floorz), NO_REPLACE));
		if (s) s.angle = mb.angle;
		if (debug) Console.Printf("RSQMB BIG BOSS t%d: %s drops in (quake, five pentagram lines)", level.maptime, mb.GetClassName());
	}

	// ---- the card on the HUD (hud.zs RenderOverlay, first) --------------------------------------------------------------
	// VR: as the Boss meter and bar (hud.zs, bossbar.zs): boxes (RSQMBWH tinted), textures and thick lines only; no
	// Screen.Dim and no clip rectangle (neither shows on the projected HUD in VR; on the rig a Dim was drawn over every
	// texture and word of the card: rig card_t1 2026-11-25, paper and plate only). The reveal crops the SOURCE (DTA_SrcY).
	ui void CardBox(TextureID wh, double x, double y, double w, double h, Color c, double a = 1.0)
	{
		if (w <= 0 || h <= 0 || a <= 0) return;
		Screen.DrawTexture(wh, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Color, c, DTA_Alpha, a, DTA_TopLeft, true);
	}
	// hud.zs RenderOverlay calls this first; the card is drawn by its own layer (RSQMB_CardLayer below, MAPINFO) so that it
	// lies over the Boss bar and RSQ VisualRewards' BIG BOSS INCOMING! banner (rig card_t1 2026-11-25: both were drawn over
	// its plate and its middle). Without the layer registered, here as before.
	ui void CardDraw(RenderEvent e)
	{
		if (EventHandler.Find("RSQMB_CardLayer")) return;
		CardDrawNow(e);
	}
	ui void CardDrawNow(RenderEvent e)
	{
		if (cardEnd <= 0) return;
		double t = level.maptime + e.FracTic;
		if (t < cardStart || t > cardEnd + 10) return;
		TextureID wh = TexMan.CheckForTexture("RSQMBWH", TexMan.Type_Any);
		if (!wh.IsValid()) return;
		double len = max(1, cardEnd - cardStart);
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		// the world dims (and stays nearly still: the slow motion)
		double dk = clamp((t - cardStart) / 8.0, 0.0, 1.0) * clamp((cardEnd + 10 - t) / 10.0, 0.0, 1.0);
		CardBox(wh, 0, 0, sw, sh, Color(255, 20, 20, 22), 0.6 * dk);
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
		CardBox(wh, x0, y0, cw, plateY - y0, Color(255, 214, 212, 198));
		double g = cw / 760.0 * 24.0;
		Color gc = Color(255, 150, 160, 168);
		for (double gx = x0 + g; gx < x0 + cw - 1; gx += g) Screen.DrawThickLine(int(gx), int(y0), int(gx), int(plateY), max(1.0, cw / 500.0), gc, 255);
		for (double gy = y0 + g; gy < plateY - 1; gy += g) Screen.DrawThickLine(int(x0), int(gy), int(x0 + cw), int(gy), max(1.0, cw / 500.0), gc, 255);
		// the Big Boss in ink, revealed top to bottom
		double sx0 = x0 + cw * 0.06, sy0 = y0 + ch * 0.03, sbw = cw * 0.38, sbh = plateY - sy0 - ch * 0.03;
		class<Actor> cls = cardCls;
		let def = cls ? GetDefaultByType(cls) : null;
		double ix = sx0, iy = sy0, iw = sbw, ih = sbh;
		// where its body stands in the picture, so the circles sit where the fight's weak points will: the sprite's own
		// offsets give the spot under its middle (its feet), its scale how many world units a pixel is
		double footX = sx0 + sbw * 0.5, footY = sy0 + sbh, pxu = 0, pxv = 0;
		if (def && def.SpawnState)
		{
			TextureID tex; bool flip; Vector2 sc;
			[tex, flip, sc] = def.SpawnState.GetSpriteTexture(0, 0, def.Scale);
			if (tex.IsValid())
			{
				Vector2 ts = TexMan.GetScaledSize(tex);
				double k = min(sbw / max(1.0, ts.x), sbh / max(1.0, ts.y));
				iw = ts.x * k; ih = ts.y * k;
				ix = sx0 + (sbw - iw) * 0.5; iy = sy0 + (sbh - ih);
				Vector2 off = TexMan.GetScaledOffset(tex);
				footX = flip ? ix + iw - off.x * k : ix + off.x * k;
				footY = iy + clamp(off.y, 0.0, ts.y) * k;
				pxu = k / max(0.01, abs(sc.x)); pxv = k / max(0.01, abs(sc.y));
				int rows = int(round(ts.y * clamp(prog / 0.35, 0.0, 1.0)));
				if (rows > 0)
					Screen.DrawTexture(tex, false, ix, iy, DTA_DestWidthF, iw, DTA_DestHeightF, ih * rows / ts.y, DTA_FillColor, Color(255, 84, 84, 80),
						DTA_SrcY, 0.0, DTA_SrcHeight, double(rows), DTA_Alpha, 0.92, DTA_TopLeft, true, DTA_FlipX, flip);
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
		double r = max(ih * 0.085, ch * 0.05);
		for (int i = 0; i < cardSX.Size(); i++)
		{
			double u = (prog - 0.4 - i * 0.08) / 0.1;
			if (u <= 0) continue;
			u = min(1.0, u);
			// the fight's spot (telegraph.zs Place): side x its radius to its own right (your left, as it faces you), up x
			// its height over its feet. Benellus' ghost guns (beside YOU): off his sides. Without a sprite: by share
			double cx, cy;
			bool ghost = false;     // Benellus' ghost guns are gone (bigkit.zs: his own code has none)
			if (ghost) { cx = cardSX[i] < 0 ? ix - r * 1.6 : ix + iw + r * 1.6; cy = iy + ih * 0.55; }
			else if (pxu > 0 && def) { cx = footX - cardSX[i] * def.radius * pxu; cy = footY - cardSY[i] * def.height * pxv; }
			else { cx = ix + iw * 0.5 - cardSX[i] * iw * 0.42; cy = iy + ih * (1.0 - cardSY[i]); }
			int segs = 28, n = int(ceil(segs * u));
			double lw = max(2.0, cw / 130.0);
			Color ink = Color(255, 30, 30, 28);
			// a pale halo under the ink, so a circle reads on the dark body as on the paper
			for (int pass = 0; pass < 2; pass++)
			for (int k = 0; k < n; k++)
			{
				double a0 = 360.0 * k / segs, a1 = 360.0 * min(k + 1, segs * u) / segs;
				Screen.DrawThickLine(int(cx + cos(a0) * r), int(cy + sin(a0) * r), int(cx + cos(a1) * r), int(cy + sin(a1) * r),
					pass ? lw : lw * 2.2, pass ? ink : Color(255, 236, 232, 218), 255);
			}
			if (u >= 1.0)
			{
				double ex = cx + (wx > cx ? r * 0.7 : -r * 0.7), ey = cy - r * 0.7;
				Screen.DrawThickLine(int(ex), int(ey), int(wx - 6), int(wy), max(1.0, cw / 260.0), ink, 255);
			}
		}
		// the plate: black, its red edge, the name slammed in gold, the kind and tier, HP counting up
		CardBox(wh, x0, plateY, cw, y0 + ch - plateY, Color(255, 16, 12, 12));
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
		// the kind and tier on the left, HP on the right: the HP's room is kept (the widest it will count to), the kind line
		// shrunk to the rest when it is long (rig 2026-11-25: WHITE SPIDER MASTERMIND ran under the HP)
		double hfs = ch * 0.08 / max(1, BigFont.GetHeight());
		double hpRoom = BigFont.StringWidth("HP " .. CommaNum(cardHP)) * hfs;
		if (prog > 0.8)
		{
			String kind = String.Format("%s  TYPE EX-%d", cardKind, cardTier);
			double fs = ch * 0.045 / max(1, SmallFont.GetHeight());
			double room = cw * 0.91 - hpRoom;
			double kw = SmallFont.StringWidth(kind) * fs;
			if (kw > room && room > 0) fs *= room / kw;
			Screen.DrawText(SmallFont, Font.CR_WHITE, x0 + cw * 0.03, y0 + ch - ch * 0.1, kind, DTA_ScaleX, fs, DTA_ScaleY, fs);
		}
		if (prog > 0.84)
		{
			double u = clamp((prog - 0.84) / 0.14, 0.0, 1.0);
			int v = int(round(cardHP * u / 10.0)) * 10;
			if (u >= 1.0) v = cardHP;
			String hp = "HP " .. CommaNum(v);
			double w = BigFont.StringWidth(hp) * hfs;
			Screen.DrawText(BigFont, Font.CR_RED, x0 + cw - w - cw * 0.03, y0 + ch - ch * 0.13, hp, DTA_ScaleX, hfs, DTA_ScaleY, hfs);
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
		if (age < 8)
		{
			double r = 40 + age * 45;
			for (int k = 0; k < 48; k++)
				A_SpawnParticle(0xFFC878, SPF_FULLBRIGHT, 2, 8, 0, cos(k * 7.5) * r, sin(k * 7.5) * r, 4, 0, 0, 0, 0, 0, 0, 1.0 - age / 8.0);
		}
	}
	States { Spawn: TNT1 A -1; Stop; }
}

// THE CARD'S OWN LAYER: the arrival card over every other HUD piece (the Boss bar, the banners of RSQ VisualRewards and
// RSQ Score): an event handler late in the order draws its overlay after the others
class RSQMB_CardLayer : EventHandler
{
	override void OnRegister() { SetOrder(9000); }
	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive || menuactive != Menu.Off) return;
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (h) h.CardDrawNow(e);
	}
}
