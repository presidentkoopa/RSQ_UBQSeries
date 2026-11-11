// THE LEGENDOOM HUD, DIRECTION D (owner 11-11 15:30; design/mockups/legendoom_hud/README.md "Direction D" and "Owner's
// decision", D_overview.png, D_card_V3_shimmer.gif, D_sequence.png). The mockup README names no home for the HUD, so it
// lives here, in the pack that draws the Gun Bonsai VR gauges the row hangs under. (LEGENDARY over a risen legendary is a
// monster word: RSQ VisualRewards' rsqvr/ldword.zs.)
//
// THE PICKUP CARD (V3, the SOTN shimmer title). When the console player takes a LegenDoom weapon power (a new
// LD<Slot>Effect_<Power> item: LegenDoom's own pickups and BD22 VR's LD mode both give one), one Gun Bonsai VR card in the
// power's rarity colour, on the HUD plane, about 3 s, no key to close it:
//   - the title: the power's name (LegenDoom's LD_FX_TITLE_*) as the SOTN two-tone word (RS Score's font, the QVW glyphs of
//     RSQ VisualRewards: each letter's top half in one tone, its bottom half in the other, on a near-black box), flashing
//     between its two looks every 10 tics as the GIF does (280 ms);
//   - the sub line: the rarity and the gun: "EPIC  RIFLE", the tag of the gun in your hand that the power is on (BD22 tags
//     its Rifle "Rifle"), else of a gun of that slot you carry, else LegenDoom's own slot name;
//   - the description (LegenDoom's LD_FX_DESCR_*, its first paragraph: the joke quote is left out) in RS Score's small font;
//   - LegenDoom's own power icon in the dark icon box, bottom right.
// Then it FOLDS (14 tics) into the gauge row of the hand that holds the power's gun: it shrinks and slides there while the
// row comes in. No such hand: it fades where it is.
// While the card is up, LegenDoom's own pickup screen (LEGNDLIB.acs EffectScreen: HudMessage ids 12300..12303, held 7.5 s,
// closed by Use / Fire / Alt-fire) is taken off the HUD (BaseStatusBar.DetachMessageID). Its jingle still plays.
//
// THE GAUGE ROW (option 1). Under the gauge of each hand whose gun carries a LegenDoom power, starting at the gauge
// octagon's inner edge and running outward: LegenDoom's icon, the power's name in its rarity colour (a soft glow behind),
// and, while the power's timed buff runs (LDPlayerLoop's list, LEGENDPLY.acs), a drain line under the name (the time left
// against the longest it has been since it started; an extension refills it) and, for Murderous, X3 (its 3x damage,
// LDMurderousDamageGiver DamageFactor "Normal", 3.0). A rarity tick in the rarity colour runs along the octagon's outer
// top corner. Kept inside the screen: a row that would leave it slides back in.
//
// Sizes are the mockups', in units of the gauge's own height (the mockup frame's gauge is 36 px tall: the card 150 x 104,
// the row's text 7, its icon 9), so all of it follows Gun Bonsai's HUD Size. Drawn as the series draws in VR: textures and
// quads cropped from the source (DTA_SrcY / DTA_SrcHeight), tinted white swatches and thick lines; no clip rectangle.
// Not drawn over any menu, on the automap, or with the HUD off (screenblocks > 11), like the gauges.
//
// ACCESSIBILITY (RSQ Accessibility, by name, as the gauges): a colour-blind mode draws every rarity in the series' HAVE colour
// (the rarity stays readable as the sub line's word), the title's two tones that colour and a lighter one. Photosensitive
// Mode: the title holds its first look (no shimmer flashing).
// OFF SWITCHES (user rows on the RSQ Gun Bonsai VR page): LegenDoom: Pickup Card (rsqgb_ld_card; off: LegenDoom's own
// pickup screen comes back) and LegenDoom: Gauge Row (rsqgb_ld_row; off: no row). LegenDoom's buff row at the top of the view
// stays as LegenDoom draws it either way: its HudMessages carry no id (LEGENDPLY.acs LDPlayerLoop, id 0), so nothing can take
// them off without taking every other mod's id-less messages too (an open item for the owner, README Status).
//
// Everything here is the console player's own screen: UI scope only, nothing in play but a map counter.
class RSQGB_LDHud : StaticEventHandler
{
	// play: bumps on every map start or loaded save, so the screen re-reads what is held without showing a card for it
	int mapSerial;
	override void WorldLoaded(WorldEvent e) { mapSerial++; }

	const CARD_T = 105;        // tics the card is up (3 s)
	const FOLD_T = 14;         // tics it folds
	const LOOK_T = 10;         // tics a title look holds (the GIF's 280 ms)
	const OCT_IN = 0.680;      // the gauge octagon's inner edge, as a fraction of the gauge's width (LHUDA6: x 1045 of 1536)

	ui int seenSerial;
	ui bool primed;
	ui Array<String> have;     // "Slot|Power" for each LegenDoom power the console player holds
	ui String cSlot, cPow, cGun;
	ui int cRar, cT0;
	ui bool cLive;
	ui TFLV_HUD geo;
	ui Array<String> bKey;     // the longest each running buff has been since it started
	ui Array<int> bMax;
	ui Service ldSvc;
	ui bool ldSvcFound;

	// LegenDoom's nine weapon slots (its actor names, LEGENDINF.acs) and four rarities (tables in functions: a class-level
	// static const array is not resolved on this build)
	const NSLOT = 9;
	static clearscope String Slot(int i)
	{
		static const String T[] = { "Fists", "Chainsaw", "Pistol", "Shotgun", "SuperShotgun", "Chaingun", "RocketLauncher", "PlasmaRifle", "BFG9000" };
		return T[clamp(i, 0, NSLOT - 1)];
	}
	static clearscope String Rar(int i)
	{
		static const String T[] = { "Common", "Uncommon", "Rare", "Epic" };
		return T[clamp(i, 0, 3)];
	}

	// ---- settings ----
	static ui bool Row(String n)
	{
		let cv = CVar.GetCVar(n, players[consoleplayer]);
		return !cv || cv.GetBool();
	}
	static ui bool CardOn() { return Row("rsqgb_ld_card"); }
	static ui bool RowOn() { return Row("rsqgb_ld_row"); }

	// ---- LegenDoom's data, by name ----
	// "LD<Slot>Effect_<Power>" -> "Slot|Power" ("" for anything else)
	static ui String Parse(String cn)
	{
		if (cn.Left(2) != "LD") return "";
		for (int i = 0; i < NSLOT; i++)
		{
			String pre = "LD" .. Slot(i) .. "Effect_";
			int n = pre.Length();
			if (int(cn.Length()) > n && cn.Left(n) == pre) return Slot(i) .. "|" .. cn.Mid(n);
		}
		return "";
	}
	static ui void Scan(Actor mo, out Array<String> into)
	{
		into.Clear();
		for (let i = mo.Inv; i; i = i.Inv)
		{
			String k = Parse(i.GetClassName());
			if (k != "") into.Push(k);
		}
	}
	// LegenDoom's icon for a power: LEGENDINF.acs effectIcons[] is "E_" + the first six letters, one exception
	static ui String IconName(String pow)
	{
		if (pow ~== "Whittling") return "E_WITTLI";
		String s = pow.Left(6);
		s = s.MakeUpper();
		return "E_" .. s;
	}
	// the rarity: the folder LegenDoom keeps the icon in (graphics/EffectIcons/<Rarity>/; one folder per power)
	static ui int RarityOf(String pow)
	{
		String ic = IconName(pow);
		for (int r = 3; r >= 0; r--)
			if (Wads.CheckNumForFullName("graphics/EffectIcons/" .. Rar(r) .. "/" .. ic) >= 0) return r;
		return 0;
	}
	static ui String Loc(String key)
	{
		String s = StringTable.Localize("$" .. key);
		return (s == key || s == "$" .. key) ? "" : s;
	}

	// the slot of a gun: BD22 VR's LD mode answers for its own guns (RSLDP_Service "ld_prefix" -> "LDChaingun"); LegenDoom's
	// own weapons are named LD<Slot>
	ui String SlotOf(Weapon w)
	{
		if (!w) return "";
		String cn = w.GetClassName();
		if (!ldSvcFound) { ldSvcFound = true; ldSvc = ServiceIterator.Find("RSLDP_Service").Next(); }
		String pre = ldSvc ? ldSvc.GetStringUI("ld_prefix", cn, 0, 0, null) : "";
		if (pre == "")
		{
			if (cn.Left(8) == "RSQ_Off_") cn = cn.Mid(8);
			pre = cn;
		}
		for (int i = 0; i < NSLOT; i++) if (pre ~== "LD" .. Slot(i)) return Slot(i);
		return "";
	}
	ui String PowerFor(String slot)
	{
		if (slot == "") return "";
		for (int i = 0; i < have.Size(); i++)
		{
			Array<String> p; have[i].Split(p, "|");
			if (p.Size() == 2 && p[0] == slot) return p[1];
		}
		return "";
	}
	// the gun the card names: in a hand, else carried, else LegenDoom's slot name
	ui String GunName(PlayerInfo p, String slot)
	{
		if (SlotOf(p.ReadyWeapon) == slot) return p.ReadyWeapon.GetTag();
		if (SlotOf(p.OffhandWeapon) == slot) return p.OffhandWeapon.GetTag();
		for (let i = p.mo.Inv; i; i = i.Inv)
		{
			let w = Weapon(i);
			if (w && SlotOf(w) == slot) return w.GetTag();
		}
		return Loc("LD_WEP_NAME_" .. slot);
	}

	// the timed buff a power runs (LEGENDPLY.acs LDPlayerLoop's list), and its multiplier word (only Murderous has one: x3)
	static ui String BuffOf(String pow, int k)
	{
		if (pow ~== "Determined") return k ? "" : "LDDeterminedResistanceBuff";
		if (pow ~== "Battlerage") return k ? "" : "LDBattlerageSpeedBoost";
		if (pow ~== "Killstreaker") return k ? "" : "LDKillstreakerSpeedBuff";
		if (pow ~== "Entrenched") return k ? "" : "LDEntrenchedDamageResistance";
		if (pow ~== "Intimidating") return k ? "PowerFrightener" : "LDIntimidatingDamage";
		if (pow ~== "Ghostly") return k ? "" : "LDGhostlyProtection";
		if (pow ~== "Murderous") return k ? "" : "LDMurderousDamageBuff";
		if (pow ~== "Unstoppable") return k ? "" : "LDUnstoppableResistanceBuff";
		if (pow ~== "Artifact") return k ? "" : "LDArtifactEffectCooldown";
		if (pow ~== "Augmented") return k ? "LDAugmentedDamageResistance" : "LDAugmentedDamage";
		return "";
	}
	// tics left on the power's buff (the longer of its two), 0 when none runs
	static ui int BuffTics(Actor mo, String pow)
	{
		int best = 0;
		for (int k = 0; k < 2; k++)
		{
			String n = BuffOf(pow, k);
			if (n == "") continue;
			class<Inventory> c = n;
			if (!c) continue;
			let pw = Powerup(mo.FindInventory(c));
			if (pw) best = max(best, pw.EffectTics);
		}
		return best;
	}
	ui double Drain(Actor mo, String pow)
	{
		int t = BuffTics(mo, pow);
		int i = bKey.Find(pow);
		if (t <= 0) { if (i < bKey.Size()) { bKey.Delete(i); bMax.Delete(i); } return 0; }
		if (i == bKey.Size()) { bKey.Push(pow); bMax.Push(t); i = bKey.Size() - 1; }
		if (t > bMax[i]) bMax[i] = t;
		return double(t) / max(1, bMax[i]);
	}

	// ---- colours (make_mockups.py RARS: the card colour, the title's top and bottom tones) ----
	static ui Color RarCol(int r, int part)
	{
		static const int T[] = {
			0x5AE65A, 0x288C28, 0x96FF78,    // Common: green
			0x6496FF, 0x2850C8, 0xAAD2FF,    // Uncommon: blue
			0xDC6EFF, 0x8228AA, 0xF0B4FF,    // Rare: purple
			0xFFA028, 0xF09614, 0xFFEC78     // Epic: orange
		};
		int cb = RSQGB_CB.Mode();
		if (cb)
		{
			int c = RSQGB_CB.Rgb(RSQGB_CB.CB_HAVE, cb);
			if (part == 2) c = Lighter(c);
			return Color(255, (c >> 16) & 255, (c >> 8) & 255, c & 255);
		}
		int c = T[clamp(r, 0, 3) * 3 + clamp(part, 0, 2)];
		return Color(255, (c >> 16) & 255, (c >> 8) & 255, c & 255);
	}
	static ui int Lighter(int c)
	{
		int r = (c >> 16) & 255, g = (c >> 8) & 255, b = c & 255;
		return (((r + 255) / 2) << 16) | (((g + 255) / 2) << 8) | ((b + 255) / 2);
	}

	// =================================================================================================================
	// EACH TIC (ui): what is held, a new power -> the card, LegenDoom's screen off while the card is up
	override void UiTick()
	{
		let p = players[consoleplayer];
		if (!p.mo) return;
		if (!primed || seenSerial != mapSerial)
		{
			primed = true;
			seenSerial = mapSerial;
			Scan(p.mo, have);
			cLive = false;
			return;
		}
		Array<String> now;
		Scan(p.mo, now);
		String fresh = "";
		for (int i = 0; i < now.Size(); i++) if (have.Find(now[i]) == have.Size()) fresh = now[i];
		have.Move(now);
		if (fresh != "")
		{
			Array<String> parts; fresh.Split(parts, "|");
			cSlot = parts[0]; cPow = parts[1];
			cRar = RarityOf(cPow);
			cGun = GunName(p, cSlot);
			cT0 = gametic;
			cLive = true;
		}
		if (cLive && gametic - cT0 > CARD_T + FOLD_T) cLive = false;
		if (cLive && CardOn()) HideLD();
	}

	// LegenDoom's pickup screen: EffectScreen's four HudMessages (ids 12300..12303). The engine files an ACS message under
	// 0xFF000000 | id; both forms are asked, so either way it goes.
	ui void HideLD()
	{
		if (!StatusBar) return;
		for (uint id = 12300; id <= 12303; id++)
		{
			StatusBar.DetachMessageID(id);
			StatusBar.DetachMessageID(0xFF000000 | id);
		}
	}

	// =================================================================================================================
	// DRAWING
	ui double ox, oy, kx, ky;    // the gauges' virtual screen -> real pixels
	ui double u;                 // real pixels per mockup unit (the gauge's height is 36)
	ui TextureID white;
	ui Font fBody;

	// a gauge's box in real pixels (after geo.Calibrate*). The gauge is drawn with DTA_VirtualWidth/Height and DTA_KeepRatio,
	// which the engine maps by plain scaling (its aspect handling is off for KeepRatio): x * width / fbw, y * height / fbh,
	// as Gun Bonsai's own DrawProgressBar assumes. (Screen.VirtualToRealCoords with its aspect handling on letterboxes as if
	// the canvas were 4:3: on the rig's square eye that put the row and the tick 0.70 x lower and the card 0.75 x smaller,
	// rig run LDH1 2026-11-11.)
	ui double, double, double, double Box()
	{
		ox = 0; oy = 0;
		double fw = geo.fbw, fh = geo.fbh;
		kx = Screen.GetWidth() / max(1.0, fw);
		ky = Screen.GetHeight() / max(1.0, fh);
		u = geo.hudh * ky / 36.0;
		return ox + geo.hudx * kx, oy + geo.hudy * ky, geo.hudw * kx, geo.hudh * ky;
	}

	ui void Rect(double x, double y, double w, double h, Color c, double a)
	{
		if (w <= 0 || h <= 0 || a <= 0) return;
		if (white.IsValid())
			Screen.DrawTexture(white, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_TopLeft, true,
				DTA_Color, c | 0xFF000000, DTA_Alpha, a);
	}
	ui void Frame(double x, double y, double w, double h, double t, Color c, double a)
	{
		Rect(x, y, w, t, c, a);
		Rect(x, y + h - t, w, t, c, a);
		Rect(x, y + t, t, h - 2 * t, c, a);
		Rect(x + w - t, y + t, t, h - 2 * t, c, a);
	}
	// RS Score's small font (RSSCFN2, 7 px glyphs: 1 font pixel = s units), else Doom's NewSmallFont at the same height
	ui double TextK(double s) { return fBody && fBody.GetHeight() <= 9 ? s * u : s * u * 7.0 / max(1, fBody.GetHeight()); }
	ui double TextW(String t, double s) { return fBody.StringWidth(t) * TextK(s); }
	ui void Text(String t, double x, double y, double s, Color c, double a)
	{
		double k = TextK(s);
		Screen.DrawText(fBody, Font.CR_WHITE, x, y, t, DTA_ScaleX, k, DTA_ScaleY, k, DTA_Color, c | 0xFF000000, DTA_Alpha, a);
	}

	// The SOTN word, h units tall, its top-left at x, y (make_mockups.py sotn(): RS Score's QVW glyphs scaled to h, 1 unit
	// apart, the top half in one tone and the bottom half in the other, a near-black box 1 unit round). Returns its width.
	// measure: width only, nothing drawn. Without RSQ VisualRewards (no QVW glyphs): Doom's SmallFont in the top tone.
	ui double Sotn(String word, double x, double y, double h, Color top, Color bot, double a, bool measure = false, double k = 1.0)
	{
		word = word.MakeUpper();
		bool any = TexMan.CheckForTexture("QVW065", TexMan.Type_Any).IsValid();
		if (!any)
		{
			double sk = h * u * k / max(1, SmallFont.GetHeight());
			if (!measure)
				Screen.DrawText(SmallFont, Font.CR_WHITE, x, y, word, DTA_ScaleX, sk, DTA_ScaleY, sk, DTA_Color, top | 0xFF000000, DTA_Alpha, a);
			return SmallFont.StringWidth(word) * sk / (u * k);
		}
		double px = h * u * k / 48.0;     // real pixels per glyph texel (a glyph cell is 48 texels tall)
		double cx = x;
		for (int i = 0; i < int(word.Length()); i++)
		{
			int c = word.ByteAt(i);
			if (c < 33 || c > 96) { cx += (h * 0.5 + 1) * u * k; continue; }
			TextureID t = TexMan.CheckForTexture(String.Format("QVW%03d", c), TexMan.Type_Any);
			if (!t.IsValid()) { cx += (h * 0.5 + 1) * u * k; continue; }
			Vector2 ts = TexMan.GetScaledSize(t);
			double gw = ts.x * px, gh = ts.y * px, half = ts.y * 0.5;
			if (!measure)
			{
				// the dark box: the glyph's shape, near-black, one unit round
				double b = u * k;
				for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
				{
					if (!dx && !dy) continue;
					Screen.DrawTexture(t, false, cx + dx * b, y + dy * b, DTA_DestWidthF, gw, DTA_DestHeightF, gh, DTA_TopLeft, true,
						DTA_FillColor, 0xFF08080A, DTA_Alpha, a);
				}
				// the two tones, each half cropped from the source; a second, added pass lifts the face toward the mockup's
				// brightness (its colour x 0.55..1.15)
				for (int part = 0; part < 2; part++)
				{
					Color col = part ? bot : top;
					double sy = part ? half : 0;
					double dy = y + (part ? gh * 0.5 : 0);
					Screen.DrawTexture(t, false, cx, dy, DTA_DestWidthF, gw, DTA_DestHeightF, gh * 0.5, DTA_TopLeft, true,
						DTA_SrcY, sy, DTA_SrcHeight, half, DTA_Color, col | 0xFF000000, DTA_Alpha, a);
					Screen.DrawTexture(t, false, cx, dy, DTA_DestWidthF, gw, DTA_DestHeightF, gh * 0.5, DTA_TopLeft, true,
						DTA_SrcY, sy, DTA_SrcHeight, half, DTA_Color, col | 0xFF000000, DTA_Alpha, a * 0.45,
						DTA_LegacyRenderStyle, STYLE_Add);
				}
			}
			cx += gw + u * k;
		}
		return (cx - x) / (u * k) - 1;
	}

	ui void Icon(String pow, double x, double y, double s, double a)
	{
		TextureID t = TexMan.CheckForTexture(IconName(pow), TexMan.Type_Any);
		if (!t.IsValid()) return;
		Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, s, DTA_DestHeightF, s, DTA_TopLeft, true, DTA_Alpha, a);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (menuactive != Menu.Off || automapactive || screenblocks > 11) return;
		let p = players[consoleplayer];
		if (!p.mo || !primed) return;
		bool card = CardOn(), rowOn = RowOn();
		if (!card && !rowOn) return;
		if (cLive && card) HideLD();
		let gb = TFLV_EventHandler(StaticEventHandler.Find("TFLV_EventHandler"));
		if (!geo) geo = new("TFLV_HUD");
		if (!white.IsValid()) white = TexMan.CheckForTexture("RSQWHITE", TexMan.Type_Any);
		fBody = Font.GetFont("RSSCFN2");
		if (!fBody) fBody = NewSmallFont;
		string ft, wt, pt;
		[ft, wt, pt] = TFLV_Settings.hud_skin();
		bool gauges = gb && ft != "" && gb.ShouldDrawHUD(consoleplayer);
		bool dual = TFLV_Settings.GetBool("bonsai_vr_dual_hud");

		double t = gametic - cT0 + e.FracTic;
		bool showCard = cLive && card && t < CARD_T + FOLD_T;
		double fold = showCard ? clamp((t - CARD_T) / FOLD_T, 0.0, 1.0) : 1.0;

		// ---- the rows (and where the card folds to) ----
		double tx = -1, ty = -1;
		for (int hand = 0; hand < 2; hand++)
		{
			if (!gauges) break;
			Weapon w = hand ? p.OffhandWeapon : p.ReadyWeapon;
			if (!w) continue;
			if (dual) geo.CalibrateForHand(hand);
			else
			{
				// the single HUD shows one hand's gun: the row goes under it only for that gun
				TFLV_CurrentStats cur;
				let st = gb.playerstats[consoleplayer];
				if (!st || !st.GetCurrentStatsPreferring(TFLV_Settings.GetInt("bonsai_vr_hud_hand"), cur) || !cur.winfo || cur.winfo.wpn != w) continue;
				geo.CalibrateSingle();
			}
			String slot = SlotOf(w);
			String pow = PowerFor(slot);
			if (pow == "") continue;
			double bx, by, bw, bh;
			[bx, by, bw, bh] = Box();
			bool isCard = showCard && slot == cSlot && pow == cPow;
			double a = isCard ? fold : 1.0;
			double rx, ry;
			[rx, ry] = DrawRow(p.mo, pow, bx, by, bw, bh, rowOn ? a : 0);
			if (isCard && rowOn) { tx = rx; ty = ry; }
		}

		// ---- the card ----
		if (!showCard) return;
		geo.CalibrateForHand(0);
		double bx, by, bw, bh;
		[bx, by, bw, bh] = Box();
		double cw = 150 * u, ch = 104 * u;
		double ccx = Screen.GetWidth() * 0.5, ccy = by + 66 * u + ch * 0.5;   // centred, its top 66 units below the gauges' top
		double k = 1.0, a = 1.0;
		if (fold > 0)
		{
			// fold: shrink toward the row (its left end), fading; no row to land in: fade where it is
			double f = fold * fold * (3 - 2 * fold);
			if (tx >= 0) { k = 1.0 - 0.8 * f; ccx += (tx - ccx) * f; ccy += (ty - ccy) * f; }
			a = 1.0 - f;
			if (tx >= 0 && a > 0.02)
				Screen.DrawThickLine(ccx, ccy, tx, ty, max(1.0, u), Color(255, 255, 200, 120), int(200 * a));
		}
		if (a > 0.01) DrawCard(ccx - cw * k * 0.5, ccy - ch * k * 0.5, k, a, t);
	}

	// One gauge row; returns where a folding card lands (the row's start, its middle). a 0: nothing drawn, place only.
	ui double, double DrawRow(Actor mo, String pow, double bx, double by, double bw, double bh, double a)
	{
		int rar = RarityOf(pow);
		Color col = RarCol(rar, 0);
		String nm = Loc("LD_FX_TITLE_" .. pow);
		if (nm == "") nm = pow;
		nm = nm.MakeUpper();
		bool right = (geo.mirror & HUD_MIRROR_H) != 0;      // the octagon is on the gauge's right (the main hand's)
		double inner = bx + (right ? OCT_IN : 1.0 - OCT_IN) * bw;
		double nameW = TextW(nm, 1.0);
		double dr = Drain(mo, pow);
		bool x3 = dr > 0 && pow ~== "Murderous";
		double blockW = 11 * u + nameW + (x3 ? 3 * u + TextW("X3", 1.0) : 0);
		double x0 = right ? inner : inner - blockW;
		x0 = clamp(x0, 0.0, max(0.0, Screen.GetWidth() - blockW));
		double y0 = by + 39 * u;            // 3 units under the gauge's box
		if (a <= 0) return x0, y0 + 4.5 * u;

		// the rarity tick along the octagon's outer top corner (LHUDA6 texels, the main gauge's face; mirrored like the frame)
		static const double TX[] = { 1180, 1315, 1477, 1477 };
		static const double TY[] = { 40, 40, 202, 300 };
		Array<double> lx, ly;
		for (int i = 0; i < 4; i++)
		{
			double x2 = 1536 - TX[i], y2 = 512 - TY[i];         // face 2 (no mirror)
			if (geo.mirror & HUD_MIRROR_H) x2 = 1536 - x2;
			if (geo.mirror & HUD_MIRROR_V) y2 = 512 - y2;
			lx.Push(bx + x2 / 1536 * bw); ly.Push(by + y2 / 512 * bh);
		}
		double th = max(1.0, bh * 14 / 512);
		for (int i = 0; i < 3; i++) Screen.DrawThickLine(lx[i], ly[i], lx[i + 1], ly[i + 1], th, col, int(255 * a));

		Icon(pow, x0, y0 - 1 * u, 9 * u, a);
		double nx = x0 + 11 * u;
		// a soft glow in the rarity colour behind the name
		for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
			if (dx || dy) Text(nm, nx + dx * u, y0 + dy * u, 1.0, col, 0.22 * a);
		Text(nm, nx, y0, 1.0, col, a);
		if (dr > 0)
		{
			double x1 = nx + nameW;
			Rect(x0, y0 + 10 * u, x1 - x0, 2 * u, Color(255, 60, 30, 10), a);
			Rect(x0, y0 + 10 * u, (x1 - x0) * clamp(dr, 0.0, 1.0), 2 * u, col, a);
			if (x3) Text("X3", x1 + 3 * u, y0, 1.0, Color(255, 255, 230, 120), a);
		}
		return x0, y0 + 4.5 * u;
	}

	// The V3 card, scale k, top-left x, y (make_mockups.py card2(shimmer)): 150 x 104 units.
	ui void DrawCard(double x, double y, double k, double a, double t)
	{
		double s = u * k;
		double w = 150 * s, h = 104 * s;
		Color col = RarCol(cRar, 0);
		// a soft halo in the card colour, the fill (Gun Bonsai VR skin A's #170D26), the double outline
		Frame(x - 4 * s, y - 4 * s, w + 8 * s, h + 8 * s, 2 * s, col, 0.12 * a);
		Frame(x - 2 * s, y - 2 * s, w + 4 * s, h + 4 * s, 2 * s, col, 0.25 * a);
		Rect(x, y, w, h, Color(255, 0x17, 0x0D, 0x26), 0.92 * a);
		Frame(x, y, w, h, 2 * s, col, a);
		Frame(x + 3 * s, y + 3 * s, w - 6 * s, h - 6 * s, 1 * s, Color(255, int(col.r * 0.45), int(col.g * 0.45), int(col.b * 0.45)), a);

		// the title: the SOTN word, 9 units, flashing between its two looks (Photosensitive Mode: the first look only)
		String title = Loc("LD_FX_TITLE_" .. cPow);
		if (title == "") title = cPow;
		Color top = RarCol(cRar, 1), bot = RarCol(cRar, 2);
		int look = RSQGB_Photo.On() ? 0 : (int(t) / LOOK_T) & 1;
		if (look)
		{
			top = Color(255, min(255, top.r + 70), min(255, top.g + 70), min(255, top.b + 70));
			bot = Color(255, 255, 255, 235);
		}
		double tk = 1.0;
		double tw = Sotn(title, 0, 0, 9, top, bot, 0, true);
		if (tw > 140) tk = 140 / tw;
		Sotn(title, x + (w - tw * tk * s) * 0.5, y + 6 * s, 9, top, bot, a, false, k * tk);
		// the sub line: the rarity and the gun, grey
		String sub = Loc("LD_RARITY_NAME_" .. Rar(cRar));
		if (sub == "") sub = Rar(cRar);
		sub = sub.MakeUpper() .. "  " .. cGun.MakeUpper();
		double sw = TextW(sub, k);
		Text(sub, x + (w - sw) * 0.5, y + 19 * s, k, Color(255, 0xB4, 0xB4, 0xBC), a);

		// the description: LegenDoom's, its first paragraph, wrapped; the lines beside the icon box stop short of it
		String d = Loc("LD_FX_DESCR_" .. cPow);
		int nl = d.IndexOf("\n");
		if (nl >= 0) d = d.Left(nl);
		d = RSQUI_Pen.Plain(d).MakeUpper();
		Array<String> words; d.Split(words, " ", TOK_SKIPEMPTY);
		double ly = y + 31 * s;
		String ln = "";
		int lines = 0;
		for (int i = 0; i <= words.Size() && lines < 7; i++)
		{
			double room = (ly + 7 * s > y + h - 45 * s ? 91 : 136) * s;
			String nx = i < words.Size() ? (ln == "" ? words[i] : ln .. " " .. words[i]) : "";
			if (i == words.Size() || (ln != "" && TextW(nx, k) > room))
			{
				if (ln != "") { Text(ln, x + 7 * s, ly, k, Color(255, 0xF2, 0xF2, 0xF2), a); ly += 10 * s; lines++; }
				ln = i < words.Size() ? words[i] : "";
			}
			else ln = nx;
		}

		// the icon box: dark, outlined in the card colour, LegenDoom's icon in it
		double bs = 38 * s, bxx = x + w - bs - 7 * s, byy = y + h - bs - 7 * s;
		Rect(bxx, byy, bs, bs, Color(255, 0x0C, 0x08, 0x18), a);
		Frame(bxx, byy, bs, bs, 1 * s, col, a);
		Icon(cPow, bxx + 3 * s, byy + 3 * s, 32 * s, a);
	}
}
