// What BD22 VR's hands / muzzle / reload scripts ask of BD22 VR systems this pack does not carry (melee, grenade,
// scopes, counters, fists). Same names and signatures, neutral answers, so those scripts run unedited.
// As each system is ported its stub here goes.

class RSVR_Token : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}
}
class RSVR_MeleeTwo : RSVR_Token {}
class RSVR_AxeTwo : RSVR_Token {}
class RSVR_SwordTwo : RSVR_Token {}
class RSG_RingHand : RSVR_Token {}
class IsPlayingAsPurist : RSVR_Token {}	// BD22's Purist class marker: never given here
class RFGLoaded : RSVR_Token {}			// the rifle's underbarrel: a round in the tube (rsr/rsr_m203.zs)
class FiredMGGrenade : RSVR_Token {}	// ...a spent case in it

// a projectile the engine counts as a shot: spawning it buzzes the hand (rsvr/melee.zs in BD22 VR)
class RSVR_Buzz : Actor
{
	Default
	{
		Projectile;
		+NOCLIP
		Radius 1;
		Height 1;
		Speed 1;
		DamageType "RSVRHaptic";
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}

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

// HUD Ammo (rsq_hud_ammo): each hand's magazine and reserve, laid out as RSQ GunBonsaiOffhandVR's hand readouts are
// (reserve dim gold, magazine beside it, the ammo's icon under them; the main hand's on its own side, the off hand's on
// the other). With GunBonsaiOffhandVR loaded this stands down: its HUD already draws both hands.
// Which counter is the magazine: with two pools, the smaller one by MaxAmount (GBOVR's rule: rsq/ui/data.zs).
class RSQ_AmmoHud : EventHandler
{
	ui static bool Other()
	{
		String n = "TFLV_EventHandler";
		class<StaticEventHandler> c = n;
		return c != null;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (automapactive || consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer])
			return;
		let p = players[consoleplayer];
		if (!p.mo || p.health <= 0 || Other())
			return;
		let cv = CVar.GetCVar('rsq_hud_ammo', p);
		int mode = cv ? cv.GetInt() : 0;
		if (mode == 2)
			return;
		let lc = CVar.FindCVar('vr_control_scheme');
		bool lefty = lc && lc.GetInt() >= 10;
		Font f = Font.GetFont("HUDFONT_DOOM");
		if (!f)
			f = BigFont;
		for (int s = 0; s <= 1; s++)
		{
			Weapon w = s == 0 ? p.ReadyWeapon : p.OffhandWeapon;
			if (!w)
				continue;
			Inventory a1 = w.Ammo1, a2 = w.Ammo2;
			int mag = -1, res = -1;
			TextureID icon;
			if (a1 && a2 && a1 != a2)
			{
				Inventory m = a1.MaxAmount <= a2.MaxAmount ? a1 : a2;
				Inventory r = m == a1 ? a2 : a1;
				mag = m.Amount;
				res = r.Amount;
				icon = r.Icon.IsValid() ? r.Icon : m.Icon;
			}
			else if (a1)
			{
				res = a1.Amount;
				icon = a1.Icon;
			}
			else if (a2)
			{
				res = a2.Amount;
				icon = a2.Icon;
			}
			if (res < 0)
				continue;
			bool left = (s == 1) != lefty;		// the main hand's readout on the main hand's side
			String rs = String.Format("%d", res);
			String ms = mode == 0 && mag >= 0 ? String.Format("%d", mag) : "";
			int rw = f.StringWidth(rs), mw = f.StringWidth(ms);
			int y = 344;
			int x = left ? 24 : 616 - rw - (ms != "" ? mw + 8 : 0);
			if (left)
			{
				Screen.DrawText(f, Font.CR_GOLD, x, y, rs, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true, DTA_Alpha, 0.75);
				if (ms != "")
					Screen.DrawText(f, s == 1 ? Font.CR_GOLD : Font.CR_ORANGE, x + rw + 8, y, ms, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
			}
			else
			{
				if (ms != "")
					Screen.DrawText(f, s == 1 ? Font.CR_GOLD : Font.CR_ORANGE, x, y, ms, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
				Screen.DrawText(f, Font.CR_GOLD, x + (ms != "" ? mw + 8 : 0), y, rs, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true, DTA_Alpha, 0.75);
			}
			if (icon.IsValid())
				Screen.DrawTexture(icon, true, left ? 40 : 600, 392, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true, DTA_CenterBottomOffset, true);
		}
	}
}

// BD22's own tokens BD22 VR's dual script sets or reads; nothing else here does
class NoAutoReload : RSVR_Token {}
class StartDualWield : RSVR_Token {}
