// What BD22 VR's hands / muzzle / reload scripts ask of BD22 VR systems this pack does not carry (melee, grenade,
// scopes, counters, fists). Same names and signatures, neutral answers, so those scripts run unedited.
// As each system is ported its stub here goes. (rsvr/melee.zs, ported for the Motorsaw's contact saw, brings
// RSVR_Token, RSVR_MeleeTwo / AxeTwo / SwordTwo and RSVR_Buzz itself.)

class RSG_RingHand : RSVR_Token {}
class IsPlayingAsPurist : RSVR_Token {}	// BD22's Purist class marker: never given here
class RFGLoaded : RSVR_Token {}			// the rifle's underbarrel: a round in the tube (rsr/rsr_m203.zs)
class FiredMGGrenade : RSVR_Token {}	// ...a spent case in it


class RSG_Handler abstract
{
	clearscope static bool WantsGrab(int n) { return false; }
}

class RSQ_Counters abstract
{
	static bool IsNonStd(Weapon w) { return false; }
	static bool NonStdOn(PlayerPawn mo) { return true; }
}

class RSQ_Fists abstract
{
	static Class<Actor> Cls(Name n) { class<Actor> c = n; return c; }
	static void PunchUse(PlayerPawn mo, Vector3 from, Vector3 dir) {}
	static void Record(Actor strike, int hand, double mps) {}	// the LegenDoom mode's strike record: not here
	static bool LineUse(PlayerPawn mo, Vector3 hand, Vector3 prevTip, Vector3 tip, double reach, String what) { return false; }
}

// The underbarrel's round going in by itself: out of VR, or with Reloading on Stock (the rifle's RSM_AltGrenade).
class RSM_StockLoad : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let ac = RSM.AmmoClass();
		if (toucher && ac && toucher.CountInv(ac) > 0 && toucher.CountInv('RFGLoaded') <= 0)
		{
			toucher.TakeInventory(ac, 1);
			toucher.TakeInventory('FiredMGGrenade', 99);
			toucher.GiveInventory('RFGLoaded', 1);
			toucher.A_StartSound("GrenadeLauncher/Load", CHAN_AUTO);
		}
		return false;
	}
}

// the underbarrel's 40 mm round in flight: an impact grenade on an arc (Doom 2's rocket art and blast)
// The underbarrel's round (owner: "rsq's own"). RSQ Grenade's grenade: its mesh (MODELDEF.rsqm203), its flight
// numbers (thrown.zs: Radius 3, Height 3, Speed 20, Gravity 0.27, the same lazy tumble), the Impact kind's rule (it
// bursts on the first thing it touches), and its blast: with RSQ Grenade loaded, RSQGN_HandBlast -- found by name,
// nothing links -- plays the grenade's own look and deals its damage (85 over 200, then 75 over 255) as the player who
// fired it. Without RSQ Grenade the same two A_Explodes, here, with Doom's explosion.
class RSQ_M203Grenade : Actor
{
	Default
	{
		Projectile;
		-NOGRAVITY
		Radius 3;
		Height 3;
		Speed 20;
		Damage 0;		// the blast does the damage, not the hit (as RSQ Grenade)
		Gravity 0.27;
		Scale 0.3;
		DamageType "Explosive";
		Obituary "%o caught %k's 40 mm grenade.";
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || !bMissile || IsFrozen())
			return;
		roll += 3.5;			// RSQ Grenade (thrown.zs): about one lazy turn per two seconds
		pitch += 3.5 * 0.43;
	}

	void Burst()
	{
		Name hn = 'RSQGN_HandBlast';	// by name, at run time: RSQ Grenade may not be loaded
		class<Actor> hb = hn;
		if (hb)
		{
			let b = Spawn(hb, pos, ALLOW_REPLACE);
			if (b)
			{
				b.target = target;		// the player who fired it gets the kill
				return;
			}
		}
		A_Explode(85, 200, XF_HURTSOURCE);
		A_Explode(75, 255, XF_HURTSOURCE);
		A_StartSound("weapons/rocklx", CHAN_AUTO);
		Spawn('RSQ_M203Fallback', pos, ALLOW_REPLACE);
	}

	States
	{
	Spawn:
		RQGL A -1;
		Stop;
	Death:
		TNT1 A 0 { bNoGravity = true; vel = (0, 0, 0); Burst(); }
		TNT1 A 1;
		Stop;
	}
}

// the look of the blast when RSQ Grenade is not loaded: Doom's own
class RSQ_M203Fallback : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		MISL B 8 Bright;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

// a pump shotgun loaded from empty: no shot until its pump has been worked (the Riotguns' RSP_ states), as BD22's ShotgunWasEmpty
class RSQ_ShotgunWasEmpty : RSVR_Token {}

// THE HUD (owner: "the GBOVR hud for health, armor, and ammo displays for mainhand and offhand"): RSQ GunBonsaiOffhandVR's
// bottom row, 1:1 (GunBonsaiOffhandVR rsq/ui/skin_a_hud.zs RSQUI_A_Skin.DrawBottom, its frame from rsq/ui/draw.zs HudFrame
// and its reads from rsq/ui/data.zs): one ammo counter per hand on that hand's side (reserve dim gold, the magazine in
// the hand's colour, the ammo's icon under the reserve), and in the middle health | face | armour, in the game's HUD
// font. Its numbers are GBOVR's (units of the safe area's height / 540, x 1.5, inset 4 %). With GBOVR loaded this stands
// down: GBOVR draws the same row itself. HUD Ammo (rsq_hud_ammo): 0 magazine + reserve, 1 reserve only, 2 the row off.
// Remove HUD Health and Armor (rsq_hud_nohp, BD22 VR Reloaded's name, which GBOVR reads too): the face stays.
class RSQ_AmmoHud : EventHandler
{
	ui double u, ox, oy, sw, sh;

	ui static bool Other()	// GBOVR (its HUD dispatcher) is loaded: it draws this row
	{
		String n = "RSQUI_Handler";
		class<StaticEventHandler> c = n;
		return c != null;
	}
	ui void HudFrame()	// GBOVR draw.zs HudFrame / SafeArea
	{
		double w = Screen.GetWidth(), h = Screen.GetHeight();
		double f = 0.04;
		double sx = w * f, sy = h * f;
		sw = w * (1 - 2 * f); sh = h * (1 - 2 * f);
		u = min(sh / 540.0, sw / 660.0) * 1.5;
		ox = sx; oy = sy;
	}
	ui double X(double x) { return ox + x * u; }
	ui double Y(double y) { return oy + y * u; }
	ui void Picture(TextureID tex, double x, double y, double w, double h)	// GBOVR draw.zs Picture
	{
		if (!tex.IsValid()) return;
		Vector2 sz = TexMan.GetScaledSize(tex);
		if (sz.x <= 0 || sz.y <= 0) return;
		double k = min(w / sz.x, h / sz.y);
		double dw = sz.x * k, dh = sz.y * k;
		Screen.DrawTexture(tex, false, X(x + (w - dw) / 2), Y(y + (h - dh) / 2), DTA_DestWidthF, dw * u, DTA_DestHeightF, dh * u, DTA_TopLeft, true);
	}
	ui double Digits(Font f, double h, String s, double x, double y, int cr, int align, double alpha = 1.0)	// GBOVR skin_a_hud.zs Digits
	{
		double k = h / max(1, f.GetHeight()) * u;
		double w = f.StringWidth(s) * k / u;
		if (align == 2) x -= w; else if (align == 1) x -= w / 2;
		Screen.DrawText(f, cr, X(x), Y(y), s, DTA_ScaleX, k, DTA_ScaleY, k, DTA_Alpha, alpha);
		return w;
	}
	// GBOVR data.zs ReadAmmo: with two pools the smaller one (by MaxAmount) is the magazine
	ui static int, int, TextureID ReadAmmo(Weapon wpn)
	{
		int mag = -1, reserve = -1;
		TextureID icon;
		icon.SetInvalid();
		if (!wpn) return mag, reserve, icon;
		Inventory a1 = wpn.Ammo1, a2 = wpn.Ammo2;
		if (a1 && a2 && a1 != a2)
		{
			Inventory m = a1.MaxAmount <= a2.MaxAmount ? a1 : a2;
			Inventory r = m == a1 ? a2 : a1;
			mag = m.Amount; reserve = r.Amount;
			icon = r.Icon.IsValid() ? r.Icon : m.Icon;
		}
		else if (a1) { reserve = a1.Amount; icon = a1.Icon; }
		else if (a2) { reserve = a2.Amount; icon = a2.Icon; }
		return mag, reserve, icon;
	}
	// GBOVR data.zs OnLeft: a right-hander's off hand on the left (QuestZDoom's Control Scheme 10+ is left-handed)
	ui static bool OnLeft(int which)
	{
		let lc = CVar.FindCVar('vr_control_scheme');
		bool lefty = lc && lc.GetInt() >= 10;
		return (which == 1) != lefty;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (automapactive || consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer])
			return;
		let p = players[consoleplayer];
		if (!p.mo || Other())
			return;
		let cv = CVar.GetCVar('rsq_hud_ammo', p);
		int mode = cv ? cv.GetInt() : 0;
		if (mode == 2)
			return;
		HudFrame();
		double W = sw / u, H = sh / u;
		Font big = Font.GetFont("HUDFONT_DOOM");
		if (!big) big = BigFont;
		for (int s = 0; s <= 1; s++)
		{
			Weapon wpn = s == 0 ? p.ReadyWeapon : p.OffhandWeapon;
			int mag, reserve;
			TextureID icon;
			[mag, reserve, icon] = ReadAmmo(wpn);
			if (!wpn || reserve < 0) continue;
			if (mode == 1) mag = -1;
			int mc = s == 1 ? Font.CR_GOLD : Font.CR_ORANGE;
			if (OnLeft(s))
			{
				double x = 39;
				double rw = Digits(big, 16, String.Format("%d", reserve), x, H - 78, Font.CR_GOLD, 0, 0.75);
				if (mag >= 0) Digits(big, 16, String.Format("%d", mag), x + rw + 6, H - 78, mc, 0);
				Picture(icon, x + rw / 2 - 13, H - 52, 26, 32);
			}
			else
			{
				double xr = W - 39;
				double rw = Digits(big, 16, String.Format("%d", reserve), xr, H - 78, Font.CR_GOLD, 2, 0.75);
				if (mag >= 0) Digits(big, 16, String.Format("%d", mag), xr - rw - 6, H - 78, mc, 2);
				Picture(icon, xr - rw / 2 - 13, H - 52, 26, 32);
			}
		}
		// centre: health | face | armour
		double cx = W / 2;
		TextureID face = StatusBar ? StatusBar.GetMugshot(5) : TexMan.CheckForTexture("STFST01", TexMan.Type_Any);
		Picture(face, cx - 17, H - 36, 34, 32);
		let nohp = CVar.GetCVar('rsq_hud_nohp', p);
		if (nohp && nohp.GetBool()) return;
		double hw = Digits(big, 24, String.Format("%d", p.mo.health), cx - 26, H - 33, Font.CR_UNTRANSLATED, 2);
		Picture(TexMan.CheckForTexture("MEDIA0", TexMan.Type_Any), cx - 26 - hw - 38, H - 34, 32, 29);
		let ba = BasicArmor(p.mo.FindInventory("BasicArmor"));
		if (ba && ba.Amount > 0)
		{
			TextureID arm = ba.Icon.IsValid() ? ba.Icon : TexMan.CheckForTexture("ARM1A0", TexMan.Type_Any);
			Picture(arm, cx + 26, H - 34, 34, 29);
			Digits(big, 24, String.Format("%d", ba.Amount), cx + 66, H - 33, Font.CR_UNTRANSLATED, 0);
		}
	}
}

// BD22's own tokens BD22 VR's dual script sets or reads; nothing else here does
class NoAutoReload : RSVR_Token {}
class StartDualWield : RSVR_Token {}
